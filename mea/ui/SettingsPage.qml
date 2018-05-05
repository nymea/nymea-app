import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Mea 1.0
import "components"

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Settings")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors { left: parent.left; right: parent.right; top: parent.top }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: app.margins

            Label {
                text: qsTr("Application").toUpperCase()
                color: app.guhAccent
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    Layout.fillWidth: true
                    text: qsTr("View mode")
                }
                ComboBox {
                    model: [qsTr("Windowed"), qsTr("Maximized"), qsTr("Fullscreen")]
                    currentIndex: {
                        switch (settings.viewMode) {
                        case ApplicationWindow.Windowed:
                            return 0;
                        case ApplicationWindow.Maximized:
                            return 1;
                        case ApplicationWindow.FullScreen:
                            return 2;
                        }
                    }

                    onCurrentIndexChanged: {
                        switch (currentIndex) {
                        case 0:
                            settings.viewMode = ApplicationWindow.Windowed;
                            break;
                        case 1:
                            settings.viewMode = ApplicationWindow.Maximized;
                            break;
                        case 2:
                            settings.viewMode = ApplicationWindow.FullScreen;
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: appBranding.length === 0
                Label {
                    Layout.fillWidth: true
                    text: "Style"
                }
                ComboBox {
                    model: ["light", "dark", "maveo"]
                    currentIndex: {
                        switch (settings.style) {
                        case "light":
                            return 0;
                        case "dark":
                            return 1;
                        case "maveo":
                            return 2;
                        }
                    }

                    onActivated: {
                        settings.style = model[index]
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    Layout.fillWidth: true
                    text: qsTr("Return to home on idle")
                }
                CheckBox {
                    checked: settings.returnToHome
                    onClicked: settings.returnToHome = checked
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    Layout.fillWidth: true
                    text: qsTr("Graph style")
                }
                RadioButton {
                    checked: settings.graphStyle === "bars"
                    text: qsTr("Bars")
                    onClicked: settings.graphStyle = "bars"
                }
                RadioButton {
                    checked: settings.graphStyle === "bezier"
                    text: qsTr("Lines")
                    onClicked: settings.graphStyle = "bezier"
                }

            }
        }


        ThinDivider {}

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            Layout.topMargin: app.margins
            text: qsTr("System").toUpperCase()
            color: app.guhAccent
        }


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
    }
}
