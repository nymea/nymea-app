include(../guh-control.pri)

TARGET = guh-common
TEMPLATE = lib

QT += network
CONFIG += static

target.path = /usr/lib/$$system('dpkg-architecture -q DEB_HOST_MULTIARCH')
INSTALLS += target

HEADERS += types/types.h \
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
    types/paramdescriptors.h

SOURCES += types/vendor.cpp \
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
    types/paramdescriptors.cpp

# install header file with relative subdirectory
for(header, HEADERS) {
    path = /usr/include/guh-common/$${dirname(header)}
    eval(headers_$${path}.files += $${header})
    eval(headers_$${path}.path = $${path})
    eval(INSTALLS *= headers_$${path})
}
