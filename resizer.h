#ifndef RESIZER_H
#define RESIZER_H

#include <QObject>
#include <QFutureWatcher>
#include <QImage>

class QJsonArray;
class QJsonObject;

enum class Position{ TopLeft = 0, TopRight, Centre, BottomLeft, BottomRight };
enum class OutputMode{ NORMAL = 0, TEMP, ZIP, LOGO };

struct LogoOptions{
    bool enabled;
    QImage image;
    Position position;
    int horizontalShift;
    int verticalShift;
    int rotation;
    int opacity;
};

struct SizeOptions{
    bool useSize;
    int maxSize;
    int ratio;
};

struct Options{
    SizeOptions size;
    LogoOptions logo;


    OutputMode mode;
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
    QStringList m_outputFolders;

signals:
    void finished();
    void progressRangeChanged(int minimum, int maximum);
    void progressValueChanged(int progressValue);
    void openOutputFolder(const QStringList &folders, bool close );

public slots:
    void resize(const QJsonArray &list , const QJsonObject &jsonOptions);

protected slots:
    void onFinished();
};

#endif // RESIZER_H
