set(LIBNYMEA_APP_SOURCES)
file(GLOB_RECURSE LIBNYMEA_APP_SOURCES CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
)
file(GLOB_RECURSE LIBNYMEA_APP_HEADERS CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/*.h
)

set(NYMEA_REMOTEPROXYCLIENT_SOURCES)
set(NYMEA_REMOTEPROXYCLIENT_HEADERS)
set(NYMEA_REMOTEPROXYCLIENT_INCLUDE_DIRS)
set(NYMEA_REMOTEPROXYCLIENT_MODULE
    ${CMAKE_SOURCE_DIR}/nymea-remoteproxy/cmake/nymea-remoteproxyclient-sources.cmake
)

if(EXISTS ${NYMEA_REMOTEPROXYCLIENT_MODULE})
    include(${NYMEA_REMOTEPROXYCLIENT_MODULE})
    if(COMMAND nymea_remoteproxyclient_sources)
        nymea_remoteproxyclient_sources(
            NYMEA_REMOTEPROXYCLIENT_SOURCES
            NYMEA_REMOTEPROXYCLIENT_HEADERS
            NYMEA_REMOTEPROXYCLIENT_INCLUDE_DIRS
        )
    else()
        message(FATAL_ERROR
            "nymea_remoteproxyclient_sources() was not provided by ${NYMEA_REMOTEPROXYCLIENT_MODULE}."
        )
    endif()
else()
    message(FATAL_ERROR
        "nymea-remoteproxyclient CMake module not found. Did you initialize the nymea-remoteproxy submodule?"
    )
endif()

set(NYMEA_APP_CORE_INCLUDE_DIRS
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_BINARY_DIR}
)

list(APPEND NYMEA_APP_CORE_INCLUDE_DIRS ${NYMEA_REMOTEPROXYCLIENT_INCLUDE_DIRS})

if(EXISTS ${CMAKE_SOURCE_DIR}/QtZeroConf)
    list(APPEND NYMEA_APP_CORE_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/QtZeroConf)
endif()

add_library(nymea-app-core STATIC
    ${LIBNYMEA_APP_SOURCES}
    ${LIBNYMEA_APP_HEADERS}
    ${NYMEA_REMOTEPROXYCLIENT_SOURCES}
    ${NYMEA_REMOTEPROXYCLIENT_HEADERS}
)
set_target_properties(nymea-app-core PROPERTIES OUTPUT_NAME "nymea-app")

list(REMOVE_DUPLICATES NYMEA_APP_CORE_INCLUDE_DIRS)
target_include_directories(nymea-app-core PUBLIC ${NYMEA_APP_CORE_INCLUDE_DIRS})

target_link_libraries(nymea-app-core
    PUBLIC
        Qt6::Core
        Qt6::Network
        Qt6::WebSockets
        Qt6::Bluetooth
        Qt6::Charts
        Qt6::Quick
        Qt6::Qml
        OpenSSL::SSL
        OpenSSL::Crypto
)

if(NYMEA_ENABLE_ZEROCONF)
    target_compile_definitions(nymea-app-core PUBLIC WITH_ZEROCONF QZEROCONF_STATIC)
    find_library(QTZEROCONF_LIBRARY NAMES QtZeroConf HINTS ${CMAKE_SOURCE_DIR}/QtZeroConf)
    if(NOT QTZEROCONF_LIBRARY AND TARGET Qt6::QtZeroConf)
        target_link_libraries(nymea-app-core PUBLIC Qt6::QtZeroConf)
    elseif(QTZEROCONF_LIBRARY)
        target_link_libraries(nymea-app-core PUBLIC ${QTZEROCONF_LIBRARY})
    else()
        message(FATAL_ERROR "ZeroConf support requested but QtZeroConf library was not found")
    endif()
endif()
