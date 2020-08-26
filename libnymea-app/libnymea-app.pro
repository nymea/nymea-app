TARGET = nymea-app
TEMPLATE = lib
CONFIG += staticlib

include(../config.pri)
!win32:!nozeroconf {
    # To enable this on Windows we'd need to install Bonjour
    # https://support.apple.com/kb/DL999
    message("Building with QtZeroConf")
    DEFINES += QZEROCONF_STATIC
    DEFINES += WITH_ZEROCONF
    include(../QtZeroConf/qtzeroconf.pri)
} else {
    message("Building without QtZeroConf")
}

include(../nymea-remoteproxy/libnymea-remoteproxyclient/libnymea-remoteproxyclient.pri)


QT -= gui
QT += network websockets bluetooth charts quick

LIBS += -lssl -lcrypto

INCLUDEPATH += $$top_srcdir/QtZeroConf

SOURCES += \
    configuration/networkmanager.cpp \
    engine.cpp \
    models/barseriesadapter.cpp \
    models/sortfilterproxymodel.cpp \
    models/xyseriesadapter.cpp \
    ruletemplates/calendaritemtemplate.cpp \
    ruletemplates/timedescriptortemplate.cpp \
    ruletemplates/timeeventitemtemplate.cpp \
    types/browseritem.cpp \
    types/browseritems.cpp \
    types/networkdevice.cpp \
    types/networkdevices.cpp \
    types/package.cpp \
    types/packages.cpp \
    types/repositories.cpp \
    types/repository.cpp \
    types/script.cpp \
    types/scripts.cpp \
    types/types.cpp \
    types/vendor.cpp \
    types/vendors.cpp \
    types/deviceclass.cpp \
    types/device.cpp \
    types/param.cpp \
    types/params.cpp \
    types/paramtype.cpp \
    types/paramtypes.cpp \
    types/statetype.cpp \
    types/statetypes.cpp \
    types/statetypesproxy.cpp \
    types/eventtype.cpp \
    types/eventtypes.cpp \
    types/actiontype.cpp \
    types/actiontypes.cpp \
    types/state.cpp \
    types/states.cpp \
    types/statesproxy.cpp \
    types/plugin.cpp \
    types/plugins.cpp \
    types/rules.cpp \
    types/rule.cpp \
    types/eventdescriptor.cpp \
    types/eventdescriptors.cpp \
    types/ruleaction.cpp \
    types/ruleactions.cpp \
    types/ruleactionparams.cpp \
    types/ruleactionparam.cpp \
    types/logentry.cpp \
    types/stateevaluators.cpp \
    types/stateevaluator.cpp \
    types/statedescriptor.cpp \
    types/paramdescriptor.cpp \
    types/paramdescriptors.cpp \
    types/interface.cpp \
    types/interfaces.cpp \
    types/timedescriptor.cpp \
    types/timeeventitem.cpp \
    types/calendaritem.cpp \
    types/timeeventitems.cpp \
    types/calendaritems.cpp \
    types/repeatingoption.cpp \
    types/tag.cpp \
    types/tags.cpp \
    types/wirelessaccesspoint.cpp \
    types/wirelessaccesspoints.cpp \
    types/tokeninfo.cpp \
    types/tokeninfos.cpp \
    types/userinfo.cpp \
    types/ioconnection.cpp \
    types/ioconnections.cpp \
    types/ioconnectionwatcher.cpp \
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
    models/taglistmodel.cpp \
    scripting/codecompletion.cpp \
    scripting/completionmodel.cpp \
    scriptmanager.cpp \
    scriptsyntaxhighlighter.cpp \
    usermanager.cpp \
    vendorsproxy.cpp \
    pluginsproxy.cpp \
    interfacesmodel.cpp \
    rulemanager.cpp \
    models/rulesfiltermodel.cpp \
    models/logsmodel.cpp \
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
    system/systemcontroller.cpp \
    thinggroup.cpp \


HEADERS += \
    configuration/networkmanager.h \
    engine.h \
    models/barseriesadapter.h \
    models/sortfilterproxymodel.h \
    models/xyseriesadapter.h \
    ruletemplates/calendaritemtemplate.h \
    ruletemplates/timedescriptortemplate.h \
    ruletemplates/timeeventitemtemplate.h \
    types/browseritem.h \
    types/browseritems.h \
    types/networkdevice.h \
    types/networkdevices.h \
    types/package.h \
    types/packages.h \
    types/repositories.h \
    types/repository.h \
    types/script.h \
    types/scripts.h \
    types/types.h \
    types/vendor.h \
    types/vendors.h \
    types/deviceclass.h \
    types/device.h \
    types/param.h \
    types/params.h \
    types/paramtype.h \
    types/paramtypes.h \
    types/statetype.h \
    types/statetypes.h \
    types/statetypesproxy.h \
    types/eventtype.h \
    types/eventtypes.h \
    types/actiontype.h \
    types/actiontypes.h \
    types/state.h \
    types/states.h \
    types/statesproxy.h \
    types/plugin.h \
    types/plugins.h \
    types/rules.h \
    types/rule.h \
    types/eventdescriptor.h \
    types/eventdescriptors.h \
    types/ruleaction.h \
    types/ruleactions.h \
    types/ruleactionparams.h \
    types/ruleactionparam.h \
    types/logentry.h \
    types/stateevaluators.h \
    types/stateevaluator.h \
    types/statedescriptor.h \
    types/paramdescriptor.h \
    types/paramdescriptors.h \
    types/interface.h \
    types/interfaces.h \
    types/timedescriptor.h \
    types/timeeventitem.h \
    types/calendaritem.h \
    types/timeeventitems.h \
    types/calendaritems.h \
    types/repeatingoption.h \
    types/tag.h \
    types/tags.h \
    types/wirelessaccesspoint.h \
    types/wirelessaccesspoints.h \
    types/tokeninfo.h \
    types/tokeninfos.h \
    types/userinfo.h \
    types/ioconnection.h \
    types/ioconnections.h \
    types/ioconnectionwatcher.h \
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
    models/taglistmodel.h \
    scripting/codecompletion.h \
    scripting/completionmodel.h \
    scriptmanager.h \
    scriptsyntaxhighlighter.h \
    usermanager.h \
    vendorsproxy.h \
    pluginsproxy.h \
    interfacesmodel.h \
    rulemanager.h \
    models/rulesfiltermodel.h \
    models/logsmodel.h \
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
    system/systemcontroller.h \
    thinggroup.h \

ubports: {
    DEFINES += UBPORTS
}

# https://bugreports.qt.io/browse/QTBUG-83165
android: {
    DESTDIR = $${ANDROID_TARGET_ARCH}
}
