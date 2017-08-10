#include "resizer.h"

#include <QImageReader>
#include <QImageWriter>

#include <QJsonObject>
#include <QJsonArray>

#include <QtConcurrent>

#include <QDesktopServices>
#include <QUrl>

#include <qexifimageheader/qexifimageheader.h>

Resizer::Resizer(QObject *parent) : QObject(parent)
{
    m_saverWatcher = new QFutureWatcher<bool>(this);
    connect(m_saverWatcher, &QFutureWatcher<bool>::finished, this, &Resizer::onFinished );
    connect(m_saverWatcher, &QFutureWatcher<bool>::progressValueChanged, this, &Resizer::onProgressChanged );
}

Options Resizer::fromJsonOption(const QJsonObject &json)
{
    Options options;

    QJsonObject size = json.value("size").toObject();

    options.size.useSize = size.value("mode").toString() == "size";
    options.size.maxSize = size.value("size").toVariant().toInt();
    options.size.ratio = size.value("ratio").toVariant().toInt();

    QJsonObject other = json.value("other").toObject();

    options.outputFolder = "/tmp/" + other.value("outputFolder").toString();
    options.closeAfterResize = other.value("closeAfterResize").toBool();
    options.keepExif = other.value("keepExif").toBool();
    options.openAfterResize = other.value("openAfterResize").toBool();

    QDir dir(options.outputFolder);
    if(!dir.exists()){
        dir.mkdir(options.outputFolder);
    }

    return options;
}

void Resizer::onFinished()
{
    if(m_openOutputFolderOnFinished){
        QDesktopServices::openUrl( QUrl::fromLocalFile(m_outputFolder) );
    }
    if(m_closeOnFinished){
        qApp->quit();
    }
}

void Resizer::resize(const QJsonArray &list, const QJsonObject &jsonOptions)
{
    qDebug() << list;

    if(list.isEmpty()){
        emit finished();
        return;
    }

    Options options = fromJsonOption(jsonOptions);

    m_closeOnFinished = options.closeAfterResize;
    m_openOutputFolderOnFinished = options.openAfterResize;

    QList<SaveInfo> images;

    for(int i=0; i<list.size(); i++){
        SaveInfo info;
        info.options = options;
        info.rotation = list.at(i).toObject().value("imgRotation").toInt();
        info.filepath = list.at(i).toObject().value("path").toString();
        images << info;
    }

    m_saverWatcher->setFuture(QtConcurrent::mapped(images, save));
}

bool Resizer::save( const SaveInfo &info )
{
    qDebug() << "Resizing: " << info.filepath;

    QFileInfo fi(info.filepath);
    QString output = info.options.outputFolder + QDir::separator() + fi.fileName();

    QDir dir(fi.absoluteDir());
    if(!dir.exists()){
        qDebug() << fi.absoluteDir().absolutePath() + " doesn't exist";
        return false;
    }

    QImage small;
    QImageReader reader(fi.absoluteFilePath());
    QSize imageSize = reader.size();

    if(info.options.noResize){
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

    /*QPoint shift;
    if(info.addLogo && !info.logo.isNull()){
        switch(info.logoPosition){
        case PositionSelector::TOP_LEFT:
            break;
        case PositionSelector::TOP_RIGHT:
            shift.setX( small.width() - info.logo.width() - info.logoShifting.x() );
            break;
        case PositionSelector::BOTTOM_LEFT:
            shift.setY( small.height() - info.logo.height() - info.logoShifting.y() );
            break;
        case PositionSelector::BOTTOM_RIGHT:
            shift.setX( small.width() - info.logo.width() - info.logoShifting.x() );
            shift.setY( small.height() - info.logo.height() - info.logoShifting.y() );
            break;
        case PositionSelector::CENTER:
            shift.setX( small.width()/2.0 - info.logo.width()/2.0 + info.logoShifting.x() );
            shift.setY( small.height()/2.0 - info.logo.height()/2.0 + info.logoShifting.y() );
            break;
        default: break;
        }

        QPainter painter(&small);
        painter.drawImage(shift,info.logo);
        painter.end();
    }*/

    small.save(output);

    if(info.options.keepExif){
        QExifImageHeader exif(fi.absoluteFilePath());
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

        //exif.setValue(QExifImageHeader::Orientation,0);
        exif.setValue(QExifImageHeader::ImageWidth,small.width());
        exif.setValue(QExifImageHeader::ImageLength,small.height());
        exif.setValue(QExifImageHeader::PixelXDimension,small.width());
        exif.setValue(QExifImageHeader::PixelYDimension,small.height());
        exif.setThumbnail(QImage());

        //exif.saveToJpeg(output);
    }

    //qDebug() << "Save: " << output;
    return true;
}

void Resizer::onProgressChanged(int)
{

}
