#include "resizer.h"

#include <QImageReader>
#include <QImageWriter>
#include <QPainter>

#include <QJsonObject>
#include <QJsonArray>

#include <QtConcurrent>

#include <QUrl>

#include <zip/qzipwriter.h>

#include <qexifimageheader/qexifimageheader.h>

Resizer::Resizer(QObject *parent) : QObject(parent)
{
    m_saverWatcher = new QFutureWatcher<bool>(this);
    connect(m_saverWatcher, &QFutureWatcher<bool>::finished, this, &Resizer::onFinished );
    connect(m_saverWatcher, &QFutureWatcher<bool>::progressRangeChanged, this, &Resizer::progressRangeChanged );
    connect(m_saverWatcher, &QFutureWatcher<bool>::progressValueChanged, this, &Resizer::progressValueChanged );
}

Options Resizer::fromJsonOption(const QJsonObject &json)
{
    Options options;

    if(json.value("mode").toString() == "temp")  options.mode = OutputMode::TEMP;
    else if(json.value("mode").toString() == "zip")  options.mode = OutputMode::ZIP;
    else if(json.value("mode").toString() == "logo")  options.mode = OutputMode::LOGO;
    else options.mode = OutputMode::NORMAL;

    QJsonObject size = json.value("size").toObject();

    options.size.useSize = size.value("mode").toString() == "size";
    options.size.maxSize = size.value("size").toVariant().toInt();
    options.size.ratio = size.value("ratio").toVariant().toInt();

    QJsonObject logo = json.value("logo").toObject();
    options.logo.enabled = logo.value("enabled").toBool();

    options.logo.position = (Position)logo.value("position").toInt();
    options.logo.horizontalShift = logo.value("horizontal").toInt();
    options.logo.verticalShift = logo.value("vertical").toInt();
    options.logo.rotation = logo.value("rotation").toInt();
    options.logo.opacity = logo.value("opacity").toInt();

    if(options.logo.enabled){
        QUrl url(logo.value("url").toString());
        QFileInfo fi(url.toLocalFile());

        if(!fi.exists()){
            options.logo.enabled = false;
        }else{
            QImageReader reader(fi.absoluteFilePath());
            if(!QImageReader::supportedImageFormats().contains(reader.format())){
                options.logo.enabled = false;
            }else{
                options.logo.image = QImage(fi.absoluteFilePath());
                if(options.logo.rotation != 0){
                    QTransform t;
                    t.rotate(options.logo.rotation);
                    options.logo.image = options.logo.image.transformed( t );
                }
            }
        }
    }

    QJsonObject general = json.value("general").toObject();

    options.outputFolder = general.value("outputFolder").toString();
    options.closeAfterResize = general.value("closeAfterResize").toBool();
    options.keepExif = general.value("keepExif").toBool();
    options.openAfterResize = general.value("openAfterResize").toBool();

    return options;
}

void Resizer::onFinished()
{
    qDebug() << m_outputFolders;
    if(m_openOutputFolderOnFinished){
        emit openOutputFolder( m_outputFolders, m_closeOnFinished );
    }else{
        if(m_closeOnFinished){
            qApp->quit();
        }
    }
}

void Resizer::resize(const QJsonArray &list, const QJsonObject &jsonOptions)
{
    if(list.isEmpty()){
        emit finished();
        return;
    }

    Options options = fromJsonOption(jsonOptions);

    m_closeOnFinished = options.closeAfterResize;
    m_openOutputFolderOnFinished = options.openAfterResize;

    QList<SaveInfo> images;

    m_outputFolders.clear();

    bool tempFolder = options.mode == OutputMode::TEMP || options.mode == OutputMode::ZIP;

    if(tempFolder){
        options.outputFolder = QDir::tempPath() + QDir::separator() + "resizer_" + QString("%1").arg(qrand()%99999,5,10,QChar('0') );
        qDebug() << options.outputFolder;
        m_outputFolders << options.outputFolder;
    }

    for(int i=0; i<list.size(); i++){
        SaveInfo info;
        info.options = options;
        info.rotation = list.at(i).toObject().value("imgRotation").toInt();
        info.filepath = list.at(i).toObject().value("path").toString();
        images << info;

        if(!tempFolder){
            QFileInfo fi(info.filepath);
            m_outputFolders << fi.absolutePath() + QDir::separator() + options.outputFolder;
        }
    }

    m_outputFolders.removeDuplicates();

    m_saverWatcher->setFuture(QtConcurrent::mapped(images, save));
}

