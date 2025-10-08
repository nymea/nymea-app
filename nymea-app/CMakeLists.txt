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

find_package(Qt6 COMPONENTS LinguistTools REQUIRED)
if(TARGET Qt6::lrelease)
    get_target_property(QT_LRELEASE_EXECUTABLE Qt6::lrelease IMPORTED_LOCATION)
elseif(DEFINED Qt6_LRELEASE_EXECUTABLE)
    set(QT_LRELEASE_EXECUTABLE ${Qt6_LRELEASE_EXECUTABLE})
endif()

if(NOT QT_LRELEASE_EXECUTABLE)
    message(FATAL_ERROR "Could not determine the Qt lrelease executable")
endif()

set(QM_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/translations")
set(QM_FILES)
foreach(TS_FILE ${TS_FILES})
    get_filename_component(TRANSLATION_FILENAME ${TS_FILE} NAME_WE)
    set(QM_FILE "${QM_OUTPUT_DIR}/${TRANSLATION_FILENAME}.qm")
    add_custom_command(
        OUTPUT ${QM_FILE}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${QM_OUTPUT_DIR}
        COMMAND ${QT_LRELEASE_EXECUTABLE} ${TS_FILE} -qm ${QM_FILE}
        DEPENDS ${TS_FILE}
        COMMENT "Generating ${TRANSLATION_FILENAME}.qm"
        VERBATIM
    )
    list(APPEND QM_FILES ${QM_FILE})
endforeach()

set_source_files_properties(${QM_FILES} PROPERTIES GENERATED TRUE)

add_custom_target(nymea_app_translations ALL DEPENDS ${QM_FILES})
add_dependencies(nymea-app nymea_app_translations)

set(_nymea_translations_qrc_content "<RCC>\n    <qresource prefix=\"/\">\n")
foreach(QM_FILE ${QM_FILES})
    get_filename_component(QM_BASENAME ${QM_FILE} NAME)
    string(APPEND _nymea_translations_qrc_content "        <file alias=\"translations/${QM_BASENAME}\">${QM_FILE}</file>\n")
endforeach()
string(APPEND _nymea_translations_qrc_content "    </qresource>\n</RCC>\n")

set(NYMEA_TRANSLATIONS_QRC "${CMAKE_CURRENT_BINARY_DIR}/translations_autogen.qrc")
file(GENERATE OUTPUT ${NYMEA_TRANSLATIONS_QRC} CONTENT "${_nymea_translations_qrc_content}")
set_source_files_properties(${NYMEA_TRANSLATIONS_QRC} PROPERTIES GENERATED TRUE)
set_property(SOURCE ${NYMEA_TRANSLATIONS_QRC} APPEND PROPERTY OBJECT_DEPENDS "${QM_FILES}")

target_sources(nymea-app PRIVATE ${NYMEA_TRANSLATIONS_QRC})

if(WIN32)
    target_compile_definitions(nymea-app PRIVATE NOMINMAX)
endif()
