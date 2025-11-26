set(NYMEA_APP_SOURCES
    main.cpp
    configuredhostsmodel.cpp
    dashboard/dashboarditem.cpp
    dashboard/dashboardmodel.cpp
    mouseobserver.cpp
    nfchelper.cpp
    nfcthingactionwriter.cpp
    platformintegration/platformpermissions.cpp
    stylecontroller.cpp
    pushnotifications.cpp
    platformhelper.cpp
    platformintegration/generic/screenhelper.cpp
    utils/privacypolicyhelper.cpp
    utils/qhashqml.cpp
)

set(NYMEA_APP_HEADERS
    configuredhostsmodel.h
    dashboard/dashboarditem.h
    dashboard/dashboardmodel.h
    mouseobserver.h
    nfchelper.h
    nfcthingactionwriter.h
    platformintegration/generic/screenhelper.h
    platformintegration/platformpermissions.h
    stylecontroller.h
    pushnotifications.h
    platformhelper.h
    ruletemplates/messages.h
    utils/privacypolicyhelper.h
    utils/qhashqml.h
)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    list(APPEND NYMEA_APP_SOURCES
        platformintegration/generic/platformhelpergeneric.cpp
    )
    list(APPEND NYMEA_APP_HEADERS
        platformintegration/generic/platformhelpergeneric.h
    )
endif()

if(ANDROID)
    list(APPEND NYMEA_APP_SOURCES
        platformintegration/android/platformhelperandroid.cpp
        platformintegration/android/platformpermissionsandroid.cpp
    )
    list(APPEND NYMEA_APP_HEADERS
        platformintegration/android/platformhelperandroid.h
        platformintegration/android/platformpermissionsandroid.h
    )
endif()

if(IOS)
    list(APPEND NYMEA_APP_SOURCES
        platformintegration/ios/platformhelperios.cpp
        platformintegration/ios/platformpermissionsios.cpp
        platformintegration/ios/platformhelperios.mm
        platformintegration/ios/pushnotifications.mm
        platformintegration/ios/platformpermissionsios.mm
    )
    list(APPEND NYMEA_APP_HEADERS
        platformintegration/ios/platformhelperios.h
        platformintegration/ios/platformpermissionsios.h
    )
endif()

set(NYMEA_APP_RESOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/resources.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/ruletemplates.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/images.qrc
)

if(NYMEA_OVERLAY_PATH)
    message(WARNING "Overlay support is not implemented in the CMake build yet; NYMEA_OVERLAY_PATH will be ignored.")
else()
    list(APPEND NYMEA_APP_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/styles.qrc)
endif()

if(NYMEA_USE_MATERIAL_ICONS)
    list(APPEND NYMEA_APP_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/ui/icons/material/icons.qrc)
else()
    list(APPEND NYMEA_APP_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/ui/icons/suru/icons.qrc)
endif()

qt_add_executable(nymea-app
    MANUAL_FINALIZATION
    ${NYMEA_APP_SOURCES}
    ${NYMEA_APP_HEADERS}
    ${NYMEA_APP_RESOURCES}
)

target_include_directories(nymea-app
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_SOURCE_DIR}/libnymea-app
        ${CMAKE_SOURCE_DIR}/experiences/airconditioning
        ${CMAKE_BINARY_DIR}
)

target_link_libraries(nymea-app
    PRIVATE
        nymea-app-core
        nymea-app-airconditioning
        Qt6::Gui
        Qt6::Network
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::Svg
        Qt6::WebSockets
        Qt6::Bluetooth
        Qt6::Charts
        Qt6::Nfc
)

if(TARGET Qt6::WebView)
    target_link_libraries(nymea-app PRIVATE Qt6::WebView)
    target_compile_definitions(nymea-app PRIVATE HAVE_WEBVIEW)
endif()

find_package(Qt6 COMPONENTS GuiPrivate QUIET)
if(TARGET Qt6::GuiPrivate)
    target_link_libraries(nymea-app PRIVATE Qt6::GuiPrivate)
else()
    message(WARNING "Qt6::GuiPrivate not found; continuing without private GUI APIs.")
endif()

if(UNIX AND NOT APPLE AND NYMEA_ENABLE_ZEROCONF)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(AVAHI REQUIRED IMPORTED_TARGET avahi-client avahi-common)
    target_link_libraries(nymea-app PRIVATE PkgConfig::AVAHI)
endif()

