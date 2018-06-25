TEMPLATE = app
TARGET = meatestrunner

include(../../nymea-app.pri)

QT += core gui testlib bluetooth websockets
CONFIG += qmltestcase

INCLUDEPATH += ../../nymea-app/ \
    ../../libnymea-common/ \
    ../../libnymea-app-core/

LIBS += -L$$top_builddir/libmea-core/ -lmea-core \
        -L$$top_builddir/libnymea-common/ -lnymea-common
win32:Debug:LIBS += -L$$top_builddir/libmea-core/debug \
                    -L$$top_builddir/libnymea-common/debug
win32:Release:LIBS += -L$$top_builddir/libmea-core/release \
                      -L$$top_builddir/libnymea-common/release

SOURCES += testrunner.cpp

RESOURCES += \
    $$top_srcdir/nymea-app/resources.qrc
