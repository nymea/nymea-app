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

qt_finalize_executable(nymea-app)

