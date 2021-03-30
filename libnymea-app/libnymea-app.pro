TARGET = nymea-app
TEMPLATE = lib
CONFIG += staticlib

include(../shared.pri)
include(libnymea-app.pri)

LIBS += -lssl -lcrypto
