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
QT += network websockets bluetooth charts

LIBS += -lssl -lcrypto

INCLUDEPATH += $$top_srcdir/libnymea-common \
    $$top_srcdir/QtZeroConf

SOURCES += \
    configuration/networkmanager.cpp \
    engine.cpp \
    connection/nymeahost.cpp \
    connection/nymeahosts.cpp  \
    connection/nymeaconnection.cpp \
    connection/nymeatransportinterface.cpp \
    connection/websockettransport.cpp \
    connection/tcpsockettransport.cpp \
    connection/bluetoothtransport.cpp \
    connection/awsclient.cpp \
    connection/discovery/nymeadiscovery.cpp \
    connection/discovery/upnpdiscovery.cpp \
    connection/discovery/zeroconfdiscovery.cpp \
    connection/discovery/bluetoothservicediscovery.cpp \
    devicemanager.cpp \
    jsonrpc/jsontypes.cpp \
    jsonrpc/jsonrpcclient.cpp \
    jsonrpc/jsonhandler.cpp \
    devices.cpp \
    devicesproxy.cpp \
    deviceclasses.cpp \
    deviceclassesproxy.cpp \
    devicediscovery.cpp \
    models/packagesfiltermodel.cpp \
    vendorsproxy.cpp \
    pluginsproxy.cpp \
    interfacesmodel.cpp \
    rulemanager.cpp \
    models/rulesfiltermodel.cpp \
    models/logsmodel.cpp \
    models/valuelogsproxymodel.cpp \
    logmanager.cpp \
    wifisetup/bluetoothdevice.cpp \
    wifisetup/bluetoothdeviceinfo.cpp \
    wifisetup/bluetoothdeviceinfos.cpp \
    wifisetup/bluetoothdiscovery.cpp \
    wifisetup/wirelesssetupmanager.cpp \
    wifisetup/networkmanagercontroller.cpp \
    models/logsmodelng.cpp \
    models/interfacesproxy.cpp \
    models/tagsproxymodel.cpp \
    tagsmanager.cpp \
    models/wirelessaccesspointsproxy.cpp \
    ruletemplates/ruletemplate.cpp \
    ruletemplates/ruletemplates.cpp \
    ruletemplates/eventdescriptortemplate.cpp \
    ruletemplates/ruleactiontemplate.cpp \
    ruletemplates/stateevaluatortemplate.cpp \
    ruletemplates/statedescriptortemplate.cpp \
    connection/cloudtransport.cpp \
    connection/sigv4utils.cpp \
    ruletemplates/ruleactionparamtemplate.cpp \
    configuration/serverconfiguration.cpp \
    configuration/serverconfigurations.cpp \
    configuration/nymeaconfiguration.cpp \
    configuration/mqttpolicy.cpp \
    configuration/mqttpolicies.cpp \
    models/devicemodel.cpp \
    system/systemcontroller.cpp

HEADERS += \
    configuration/networkmanager.h \
    engine.h \
    connection/nymeahost.h \
    connection/nymeahosts.h \
    connection/nymeaconnection.h \
    connection/nymeatransportinterface.h \
    connection/websockettransport.h \
    connection/tcpsockettransport.h \
    connection/bluetoothtransport.h \
    connection/awsclient.h \
    connection/sigv4utils.h \
    connection/discovery/nymeadiscovery.h \
    connection/discovery/upnpdiscovery.h \
    connection/discovery/zeroconfdiscovery.h \
    connection/discovery/bluetoothservicediscovery.h \
    devicemanager.h \
    jsonrpc/jsontypes.h \
    jsonrpc/jsonrpcclient.h \
    jsonrpc/jsonhandler.h \
    devices.h \
    devicesproxy.h \
    deviceclasses.h \
    deviceclassesproxy.h \
    devicediscovery.h \
    models/packagesfiltermodel.h \
    vendorsproxy.h \
    pluginsproxy.h \
    interfacesmodel.h \
    rulemanager.h \
    models/rulesfiltermodel.h \
    models/logsmodel.h \
    models/valuelogsproxymodel.h \
    logmanager.h \
    wifisetup/bluetoothdevice.h \
    wifisetup/bluetoothdeviceinfo.h \
    wifisetup/bluetoothdeviceinfos.h \
    wifisetup/bluetoothdiscovery.h \
    wifisetup/wirelesssetupmanager.h \
    wifisetup/networkmanagercontroller.h \
    libnymea-app-core.h \
    models/logsmodelng.h \
    models/interfacesproxy.h \
    tagsmanager.h \
    models/tagsproxymodel.h \
    models/wirelessaccesspointsproxy.h \
    ruletemplates/ruletemplate.h \
    ruletemplates/ruletemplates.h \
    ruletemplates/eventdescriptortemplate.h \
    ruletemplates/ruleactiontemplate.h \
    ruletemplates/stateevaluatortemplate.h \
    ruletemplates/statedescriptortemplate.h \
    connection/cloudtransport.h \
    ruletemplates/ruleactionparamtemplate.h \
    configuration/serverconfiguration.h \
    configuration/serverconfigurations.h \
    configuration/nymeaconfiguration.h \
    configuration/mqttpolicy.h \
    configuration/mqttpolicies.h \
    models/devicemodel.h \
    system/systemcontroller.h
