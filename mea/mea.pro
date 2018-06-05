TEMPLATE=app
TARGET=mea
include(../mea.pri)

QT += qml quick quickcontrols2 svg websockets bluetooth

INCLUDEPATH += $$top_srcdir/libnymea-common \
               $$top_srcdir/libmea-core
LIBS += -L$$top_builddir/libmea-core/ -lmea-core \
        -L$$top_builddir/libnymea-common/ -lnymea-common
win32:Debug:LIBS += -L$$top_builddir/libmea-core/debug \
                    -L$$top_builddir/libnymea-common/debug
win32:Release:LIBS += -L$$top_builddir/libmea-core/release \
                      -L$$top_builddir/libnymea-common/release
linux:!android:LIBS += -lavahi-client -lavahi-common
PRE_TARGETDEPS += ../libmea-core
HEADERS += \
    stylecontroller.h

SOURCES += main.cpp \
    stylecontroller.cpp


RESOURCES += \
    resources.qrc

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_EXTRA_LIBS = \
        /opt/android-openssl/prebuilt/armeabi-v7a/libcrypto.so \
        /opt/android-openssl/prebuilt/armeabi-v7a/libssl.so
}

android {
ANDROID_PACKAGE_SOURCE_DIR = $$PWD/../packaging/android

DISTFILES += \
    $$ANDROID_PACKAGE_SOURCE_DIR/AndroidManifest.xml \
    $$ANDROID_PACKAGE_SOURCE_DIR/gradle/wrapper/gradle-wrapper.jar \
    $$ANDROID_PACKAGE_SOURCE_DIR/gradlew \
    $$ANDROID_PACKAGE_SOURCE_DIR/res/values/libs.xml \
    $$ANDROID_PACKAGE_SOURCE_DIR/build.gradle \
    $$ANDROID_PACKAGE_SOURCE_DIR/gradle/wrapper/gradle-wrapper.properties \
    $$ANDROID_PACKAGE_SOURCE_DIR/gradlew.bat \
    $$ANDROID_PACKAGE_SOURCE_DIR/LICENSE
}

BR=$$BRANDING
!equals(BR, "") {
    DEFINES += BRANDING=\\\"$${BR}\\\"
    win32:RCC_ICONS += ../packaging/windows_$${BR}/packages/io.guh.$${BR}/meta/logo.ico
} else {
    win32:RCC_ICONS += ../packaging/windows/packages/io.guh.mea/meta/logo.ico
}

withavahi: {
    LIBS += -lavahi-client -lavahi-common
}

target.path = /usr/bin
INSTALLS += target
