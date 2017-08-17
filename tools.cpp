#include "tools.h"

#include <QDir>
#include <QFileInfo>
#include <QTimer>
#include <QEventLoop>
#include <QImageReader>
#include <QImageWriter>

#include <qexifimageheader/qexifimageheader.h>

#include <QDebug>

Tools::Tools(QObject *parent) : QObject(parent)
{

}

void Tools::openFolder(const QUrl &url, bool autoDetectRotation)
{
    QEventLoop loop;
    QTimer::singleShot(50, &loop, &QEventLoop::quit );
    loop.exec();

    QString path = url.toLocalFile();
    qDebug() << "Add folder: " << path;

    QList<QUrl> absoluteFilepaths;

    QFileInfo fi(path);

    if(!fi.exists())
        return;

    if(fi.isDir()){
        QDir dir(fi.absoluteFilePath());

        dir.setFilter(QDir::Files);
        QStringList filenames = dir.entryList();

        foreach( const QString &filename, filenames)
            absoluteFilepaths << QUrl::fromLocalFile(dir.absoluteFilePath(filename));
    }else{
        absoluteFilepaths << QUrl::fromLocalFile(fi.absoluteFilePath());
    }

    openFiles( absoluteFilepaths, autoDetectRotation );
}

void Tools::openFiles(const QList<QUrl> &urls, bool autoDetectRotation)
{
    qDebug() << "Add files: " << urls;

    foreach(QUrl url, urls){
        const QString filepath = url.toLocalFile();

        QFileInfo fi(filepath);

        if( !fi.exists() ){
            continue;
        }

        if( fi.isDir() ){
            openFolder( url );
            continue;
        }

        //Check image format
        QImageReader reader(fi.absoluteFilePath());
        if(!QImageWriter::supportedImageFormats().contains(reader.format())){
            continue;
        }

        int rotation = 0;
        if(autoDetectRotation){
            QExifImageHeader exif(filepath);
            quint16 orientation = exif.value(QExifImageHeader::ImageTag::Orientation).toShort();
            QString brand = exif.value(QExifImageHeader::ImageTag::Make).toString();
            rotation = getRotation(brand, orientation);
        }

        emit load( fi.absoluteFilePath(), rotation );
    }
}

bool Tools::removeFile(const QString &path)
{
    qDebug() << "Remove file: " << path;
    QFileInfo fi(path);
    if(!fi.exists())
        return true;

    return QFile::remove(fi.absoluteFilePath());
}

int Tools::getRotation(const QString &brand, const quint16 value)
{
    Q_UNUSED(brand);

    switch (value) {
    case 3: return 2;
    case 6: return 1;
    case 8: return 3;
    }

    return 0;
}

QString Tools::supportedFormats() const
{
    QList<QByteArray> supported = QImageWriter::supportedImageFormats();
    QStringList filters;
    foreach(QByteArray filter, supported){
        filters << "*." + QString(filter).toLower();
        filters << "*." + QString(filter).toUpper();
    }
    return filters.join(" ");
}

bool Tools::containsValidFiles(const QList<QUrl> &urls) const
{
    foreach(const QUrl &url, urls){
        if(url.isLocalFile()){
            QFileInfo fi(url.toLocalFile());

            if(fi.isDir())
                return true;

            QImageReader reader(fi.absoluteFilePath());
            if(QImageWriter::supportedImageFormats().contains(reader.format())){
                return true;
            }
        }
    }
    return false;
}

bool Tools::containsValidUrls(const QJsonObject &urls) const
{
    foreach(const QJsonValue &val, urls){
        QUrl url(val.toString());
        if(url.isLocalFile()){
            QFileInfo fi(url.toLocalFile());

            if(fi.isDir())
                return true;

            QImageReader reader(fi.absoluteFilePath());
            if(QImageWriter::supportedImageFormats().contains(reader.format())){
                return true;
            }
        }
    }
    return false;
}
