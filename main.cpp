#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTranslator>

#include <QQmlContext>

#include <QCommandLineParser>
#include <QCommandLineOption>

#include <QIcon>

#include "tools.h"
#include "resizer.h"

#include <QQmlExtensionPlugin>

#include "previewimageprovider.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);
    QCoreApplication::setApplicationName("Resizer");
    QCoreApplication::setApplicationVersion("1.0");

    app.setWindowIcon( QIcon(":/images/resizer" ) );

    // ----------------------- translate ---------------------- //

    QString lang = QLocale::system().name().section('_', 0, 0);
    lang = lang.toLower();

    QTranslator *translator = new QTranslator();
    if( translator->load( QString(":/lang/lang_%1").arg(lang) ) ){
        qApp->installTranslator( translator );
    }else{
        qWarning() << "Failed to load language: " << lang;
    }

    // ----------------------- arguments ---------------------- //

    QCommandLineParser parser;
    parser.setApplicationDescription(QCoreApplication::translate("main", "Resize an image batch"));
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addPositionalArgument("urls", QCoreApplication::translate("main", "URLs to open, optionally."), "[urls...]");


    QCommandLineOption noWindowOption("n", QCoreApplication::translate("main", "No window"));
    parser.addOption(noWindowOption);

    QCommandLineOption openFileOption(QStringList() << "f" << "open-file",
            QCoreApplication::translate("main", "Open file dialog at startup"));
    parser.addOption(openFileOption);

    QCommandLineOption openDirectoryOption(QStringList() << "d" << "open-directory",
            QCoreApplication::translate("main", "Open folder dialog at startup"));
    parser.addOption(openDirectoryOption);

    parser.process(app);

    const QStringList args = parser.positionalArguments();

    bool noWindow = parser.isSet(noWindowOption);
    bool openFileDialog = parser.isSet(openFileOption);
    bool openDirectoryDialog = parser.isSet(openDirectoryOption);

    // ----------------------- qml ---------------------- //

    QQmlApplicationEngine engine;

    engine.addImageProvider(QLatin1String("preview"), new PreviewImageProvider);

    Tools tools;
    engine.rootContext()->setContextProperty( "tools", &tools );

    Resizer resizer;
    engine.rootContext()->setContextProperty( "resizer", &resizer );

    engine.rootContext()->setContextProperty( "version", app.applicationVersion() );

    engine.rootContext()->setContextProperty( "noWindow", noWindow );

    engine.load(QUrl(QLatin1String("qrc:/qml/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    // ----------------------- load ---------------------- //

    foreach (const QString &arg, args) {
        tools.openFiles( QList<QUrl>() << QUrl::fromLocalFile(arg) );
    }

    if(noWindow){

    }else{
        if(openFileDialog && openDirectoryDialog) openFileDialog = false;
        if(openFileDialog) tools.trigOpenFileDialog();
        if(openDirectoryDialog) tools.trigOpenFolderDialog();
    }

    return app.exec();
}
