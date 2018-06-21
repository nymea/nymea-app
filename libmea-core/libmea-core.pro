TARGET = mea-core
TEMPLATE = lib
CONFIG += staticlib

include(../mea.pri)
!win32: {
    # To enable this on Windows we'd need to install Bonjour
    # https://support.apple.com/kb/DL999
    DEFINES += QZEROCONF_STATIC
    DEFINES += WITH_ZEROCONF
    include(../QtZeroConf/qtzeroconf.pri)
}

QT -= gui
QT += websockets bluetooth

INCLUDEPATH += $$top_srcdir/libnymea-common $$top_srcdir/QtZeroConf

SOURCES += \
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
    models/eventdescriptorparamsfiltermodel.cpp \
    wifisetup/bluetoothdevice.cpp \
    wifisetup/bluetoothdeviceinfo.cpp \
    wifisetup/bluetoothdeviceinfos.cpp \
    wifisetup/bluetoothdiscovery.cpp \
    wifisetup/wirelessaccesspoint.cpp \
    wifisetup/wirelessaccesspoints.cpp \
    wifisetup/wirelesssetupmanager.cpp \
    wifisetup/networkmanagercontroler.cpp \
    models/logsmodelng.cpp \
    models/interfacesproxy.cpp

HEADERS += \
    engine.h \
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
    models/eventdescriptorparamsfiltermodel.h \
    wifisetup/bluetoothdevice.h \
    wifisetup/bluetoothdeviceinfo.h \
    wifisetup/bluetoothdeviceinfos.h \
    wifisetup/bluetoothdiscovery.h \
    wifisetup/wirelessaccesspoint.h \
    wifisetup/wirelessaccesspoints.h \
    wifisetup/wirelesssetupmanager.h \
    wifisetup/networkmanagercontroler.h \
    libmea-core.h \
    models/logsmodelng.h \
    models/interfacesproxy.h

unix {
    target.path = /usr/lib
    INSTALLS += target
}
