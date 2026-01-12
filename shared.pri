greaterThan(QT_MAJOR_VERSION, 5) {
    message("Building using Qt6 support")
    CONFIG *= c++17
    QMAKE_LFLAGS *= -std=c++17
    QMAKE_CXXFLAGS *= -std=c++17
} else {
    message("Building using Qt5 support")
    CONFIG *= c++14
    QMAKE_LFLAGS *= -std=c++14
    QMAKE_CXXFLAGS *= -std=c++14
    DEFINES += QT_DISABLE_DEPRECATED_UP_TO=0x050F00
}

win32-msvc {
    QMAKE_CXXFLAGS += /WX
    QMAKE_CXXFLAGS += /wd4996
} else {
    QMAKE_CXXFLAGS += -Werror
    QMAKE_CXXFLAGS += -Wno-deprecated-declarations
    QMAKE_CXXFLAGS += -Wno-deprecated-copy
}

# This warning group is not available on older clang version.
# When building with Qt >= 6.10.x -Wno-unknown-warning-option
# this seems not to work with the available clang versions (Android/Windows).
# Disable this warning group until this is fixed with the shiped clang version:
# https://github.com/llvm/llvm-project/issues/163719
contains(QMAKE_COMPILER, clang) {
    QMAKE_CXXFLAGS += -Wno-unknown-warning-option
}

QMAKE_CXXFLAGS += -g

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
