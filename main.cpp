#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QQmlContext>

#include "tools.h"
#include "resizer.h"

#include <QQmlExtensionPlugin>

#include "previewimageprovider.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    engine.addImageProvider(QLatin1String("preview"), new PreviewImageProvider);

    Tools tools;
    engine.rootContext()->setContextProperty( "tools", &tools );

    Resizer resizer;
    engine.rootContext()->setContextProperty( "resizer", &resizer );

    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
