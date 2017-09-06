#ifndef TOOLS_H
#define TOOLS_H

#include <QObject>
#include <QUuid>
#include <QImage>

#include <QDateTime>
#include <QUrl>


class Tools : public QObject
{
    Q_OBJECT
public:
    explicit Tools(QObject *parent = nullptr);

    int getRotation(const QString &brand, const quint16 value);

    Q_INVOKABLE QString supportedFormats() const;
    Q_INVOKABLE bool containsValidFiles(const QList<QUrl> &urls) const;
    Q_INVOKABLE bool containsValidUrls(const QJsonObject &urls) const;

    Q_INVOKABLE inline qint64 currentTimestamp() const { return QDateTime::currentMSecsSinceEpoch(); }

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

    void openFolderInExplorer(const QString &path);

};

#endif // TOOLS_H
