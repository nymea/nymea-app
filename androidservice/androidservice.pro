TEMPLATE = lib
TARGET = service
CONFIG += dll
QT += core androidextras
QT += network qml quick quickcontrols2 svg websockets bluetooth charts

include(../config.pri)
include(../android_openssl/openssl.pri)


INCLUDEPATH += $$top_srcdir/libnymea-app/

# https://bugreports.qt.io/browse/QTBUG-83165
LIBS += -L$${top_builddir}/libnymea-app/$${ANDROID_TARGET_ARCH}

LIBS += -L$$top_builddir/libnymea-app/ -lnymea-app
PRE_TARGETDEPS += ../libnymea-app

SOURCES += \
    androidbinder.cpp \
    service_main.cpp

#HEADERS += servicemessenger.h

HEADERS += \
    androidbinder.h

DISTFILES += \
    ../packaging/android/src/io/guh/nymeaapp/Action.java \
    ../packaging/android/src/io/guh/nymeaapp/NymeaAppControlsActivity.java \
    ../packaging/android/src/io/guh/nymeaapp/NymeaAppServiceConnection.java \
    ../packaging/android/src/io/guh/nymeaapp/Thing.java \
    ../packaging/android/src/io/guh/nymeaapp/State.java

