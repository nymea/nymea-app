import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

TabButton {
    id: root
    property string iconSource
    property var alignment: Qt.Vertical

    Rectangle {
        anchors.fill: parent
        color: Material.foreground
        opacity: 0.05
    }

    contentItem: GridLayout {
        columns: root.alignment === Qt.Vertical ? 1 : 2
        ColorIcon {
            Layout.preferredWidth: app.iconSize
            Layout.preferredHeight: app.iconSize
            Layout.alignment: Qt.AlignHCenter
            name: root.iconSource
            color: root.checked ? app.accentColor : keyColor
        }
        Label {
            Layout.fillWidth: root.alignment === Qt.Vertical
            text: root.text
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: app.smallFont
            color: root.checked ? app.accentColor : Material.foreground
        }
    }
}

