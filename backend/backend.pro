include(../guh-control.pri)

QT += qml quick websockets quickcontrols2

TARGET = guh-control

RESOURCES += ../ui/qml.qrc ../data.qrc

INCLUDEPATH += $$top_srcdir/libguh-common
LIBS += -L$$top_builddir/libguh-common/ -lguh-common

QML_FILES += $$files(*.qml,true) \
             $$files(*.js,true)

OTHER_FILES += $${QML_FILES}

HEADERS += \
    engine.h \
    guhinterface.h \
    devicemanager.h \
    websocketinterface.h \
    jsonrpc/jsontypes.h \
    jsonrpc/jsonrpcclient.h \
    jsonrpc/devicehandler.h \
    jsonrpc/jsonhandler.h \
    jsonrpc/actionhandler.h \
    jsonrpc/eventhandler.h \
    jsonrpc/logginghandler.h \
    jsonrpc/networkmanagerhandler.h \
    jsonrpc/configurationhandler.h

SOURCES += main.cpp \
    engine.cpp \
    guhinterface.cpp \
    devicemanager.cpp \
    websocketinterface.cpp \
    jsonrpc/jsontypes.cpp \
    jsonrpc/jsonrpcclient.cpp \
    jsonrpc/devicehandler.cpp \
    jsonrpc/jsonhandler.cpp \
    jsonrpc/actionhandler.cpp \
    jsonrpc/eventhandler.cpp \
    jsonrpc/logginghandler.cpp \
    jsonrpc/networkmanagerhandler.cpp \
    jsonrpc/configurationhandler.cpp

target.path = /usr/bin
INSTALLS += target
