TEMPLATE=app
TARGET=guh-control
include(../guh-control.pri)


QT += qml quick quickcontrols2 websockets svg charts

INCLUDEPATH += $$top_srcdir/libguh-common
LIBS += -L$$top_builddir/libguh-common/ -lguh-common

HEADERS += engine.h \
    guhinterface.h \
    devicemanager.h \
    websocketinterface.h \
    jsonrpc/jsontypes.h \
    jsonrpc/jsonrpcclient.h \
    jsonrpc/jsonhandler.h \
    discovery/guhhost.h \
    discovery/guhhosts.h \
    discovery/upnpdiscovery.h \
    devices.h \
    devicesproxy.h \
    deviceclasses.h \
    deviceclassesproxy.h \
    devicediscovery.h \
    vendorsproxy.h \
    pluginsproxy.h \
    tcpsocketinterface.h \
    guhconnection.h \
    interfacesmodel.h \
    discovery/zeroconfdiscovery.h \
    discovery/discoverydevice.h \
    discovery/discoverymodel.h \
    rulemanager.h \
    models/rulesfiltermodel.h \
    models/logsmodel.h \
    models/valuelogsproxymodel.h


SOURCES += main.cpp \
    engine.cpp \
    guhinterface.cpp \
    devicemanager.cpp \
    websocketinterface.cpp \
    jsonrpc/jsontypes.cpp \
    jsonrpc/jsonrpcclient.cpp \
    jsonrpc/jsonhandler.cpp \
    discovery/guhhost.cpp \
    discovery/guhhosts.cpp  \
    discovery/upnpdiscovery.cpp \
    devices.cpp \
    devicesproxy.cpp \
    deviceclasses.cpp \
    deviceclassesproxy.cpp \
    devicediscovery.cpp \
    vendorsproxy.cpp \
    pluginsproxy.cpp \
    tcpsocketinterface.cpp \
    guhconnection.cpp \
    interfacesmodel.cpp \
    discovery/zeroconfdiscovery.cpp \
    discovery/discoverydevice.cpp \
    discovery/discoverymodel.cpp \
    rulemanager.cpp \
    models/rulesfiltermodel.cpp \
    models/logsmodel.cpp \
    models/valuelogsproxymodel.cpp

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

#DISTFILES += \
#    android/AndroidManifest.xml \
#    android/gradle/wrapper/gradle-wrapper.jar \
#    android/gradlew \
#    android/res/values/libs.xml \
#    android/build.gradle \
#    android/gradle/wrapper/gradle-wrapper.properties \
#    android/gradlew.bat

#ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

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
    android/gradlew.bat

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android


