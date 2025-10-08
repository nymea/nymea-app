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

set(NYMEA_APP_RESOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/resources.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/ruletemplates.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/images.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/translations.qrc
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

add_executable(nymea-app
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
        Qt${QT_VERSION_MAJOR}::Gui
        Qt${QT_VERSION_MAJOR}::Network
        Qt${QT_VERSION_MAJOR}::Qml
        Qt${QT_VERSION_MAJOR}::Quick
        Qt${QT_VERSION_MAJOR}::QuickControls2
        Qt${QT_VERSION_MAJOR}::Svg
        Qt${QT_VERSION_MAJOR}::WebSockets
        Qt${QT_VERSION_MAJOR}::Bluetooth
        Qt${QT_VERSION_MAJOR}::Charts
        Qt${QT_VERSION_MAJOR}::Nfc
)

if(TARGET Qt${QT_VERSION_MAJOR}::WebView)
    target_link_libraries(nymea-app PRIVATE Qt${QT_VERSION_MAJOR}::WebView)
    target_compile_definitions(nymea-app PRIVATE HAVE_WEBVIEW)
endif()

if(QT_VERSION_MAJOR EQUAL 6)
    find_package(Qt6 COMPONENTS GuiPrivate REQUIRED)
    target_link_libraries(nymea-app PRIVATE Qt6::GuiPrivate)
else()
    if(DEFINED Qt5Gui_PRIVATE_INCLUDE_DIRS)
        target_include_directories(nymea-app PRIVATE ${Qt5Gui_PRIVATE_INCLUDE_DIRS})
    endif()
    if(DEFINED Qt5Gui_PRIVATE_DEFINITIONS)
        target_compile_definitions(nymea-app PRIVATE ${Qt5Gui_PRIVATE_DEFINITIONS})
    endif()
    target_compile_definitions(nymea-app PRIVATE QT_DISABLE_DEPRECATED_UP_TO=0x050F00)
endif()

if(UNIX AND NOT APPLE AND NYMEA_ENABLE_ZEROCONF)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(AVAHI REQUIRED IMPORTED_TARGET avahi-client avahi-common)
    target_link_libraries(nymea-app PRIVATE PkgConfig::AVAHI)
endif()

set(TS_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/translations/nymea-app.cs.ts
    ${CMAKE_CURRENT_SOURCE_DIR}/translations/nymea-app.de.ts
    ${CMAKE_CURRENT_SOURCE_DIR}/translations/nymea-app.en.ts
    ${CMAKE_CURRENT_SOURCE_DIR}/translations/nymea-app.en_US.ts
    ${CMAKE_CURRENT_SOURCE_DIR}/translations/nymea-app.it.ts
    ${CMAKE_CURRENT_SOURCE_DIR}/translations/nymea-app.ko.ts
    ${CMAKE_CURRENT_SOURCE_DIR}/translations/nymea-app.nl.ts
    ${CMAKE_CURRENT_SOURCE_DIR}/translations/nymea-app.tr.ts
    ${CMAKE_CURRENT_SOURCE_DIR}/translations/nymea-app.vi.ts
)

if(QT_VERSION_MAJOR EQUAL 6)
    find_package(Qt6 COMPONENTS LinguistTools REQUIRED)
    if(TARGET Qt6::lrelease)
        get_target_property(QT_LRELEASE_EXECUTABLE Qt6::lrelease IMPORTED_LOCATION)
    endif()
else()
    find_package(Qt5 COMPONENTS LinguistTools REQUIRED)
    set(QT_LRELEASE_EXECUTABLE ${Qt5_LRELEASE_EXECUTABLE})
endif()

if(NOT QT_LRELEASE_EXECUTABLE)
    message(FATAL_ERROR "Could not determine the Qt lrelease executable")
endif()

set(QM_FILES)
foreach(TS_FILE ${TS_FILES})
    get_filename_component(TRANSLATION_FILENAME ${TS_FILE} NAME_WE)
    set(QM_FILE "${CMAKE_CURRENT_SOURCE_DIR}/translations/${TRANSLATION_FILENAME}.qm")
    add_custom_command(
        OUTPUT ${QM_FILE}
        COMMAND ${QT_LRELEASE_EXECUTABLE} ${TS_FILE} -qm ${QM_FILE}
        DEPENDS ${TS_FILE}
        COMMENT "Generating ${TRANSLATION_FILENAME}.qm"
        VERBATIM
    )
    list(APPEND QM_FILES ${QM_FILE})
endforeach()

add_custom_target(nymea_app_translations ALL DEPENDS ${QM_FILES})
add_dependencies(nymea-app nymea_app_translations)

if(WIN32)
    target_compile_definitions(nymea-app PRIVATE NOMINMAX)
endif()
