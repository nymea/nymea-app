import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Guh 1.0
import "components"

Page {
    id: root
    header: GuhHeader {
        text: "Settings"
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors { left: parent.left; right: parent.right; top: parent.top }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: app.margins

            Label {
                text: "Application".toUpperCase()
                color: app.guhAccent
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    Layout.fillWidth: true
                    text: "View mode"
                }
                ComboBox {
                    model: ["Windowed", "Maximized", "Fullscreen"]
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
                Label {
                    Layout.fillWidth: true
                    text: "Return to home on idle"
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
                    text: "Graph style"
                }
                RadioButton {
                    checked: settings.graphStyle === "bars"
                    text: "Bars"
                    onClicked: settings.graphStyle = "bars"
                }
                RadioButton {
                    checked: settings.graphStyle === "bezier"
                    text: "Lines"
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
            text: "System".toUpperCase()
            color: app.guhAccent
        }

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
                checked: Engine.basicConfiguration.debugServerEnabled
                onClicked: Engine.basicConfiguration.debugServerEnabled = checked
            }
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

        ItemDelegate {
            Layout.fillWidth: true
            contentItem: RowLayout {
                Label {
                    Layout.fillWidth: true
                    text: "Plugins"
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
