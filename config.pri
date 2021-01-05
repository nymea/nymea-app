CONFIG += c++11

# We want -Wall to keep the code clean and tidy, however:
# On Windows, -Wall goes mental, so not using it there
# As of Qt 5.15, lots of things are deprecated inside Qt in preparation for Qt6 but no replacement to actually fix those yet.
!win32:QMAKE_CXXFLAGS += -Wall -Wno-deprecated-declarations -Wno-deprecated-copy

top_srcdir=$$PWD
top_builddir=$$shadowed($$PWD)

VERSION_INFO=$$cat(version.txt)
APP_VERSION=$$member(VERSION_INFO, 0)
APP_REVISION=$$member(VERSION_INFO, 1)

DEFINES+=APP_VERSION=\\\"$${APP_VERSION}\\\"

android: {
    QMAKE_POST_LINK += cp $$top_srcdir/version.txt $$top_builddir/

    !equals(OVERLAY_PATH, ""):!equals(BRANDING, "") {
        ANDROID_PACKAGE_SOURCE_DIR = $${OVERLAY_PATH}/packaging/android_$$BRANDING
    } else {
        ANDROID_PACKAGE_SOURCE_DIR = $${top_srcdir}/packaging/android
    }

    !no-firebase:DEFINES+=WITH_FIREBASE
}

ios: {
    !no-firebase:DEFINES+=WITH_FIREBASE
}
