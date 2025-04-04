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

INCLUDEPATH += \
    $${PWD} \
    $$top_srcdir/QtZeroConf

SOURCES += \
    $$PWD/appdata.cpp \
    $$PWD/connection/networkreachabilitymonitor.cpp \
    $$PWD/energy/energylogs.cpp \
    $$PWD/energy/energymanager.cpp \
    $$PWD/energy/powerbalancelogs.cpp \
    $$PWD/energy/thingpowerlogs.cpp \
    $$PWD/connection/tunnelproxytransport.cpp \
    $$PWD/models/boolseriesadapter.cpp \
    $$PWD/models/newlogentry.cpp \
    $$PWD/models/newlogsmodel.cpp \
    $$PWD/models/scriptsproxymodel.cpp \
    $$PWD/pluginconfigmanager.cpp \
    $$PWD/serverdebug/serverdebugmanager.cpp \
    $$PWD/serverdebug/serverloggingcategories.cpp \
    $$PWD/serverdebug/serverloggingcategory.cpp \
    $$PWD/tagwatcher.cpp \
    $$PWD/zigbee/zigbeenode.cpp \
    $$PWD/zigbee/zigbeenodes.cpp \
    $$PWD/zigbee/zigbeenodesproxy.cpp \
    $$PWD/zwave/zwavemanager.cpp \
    $$PWD/zwave/zwavenetwork.cpp \
    $$PWD/zwave/zwavenode.cpp \
    $${PWD}/logging.cpp \
    $${PWD}/applogcontroller.cpp \
    $${PWD}/wifisetup/btwifisetup.cpp \
    $$PWD/modbus/modbusrtumanager.cpp \
    $$PWD/modbus/modbusrtumaster.cpp \
    $$PWD/modbus/modbusrtumasters.cpp \
    $$PWD/types/serialport.cpp \
    $$PWD/types/serialports.cpp \
    $$PWD/types/serialportsproxy.cpp \
    $${PWD}/configuration/networkmanager.cpp \
    $${PWD}/engine.cpp \
    $${PWD}/models/barseriesadapter.cpp \
    $${PWD}/models/sortfilterproxymodel.cpp \
    $${PWD}/models/xyseriesadapter.cpp \
    $${PWD}/ruletemplates/calendaritemtemplate.cpp \
    $${PWD}/ruletemplates/timedescriptortemplate.cpp \
    $${PWD}/ruletemplates/timeeventitemtemplate.cpp \
    $${PWD}/scripting/scriptautosaver.cpp \
    $${PWD}/types/browseritem.cpp \
    $${PWD}/types/browseritems.cpp \
    $${PWD}/types/networkdevice.cpp \
    $${PWD}/types/networkdevices.cpp \
    $${PWD}/types/package.cpp \
    $${PWD}/types/packages.cpp \
    $${PWD}/types/repositories.cpp \
    $${PWD}/types/repository.cpp \
    $${PWD}/types/script.cpp \
    $${PWD}/types/scripts.cpp \
    $${PWD}/types/types.cpp \
    $${PWD}/types/vendor.cpp \
    $${PWD}/types/vendors.cpp \
    $${PWD}/types/thingclass.cpp \
    $${PWD}/types/thing.cpp \
    $${PWD}/types/param.cpp \
    $${PWD}/types/params.cpp \
    $${PWD}/types/paramtype.cpp \
    $${PWD}/types/paramtypes.cpp \
    $${PWD}/types/statetype.cpp \
    $${PWD}/types/statetypes.cpp \
    $${PWD}/types/statetypesproxy.cpp \
    $${PWD}/types/eventtype.cpp \
    $${PWD}/types/eventtypes.cpp \
    $${PWD}/types/actiontype.cpp \
    $${PWD}/types/actiontypes.cpp \
    $${PWD}/types/state.cpp \
    $${PWD}/types/states.cpp \
    $${PWD}/types/statesproxy.cpp \
    $${PWD}/types/plugin.cpp \
    $${PWD}/types/plugins.cpp \
    $${PWD}/types/rules.cpp \
    $${PWD}/types/rule.cpp \
    $${PWD}/types/eventdescriptor.cpp \
    $${PWD}/types/eventdescriptors.cpp \
    $${PWD}/types/ruleaction.cpp \
    $${PWD}/types/ruleactions.cpp \
    $${PWD}/types/ruleactionparams.cpp \
    $${PWD}/types/ruleactionparam.cpp \
    $${PWD}/types/logentry.cpp \
    $${PWD}/types/stateevaluators.cpp \
    $${PWD}/types/stateevaluator.cpp \
    $${PWD}/types/statedescriptor.cpp \
    $${PWD}/types/paramdescriptor.cpp \
    $${PWD}/types/paramdescriptors.cpp \
    $${PWD}/types/interface.cpp \
    $${PWD}/types/interfaces.cpp \
    $${PWD}/types/timedescriptor.cpp \
    $${PWD}/types/timeeventitem.cpp \
    $${PWD}/types/calendaritem.cpp \
    $${PWD}/types/timeeventitems.cpp \
    $${PWD}/types/calendaritems.cpp \
    $${PWD}/types/repeatingoption.cpp \
    $${PWD}/types/tag.cpp \
    $${PWD}/types/tags.cpp \
    $${PWD}/types/wirelessaccesspoint.cpp \
    $${PWD}/types/wirelessaccesspoints.cpp \
    $${PWD}/types/tokeninfo.cpp \
    $${PWD}/types/tokeninfos.cpp \
    $${PWD}/types/userinfo.cpp \
    $${PWD}/types/ioconnection.cpp \
    $${PWD}/types/ioconnections.cpp \
    $${PWD}/types/ioconnectionwatcher.cpp \
    $${PWD}/connection/nymeahost.cpp \
    $${PWD}/connection/nymeahosts.cpp  \
    $${PWD}/connection/nymeaconnection.cpp \
    $${PWD}/connection/nymeatransportinterface.cpp \
    $${PWD}/connection/websockettransport.cpp \
    $${PWD}/connection/tcpsockettransport.cpp \
    $${PWD}/connection/bluetoothtransport.cpp \
    $${PWD}/connection/discovery/nymeadiscovery.cpp \
    $${PWD}/connection/discovery/upnpdiscovery.cpp \
    $${PWD}/connection/discovery/zeroconfdiscovery.cpp \
    $${PWD}/connection/discovery/bluetoothservicediscovery.cpp \
    $${PWD}/thingmanager.cpp \
    $${PWD}/jsonrpc/jsonrpcclient.cpp \
    $${PWD}/things.cpp \
    $${PWD}/thingsproxy.cpp \
    $${PWD}/thingclasses.cpp \
    $${PWD}/thingclassesproxy.cpp \
    $${PWD}/thingdiscovery.cpp \
    $${PWD}/models/packagesfiltermodel.cpp \
    $${PWD}/models/taglistmodel.cpp \
    $${PWD}/scripting/codecompletion.cpp \
    $${PWD}/scripting/completionmodel.cpp \
    $${PWD}/scriptmanager.cpp \
    $${PWD}/scriptsyntaxhighlighter.cpp \
    $${PWD}/usermanager.cpp \
    $${PWD}/vendorsproxy.cpp \
    $${PWD}/pluginsproxy.cpp \
    $${PWD}/interfacesmodel.cpp \
    $${PWD}/rulemanager.cpp \
    $${PWD}/models/rulesfiltermodel.cpp \
    $${PWD}/models/logsmodel.cpp \
    $${PWD}/logmanager.cpp \
    $${PWD}/wifisetup/bluetoothdevice.cpp \
    $${PWD}/wifisetup/bluetoothdeviceinfo.cpp \
    $${PWD}/wifisetup/bluetoothdeviceinfos.cpp \
    $${PWD}/wifisetup/bluetoothdiscovery.cpp \
    $${PWD}/models/logsmodelng.cpp \
    $${PWD}/models/interfacesproxy.cpp \
    $${PWD}/models/tagsproxymodel.cpp \
    $${PWD}/tagsmanager.cpp \
    $${PWD}/models/wirelessaccesspointsproxy.cpp \
    $${PWD}/ruletemplates/ruletemplate.cpp \
    $${PWD}/ruletemplates/ruletemplates.cpp \
    $${PWD}/ruletemplates/eventdescriptortemplate.cpp \
    $${PWD}/ruletemplates/ruleactiontemplate.cpp \
    $${PWD}/ruletemplates/stateevaluatortemplate.cpp \
    $${PWD}/ruletemplates/statedescriptortemplate.cpp \
    $${PWD}/ruletemplates/ruleactionparamtemplate.cpp \
    $${PWD}/configuration/serverconfiguration.cpp \
    $${PWD}/configuration/serverconfigurations.cpp \
    $${PWD}/configuration/nymeaconfiguration.cpp \
    $${PWD}/configuration/mqttpolicy.cpp \
    $${PWD}/configuration/mqttpolicies.cpp \
    $${PWD}/models/thingmodel.cpp \
    $${PWD}/system/systemcontroller.cpp \
    $${PWD}/thinggroup.cpp \
    $${PWD}/zigbee/zigbeeadapters.cpp \
    $${PWD}/zigbee/zigbeeadaptersproxy.cpp \
    $${PWD}/zigbee/zigbeemanager.cpp \
    $${PWD}/zigbee/zigbeeadapter.cpp \
    $${PWD}/zigbee/zigbeenetwork.cpp \
    $${PWD}/zigbee/zigbeenetworks.cpp



