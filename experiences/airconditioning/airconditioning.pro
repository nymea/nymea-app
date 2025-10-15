TEMPLATE = lib
CONFIG += staticlib
TARGET = nymea-app-airconditioning

QT -= gui
QT += network websockets bluetooth charts quick

include(../../shared.pri)

LIBS += -L$${top_builddir}/libnymea-app/ -lnymea-app

android: {
        LIBS += -L$${top_builddir}/libnymea-app/$${ANDROID_TARGET_ARCH}
        PRE_TARGETDEPS += $$top_builddir/libnymea-app/$${ANDROID_TARGET_ARCH}/libnymea-app.a
}

INCLUDEPATH += $${top_srcdir}/libnymea-app/

# Input
SOURCES += \
        airconditioningmanager.cpp \
        zoneinfo.cpp \
        temperatureschedule.cpp \

HEADERS += \
        airconditioningmanager.h \
        libnymea-app-airconditioning.h \
        zoneinfo.h \
        temperatureschedule.h \

DISTFILES =

android: {
    DESTDIR = $${ANDROID_TARGET_ARCH}
}
