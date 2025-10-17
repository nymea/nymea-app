cmake_minimum_required(VERSION 3.16)

file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/version.txt" NYMEA_VERSION_LINES)
list(LENGTH NYMEA_VERSION_LINES NYMEA_VERSION_COUNT)
if(NOT NYMEA_VERSION_COUNT GREATER_EQUAL 1)
    message(FATAL_ERROR "version.txt must contain at least the application version")
endif()
list(GET NYMEA_VERSION_LINES 0 NYMEA_APP_VERSION)
if(NOT NYMEA_VERSION_COUNT GREATER_EQUAL 2)
    set(NYMEA_APP_REVISION "0")
else()
    list(GET NYMEA_VERSION_LINES 1 NYMEA_APP_REVISION)
endif()

project(nymea-app VERSION ${NYMEA_APP_VERSION} LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(APPLICATION_NAME "nymea-app" CACHE STRING "Application name")
set(ORGANISATION_NAME "nymea" CACHE STRING "Organisation name")

option(NYMEA_ENABLE_ZEROCONF "Enable ZeroConf support" OFF)
option(NYMEA_USE_MATERIAL_ICONS "Use the Material icon set instead of Suru" OFF)
option(NYMEA_ENABLE_FIREBASE "Enable Firebase Cloud Messaging integration" ON)
set(NYMEA_OVERLAY_PATH "" CACHE PATH "Optional overlay directory for branding")

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Network
    Qml
    Quick
    QuickControls2
    Svg
    WebSockets
    Bluetooth
    Charts
    Nfc
)

find_package(OpenSSL QUIET)

if(ANDROID)
    include(FetchContent)
    FetchContent_Declare(
        android_openssl
        DOWNLOAD_EXTRACT_TIMESTAMP true
        URL https://github.com/KDAB/android_openssl/archive/refs/heads/master.zip
    )
    FetchContent_MakeAvailable(android_openssl)
    include(${android_openssl_SOURCE_DIR}/android_openssl.cmake)

    set(NYMEA_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/packaging/android" CACHE PATH "Android packaging directory")

    set(_nymea_app_root_property "nymeaAppRoot=${CMAKE_SOURCE_DIR}")
    if(NYMEA_ENABLE_FIREBASE)
        set(_nymea_firebase_property "useFirebase=true")
    else()
        set(_nymea_firebase_property "useFirebase=false")
    endif()

    file(WRITE "${NYMEA_ANDROID_PACKAGE_SOURCE_DIR}/nymeaapp.properties" "${_nymea_app_root_property}\n${_nymea_firebase_property}\n")
    configure_file(
        "${CMAKE_SOURCE_DIR}/version.txt"
        "${NYMEA_ANDROID_PACKAGE_SOURCE_DIR}/version.txt"
        COPYONLY
    )

    add_link_options("-Wl,-z,max-page-size=16384")
endif()

# Make config.h available to all targets
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config.h.in ${CMAKE_BINARY_DIR}/config.h @ONLY)

# Common warning flags
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    add_compile_options(-Wall)
    if(UNIX AND NOT APPLE)
        add_compile_options(-Wno-deprecated-declarations -Wno-deprecated-copy)
    endif()
endif()

set(APP_VERSION ${NYMEA_APP_VERSION})
set(APP_REVISION ${NYMEA_APP_REVISION})

add_subdirectory(libnymea-app)
add_subdirectory(experiences)
add_subdirectory(nymea-app)
