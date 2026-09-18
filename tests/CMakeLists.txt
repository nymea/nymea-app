if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    cmake_minimum_required(VERSION 3.16)
    project(nymea-app-tests LANGUAGES CXX)
    set(CMAKE_AUTOMOC ON)
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    enable_testing()
    get_filename_component(NYMEA_APP_SOURCE_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/.." ABSOLUTE)
else()
    set(NYMEA_APP_SOURCE_ROOT "${CMAKE_SOURCE_DIR}")
endif()

find_package(Qt6 REQUIRED COMPONENTS Nfc Qml Test)

qt_add_executable(tst_nfchelper
    auto/tst_nfchelper.cpp
    ${NYMEA_APP_SOURCE_ROOT}/nymea-app/nfchelper.cpp
    ${NYMEA_APP_SOURCE_ROOT}/nymea-app/nfchelper.h
)

target_include_directories(tst_nfchelper PRIVATE
    ${NYMEA_APP_SOURCE_ROOT}/nymea-app
)

target_link_libraries(tst_nfchelper PRIVATE
    Qt6::Core
    Qt6::Nfc
    Qt6::Qml
    Qt6::Test
)

add_test(NAME tst_nfchelper COMMAND tst_nfchelper)

qt_add_executable(tst_platformpermissionsiossettings
    auto/platformintegration/tst_platformpermissionsiossettings.cpp
)

target_include_directories(tst_platformpermissionsiossettings PRIVATE
    ${NYMEA_APP_SOURCE_ROOT}/nymea-app
)

target_link_libraries(tst_platformpermissionsiossettings PRIVATE
    Qt6::Core
    Qt6::Test
)

add_test(NAME tst_platformpermissionsiossettings COMMAND tst_platformpermissionsiossettings)
