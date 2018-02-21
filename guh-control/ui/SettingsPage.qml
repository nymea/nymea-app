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
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: app.margins }

        Label {
            Layout.fillWidth: true
            text: "Application".toUpperCase()
            color: app.guhAccent
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
}
