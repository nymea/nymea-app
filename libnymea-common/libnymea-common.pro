include(../config.pri)

TARGET = nymea-common
TEMPLATE = lib
CONFIG += staticlib

QT -= gui
QT += network

HEADERS += \
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

SOURCES += \
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
