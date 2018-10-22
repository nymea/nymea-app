TARGET = nymea-app-core
TEMPLATE = lib
CONFIG += staticlib

include(../config.pri)
!win32: {
    # To enable this on Windows we'd need to install Bonjour
    # https://support.apple.com/kb/DL999
    DEFINES += QZEROCONF_STATIC
    DEFINES += WITH_ZEROCONF
    include(../QtZeroConf/qtzeroconf.pri)
}

include(../nymea-remoteproxy/libnymea-remoteproxyclient/libnymea-remoteproxyclient.pri)


QT -= gui
QT += network websockets bluetooth

LIBS += -lssl -lcrypto

INCLUDEPATH += $$top_srcdir/libnymea-common \
    $$top_srcdir/QtZeroConf \
    $$top_srcdir/qmqtt/src/mqtt/

SOURCES += \
    engine.cpp \
    connection/nymeaconnection.cpp \
    connection/nymeatransportinterface.cpp \
    connection/websockettransport.cpp \
    connection/tcpsockettransport.cpp \
    connection/bluetoothtransport.cpp \
    connection/awsclient.cpp \
    devicemanager.cpp \
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
    configuration/basicconfiguration.cpp \
    wifisetup/bluetoothdevice.cpp \
    wifisetup/bluetoothdeviceinfo.cpp \
    wifisetup/bluetoothdeviceinfos.cpp \
    wifisetup/bluetoothdiscovery.cpp \
    wifisetup/wirelessaccesspoint.cpp \
    wifisetup/wirelessaccesspoints.cpp \
    wifisetup/wirelesssetupmanager.cpp \
    wifisetup/networkmanagercontroller.cpp \
    models/logsmodelng.cpp \
    models/interfacesproxy.cpp \
    models/tagsproxymodel.cpp \
    tagsmanager.cpp \
    wifisetup/wirelessaccesspointsproxy.cpp \
    ruletemplates/ruletemplate.cpp \
    ruletemplates/ruletemplates.cpp \
    ruletemplates/eventdescriptortemplate.cpp \
    ruletemplates/ruleactiontemplate.cpp \
    ruletemplates/stateevaluatortemplate.cpp \
    ruletemplates/statedescriptortemplate.cpp \
    discovery/bluetoothservicediscovery.cpp \
    connection/cloudtransport.cpp \
    connection/sigv4utils.cpp \
    ruletemplates/ruleactionparamtemplate.cpp \
    configuration/serverconfiguration.cpp \
    configuration/serverconfigurations.cpp

HEADERS += \
    engine.h \
    connection/nymeaconnection.h \
    connection/nymeatransportinterface.h \
    connection/websockettransport.h \
    connection/tcpsockettransport.h \
    connection/bluetoothtransport.h \
    connection/awsclient.h \
    connection/sigv4utils.h \
    devicemanager.h \
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
    configuration/basicconfiguration.h \
    wifisetup/bluetoothdevice.h \
    wifisetup/bluetoothdeviceinfo.h \
    wifisetup/bluetoothdeviceinfos.h \
    wifisetup/bluetoothdiscovery.h \
    wifisetup/wirelessaccesspoint.h \
    wifisetup/wirelessaccesspoints.h \
    wifisetup/wirelesssetupmanager.h \
    wifisetup/networkmanagercontroller.h \
    libnymea-app-core.h \
    models/logsmodelng.h \
    models/interfacesproxy.h \
    tagsmanager.h \
    models/tagsproxymodel.h \
    wifisetup/wirelessaccesspointsproxy.h \
    ruletemplates/ruletemplate.h \
    ruletemplates/ruletemplates.h \
    ruletemplates/eventdescriptortemplate.h \
    ruletemplates/ruleactiontemplate.h \
    ruletemplates/stateevaluatortemplate.h \
    ruletemplates/statedescriptortemplate.h \
    discovery/bluetoothservicediscovery.h \
    connection/cloudtransport.h \
    ruletemplates/ruleactionparamtemplate.h \
    configuration/serverconfiguration.h \
    configuration/serverconfigurations.h

unix {
    target.path = /usr/lib
    INSTALLS += target
}
