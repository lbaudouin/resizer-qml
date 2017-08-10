#include "previewimageprovider.h"

#include <QImage>
#include <QPainter>
#include <QImageReader>

#include <QDebug>

PreviewImageProvider::PreviewImageProvider() : QQuickImageProvider(QQuickImageProvider::Pixmap)
{

}

QPixmap PreviewImageProvider::requestPixmap(const QString &filepath, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(size);
    Q_UNUSED(requestedSize);

    int width = 200;
    int height = 200;

    QImageReader reader(filepath);
    QSize imageSize = reader.size();
    QImage image;

    if(imageSize.isValid()){
        imageSize.scale(width,height,Qt::KeepAspectRatio);
        reader.setScaledSize(imageSize);
        image = reader.read();
    }else{
        image = QImage(filepath).scaled(320,320,Qt::KeepAspectRatio);
    }

    QPixmap pixmap = QPixmap::fromImage( image );

    return pixmap;
}
