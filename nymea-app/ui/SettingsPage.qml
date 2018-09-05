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

    ColumnLayout {
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
                    text: Engine.connection.url
                }
                Button {
                    text: qsTr("Disconnect")
                    onClicked: {
                        settings.lastConnectedHost = "";
                        Engine.connection.disconnect();
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
                text: qsTr("Server name")
            }
            TextField {
                Layout.fillWidth: true
                text: Engine.basicConfiguration.serverName
                onAccepted: Engine.basicConfiguration.serverName = text
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
                    checked: Engine.basicConfiguration.debugServerEnabled
                    onClicked: Engine.basicConfiguration.debugServerEnabled = checked
                }
            }

            Button {
                id: debugServerButton
                Layout.fillWidth: true
                Layout.margins: app.margins
                visible: debugServerEnabledSwitch.checked
                text: qsTr("Open debug interface")
                onClicked: Qt.openUrlExternally("http://" + Engine.connection.hostAddress + "/debug")
            }

        }

        MeaListItemDelegate {
            Layout.fillWidth: true
            iconName: "../images/cloud.svg"
            text: qsTr("Cloud")
            visible: Engine.jsonRpcClient.ensureServerVersion("1.9")
            onClicked: pageStack.push(Qt.resolvedUrl("system/CloudSettingsPage.qml"))
        }

        MeaListItemDelegate {
            Layout.fillWidth: true
            iconName: "../images/plugin.svg"
            text: qsTr("Plugins")
            onClicked:pageStack.push(Qt.resolvedUrl("system/PluginsPage.qml"))
        }

        MeaListItemDelegate {
            Layout.fillWidth: true
            iconName: "../images/logs.svg"
            text: qsTr("Log viewer")
            onClicked: pageStack.push(Qt.resolvedUrl("system/LogViewerPage.qml"))
        }
        MeaListItemDelegate {
            Layout.fillWidth: true
            iconName: "../images/info.svg"
            text: qsTr("About nymea")
            onClicked: pageStack.push(Qt.resolvedUrl("system/AboutNymeaPage.qml"))
        }
    }
}
