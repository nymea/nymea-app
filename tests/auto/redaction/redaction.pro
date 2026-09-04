TEMPLATE = app
TARGET = tst_redaction

include(../../../shared.pri)

QT += core gui testlib bluetooth websockets charts qml quick network dbus
CONFIG += testcase console
CONFIG -= app_bundle

INCLUDEPATH += ../../../libnymea-app

LIBS += -L$$top_builddir/libnymea-app/ -lnymea-app \
        -lavahi-common -lavahi-client
win32:Debug:LIBS += -L$$top_builddir/libnymea-app/debug
win32:Release:LIBS += -L$$top_builddir/libnymea-app/release

SOURCES += tst_redaction.cpp
