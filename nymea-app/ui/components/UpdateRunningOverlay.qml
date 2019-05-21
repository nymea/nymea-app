import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.2
import Nymea 1.0

Rectangle {
    anchors.fill: parent
    color: Material.background
    visible: engine.systemController.updateRunning

    // Event eater
    MouseArea {
        anchors.fill: parent
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width

        ColorIcon {
            height: app.iconSize * 3
            width: height
            Layout.alignment: Qt.AlignHCenter
            name: Qt.resolvedUrl("../images/system-update.svg")
            color: app.accentColor
            PropertyAnimation on rotation {
                from: 0; to: 360;
                duration: 2000
                loops: Animation.Infinite
//                onStopped: start(); // No clue why loops won't work
            }
        }

        Label {
            Layout.fillWidth: true
            Layout.margins: app.margins * 2
            text: qsTr("System update in progress...")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: app.largeFont
        }
        Label {
            Layout.fillWidth: true
            Layout.margins: app.margins * 2
            text: qsTr("Please wait")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
        Label {
            Layout.fillWidth: true
            Layout.margins: app.margins * 2
            text: qsTr("The system may restart in order to complete the update. %1:app will reconnect automatically after the update.").arg(app.systemName)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: app.smallFont
        }
    }
}
