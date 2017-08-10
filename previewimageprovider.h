#ifndef RESIZEDIMAGEPROVIDER_H
#define RESIZEDIMAGEPROVIDER_H

#include <QQuickImageProvider>

class PreviewImageProvider : public QQuickImageProvider
{
public:
    explicit PreviewImageProvider();

    QPixmap requestPixmap(const QString &filepath, QSize *size, const QSize &requestedSize);

    void rotation( const QString &brand, const quint16 value);
};

#endif // RESIZEDIMAGEPROVIDER_H
