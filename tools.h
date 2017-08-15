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

    Q_INVOKABLE QString supportedFormats() const;
    Q_INVOKABLE bool containsValidFiles(const QList<QUrl> &urls) const;

protected:

signals:
    void load( const QString &path, int rotation );

    void openFileDialog();
    void openFolderDialog();

public slots:
    void openFolder(const QUrl &url, bool autoDetectRotation = true);
    void openFiles(const QList<QUrl> &urls, bool autoDetectRotation = true);

    bool removeFile(const QString &path);

    inline void trigOpenFileDialog() { emit openFileDialog(); }
    void trigOpenFolderDialog() { emit openFolderDialog(); }

};

#endif // TOOLS_H
