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

qt_add_executable(tst_invitation
    auto/invitation/tst_invitation.cpp
    ${NYMEA_APP_SOURCE_ROOT}/libnymea-app/connection/invitation.cpp
    ${NYMEA_APP_SOURCE_ROOT}/libnymea-app/connection/invitation.h
)

target_include_directories(tst_invitation PRIVATE
    ${NYMEA_APP_SOURCE_ROOT}/libnymea-app
)

target_link_libraries(tst_invitation PRIVATE
    Qt6::Core
    Qt6::Test
)

add_test(NAME tst_invitation COMMAND tst_invitation)

# Only available when tests/ is built as part of the full project tree (the normal way):
# unlike Invitation, JsonRpcClient pulls in the whole transport stack, so exercising its
# redaction/cache-safety helpers standalone reuses the already-configured nymea-app-core
# target instead of re-listing every transitive source file.
if(TARGET nymea-app-core)
    qt_add_executable(tst_redaction
        auto/redaction/tst_redaction.cpp
    )

    target_link_libraries(tst_redaction PRIVATE
        nymea-app-core
        Qt6::Test
    )

    add_test(NAME tst_redaction COMMAND tst_redaction)
endif()
