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

#include "zip/qzipwriter.h"

enum class Position{ TopLeft = 0, TopRight, Centre, BottomLeft, BottomRight };

struct LogoOptions{
    bool enabled;
    QImage image;
    QUrl imageUrl;
    Position position;
    int horizontalShift;
    int verticalShift;
    int rotation;
    int opacity;

    static LogoOptions fromJson( const QJsonObject &in ){
        LogoOptions out;
        out.enabled         = in.value("enabled").toBool(false);
        out.imageUrl        = QUrl(in.value("url").toString());
        out.position        = static_cast<Position>(in.value("position").toInt(0));
        out.horizontalShift = in.value("horizontalShift").toInt(0);
        out.verticalShift   = in.value("verticalShift").toInt(0);
        out.rotation        = in.value("rotation").toInt(0);
        out.opacity         = in.value("opacity").toInt(1);
        return out;
    }
    QJsonObject toJson() const{
        QJsonObject out;
        out.insert( "enabled", enabled );
        out.insert( "url", imageUrl.toString() );
        out.insert( "position", static_cast<int>(position) );
        out.insert( "horizontalShift", horizontalShift );
        out.insert( "verticalShift", verticalShift );
        out.insert( "rotation", rotation );
        out.insert( "opacity", opacity );
        out.insert( "image", QString("QSize(%1,%2)").arg(image.size().width()).arg(image.size().height()) );
        return out;
    }
};

struct SizeOptions{
    bool useSize;
    int maxSize;
    int ratio;

    static SizeOptions fromJson( const QJsonObject &in ){
        SizeOptions out;
        out.useSize = in.value("mode").toString() == "size"; //.toBool(false);
        out.maxSize = in.value("maxSize").toInt(1024);
        out.ratio   = in.value("ratio").toInt(33);
        return out;
    }
    QJsonObject toJson() const{
        QJsonObject out;
        out.insert( "useSize", useSize );
        out.insert( "maxSize", maxSize );
        out.insert( "ratio", ratio );
        return out;
    }
};

struct GeneralOptions
{
    Resizer::Mode mode;
    QString outputFolder;
    bool noResize;
    bool closeAfterResize;
    bool keepExif;
    bool openAfterResize;

    static GeneralOptions fromJson( const QJsonObject &in ){
        GeneralOptions out;
        out.mode            = static_cast<Resizer::Mode>(in.value("mode").toInt(0));
        out.outputFolder    = in.value("outputFolder").toString();
        out.noResize        = in.value("noResize").toBool(false);
        out.closeAfterResize= in.value("closeAfterResize").toBool(true);
        out.keepExif        = in.value("keepExif").toBool(true);
        out.openAfterResize = in.value("openAfterResize").toBool(false);
        return out;
    }
    QJsonObject toJson() const{
        QJsonObject out;
        out.insert( "mode", static_cast<int>(mode) );
        out.insert( "outputFolder", outputFolder );
        out.insert( "noResize", noResize );
        out.insert( "closeAfterResize", closeAfterResize );
        out.insert( "keepExif", keepExif );
        out.insert( "openAfterResize", openAfterResize );
        return out;
    }
};

struct Options{
    SizeOptions size;
    LogoOptions logo;
    GeneralOptions general;

    static Options fromJson( const QJsonObject &in ){
        Options out;
        out.size    = SizeOptions::fromJson( in.value("size").toObject() );
        out.logo    = LogoOptions::fromJson( in.value("logo").toObject() );
        out.general = GeneralOptions::fromJson( in.value("general").toObject() );
        return out;
    }
    QJsonObject toJson() const{
        QJsonObject out;
        out.insert( "size", size.toJson() );
        out.insert( "logo", logo.toJson() );
        out.insert( "general", general.toJson() );
        return out;
    }
};

struct SaveInfo{
    QString input;
    QString output;
    int rotation;
    Options options;
};

QDebug operator<<(QDebug debug, const Options &in)
{
    QDebugStateSaver saver(debug);
    debug.nospace() << in.toJson();
    return debug;
}

Resizer::Resizer(QObject *parent) : QObject(parent), m_progress(-1)
{
    m_saverWatcher = new QFutureWatcher<bool>(this);
    connect(m_saverWatcher, &QFutureWatcher<bool>::finished, this, &Resizer::onFinished );
    connect(m_saverWatcher, &QFutureWatcher<bool>::progressRangeChanged, this, &Resizer::onProgressRangeChanged );
    connect(m_saverWatcher, &QFutureWatcher<bool>::progressValueChanged, this, &Resizer::onProgressValueChanged );
}

int Resizer::progress() const
{
    return m_progress;
}

