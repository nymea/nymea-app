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
        Qt6::Core
        Qt6::Network
        Qt6::WebSockets
        Qt6::Bluetooth
        Qt6::Charts
        Qt6::Quick
        Qt6::Qml
)
