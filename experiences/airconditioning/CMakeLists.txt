file(GLOB AIRCONDITIONING_SOURCES CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
)
file(GLOB AIRCONDITIONING_HEADERS CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/*.h
)

add_library(nymea-app-airconditioning STATIC
    ${AIRCONDITIONING_SOURCES}
    ${AIRCONDITIONING_HEADERS}
)
set_target_properties(nymea-app-airconditioning PROPERTIES OUTPUT_NAME "nymea-app-airconditioning")

target_include_directories(nymea-app-airconditioning
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_SOURCE_DIR}/libnymea-app
        ${CMAKE_BINARY_DIR}
)

target_link_libraries(nymea-app-airconditioning
    PUBLIC
        nymea-app-core
        Qt${QT_VERSION_MAJOR}::Core
        Qt${QT_VERSION_MAJOR}::Network
        Qt${QT_VERSION_MAJOR}::WebSockets
        Qt${QT_VERSION_MAJOR}::Bluetooth
        Qt${QT_VERSION_MAJOR}::Charts
        Qt${QT_VERSION_MAJOR}::Quick
        Qt${QT_VERSION_MAJOR}::Qml
)

if(QT_VERSION_MAJOR EQUAL 5)
    target_compile_definitions(nymea-app-airconditioning PUBLIC QT_DISABLE_DEPRECATED_UP_TO=0x050F00)
endif()
