TEMPLATE = app
TARGET = meatestrunner

include(../../config.pri)

QT += core gui testlib bluetooth websockets
CONFIG += qmltestcase

INCLUDEPATH += ../../nymea-app/ \
    ../../libnymea-app

LIBS += -L$$top_builddir/libnymea-app/ -lnymea-app \
        -lavahi-common -lavahi-client
win32:Debug:LIBS += -L$$top_builddir/libnymea-app/debug
win32:Release:LIBS += -L$$top_builddir/libnymea-app/release

SOURCES += testrunner.cpp

RESOURCES += \
    $$top_srcdir/nymea-app/resources.qrc
