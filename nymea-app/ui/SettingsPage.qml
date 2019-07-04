import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "components"

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("System settings")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: layout.implicitHeight + (layout.isGrid ? app.margins * 2 : 0)

        GridLayout {
            id: layout
            property bool isGrid: columns > 1
            anchors { left: parent.left; top: parent.top; right: parent.right; margins: isGrid ? app.margins : 0 }
            columns: Math.max(1, Math.floor(parent.width / 300))
            rowSpacing: isGrid ? app.margins : 0
            columnSpacing: isGrid ? app.margins : 0

            Pane {
                Layout.fillWidth: true
                Material.elevation: layout.isGrid ? 1 : 0
                padding: 0
                NymeaListItemDelegate {
                    width: parent.width
                    iconName: "../images/configure.svg"
                    text: qsTr("General")
                    subText: qsTr("Change system name and time zone")
                    prominentSubText: false
                    wrapTexts: false
                    onClicked: pageStack.push(Qt.resolvedUrl("system/GeneralSettingsPage.qml"))
                }
            }

            Pane {
                Layout.fillWidth: true
                Material.elevation: layout.isGrid ? 1 : 0

                padding: 0
                NymeaListItemDelegate {
                    width: parent.width
                    iconName: "../images/network-wifi.svg"
                    text: qsTr("Networking")
                    subText: qsTr("Configure the system's network connection")
                    prominentSubText: false
                    wrapTexts: false
                    onClicked: pageStack.push(Qt.resolvedUrl("system/NetworkSettingsPage.qml"))
                }
            }

            Pane {
                Layout.fillWidth: true
                Material.elevation: layout.isGrid ? 1 : 0
                visible: engine.jsonRpcClient.ensureServerVersion("1.9")

                padding: 0
                NymeaListItemDelegate {
                    width: parent.width
                    iconName: "../images/cloud.svg"
                    text: qsTr("Cloud")
                    subText: qsTr("Connect this %1:core to %1:cloud").arg(app.systemName)
                    prominentSubText: false
                    wrapTexts: false
                    onClicked: pageStack.push(Qt.resolvedUrl("system/CloudSettingsPage.qml"))
                }
            }

            Pane {
                Layout.fillWidth: true
                Material.elevation: layout.isGrid ? 1 : 0

                padding: 0
                NymeaListItemDelegate {
                    width: parent.width
                    iconName: "../images/network-vpn.svg"
                    text: qsTr("API interfaces")
                    prominentSubText: false
                    wrapTexts: false
                    subText: qsTr("Configure how clients interact with this system")
                    onClicked: pageStack.push(Qt.resolvedUrl("system/ConnectionInterfacesPage.qml"))
                }
            }

            Pane {
                Layout.fillWidth: true
                Material.elevation: layout.isGrid ? 1 : 0
                visible: engine.jsonRpcClient.ensureServerVersion("1.11")

                padding: 0
                NymeaListItemDelegate {
                    width: parent.width
                    iconName: "../images/mqtt.svg"
                    text: qsTr("MQTT broker")
                    subText: qsTr("Configure the MQTT broker")
                    prominentSubText: false
                    wrapTexts: false
                    onClicked: pageStack.push(Qt.resolvedUrl("system/MqttBrokerSettingsPage.qml"))
                }
            }

            Pane {
                Layout.fillWidth: true
                Material.elevation: layout.isGrid ? 1 : 0

                padding: 0
                NymeaListItemDelegate {
                    width: parent.width
                    iconName: "../images/stock_website.svg"
                    text: qsTr("Web server")
                    subText: qsTr("Configure the web server")
                    prominentSubText: false
                    wrapTexts: false
                    onClicked: pageStack.push(Qt.resolvedUrl("system/WebServerSettingsPage.qml"))
                }

            }

            Pane {
                Layout.fillWidth: true
                Material.elevation: layout.isGrid ? 1 : 0

                padding: 0
                NymeaListItemDelegate {
                    width: parent.width
                    iconName: "../images/plugin.svg"
                    text: qsTr("Plugins")
                    subText: qsTr("List and cofigure installed plugins")
                    prominentSubText: false
                    wrapTexts: false
                    onClicked:pageStack.push(Qt.resolvedUrl("system/PluginsPage.qml"))
                }
            }

            Pane {
                Layout.fillWidth: true
                Material.elevation: layout.isGrid ? 1 : 0

                padding: 0
                NymeaListItemDelegate {
                    width: parent.width
                    iconName: "../images/sdk.svg"
                    text: qsTr("Developer tools")
                    subText: qsTr("Access tools for debugging and error reporting")
                    prominentSubText: false
                    wrapTexts: false
                    onClicked: pageStack.push(Qt.resolvedUrl("system/DeveloperTools.qml"))
                }
            }

            Pane {
                Layout.fillWidth: true
                Material.elevation: layout.isGrid ? 1 : 0
                visible: engine.jsonRpcClient.ensureServerVersion("2.1") && engine.systemController.updateManagementAvailable

                padding: 0
                NymeaListItemDelegate {
                    width: parent.width
                    iconName: "../images/system-update.svg"
                    text: qsTr("System update")
                    subText: qsTr("Update your %1:core system").arg(app.systemName)
                    prominentSubText: false
                    wrapTexts: false
                    onClicked: pageStack.push(Qt.resolvedUrl("system/SystemUpdatePage.qml"))
                }
            }

            Pane {
                Layout.fillWidth: true
                Material.elevation: layout.isGrid ? 1 : 0

                padding: 0
                NymeaListItemDelegate {
                    width: parent.width
                    iconName: "../images/logs.svg"
                    text: qsTr("Log viewer")
                    subText: qsTr("View system log")
                    prominentSubText: false
                    wrapTexts: false
                    onClicked: pageStack.push(Qt.resolvedUrl("system/LogViewerPage.qml"))
                }
            }

            Pane {
                Layout.fillWidth: true
                Material.elevation: layout.isGrid ? 1 : 0

                padding: 0
                NymeaListItemDelegate {
                    width: parent.width
                    iconName: "../images/info.svg"
                    text: qsTr("About %1:core").arg(app.systemName)
                    subText: qsTr("Find server UUID and versions")
                    prominentSubText: false
                    wrapTexts: false
                    onClicked: pageStack.push(Qt.resolvedUrl("system/AboutNymeaPage.qml"))
                }
            }
        }
    }
}
