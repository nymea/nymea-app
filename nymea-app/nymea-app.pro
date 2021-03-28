TEMPLATE=app
TARGET=nymea-app
include(../config.pri)

CONFIG += link_pkgconfig

QT += network qml quick quickcontrols2 svg websockets bluetooth charts gui-private nfc

INCLUDEPATH += $$top_srcdir/libnymea-app
LIBS += -L$$top_builddir/libnymea-app/ -lnymea-app

win32:Debug:LIBS += -L$$top_builddir/libnymea-app/debug
win32:Release:LIBS += -L$$top_builddir/libnymea-app/release
win32:CXX_FLAGS += /w

linux:!android:!nozeroconf:LIBS += -lavahi-client -lavahi-common
PRE_TARGETDEPS += ../libnymea-app
linux:!android:PRE_TARGETDEPS += $$top_builddir/libnymea-app/libnymea-app.a

HEADERS += \
    mainmenumodel.h \
    nfchelper.h \
    nfcthingactionwriter.h \
    platformintegration/generic/screenhelper.h \
    platformintegration/ubports/platformhelperubports.h \
    stylecontroller.h \
    pushnotifications.h \
    platformhelper.h \
    platformintegration/generic/platformhelpergeneric.h \
    ruletemplates/messages.h

SOURCES += main.cpp \
    mainmenumodel.cpp \
    nfchelper.cpp \
    nfcthingactionwriter.cpp \
    platformintegration/generic/screenhelper.cpp \
    platformintegration/ubports/platformhelperubports.cpp \
    stylecontroller.cpp \
    pushnotifications.cpp \
    platformhelper.cpp \
    platformintegration/generic/platformhelpergeneric.cpp \

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
    include(../3rdParty/android/android_openssl/openssl.pri)

    QT += androidextras webview
    HEADERS += platformintegration/android/platformhelperandroid.h
    SOURCES += platformintegration/android/platformhelperandroid.cpp

    # https://bugreports.qt.io/browse/QTBUG-83165
    LIBS += -L$${top_builddir}/libnymea-app/$${ANDROID_TARGET_ARCH}
    PRE_TARGETDEPS += $$top_builddir/libnymea-app/$${ANDROID_TARGET_ARCH}/libnymea-app.a

    QMAKE_POST_LINK += $$QMAKE_COPY $$shell_path($$top_srcdir/version.txt) $$shell_path($$top_builddir/)

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
        INCLUDEPATH += $${top_srcdir}/3rdParty/android/firebase_cpp_sdk/include
        LIBS += -L$${top_srcdir}/3rdParty/android/firebase_cpp_sdk/libs/android/$$ANDROID_TARGET_ARCH/c++/ -lfirebase_messaging -lfirebase_app
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
    OBJECTIVE_SOURCES += $$PWD/../packaging/ios/platformhelperios.mm \
                         $$PWD/../packaging/ios/pushnotifications.mm \

# Firebase CPP SDK
#    QMAKE_LFLAGS += -ObjC $(inherited)
#    INCLUDEPATH += /Users/micha/Downloads/firebase_cpp_sdk/include/
#    LIBS += -F/Users/micha/Downloads/firebase_cpp_sdk/libs/ios/arm64/
#    LIBS += -ObjC -L/Users/micha/Downloads/firebase_cpp_sdk/libs/ios/arm64/ -lfirebase_messaging -lfirebase_app
#    LIBS += -framework "FirebaseCore"

    # Add Firebase SDK
    QMAKE_LFLAGS += -ObjC $(inherited)
    firebase_files.files += $$files(../packaging/ios/GoogleService-Info.plist)
    QMAKE_BUNDLE_DATA += firebase_files
    INCLUDEPATH += ../3rdParty/ios/
    LIBS += -F$$PWD/../3rdParty/ios/Firebase/FirebaseAnalytics/ \
            -F$$PWD/../3rdParty/ios/Firebase/FirebaseMessaging
    LIBS += -framework "FirebaseMessaging" \
            -framework "GoogleUtilities" \
            -framework "Protobuf" \
            -framework "FirebaseCore" \
            -framework "FirebaseInstanceID" \
            -framework "FirebaseInstallations" \
            -framework "PromisesObjC" \


    QMAKE_TARGET_BUNDLE_PREFIX = io.guh
    QMAKE_BUNDLE = nymeaApp
    # Configure generated xcode project to have our bundle id
    xcode_product_bundle_identifier_setting.value = $${QMAKE_TARGET_BUNDLE_PREFIX}.$${QMAKE_BUNDLE}
    plist.input = ../packaging/ios/Info.plist.in
    plist.output = $$OUT_PWD/Info.plist
    QMAKE_SUBSTITUTES += plist
    QMAKE_INFO_PLIST = $$OUT_PWD/Info.plist
    OTHER_FILES += ../packaging/ios/Info.plist.in \
                   ../packaging/ios/pushnotifications.entitlements \
                   ../packaging/ios/GoogleService-Info.plist

    QMAKE_ASSET_CATALOGS += ../packaging/ios/Assets.xcassets

    ios_launch_images.files += ../packaging/ios/NymeaLaunchScreen.storyboard
    QMAKE_BUNDLE_DATA += ios_launch_images

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

