import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"


Page {
    id: root

    signal cancel()

    ColumnLayout {
        id: columnLayout
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: app.margins }
        spacing: app.margins
        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: parent.visible
        }
        Label {
            text: qsTr("Connecting...")
            font.pixelSize: app.largeFont
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
        Label {
            Layout.fillWidth: true
            text: engine.connection.url
            font.pixelSize: app.smallFont
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Button {
        text: qsTr("Cancel")
        anchors { left: parent.left; top: columnLayout.bottom; right: parent.right }
        anchors.margins: app.margins
        onClicked: root.cancel()
    }
}