if(WIN32)
    target_compile_definitions(nymea-app PRIVATE NOMINMAX)
endif()

if(ANDROID)
    if(DEFINED NYMEA_ANDROID_PACKAGE_SOURCE_DIR)
        set_property(TARGET nymea-app PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR "${NYMEA_ANDROID_PACKAGE_SOURCE_DIR}")
    endif()

    set_property(TARGET nymea-app PROPERTY QT_ANDROID_MIN_SDK_VERSION 23)
    set_property(TARGET nymea-app PROPERTY QT_ANDROID_TARGET_SDK_VERSION 35)

    if(NYMEA_ENABLE_FIREBASE)
        target_compile_definitions(nymea-app PRIVATE WITH_FIREBASE)
        target_include_directories(nymea-app PRIVATE ${CMAKE_SOURCE_DIR}/3rdParty/android/firebase_cpp_sdk/include)

        if(CMAKE_ANDROID_ARCH_ABI)
            set(_firebase_lib_dir "${CMAKE_SOURCE_DIR}/3rdParty/android/firebase_cpp_sdk/libs/android/${CMAKE_ANDROID_ARCH_ABI}/c++")
            target_link_libraries(nymea-app PRIVATE
                "${_firebase_lib_dir}/libfirebase_messaging.a"
                "${_firebase_lib_dir}/libfirebase_app.a"
            )
        else()
            message(WARNING "CMAKE_ANDROID_ARCH_ABI is not defined; Firebase static libraries could not be linked.")
        endif()
    else()
        message(STATUS "Firebase support disabled via NYMEA_ENABLE_FIREBASE option.")
    endif()
endif()

if(IOS)
    target_link_libraries(nymea-app PRIVATE
        "-framework CoreLocation"
        "-framework CoreBluetooth"
        "-framework CoreNFC"
    )

    set(_nymea_ios_plist "${CMAKE_CURRENT_BINARY_DIR}/ios/Info.plist")
    file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/ios")
    configure_file(
        ${CMAKE_SOURCE_DIR}/packaging/ios/Info.plist.cmake.in
        ${_nymea_ios_plist}
        @ONLY
    )

    set_target_properties(nymea-app PROPERTIES
        MACOSX_BUNDLE_INFO_PLIST "${_nymea_ios_plist}"
        MACOSX_BUNDLE_GUI_IDENTIFIER "io.guh.nymeaApp"
        MACOSX_BUNDLE_BUNDLE_VERSION "${APP_REVISION}"
        MACOSX_BUNDLE_SHORT_VERSION_STRING "${APP_VERSION}"
        XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS "${CMAKE_SOURCE_DIR}/packaging/ios/app.entitlements"
    )

    target_link_options(nymea-app PRIVATE "-ObjC")

    set_property(TARGET nymea-app APPEND PROPERTY
        QT_IOS_ASSET_CATALOGS "${CMAKE_SOURCE_DIR}/packaging/ios/Assets.xcassets")

    set(_nymea_ios_resources
        ${CMAKE_SOURCE_DIR}/packaging/ios/NymeaLaunchScreen.storyboard
        ${CMAKE_SOURCE_DIR}/packaging/ios/GoogleService-Info.plist
    )
    set_source_files_properties(${_nymea_ios_resources} PROPERTIES
        MACOSX_PACKAGE_LOCATION Resources)
    target_sources(nymea-app PRIVATE ${_nymea_ios_resources})

    if(NYMEA_ENABLE_FIREBASE)
        target_compile_definitions(nymea-app PRIVATE WITH_FIREBASE FIREBASE_ANALYTICS_SUPPRESS_WARNING)
        target_include_directories(nymea-app PRIVATE ${CMAKE_SOURCE_DIR}/3rdParty/ios)
        target_link_directories(nymea-app PRIVATE
            ${CMAKE_SOURCE_DIR}/3rdParty/ios/Firebase/FirebaseAnalytics
            ${CMAKE_SOURCE_DIR}/3rdParty/ios/Firebase/FirebaseMessaging
        )
        target_link_libraries(nymea-app PRIVATE
            "-framework FirebaseMessaging"
            "-framework GoogleUtilities"
            "-framework Protobuf"
            "-framework FirebaseCore"
            "-framework FirebaseInstanceID"
            "-framework FirebaseInstallations"
            "-framework PromisesObjC"
        )
    endif()
endif()

qt_finalize_executable(nymea-app)