bool Resizer::save( const SaveInfo &info )
{
    qDebug() << "Resizing: " << info.filepath;

    QFileInfo fi(info.filepath);

    QString outputFolder;

    if(info.options.mode == OutputMode::TEMP || info.options.mode == OutputMode::ZIP){
        outputFolder = info.options.outputFolder;
    }else{
        outputFolder = fi.absolutePath() + QDir::separator() + info.options.outputFolder;
    }

    QString outputFilepath = outputFolder + QDir::separator() + fi.fileName();

    QDir dir(outputFolder);
    if(!dir.exists()){
        dir.mkdir(outputFolder);
        if(!dir.exists()){
            qCritical() << outputFolder + " doesn't exist";
            return false;
        }
    }

    QImage small;
    QImageReader reader(fi.absoluteFilePath());
    QSize imageSize = reader.size();

    if(info.options.mode == OutputMode::LOGO ){
        small.load(fi.absoluteFilePath());
    }else{
        if(imageSize.isValid()){
            if(info.options.size.useSize){
                int maxSize = info.options.size.maxSize;
                imageSize.scale(maxSize,maxSize,Qt::KeepAspectRatio);
            }else{
                imageSize *= info.options.size.ratio;
            }
            reader.setScaledSize(imageSize);
            small = reader.read();
        }else{
            QImage original(fi.absoluteFilePath());
            imageSize = original.size();
            if(info.options.size.useSize){
                int maxSize = info.options.size.maxSize;
                imageSize.scale(maxSize,maxSize,Qt::KeepAspectRatio);
            }else{
                imageSize *= info.options.size.ratio;
            }
            small = original.scaled(imageSize,Qt::KeepAspectRatio);
        }
    }

    if( info.rotation != 0 ){
        QTransform transform;
        switch(info.rotation){
        case 1: transform.rotate(90); break;
        case 2: transform.rotate(180); break;
        case 3: transform.rotate(270); break;
        default: transform.reset();
        }
        small = small.transformed(transform);
    }

    if(info.options.logo.enabled){
        QSize logoSize = info.options.logo.image.size();

        QPoint shift;

        switch(info.options.logo.position){
        case Position::TopLeft:
            break;
        case Position::TopRight:
            shift.setX( small.width() - logoSize.width() - info.options.logo.horizontalShift );
            break;
        case Position::BottomLeft:
            shift.setY( small.height() - logoSize.height() - info.options.logo.verticalShift );
            break;
        case Position::BottomRight:
            shift.setX( small.width() - logoSize.width() - info.options.logo.horizontalShift );
            shift.setY( small.height() - logoSize.height() - info.options.logo.verticalShift );
            break;
        case Position::Centre:
            shift.setX( small.width()/2.0 - logoSize.width()/2.0 + info.options.logo.horizontalShift );
            shift.setY( small.height()/2.0 - logoSize.height()/2.0 + info.options.logo.verticalShift );
            break;
        default: break;
        }

        QPainter painter(&small);
        painter.setOpacity(0.01 * info.options.logo.opacity);
        painter.drawImage(shift,info.options.logo.image);
        painter.end();
    }

    small.save(outputFilepath);

    if(info.options.keepExif){
        QExifImageHeader exif;
        if(exif.loadFromJpeg(fi.absoluteFilePath())){
#if 0
            QList<QExifImageHeader::ImageTag> list1 = exif.imageTags();
            QList<QExifImageHeader::ExifExtendedTag> list2 = exif.extendedTags();
            QList<QExifImageHeader::GpsTag> list3 = exif.gpsTags();

            for(int i=0;i<list1.size();i++){
                qDebug() << exif.value(list1[i]).toString();
            }
            for(int i=0;i<list2.size();i++){
                qDebug() << exif.value(list2[i]).toString();
            }
            for(int i=0;i<list3.size();i++){
                qDebug() << exif.value(list3[i]).toString();
            }
#endif

            exif.setValue(QExifImageHeader::Orientation, (quint8)1);
            exif.setValue(QExifImageHeader::ImageWidth,small.width());
            exif.setValue(QExifImageHeader::ImageLength,small.height());
            exif.setValue(QExifImageHeader::PixelXDimension,small.width());
            exif.setValue(QExifImageHeader::PixelYDimension,small.height());
            exif.setThumbnail(QImage());

            exif.saveToJpeg(outputFilepath);
        }else{
            qDebug() << "Failed to load Exif";
        }
    }

    qDebug() << "Saved: " << outputFilepath;
    return true;
}

