TEMPLATE=app
TARGET=nymea-app
include(../config.pri)

QT += network qml quick quickcontrols2 svg websockets bluetooth

INCLUDEPATH += $$top_srcdir/libnymea-common \
               $$top_srcdir/libnymea-app-core
LIBS += -L$$top_builddir/libnymea-app-core/ -lnymea-app-core \
        -L$$top_builddir/libnymea-common/ -lnymea-common \

win32:Debug:LIBS += -L$$top_builddir/libnymea-app-core/debug \
                    -L$$top_builddir/libnymea-common/debug
win32:Release:LIBS += -L$$top_builddir/libnymea-app-core/release \
                      -L$$top_builddir/libnymea-common/release
linux:!android:LIBS += -lavahi-client -lavahi-common
PRE_TARGETDEPS += ../libnymea-app-core ../libnymea-common

HEADERS += \
    stylecontroller.h

SOURCES += main.cpp \
    stylecontroller.cpp

OTHER_FILES += $$files(*.qml, true)

RESOURCES += resources.qrc
equals(STYLES_PATH, "") {
    RESOURCES += styles.qrc
} else {
    message("Style override enabled. Will be using styles from $${STYLES_PATH}")
    RESOURCES += $${STYLES_PATH}/styles.qrc
}

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_EXTRA_LIBS = \
        /opt/android-openssl/prebuilt/armeabi-v7a/libcrypto.so \
        /opt/android-openssl/prebuilt/armeabi-v7a/libssl.so
}

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/../packaging/android

    QT += androidextras

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

macx: {
    PRODUCT_NAME=$$TARGET
    plist.input = ../packaging/osx/Info.plist.in
    plist.output = $$OUT_PWD/Info.plist
    QMAKE_SUBSTITUTES += plist
    QMAKE_INFO_PLIST = $$OUT_PWD/Info.plist
    OTHER_FILES += ../packaging/osx/Info.plist.in
    ICON = ../packaging/osx/icon.icns
}

ios: {
    message("iOS build")
    QMAKE_TARGET_BUNDLE_PREFIX = io.guh
    QMAKE_BUNDLE = nymeaApp
    # Configure generated xcode project to have our bundle id
    xcode_product_bundle_identifier_setting.value = $${QMAKE_TARGET_BUNDLE_PREFIX}.$${QMAKE_BUNDLE}
    QMAKE_ASSET_CATALOGS += ../packaging/ios/AppIcons.xcassets
    plist.input = ../packaging/ios/Info.plist.in
    plist.output = $$OUT_PWD/Info.plist
    QMAKE_SUBSTITUTES += plist
    QMAKE_INFO_PLIST = $$OUT_PWD/Info.plist
    OTHER_FILES += ../packaging/ios/Info.plist.in

    ios_icon_files.files += $$files(../packaging/ios/AppIcon*.png)
    ios_launch_images.files += $$files(../packaging/ios/LaunchImage*.png) ../packaging/ios/LaunchScreen1.xib
    QMAKE_BUNDLE_DATA += ios_icon_files ios_launch_images
}

BR=$$BRANDING
!equals(BR, "") {
    DEFINES += BRANDING=\\\"$${BR}\\\"
    win32:RCC_ICONS += ../packaging/windows_$${BR}/packages/io.guh.$${BR}/meta/logo.ico
} else {
    win32:RCC_ICONS += ../packaging/windows/packages/io.guh.nymeaapp/meta/logo.ico
}

target.path = /usr/bin
INSTALLS += target
