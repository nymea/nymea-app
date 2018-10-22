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
    stylecontroller.h \
    pushnotifications.h \
    platformhelper.h \
    platformintegration/generic/platformhelpergeneric.h \

SOURCES += main.cpp \
    stylecontroller.cpp \
    pushnotifications.cpp \
    platformhelper.cpp \
    platformintegration/generic/platformhelpergeneric.cpp \

RESOURCES += resources.qrc \
    ruletemplates.qrc \
    images.qrc
equals(STYLES_PATH, "") {
    RESOURCES += styles.qrc
} else {
    message("Style override enabled. Will be using styles from $${STYLES_PATH}")
    RESOURCES += $${STYLES_PATH}/styles.qrc
}

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/../packaging/android

    INCLUDEPATH += /opt/firebase_cpp_sdk/include
    LIBS += -L/opt/firebase_cpp_sdk/libs/android/armeabi-v7a/gnustl/ -lfirebase_messaging -lfirebase_app

    QT += androidextras
    HEADERS += platformintegration/android/platformhelperandroid.h
    SOURCES += platformintegration/android/platformhelperandroid.cpp

    DISTFILES += \
        $$ANDROID_PACKAGE_SOURCE_DIR/AndroidManifest.xml \
        $$ANDROID_PACKAGE_SOURCE_DIR/google-services.json \
        $$ANDROID_PACKAGE_SOURCE_DIR/gradle/wrapper/gradle-wrapper.jar \
        $$ANDROID_PACKAGE_SOURCE_DIR/gradlew \
        $$ANDROID_PACKAGE_SOURCE_DIR/res/values/libs.xml \
        $$ANDROID_PACKAGE_SOURCE_DIR/build.gradle \
        $$ANDROID_PACKAGE_SOURCE_DIR/gradle/wrapper/gradle-wrapper.properties \
        $$ANDROID_PACKAGE_SOURCE_DIR/gradlew.bat \
        $$ANDROID_PACKAGE_SOURCE_DIR/src/io/guh/nymeaapp/NymeaAppActivity.java \
        $$ANDROID_PACKAGE_SOURCE_DIR/src/io/guh/nymeaapp/NymeaAppNotificationService.java \
        $$ANDROID_PACKAGE_SOURCE_DIR/LICENSE


    ANDROID_EXTRA_LIBS = \
        /opt/android-openssl/prebuilt/armeabi-v7a/libcrypto.so \
        /opt/android-openssl/prebuilt/armeabi-v7a/libssl.so
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
    HEADERS += platformintegration/ios/platformhelperios.h
    SOURCES += platformintegration/ios/platformhelperios.cpp
    OBJECTIVE_SOURCES += $$PWD/../packaging/ios/pushnotifications.mm \
                         $$PWD/../packaging/ios/platformhelperios.mm

    QMAKE_TARGET_BUNDLE_PREFIX = io.guh
    QMAKE_BUNDLE = nymeaApp
    # Configure generated xcode project to have our bundle id
    xcode_product_bundle_identifier_setting.value = $${QMAKE_TARGET_BUNDLE_PREFIX}.$${QMAKE_BUNDLE}
    QMAKE_ASSET_CATALOGS += ../packaging/ios/AppIcons.xcassets
    plist.input = ../packaging/ios/Info.plist.in
    plist.output = $$OUT_PWD/Info.plist
    QMAKE_SUBSTITUTES += plist
    QMAKE_INFO_PLIST = $$OUT_PWD/Info.plist
    OTHER_FILES += ../packaging/ios/Info.plist.in \
                   ../packaging/ios/pushnotifications.entitlements

    ios_icon_files.files += $$files(../packaging/ios/AppIcon*.png)
    ios_launch_images.files += $$files(../packaging/ios/LaunchImage*.png) ../packaging/ios/LaunchScreen1.xib
    QMAKE_BUNDLE_DATA += ios_icon_files ios_launch_images

    IOS_DEVELOPMENT_TEAM.name = DEVELOPMENT_TEAM
    IOS_DEVELOPMENT_TEAM.value = Z45PLKLTHM
    QMAKE_MAC_XCODE_SETTINGS += IOS_DEVELOPMENT_TEAM

    IOS_ENTITLEMENTS.name = CODE_SIGN_ENTITLEMENTS
    IOS_ENTITLEMENTS.value = $$files($$PWD/../packaging/ios/pushnotifications.entitlements)
    QMAKE_MAC_XCODE_SETTINGS += IOS_ENTITLEMENTS
}

ubuntu_files.path += /
ubuntu_files.files += ../manifest.json ../nymea-app.apparmor ../nymea-app.desktop ../packaging/android/appicon.svg
INSTALLS += ubuntu_files

BR=$$BRANDING
!equals(BR, "") {
    DEFINES += BRANDING=\\\"$${BR}\\\"
    win32:RCC_ICONS += ../packaging/windows_$${BR}/packages/io.guh.$${BR}/meta/logo.ico
} else {
    win32:RCC_ICONS += ../packaging/windows/packages/io.guh.nymeaapp/meta/logo.ico
}

target.path = /usr/bin
INSTALLS += target

