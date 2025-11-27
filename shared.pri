CONFIG *= c++14
QMAKE_LFLAGS *= -std=c++14
QMAKE_CXXFLAGS *= -std=c++14

top_srcdir=$$PWD
top_builddir=$$shadowed($$PWD)

# Read version info from version.txt
VERSION_INFO=$$cat(version.txt)
APP_VERSION=$$member(VERSION_INFO, 0)
APP_REVISION=$$member(VERSION_INFO, 1)

equals(OVERLAY_PATH, "") {
    include(config.pri)
    PACKAGE_BASE_DIR = $$shell_path($$PWD/packaging)
} else {
    message("Overlay enabled. Using overlay from $${OVERLAY_PATH}")
    include($${OVERLAY_PATH}/overlay-config.pri)
    PACKAGE_BASE_DIR = $$shell_path($${OVERLAY_PACKAGE_DIR})
}

QMAKE_SUBSTITUTES += $${top_srcdir}/config.h.in
INCLUDEPATH += $${top_builddir}

# We want -Wall to keep the code clean and tidy, however:
# On Windows, -Wall goes mental, so not using it there
!win32:QMAKE_CXXFLAGS += -Wall

# As of Qt 5.15, lots of things are deprecated inside Qt in preparation for Qt6 but no replacement to actually fix those yet.
linux:!android {
    QMAKE_CXXFLAGS += -Wno-deprecated-declarations -Wno-deprecated-copy
}

android: {
    QMAKE_CXXFLAGS += -Wno-deprecated-declarations
    QMAKE_LFLAGS *= "-Wl,-z,max-page-size=16384"

    ANDROID_PACKAGE_SOURCE_DIR = $${PACKAGE_BASE_DIR}/android
    message("Android package directory: $${ANDROID_PACKAGE_SOURCE_DIR}")

    !no-firebase:DEFINES+=WITH_FIREBASE
}

ios: {
    !no-firebase:DEFINES+=WITH_FIREBASE
    IOS_PACKAGE_DIR = $${PACKAGE_BASE_DIR}/ios/
}

macx: {
    MACX_PACKAGE_DIR = $${PACKAGE_BASE_DIR}/osx/
}

win32: {
    WIN_PACKAGE_DIR = $${PACKAGE_BASE_DIR}\windows
}
