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

RESOURCES += controlviews/controlviews.qrc \
             ../nymea-app/resources.qrc \
             ../nymea-app/images.qrc \
             ../nymea-app/styles.qrc

INCLUDEPATH += ../nymea-app/

SOURCES += \
    controlviews/devicecontrolapplication.cpp \
    nymeaappservice/nymeaappservice.cpp \
    nymeaappservice/androidbinder.cpp \
    ../nymea-app/stylecontroller.cpp \
    ../nymea-app/platformhelper.cpp \
    ../nymea-app/platformintegration/android/platformhelperandroid.cpp \
    service_main.cpp

HEADERS += \
    controlviews/devicecontrolapplication.h \
    nymeaappservice/nymeaappservice.h \
    nymeaappservice/androidbinder.h \
    ../nymea-app/stylecontroller.h \
    ../nymea-app/platformhelper.h \
    ../nymea-app/platformintegration/android/platformhelperandroid.h \

DISTFILES += \
    ../packaging/android/src/io/guh/nymeaapp/Action.java \
    ../packaging/android/src/io/guh/nymeaapp/NymeaAppControlService.java \
    ../packaging/android/src/io/guh/nymeaapp/NymeaAppService.java \
    ../packaging/android/src/io/guh/nymeaapp/NymeaAppControlsActivity.java \
    ../packaging/android/src/io/guh/nymeaapp/NymeaAppServiceConnection.java \
    ../packaging/android/src/io/guh/nymeaapp/Thing.java \
    ../packaging/android/src/io/guh/nymeaapp/State.java \
    ../packaging/android/src/io/guh/nymeaapp/NymeaHost.java \
    controlviews/Main.qml

