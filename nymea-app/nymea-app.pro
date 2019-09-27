TEMPLATE=app
TARGET=nymea-app
include(../config.pri)

QT += network qml quick quickcontrols2 svg websockets bluetooth charts gui-private

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
    platformintegration/generic/raspberrypihelper.h \
    stylecontroller.h \
    pushnotifications.h \
    platformhelper.h \
    platformintegration/generic/platformhelpergeneric.h \
    applogcontroller.h \
    ruletemplates/messages.h

SOURCES += main.cpp \
    platformintegration/generic/raspberrypihelper.cpp \
    stylecontroller.cpp \
    pushnotifications.cpp \
    platformhelper.cpp \
    platformintegration/generic/platformhelpergeneric.cpp \
    applogcontroller.cpp

RESOURCES += resources.qrc \
    ruletemplates.qrc \
    images.qrc \
    translations.qrc
equals(STYLES_PATH, "") {
    RESOURCES += styles.qrc
} else {
    message("Style override enabled. Will be using styles from $${STYLES_PATH}")
    RESOURCES += $${STYLES_PATH}/styles.qrc
}

win32 {
    QT += webview
}

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/../packaging/android

    android-clang {
        FIREBASE_STL_VARIANT = c++
    }

    isEmpty(FIREBASE_STL_VARIANT){
        FIREBASE_STL_VARIANT = gnustl
    }

    include(../android_openssl/openssl.pri)

    INCLUDEPATH += /opt/firebase_cpp_sdk/include
    LIBS += -L/opt/firebase_cpp_sdk/libs/android/$$ANDROID_TARGET_ARCH/$$FIREBASE_STL_VARIANT/ -lfirebase_messaging -lfirebase_app

    QT += androidextras webview
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

}

macx: {
    QT += webview
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
    QT += webview
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

BR=$$BRANDING
!equals(BR, "") {
    DEFINES += BRANDING=\\\"$${BR}\\\"
    win32:RCC_ICONS += ../packaging/windows_$${BR}/packages/io.guh.$${BR}/meta/logo.ico
} else {
    win32:RCC_ICONS += ../packaging/windows/packages/io.guh.nymeaapp/meta/logo.ico
}

target.path = /usr/bin
INSTALLS += target
