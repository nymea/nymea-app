TARGET = testsigv4

include(../../../config.pri)
INCLUDEPATH += $$top_srcdir/libnymea-app-core
LIBS += -L$$top_builddir/libnymea-app-core/ -lnymea-app-core

QT += testlib network sql
CONFIG += testcase

DEFINES += TESTDATADIR=\\\"$${PWD}\/aws-sig-v4-test-suite\\\"

SOURCES += testsigv4.cpp
