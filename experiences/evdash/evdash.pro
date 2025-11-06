TEMPLATE = lib
CONFIG += staticlib
TARGET = nymea-app-evdash

QT -= gui
QT += network websockets quick

include(../../shared.pri)

LIBS += -L$${top_builddir}/libnymea-app/ -lnymea-app
INCLUDEPATH += $${top_srcdir}/libnymea-app/

android: {
        LIBS += -L$${top_builddir}/libnymea-app/$${ANDROID_TARGET_ARCH}
        PRE_TARGETDEPS += $$top_builddir/libnymea-app/$${ANDROID_TARGET_ARCH}/libnymea-app_$${ANDROID_TARGET_ARCH}.a
}

HEADERS += \
        evdashmanager.h \
        evdashusers.h \
        libnymea-app-evdash.h

SOURCES += \
        evdashmanager.cpp \
        evdashusers.cpp

android: {
    DESTDIR = $${ANDROID_TARGET_ARCH}
}
