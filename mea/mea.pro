TEMPLATE=app
TARGET=mea
include(../mea.pri)


QT += qml quick quickcontrols2 websockets svg

INCLUDEPATH += $$top_srcdir/libnymea-common
LIBS += -L$$top_builddir/libnymea-common/release -L$$top_builddir/libnymea-common/ -lnymea-common

HEADERS += engine.h \
    nymeainterface.h \
    devicemanager.h \
    websocketinterface.h \
    jsonrpc/jsontypes.h \
    jsonrpc/jsonrpcclient.h \
    jsonrpc/jsonhandler.h \
    discovery/nymeahost.h \
    discovery/nymeahosts.h \
    discovery/upnpdiscovery.h \
    devices.h \
    devicesproxy.h \
    deviceclasses.h \
    deviceclassesproxy.h \
    devicediscovery.h \
    vendorsproxy.h \
    pluginsproxy.h \
    tcpsocketinterface.h \
    nymeaconnection.h \
    interfacesmodel.h \
    discovery/zeroconfdiscovery.h \
    discovery/discoverydevice.h \
    discovery/discoverymodel.h \
    rulemanager.h \
    models/rulesfiltermodel.h \
    models/logsmodel.h \
    models/valuelogsproxymodel.h \
    discovery/nymeadiscovery.h \
    logmanager.h \
    basicconfiguration.h \
    models/eventdescriptorparamsfiltermodel.h


SOURCES += main.cpp \
    engine.cpp \
    nymeainterface.cpp \
    devicemanager.cpp \
    websocketinterface.cpp \
    jsonrpc/jsontypes.cpp \
    jsonrpc/jsonrpcclient.cpp \
    jsonrpc/jsonhandler.cpp \
    discovery/nymeahost.cpp \
    discovery/nymeahosts.cpp  \
    discovery/upnpdiscovery.cpp \
    devices.cpp \
    devicesproxy.cpp \
    deviceclasses.cpp \
    deviceclassesproxy.cpp \
    devicediscovery.cpp \
    vendorsproxy.cpp \
    pluginsproxy.cpp \
    tcpsocketinterface.cpp \
    nymeaconnection.cpp \
    interfacesmodel.cpp \
    discovery/zeroconfdiscovery.cpp \
    discovery/discoverydevice.cpp \
    discovery/discoverymodel.cpp \
    rulemanager.cpp \
    models/rulesfiltermodel.cpp \
    models/logsmodel.cpp \
    models/valuelogsproxymodel.cpp \
    discovery/nymeadiscovery.cpp \
    logmanager.cpp \
    basicconfiguration.cpp \
    models/eventdescriptorparamsfiltermodel.cpp

withavahi {
DEFINES += WITH_AVAHI

LIBS +=  -lavahi-client -lavahi-common

HEADERS += discovery/avahi/avahiserviceentry.h \
    discovery/avahi/qt-watch.h \
    discovery/avahi/qtavahiclient.h \
    discovery/avahi/qtavahiservice_p.h \
    discovery/avahi/qtavahiservice.h \
    discovery/avahi/qtavahiservicebrowser_p.h \
    discovery/avahi/qtavahiservicebrowser.h \

SOURCES += discovery/avahi/avahiserviceentry.cpp \
    discovery/avahi/qt-watch.cpp \
    discovery/avahi/qtavahiclient.cpp \
    discovery/avahi/qtavahiservice_p.cpp \
    discovery/avahi/qtavahiservice.cpp \
    discovery/avahi/qtavahiservicebrowser_p.cpp \
    discovery/avahi/qtavahiservicebrowser.cpp \

}

RESOURCES += \
    resources.qrc

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_EXTRA_LIBS = \
        $$PWD/../../android-openssl/prebuilt/armeabi-v7a/libcrypto.so \
        $$PWD/../../android-openssl/prebuilt/armeabi-v7a/libssl.so
}

DISTFILES += \
    android/AndroidManifest.xml \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat \
    LICENSE

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/../packaging/android

BR=$$BRANDING
!equals(BR, "") {
DEFINES += BRANDING=\\\"maveo\\\"
}

DISTFILES += \
    $$PWD/../win-installer.nsi
target.path = /usr/bin
INSTALLS += target
