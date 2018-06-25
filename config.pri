CONFIG += c++11
#DEFINES += QT_DEPRECATED_WARNINGS
QMAKE_CXXFLAGS += -Wall

top_srcdir=$$PWD
top_builddir=$$shadowed($$PWD)

APP_VERSION=$$cat(version.txt)
DEFINES+=APP_VERSION=\\\"$${APP_VERSION}\\\"
android:QMAKE_POST_LINK += cp $$top_srcdir/version.txt $$top_builddir/
