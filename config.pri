CONFIG += c++11
#DEFINES += QT_DEPRECATED_WARNINGS
QMAKE_CXXFLAGS += -Wall

top_srcdir=$$PWD
top_builddir=$$shadowed($$PWD)

VERSION_INFO=$$cat(version.txt)
APP_VERSION=$$member(VERSION_INFO, 0)
APP_REVISION=$$member(VERSION_INFO, 1)
message("APP_VERSION: $${APP_VERSION} ($${APP_REVISION})")

DEFINES+=APP_VERSION=\\\"$${APP_VERSION}\\\"
android:QMAKE_POST_LINK += cp $$top_srcdir/version.txt $$top_builddir/
