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
                text: "Full screen"
            }
            CheckBox {
                checked: settings.fullscreen
                onClicked: settings.fullscreen = checked
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
    }
}
