#ifndef TOOLS_H
#define TOOLS_H

#include <QObject>
#include <QUuid>
#include <QImage>

#include <QUrl>


class Tools : public QObject
{
    Q_OBJECT
public:
    explicit Tools(QObject *parent = nullptr);

    int getRotation(const QString &brand, const quint16 value);

protected:

signals:
    void load( const QString &path, int rotation );

    void openFileDialog();
    void openFolderDialog();

public slots:
    void openFolder(const QUrl &url, bool autoDetectRotation = true);
    void openFiles(const QList<QUrl> &urls, bool autoDetectRotation = true);

    void removeFile( const QString &path );

    inline void trigOpenFileDialog() { emit openFileDialog(); }
    void trigOpenFolderDialog() { emit openFolderDialog(); }

};

#endif // TOOLS_H
