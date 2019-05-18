import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

Rectangle {
    anchors.fill: parent
    color: "#99000000"
    visible: shown

    property bool shown: false
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
                loops: Animation.Inifinite
                onStopped: start(); // No clue why loops won't work
            }
        }

        Label {
            Layout.fillWidth: true
            Layout.margins: app.margins * 2
            text: qsTr("An update operation is currently running.\nPlease wait for it to complete.")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: app.largeFont
            color: "white"
        }
    }
}
