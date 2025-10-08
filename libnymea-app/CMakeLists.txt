set(LIBNYMEA_APP_SOURCES)
file(GLOB_RECURSE LIBNYMEA_APP_SOURCES CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
)
file(GLOB_RECURSE LIBNYMEA_APP_HEADERS CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/*.h
)

set(REMOTE_PROXY_SOURCES)
set(REMOTE_PROXY_HEADERS)
set(REMOTE_PROXY_DIR ${CMAKE_SOURCE_DIR}/nymea-remoteproxy/libnymea-remoteproxyclient)
if(EXISTS ${REMOTE_PROXY_DIR})
    file(GLOB_RECURSE REMOTE_PROXY_SOURCES CONFIGURE_DEPENDS
        ${REMOTE_PROXY_DIR}/*.cpp
    )
    file(GLOB_RECURSE REMOTE_PROXY_HEADERS CONFIGURE_DEPENDS
        ${REMOTE_PROXY_DIR}/*.h
    )
endif()

add_library(nymea-app-core STATIC
    ${LIBNYMEA_APP_SOURCES}
    ${LIBNYMEA_APP_HEADERS}
    ${REMOTE_PROXY_SOURCES}
    ${REMOTE_PROXY_HEADERS}
)
set_target_properties(nymea-app-core PROPERTIES OUTPUT_NAME "nymea-app")

target_include_directories(nymea-app-core
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_BINARY_DIR}
)
if(EXISTS ${REMOTE_PROXY_DIR})
    set(REMOTE_PROXY_INCLUDE_DIRS ${REMOTE_PROXY_DIR})
    file(GLOB_RECURSE REMOTE_PROXY_ALL_PATHS LIST_DIRECTORIES true
        ${REMOTE_PROXY_DIR}/*
    )
    foreach(_remote_proxy_path IN LISTS REMOTE_PROXY_ALL_PATHS)
        if(IS_DIRECTORY "${_remote_proxy_path}")
            list(APPEND REMOTE_PROXY_INCLUDE_DIRS "${_remote_proxy_path}")
        endif()
    endforeach()
    if(REMOTE_PROXY_INCLUDE_DIRS)
        list(REMOVE_DUPLICATES REMOTE_PROXY_INCLUDE_DIRS)
        target_include_directories(nymea-app-core PUBLIC ${REMOTE_PROXY_INCLUDE_DIRS})
    endif()
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/QtZeroConf)
    target_include_directories(nymea-app-core PUBLIC ${CMAKE_SOURCE_DIR}/QtZeroConf)
endif()

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
