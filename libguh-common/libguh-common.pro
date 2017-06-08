include(../guh-control.pri)

TARGET = guh-common
TEMPLATE = lib

QT += network

target.path = /usr/lib/$$system('dpkg-architecture -q DEB_HOST_MULTIARCH')
INSTALLS += target

HEADERS += types/types.h \
           types/vendor.h \
           types/vendors.h \
           types/vendorsproxy.h \
           types/deviceclass.h \
           types/deviceclasses.h \
           types/deviceclassesproxy.h \
           types/device.h \
           types/devices.h \
           types/devicesproxy.h \
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
           types/pluginsproxy.h \

SOURCES += types/vendor.cpp \
           types/vendors.cpp \
           types/vendorsproxy.cpp \
           types/deviceclass.cpp \
           types/deviceclasses.cpp \
           types/deviceclassesproxy.cpp \
           types/device.cpp \
           types/devices.cpp \
           types/devicesproxy.cpp \
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
           types/pluginsproxy.cpp \

# install header file with relative subdirectory
for(header, HEADERS) {
    path = /usr/include/guh-common/$${dirname(header)}
    eval(headers_$${path}.files += $${header})
    eval(headers_$${path}.path = $${path})
    eval(INSTALLS *= headers_$${path})
}
