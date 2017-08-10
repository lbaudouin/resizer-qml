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

void Tools::openFolder(const QString &path, bool autoDetectRotation)
{
    QEventLoop loop;
    QTimer::singleShot(50,[&loop](){loop.quit();});
    loop.exec();

    QString clean = path;
    clean = clean.remove("file://");

    qDebug() << "Add folder: " << clean;

    QStringList absoluteFilepaths;

    QFileInfo fileinfo(clean);
    if(!fileinfo.exists())
        return;

    if(fileinfo.isDir()){
        QDir dir(fileinfo.absoluteFilePath());
        if(!dir.exists())
            return;

        dir.setFilter(QDir::Files);
        QStringList filenames = dir.entryList();

        foreach( const QString &filename, filenames)
            absoluteFilepaths << dir.absoluteFilePath(filename);
    }else{
        absoluteFilepaths << fileinfo.absoluteFilePath();
    }

    openFiles( absoluteFilepaths, autoDetectRotation );
}

void Tools::openFiles(const QStringList &files, bool autoDetectRotation)
{
    qDebug() << "Add files: " << files;

    foreach(QString filepath, files){
        filepath = filepath.remove("file://");

        QFileInfo fi(filepath);

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

void Tools::removeFile(const QString &path)
{
    qDebug() << "Remove file: " << path;
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


