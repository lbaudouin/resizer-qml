#ifndef TOOLS_H
#define TOOLS_H

#include <QObject>
#include <QUuid>
#include <QImage>


class Tools : public QObject
{
    Q_OBJECT
public:
    explicit Tools(QObject *parent = nullptr);

    int getRotation(const QString &brand, const quint16 value);

protected:

signals:
    void load( const QString &path, int rotation );

public slots:
    void openFolder( const QString &path, bool autoDetectRotation = true);
    void openFiles(const QStringList &files, bool autoDetectRotation = true);

    void removeFile( const QString &path );

};

#endif // TOOLS_H
