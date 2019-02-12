import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "components"

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Box settings")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: settingsColumn.implicitHeight
        interactive: contentHeight > height

        ColumnLayout {
            id: settingsColumn
            anchors { left: parent.left; right: parent.right; top: parent.top }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: app.margins

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Connected to:")
                    color: Material.accent
                }
                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        Layout.fillWidth: true
                        elide: Text.ElideMiddle
                        text: engine.connection.currentConnection.url
                    }
                    Button {
                        text: qsTr("Disconnect")
                        onClicked: {
                            tabSettings.lastConnectedHost = "";
                            engine.connection.disconnect();
                        }
                    }
                }
            }

            ThinDivider {}

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                spacing: app.margins
                Label {
                    text: qsTr("Name")
                }
                TextField {
                    id: nameTextField
                    Layout.fillWidth: true
                    text: engine.nymeaConfiguration.serverName
                }
                Button {
                    text: qsTr("OK")
                    visible: nameTextField.displayText !== engine.nymeaConfiguration.serverName
                    onClicked: engine.nymeaConfiguration.serverName = nameTextField.displayText
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                spacing: app.margins
                Label {
                    Layout.fillWidth: true
                    text: qsTr("Language")
                }
                ComboBox {
                    model: engine.nymeaConfiguration.availableLanguages
                    currentIndex: model.indexOf(engine.nymeaConfiguration.language)
                    onActivated: {
                        engine.nymeaConfiguration.language = currentText;
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                spacing: app.margins
                Label {
                    Layout.fillWidth: true
                    text: qsTr("Time zone")
                }
                ComboBox {
                    Layout.minimumWidth: 200
                    model: engine.nymeaConfiguration.timezones
                    currentIndex: model.indexOf(engine.nymeaConfiguration.timezone)
                    onActivated: {
                        engine.nymeaConfiguration.timezone = currentText;
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    spacing: app.margins
                    Label {
                        text: qsTr("Debug server enabled")
                        Layout.fillWidth: true
                    }
                    Switch {
                        id: debugServerEnabledSwitch
                        checked: engine.nymeaConfiguration.debugServerEnabled
                        onClicked: engine.nymeaConfiguration.debugServerEnabled = checked
                    }
                }

                Button {
                    id: debugServerButton
                    Layout.fillWidth: true
                    Layout.margins: app.margins
                    visible: debugServerEnabledSwitch.checked
                    text: qsTr("Open debug interface")
                    onClicked: Qt.openUrlExternally("http://" + engine.connection.hostAddress + "/debug")
                }

            }

            MeaListItemDelegate {
                Layout.fillWidth: true
                iconName: "../images/logs.svg"
                text: qsTr("Log viewer")
                onClicked: pageStack.push(Qt.resolvedUrl("system/LogViewerPage.qml"))
            }
            MeaListItemDelegate {
                Layout.fillWidth: true
                iconName: "../images/cloud.svg"
                text: qsTr("Cloud")
                visible: engine.jsonRpcClient.ensureServerVersion("1.9")
                onClicked: pageStack.push(Qt.resolvedUrl("system/CloudSettingsPage.qml"))
            }
            MeaListItemDelegate {
                Layout.fillWidth: true
                iconName: "../images/network-vpn.svg"
                text: qsTr("Server interfaces")
                onClicked: pageStack.push(Qt.resolvedUrl("system/ConnectionInterfacesPage.qml"))
            }
            MeaListItemDelegate {
                Layout.fillWidth: true
                iconName: "../images/mqtt.svg"
                text: qsTr("MQTT broker")
                visible: engine.jsonRpcClient.ensureServerVersion("1.11")
                onClicked: pageStack.push(Qt.resolvedUrl("system/MqttBrokerSettingsPage.qml"))
            }
            MeaListItemDelegate {
                Layout.fillWidth: true
                iconName: "../images/plugin.svg"
                text: qsTr("Plugins")
                onClicked:pageStack.push(Qt.resolvedUrl("system/PluginsPage.qml"))
            }
            MeaListItemDelegate {
                Layout.fillWidth: true
                iconName: "../images/info.svg"
                text: qsTr("About %1:core").arg(app.systemName)
                onClicked: pageStack.push(Qt.resolvedUrl("system/AboutNymeaPage.qml"))
            }
        }
    }
}