void Resizer::onFinished()
{
    setProgress(-1);

    if( m_mode == Mode::ZipMode ){

    }

    qDebug() << m_outputFolders;
    if(m_openOutputFolderOnFinished){
        emit openOutputFolder( m_outputFolders, m_closeOnFinished );
    }else{
        if(m_closeOnFinished){
            qApp->quit();
        }
    }
}

void Resizer::onProgressRangeChanged(int minimum, int maximum)
{

}

void Resizer::onProgressValueChanged(int progressValue)
{
    if( m_saverWatcher->progressMinimum() == m_saverWatcher->progressMaximum())
        setProgress( -1 );
    else
        setProgress( 1.0 * ( progressValue - m_saverWatcher->progressMinimum()) / (m_saverWatcher->progressMaximum() - m_saverWatcher->progressMinimum()) );
}

void Resizer::resize(const QJsonArray &list, const QJsonObject &jsonOptions)
{
    if(list.isEmpty()){
        emit finished();
        return;
    }

    Options options = Options::fromJson(jsonOptions);

    qDebug() << options;

    m_closeOnFinished = options.general.closeAfterResize;
    m_openOutputFolderOnFinished = options.general.openAfterResize;

    QList<SaveInfo> images;

    m_outputFolders.clear();

    m_mode = options.general.mode;

    if( m_mode == Resizer::Mode::LogoMode ){
        options.logo.enabled = true;
    }

    if( options.logo.enabled ){
        if( !options.logo.image.load( options.logo.imageUrl.toLocalFile() ) ){
            qCritical() << "Failed to load " << options.logo.imageUrl;
        }
    }

    QString temp = QDir::tempPath() + QDir::separator() + "resizer_" + QString("%1").arg(qrand()%99999,5,10,QChar('0') );

    if( m_mode != Resizer::Mode::NormalMode ){
        options.general.outputFolder = temp;
        m_outputFolders << options.general.outputFolder;
    }

    for(int i=0; i<list.size(); i++){

        QString inputPath = list.at(i).toObject().value("path").toString();
        QString outputPath;

        QFileInfo fi(inputPath);

        switch( m_mode ){
        case Mode::NormalMode:
            outputPath = fi.absoluteDir().path() + QDir::separator() + options.general.outputFolder + QDir::separator() + fi.fileName();
            break;
        case Mode::LogoMode:
            outputPath = fi.absoluteDir().path() + QDir::separator() + "logo" + QDir::separator() + fi.fileName();
            break;
        case Mode::TempMode:
        case Mode::ZipMode:
            outputPath = temp + QDir::separator() + fi.fileName();
            break;
        }

        SaveInfo info;
        info.options = options;
        info.rotation = list.at(i).toObject().value("imgRotation").toInt();
        info.input = inputPath;
        info.output = outputPath;
        images << info;

        m_outputFolders << fi.absolutePath() + QDir::separator() + options.general.outputFolder;
    }

    m_outputFolders.removeDuplicates();

    m_saverWatcher->setFuture(QtConcurrent::mapped(images, save));
}

void Resizer::setProgress(int progress)
{
    if (m_progress == progress)
        return;

    m_progress = progress;
    emit progressChanged(m_progress);
}

bool Resizer::save( const SaveInfo &info )
{
    qDebug() << "Resizing: " << info.input;

    QFileInfo fi(info.output);
    QDir dir = fi.absoluteDir();
    if(!dir.exists()){
        dir.mkdir(dir.path());
        if(!dir.exists()){
            qCritical() << dir.path() + " doesn't exist";
            return false;
        }
    }

    QImage small;

    if(info.options.general.mode == Resizer::Mode::LogoMode ){
        small.load(info.input);
    }else{
        QImageReader reader(info.input);
        QSize imageSize = reader.size();
        if(imageSize.isValid()){
            if(info.options.size.useSize){
                int maxSize = info.options.size.maxSize;
                imageSize.scale(maxSize,maxSize,Qt::KeepAspectRatio);
            }else{
                imageSize *= info.options.size.ratio * 0.01;
            }
            reader.setScaledSize(imageSize);
            small = reader.read();
        }else{
            QImage original(info.input);
            imageSize = original.size();
            if(info.options.size.useSize){
                int maxSize = info.options.size.maxSize;
                imageSize.scale(maxSize,maxSize,Qt::KeepAspectRatio);
            }else{
                imageSize *= info.options.size.ratio * 0.01;
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

    small.save(info.output);

    if(info.options.general.keepExif){
        QExifImageHeader exif;
        if(exif.loadFromJpeg(info.input)){
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

            exif.saveToJpeg(info.output);
        }else{
            qDebug() << "Failed to load Exif";
        }
    }

    qDebug() << "Saved: " << info.output;
    return true;
}

