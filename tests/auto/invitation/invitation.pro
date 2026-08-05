TEMPLATE = app
TARGET = tst_invitation

QT += core testlib
QT -= gui
CONFIG += testcase console
CONFIG -= app_bundle

INCLUDEPATH += ../../../libnymea-app

SOURCES += tst_invitation.cpp \
    ../../../libnymea-app/connection/invitation.cpp

HEADERS += ../../../libnymea-app/connection/invitation.h
