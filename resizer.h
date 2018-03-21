#ifndef RESIZER_H
#define RESIZER_H

#include <QObject>
#include <QFutureWatcher>
#include <QImage>
#include <QJsonObject>

class QJsonArray;
class QJsonObject;

struct SaveInfo;

class Resizer : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int progress READ progress WRITE setProgress NOTIFY progressChanged)


public:
    explicit Resizer(QObject *parent = nullptr);

    enum Mode { NormalMode, TempMode, ZipMode, LogoMode };
    Q_ENUM( Mode )

    int progress() const;

protected:
    static bool save(const SaveInfo &info);

private:
    QFutureWatcher<bool> *m_saverWatcher;

    bool m_closeOnFinished;
    bool m_openOutputFolderOnFinished;
    QStringList m_outputFolders;

    int m_progress;
    Mode m_mode;

signals:
    void finished();
    void openOutputFolder(const QStringList &folders, bool close );

    void progressChanged(int progress);

public slots:
    void resize(const QJsonArray &list , const QJsonObject &jsonOptions);

    void setProgress(int progress);

protected slots:
    void onFinished();
    void onProgressRangeChanged(int minimum, int maximum);
    void onProgressValueChanged(int progressValue);
};

#endif // RESIZER_H
