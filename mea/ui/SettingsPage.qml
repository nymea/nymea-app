import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Mea 1.0
import "components"

Page {
    id: root
    header: GuhHeader {
        text: qsTr("System settings")
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

        ItemDelegate {
            Layout.fillWidth: true
            contentItem: RowLayout {
                Label {
                    Layout.fillWidth: true
                    text: qsTr("Plugins")
                }
                Image {
                    source: "images/next.svg"
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: height
                }
            }
            onClicked: {
                pageStack.push(Qt.resolvedUrl("system/PluginsPage.qml"))
            }
        }

        ItemDelegate {
            Layout.fillWidth: true
            contentItem: RowLayout {
                Label {
                    text: qsTr("Log viewer")
                    Layout.fillWidth: true
                }
                Image {
                    source: "images/next.svg"
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: height
                }
            }

            onClicked: pageStack.push(Qt.resolvedUrl("system/LogViewerPage.qml"))
        }

    }

    Component {
        id: styleChangedDialog
        Dialog {
            width: Math.min(parent.width * .8, contentLabel.implicitWidth)
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true

            title: qsTr("Style changed")

            standardButtons: Dialog.Ok

            ColumnLayout {
                id: content
                anchors { left: parent.left; top: parent.top; right: parent.right }

                Label {
                    id: contentLabel
                    Layout.fillWidth: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTr("The application needs to be restarted for style changes to take effect.")
                }
            }
        }
    }
}
