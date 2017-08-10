#ifndef RESIZER_H
#define RESIZER_H

#include <QObject>
#include <QFutureWatcher>

class QJsonArray;
class QJsonObject;

struct LogoOptions{
};

struct SizeOptions{
    bool useSize;
    int maxSize;
    int ratio;
};

struct Options{
    SizeOptions size;
    LogoOptions logo;

    QString outputFolder;
    bool noResize;
    bool closeAfterResize;
    bool keepExif;
    bool openAfterResize;
};

struct SaveInfo{
    QString filepath;
    int rotation;
    Options options;
};

class Resizer : public QObject
{
    Q_OBJECT
public:
    explicit Resizer(QObject *parent = nullptr);

protected:
    Options fromJsonOption( const QJsonObject &json );
    static bool save(const SaveInfo &info);

private:
    QFutureWatcher<bool> *m_saverWatcher;

    bool m_closeOnFinished;
    bool m_openOutputFolderOnFinished;
    QString m_outputFolder;

signals:
    void finished();

public slots:
    void resize(const QJsonArray &list , const QJsonObject &jsonOptions );

protected slots:
    void onFinished();
    void onProgressChanged(int);
};

#endif // RESIZER_H
