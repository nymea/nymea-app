TEMPLATE=app
include(../shared.pri)

TARGET=$${APPLICATION_NAME}

CONFIG += link_pkgconfig

QT += network qml quick quickcontrols2 svg websockets bluetooth charts gui-private nfc
!ubports: QT += webview

INCLUDEPATH += $$top_srcdir/libnymea-app
LIBS += -L$$top_builddir/libnymea-app/ -lnymea-app

win32:Debug:LIBS += -L$$top_builddir/libnymea-app/debug
win32:Release:LIBS += -L$$top_builddir/libnymea-app/release
win32:CXX_FLAGS += /w

linux:!android:!nozeroconf:LIBS += -lavahi-client -lavahi-common
PRE_TARGETDEPS += ../libnymea-app
linux:!android:PRE_TARGETDEPS += $$top_builddir/libnymea-app/libnymea-app.a

HEADERS += \
    configuredhostsmodel.h \
    dashboard/dashboarditem.h \
    dashboard/dashboardmodel.h \
    mouseobserver.h \
    nfchelper.h \
    nfcthingactionwriter.h \
    platformintegration/generic/screenhelper.h \
    stylecontroller.h \
    pushnotifications.h \
    platformhelper.h \
    ruletemplates/messages.h

SOURCES += main.cpp \
    configuredhostsmodel.cpp \
    dashboard/dashboarditem.cpp \
    dashboard/dashboardmodel.cpp \
    mouseobserver.cpp \
    nfchelper.cpp \
    nfcthingactionwriter.cpp \
    stylecontroller.cpp \
    pushnotifications.cpp \
    platformhelper.cpp \
    platformintegration/generic/screenhelper.cpp

RESOURCES += resources.qrc \
    ruletemplates.qrc \
    images.qrc \
    translations.qrc \

linux:!android:!ubports: {
    HEADERS += platformintegration/generic/platformhelpergeneric.h
    SOURCES += platformintegration/generic/platformhelpergeneric.cpp
}


!equals(OVERLAY_PATH, "") {
    message("Resource overlay enabled. Will be using overlay from $${OVERLAY_PATH}")
    RESOURCES += $${OVERLAY_PATH}/overlay.qrc

    exists($${OVERLAY_PATH}/src/src.pri) {
        message("Including sources from overlay")
        include($${OVERLAY_PATH}/src/src.pri)
        DEFINES += OVERLAY_QMLTYPES=\\\"$${OVERLAY_PATH}/src/qmltypes.h\\\"
    }
} else {
    RESOURCES += styles.qrc
}

android {
    include(../3rdParty/android/android_openssl/openssl.pri)

    ANDROID_MIN_SDK_VERSION = 21
    ANDROID_TARGET_SDK_VERSION = 30

    QT += androidextras
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
    HEADERS += platformintegration/generic/platformhelpergeneric.h
    SOURCES += platformintegration/generic/platformhelpergeneric.cpp

    PRODUCT_NAME=$$TARGET

    QMAKE_TARGET_BUNDLE_PREFIX = io.nymea
    QMAKE_BUNDLE = nymeaApp.mac

    plist.input = $${MACX_PACKAGE_DIR}/Info.plist.in
    plist.output = $$OUT_PWD/Info.plist
    QMAKE_SUBSTITUTES += plist
    QMAKE_INFO_PLIST = $$OUT_PWD/Info.plist
    OTHER_FILES += $${MACX_PACKAGE_DIR}/Info.plist.in \
                   $${MACX_PACKAGE_DIR}/$${APPLICATION_NAME}.entitlements

    ICON = $${MACX_PACKAGE_DIR}/AppIcon.icns

    OSX_ENTITLEMENTS.name = CODE_SIGN_ENTITLEMENTS
    OSX_ENTITLEMENTS.value = $$files($${MACX_PACKAGE_DIR}/$${APPLICATION_NAME}.entitlements)
    QMAKE_MAC_XCODE_SETTINGS += OSX_ENTITLEMENTS
}

ios: {
    message("iOS build")
    HEADERS += platformintegration/ios/platformhelperios.h
    SOURCES += platformintegration/ios/platformhelperios.cpp
    OBJECTIVE_SOURCES += $${IOS_PACKAGE_DIR}/platformhelperios.mm \
                         $${IOS_PACKAGE_DIR}/pushnotifications.mm \

    OTHER_FILES += $${OBJECTIVE_SOURCES}

    # Add Firebase SDK
    QMAKE_LFLAGS += -ObjC $(inherited)
    firebase_files.files += $$files($${IOS_PACKAGE_DIR}/GoogleService-Info.plist)
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


    # Configure generated xcode project to have our bundle id
    QMAKE_TARGET_BUNDLE_PREFIX=$${IOS_BUNDLE_PREFIX}
    QMAKE_BUNDLE=$${IOS_BUNDLE_NAME}
    plist.input = $${IOS_PACKAGE_DIR}/Info.plist.in
    plist.output = $$OUT_PWD/Info.plist
    QMAKE_SUBSTITUTES += plist
    QMAKE_INFO_PLIST = $$OUT_PWD/Info.plist
    OTHER_FILES += $${IOS_PACKAGE_DIR}/Info.plist.in \
                   $${IOS_PACKAGE_DIR}/pushnotifications.entitlements \
                   $${IOS_PACKAGE_DIR}/GoogleService-Info.plist

    QMAKE_ASSET_CATALOGS += $${IOS_PACKAGE_DIR}/Assets.xcassets

    ios_launch_images.files += $${IOS_PACKAGE_DIR}/NymeaLaunchScreen.storyboard
    QMAKE_BUNDLE_DATA += ios_launch_images

    IOS_DEVELOPMENT_TEAM.name = DEVELOPMENT_TEAM
    IOS_DEVELOPMENT_TEAM.value = Z45PLKLTHM
    QMAKE_MAC_XCODE_SETTINGS += IOS_DEVELOPMENT_TEAM

    IOS_ENTITLEMENTS.name = CODE_SIGN_ENTITLEMENTS
    IOS_ENTITLEMENTS.value = $$files($${IOS_PACKAGE_DIR}/pushnotifications.entitlements)
    QMAKE_MAC_XCODE_SETTINGS += IOS_ENTITLEMENTS
}

ubports: {
    DEFINES += UBPORTS

    CONFIG += link_pkgconfig
    PKGCONFIG += connectivity-qt1

    HEADERS += platformintegration/ubports/pushclient.h \
               platformintegration/ubports/platformhelperubports.h \

    SOURCES += platformintegration/ubports/pushclient.cpp \
               platformintegration/ubports/platformhelperubports.cpp \
}

win32 {
    HEADERS += platformintegration/generic/platformhelpergeneric.h
    SOURCES += platformintegration/generic/platformhelpergeneric.cpp

    equals(OVERLAY_PATH, "") {
        win32:RCC_ICONS += ../packaging/windows/packages/io.nymea.nymeaapp/meta/logo.ico
    } else {
        win32:RCC_ICONS += $${OVERLAY_PATH}/packaging/windows/packages/io.guh.$${BR}/meta/logo.ico
    }
}

target.path = /usr/bin
INSTALLS += target

