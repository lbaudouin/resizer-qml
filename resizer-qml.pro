QT += qml quick concurrent

TARGET = resizer

CONFIG += c++11

SOURCES += main.cpp \
    tools.cpp \
    previewimageprovider.cpp \
    qexifimageheader/qexifimageheader.cpp \
    resizer.cpp \
    zip/qzip.cpp

RESOURCES += qml.qrc \
    images.qrc \
    i18n.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# Default rules for deployment.
target.path = $$PREFIX/usr/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    tools.h \
    previewimageprovider.h \
    qexifimageheader/qexifimageheader.h \
    resizer.h \
    zip/qzipreader.h \
    zip/qzipwriter.h

LANGUAGES = fr en

TRANSLATIONS += i18n/resizer_fr.ts i18n/resizer_en.ts

TRANSLATIONS_FILES =

qtPrepareTool(LRELEASE, lrelease)
for(tsfile, TRANSLATIONS) {
 qmfile = $$shadowed($$tsfile)
 qmfile ~= s,.ts$,.qm,
 qmdir = $$dirname(qmfile)
 !exists($$qmdir) {
 mkpath($$qmdir)|error("Aborting.")
 }
 command = $$LRELEASE -removeidentical $$tsfile -qm $$qmfile
 system($$command)|error("Failed to run: $$command")
 TRANSLATIONS_FILES += $$qmfile
}


!contains( QT_CONFIG, system-zlib ) {
    if( unix|win32-g++* ): LIBS += -lz
    else: LIBS += zdll.lib
}