HEADERS += \
    $$PWD/appdata.h \
    $$PWD/connection/networkreachabilitymonitor.h \
    $$PWD/energy/energylogs.h \
    $$PWD/energy/energymanager.h \
    $$PWD/energy/powerbalancelogs.h \
    $$PWD/energy/thingpowerlogs.h \
    $$PWD/connection/tunnelproxytransport.h \
    $$PWD/models/boolseriesadapter.h \
    $$PWD/models/newlogentry.h \
    $$PWD/models/newlogsmodel.h \
    $$PWD/models/scriptsproxymodel.h \
    $$PWD/pluginconfigmanager.h \
    $$PWD/serverdebug/serverdebugmanager.h \
    $$PWD/serverdebug/serverloggingcategories.h \
    $$PWD/serverdebug/serverloggingcategory.h \
    $$PWD/tagwatcher.h \
    $$PWD/zigbee/zigbeenode.h \
    $$PWD/zigbee/zigbeenodes.h \
    $$PWD/zigbee/zigbeenodesproxy.h \
    $$PWD/zwave/zwavemanager.h \
    $$PWD/zwave/zwavenetwork.h \
    $$PWD/zwave/zwavenode.h \
    $${PWD}/logging.h \
    $${PWD}/applogcontroller.h \
    $${PWD}/wifisetup/btwifisetup.h \
    $$PWD/modbus/modbusrtumanager.h \
    $$PWD/modbus/modbusrtumaster.h \
    $$PWD/modbus/modbusrtumasters.h \
    $$PWD/types/serialport.h \
    $$PWD/types/serialports.h \
    $$PWD/types/serialportsproxy.h \
    $${PWD}/configuration/networkmanager.h \
    $${PWD}/engine.h \
    $${PWD}/models/barseriesadapter.h \
    $${PWD}/models/sortfilterproxymodel.h \
    $${PWD}/models/xyseriesadapter.h \
    $${PWD}/ruletemplates/calendaritemtemplate.h \
    $${PWD}/ruletemplates/timedescriptortemplate.h \
    $${PWD}/ruletemplates/timeeventitemtemplate.h \
    $${PWD}/scripting/scriptautosaver.h \
    $${PWD}/types/browseritem.h \
    $${PWD}/types/browseritems.h \
    $${PWD}/types/networkdevice.h \
    $${PWD}/types/networkdevices.h \
    $${PWD}/types/package.h \
    $${PWD}/types/packages.h \
    $${PWD}/types/repositories.h \
    $${PWD}/types/repository.h \
    $${PWD}/types/script.h \
    $${PWD}/types/scripts.h \
    $${PWD}/types/types.h \
    $${PWD}/types/vendor.h \
    $${PWD}/types/vendors.h \
    $${PWD}/types/thingclass.h \
    $${PWD}/types/thing.h \
    $${PWD}/types/param.h \
    $${PWD}/types/params.h \
    $${PWD}/types/paramtype.h \
    $${PWD}/types/paramtypes.h \
    $${PWD}/types/statetype.h \
    $${PWD}/types/statetypes.h \
    $${PWD}/types/statetypesproxy.h \
    $${PWD}/types/eventtype.h \
    $${PWD}/types/eventtypes.h \
    $${PWD}/types/actiontype.h \
    $${PWD}/types/actiontypes.h \
    $${PWD}/types/state.h \
    $${PWD}/types/states.h \
    $${PWD}/types/statesproxy.h \
    $${PWD}/types/plugin.h \
    $${PWD}/types/plugins.h \
    $${PWD}/types/rules.h \
    $${PWD}/types/rule.h \
    $${PWD}/types/eventdescriptor.h \
    $${PWD}/types/eventdescriptors.h \
    $${PWD}/types/ruleaction.h \
    $${PWD}/types/ruleactions.h \
    $${PWD}/types/ruleactionparams.h \
    $${PWD}/types/ruleactionparam.h \
    $${PWD}/types/logentry.h \
    $${PWD}/types/stateevaluators.h \
    $${PWD}/types/stateevaluator.h \
    $${PWD}/types/statedescriptor.h \
    $${PWD}/types/paramdescriptor.h \
    $${PWD}/types/paramdescriptors.h \
    $${PWD}/types/interface.h \
    $${PWD}/types/interfaces.h \
    $${PWD}/types/timedescriptor.h \
    $${PWD}/types/timeeventitem.h \
    $${PWD}/types/calendaritem.h \
    $${PWD}/types/timeeventitems.h \
    $${PWD}/types/calendaritems.h \
    $${PWD}/types/repeatingoption.h \
    $${PWD}/types/tag.h \
    $${PWD}/types/tags.h \
    $${PWD}/types/wirelessaccesspoint.h \
    $${PWD}/types/wirelessaccesspoints.h \
    $${PWD}/types/tokeninfo.h \
    $${PWD}/types/tokeninfos.h \
    $${PWD}/types/userinfo.h \
    $${PWD}/types/ioconnection.h \
    $${PWD}/types/ioconnections.h \
    $${PWD}/types/ioconnectionwatcher.h \
    $${PWD}/connection/nymeahost.h \
    $${PWD}/connection/nymeahosts.h \
    $${PWD}/connection/nymeaconnection.h \
    $${PWD}/connection/nymeatransportinterface.h \
    $${PWD}/connection/websockettransport.h \
    $${PWD}/connection/tcpsockettransport.h \
    $${PWD}/connection/bluetoothtransport.h \
    $${PWD}/connection/discovery/nymeadiscovery.h \
    $${PWD}/connection/discovery/upnpdiscovery.h \
    $${PWD}/connection/discovery/zeroconfdiscovery.h \
    $${PWD}/connection/discovery/bluetoothservicediscovery.h \
    $${PWD}/thingmanager.h \
    $${PWD}/jsonrpc/jsonrpcclient.h \
    $${PWD}/things.h \
    $${PWD}/thingsproxy.h \
    $${PWD}/thingclasses.h \
    $${PWD}/thingclassesproxy.h \
    $${PWD}/thingdiscovery.h \
    $${PWD}/models/packagesfiltermodel.h \
    $${PWD}/models/taglistmodel.h \
    $${PWD}/scripting/codecompletion.h \
    $${PWD}/scripting/completionmodel.h \
    $${PWD}/scriptmanager.h \
    $${PWD}/scriptsyntaxhighlighter.h \
    $${PWD}/usermanager.h \
    $${PWD}/vendorsproxy.h \
    $${PWD}/pluginsproxy.h \
    $${PWD}/interfacesmodel.h \
    $${PWD}/rulemanager.h \
    $${PWD}/models/rulesfiltermodel.h \
    $${PWD}/models/logsmodel.h \
    $${PWD}/logmanager.h \
    $${PWD}/wifisetup/bluetoothdevice.h \
    $${PWD}/wifisetup/bluetoothdeviceinfo.h \
    $${PWD}/wifisetup/bluetoothdeviceinfos.h \
    $${PWD}/wifisetup/bluetoothdiscovery.h \
    $${PWD}/libnymea-app-core.h \
    $${PWD}/models/logsmodelng.h \
    $${PWD}/models/interfacesproxy.h \
    $${PWD}/tagsmanager.h \
    $${PWD}/models/tagsproxymodel.h \
    $${PWD}/models/wirelessaccesspointsproxy.h \
    $${PWD}/ruletemplates/ruletemplate.h \
    $${PWD}/ruletemplates/ruletemplates.h \
    $${PWD}/ruletemplates/eventdescriptortemplate.h \
    $${PWD}/ruletemplates/ruleactiontemplate.h \
    $${PWD}/ruletemplates/stateevaluatortemplate.h \
    $${PWD}/ruletemplates/statedescriptortemplate.h \
    $${PWD}/ruletemplates/ruleactionparamtemplate.h \
    $${PWD}/configuration/serverconfiguration.h \
    $${PWD}/configuration/serverconfigurations.h \
    $${PWD}/configuration/nymeaconfiguration.h \
    $${PWD}/configuration/mqttpolicy.h \
    $${PWD}/configuration/mqttpolicies.h \
    $${PWD}/models/thingmodel.h \
    $${PWD}/system/systemcontroller.h \
    $${PWD}/thinggroup.h \
    $${PWD}/zigbee/zigbeeadapters.h \
    $${PWD}/zigbee/zigbeeadaptersproxy.h \
    $${PWD}/zigbee/zigbeemanager.h \
    $${PWD}/zigbee/zigbeeadapter.h \
    $${PWD}/zigbee/zigbeenetwork.h \
    $${PWD}/zigbee/zigbeenetworks.h

ubports: {
    DEFINES += UBPORTS
}

# https://bugreports.qt.io/browse/QTBUG-83165
android: {
    DESTDIR = $${ANDROID_TARGET_ARCH}
}

ios: {
    OBJECTIVE_SOURCES += $${PWD}/connection/networkreachabilitymonitorios.mm
}
