TEMPLATE=app
TARGET=nymea-app
include(../config.pri)

QT += network qml quick quickcontrols2 svg websockets bluetooth charts gui-private nfc

INCLUDEPATH += $$top_srcdir/libnymea-app
LIBS += -L$$top_builddir/libnymea-app/ -lnymea-app

win32:Debug:LIBS += -L$$top_builddir/libnymea-app/debug
win32:Release:LIBS += -L$$top_builddir/libnymea-app/release
linux:!android:!nozeroconf:LIBS += -lavahi-client -lavahi-common
PRE_TARGETDEPS += ../libnymea-app

HEADERS += \
    mainmenumodel.h \
    nfchelper.h \
    nfcthingactionwriter.h \
    platformintegration/generic/raspberrypihelper.h \
    stylecontroller.h \
    pushnotifications.h \
    platformhelper.h \
    platformintegration/generic/platformhelpergeneric.h \
    applogcontroller.h \
    ruletemplates/messages.h

SOURCES += main.cpp \
    mainmenumodel.cpp \
    nfchelper.cpp \
    nfcthingactionwriter.cpp \
    platformintegration/generic/raspberrypihelper.cpp \
    stylecontroller.cpp \
    pushnotifications.cpp \
    platformhelper.cpp \
    platformintegration/generic/platformhelpergeneric.cpp \
    applogcontroller.cpp

RESOURCES += resources.qrc \
    ruletemplates.qrc \
    images.qrc \
    translations.qrc \
    styles.qrc

!equals(OVERLAY_PATH, "") {
    message("Resource overlay enabled. Will be using overlay from $${OVERLAY_PATH}")
    RESOURCES += $${OVERLAY_PATH}/overlay.qrc
}

win32 {
    QT += webview
}

android {

    include(../android_openssl/openssl.pri)

    QT += androidextras webview
    HEADERS += platformintegration/android/platformhelperandroid.h
    SOURCES += platformintegration/android/platformhelperandroid.cpp

    # https://bugreports.qt.io/browse/QTBUG-83165
    LIBS += -L$${top_builddir}/libnymea-app/$${ANDROID_TARGET_ARCH}

    DISTFILES += \
        $$ANDROID_PACKAGE_SOURCE_DIR/AndroidManifest.xml \
        $$ANDROID_PACKAGE_SOURCE_DIR/google-services.json \
        $$ANDROID_PACKAGE_SOURCE_DIR/gradle/wrapper/gradle-wrapper.jar \
        $$ANDROID_PACKAGE_SOURCE_DIR/gradlew \
        $$ANDROID_PACKAGE_SOURCE_DIR/res/values/libs.xml \
        $$ANDROID_PACKAGE_SOURCE_DIR/build.gradle \
        $$ANDROID_PACKAGE_SOURCE_DIR/gradle/wrapper/gradle-wrapper.properties \
        $$ANDROID_PACKAGE_SOURCE_DIR/gradlew.bat \
        $$ANDROID_PACKAGE_SOURCE_DIR/LICENSE \
        platformintegration/android/java/io/guh/nymeaapp/NymeaAppActivity.java \
        platformintegration/android/java-firebase/io/guh/nymeaapp/NymeaAppNotificationService.java \

    !no-firebase: {
        android-clang {
            FIREBASE_STL_VARIANT = c++
        }
        isEmpty(FIREBASE_STL_VARIANT){
            FIREBASE_STL_VARIANT = gnustl
        }
        INCLUDEPATH += /opt/firebase_cpp_sdk/include
        LIBS += -L/opt/firebase_cpp_sdk/libs/android/$$ANDROID_TARGET_ARCH/$$FIREBASE_STL_VARIANT/ -lfirebase_messaging -lfirebase_app
    }

}

macx: {
    QT += webview
    PRODUCT_NAME=$$TARGET

    QMAKE_TARGET_BUNDLE_PREFIX = io.nymea
    QMAKE_BUNDLE = nymeaApp.mac

    plist.input = ../packaging/osx/Info.plist.in
    plist.output = $$OUT_PWD/Info.plist
    QMAKE_SUBSTITUTES += plist
    QMAKE_INFO_PLIST = $$OUT_PWD/Info.plist
    OTHER_FILES += ../packaging/osx/Info.plist.in \
                   ../packaging/osx/nymea-app.entitlements

    ICON = ../packaging/osx/AppIcon.icns

    OSX_ENTITLEMENTS.name = CODE_SIGN_ENTITLEMENTS
    OSX_ENTITLEMENTS.value = $$files($$PWD/../packaging/ios/nymea-app.entitlements)
    QMAKE_MAC_XCODE_SETTINGS += OSX_ENTITLEMENTS
}

ios: {
    message("iOS build")
    QT += webview
    HEADERS += platformintegration/ios/platformhelperios.h
    SOURCES += platformintegration/ios/platformhelperios.cpp
    OBJECTIVE_SOURCES += $$PWD/../packaging/ios/pushnotifications.mm \
                         $$PWD/../packaging/ios/platformhelperios.mm

    LIBS += -framework "UserNotifications"

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

    ios_icon_files.files += $$files(../packaging/ios/AppIcons.xcassets/AppIcon.appiconset/AppIcon*.png)
    ios_launch_images.files += $$files(../packaging/ios/LaunchImage*.png) ../packaging/ios/LaunchScreen1.xib
    QMAKE_BUNDLE_DATA += ios_icon_files ios_launch_images

    IOS_DEVELOPMENT_TEAM.name = DEVELOPMENT_TEAM
    IOS_DEVELOPMENT_TEAM.value = Z45PLKLTHM
    QMAKE_MAC_XCODE_SETTINGS += IOS_DEVELOPMENT_TEAM

    IOS_ENTITLEMENTS.name = CODE_SIGN_ENTITLEMENTS
    IOS_ENTITLEMENTS.value = $$files($$PWD/../packaging/ios/pushnotifications.entitlements)
    QMAKE_MAC_XCODE_SETTINGS += IOS_ENTITLEMENTS
}

ubports: {
    DEFINES += UBPORTS

    CONFIG += link_pkgconfig
    PKGCONFIG += connectivity-qt1

    HEADERS += platformintegration/ubports/pushclient.h

    SOURCES += platformintegration/ubports/pushclient.cpp
}

BR=$$BRANDING
!equals(BR, "") {
    message("Branding the style to: $${BR}")
    DEFINES += BRANDING=\\\"$${BR}\\\"
    win32:RCC_ICONS += ../packaging/windows_$${BR}/packages/io.guh.$${BR}/meta/logo.ico
} else {
    win32:RCC_ICONS += ../packaging/windows/packages/io.guh.nymeaapp/meta/logo.ico
}

target.path = /usr/bin
INSTALLS += target

ANDROID_ABIS = armeabi-v7a arm64-v8a

