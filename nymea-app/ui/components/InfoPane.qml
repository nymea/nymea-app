import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.2
import Nymea 1.0

InfoPaneBase {
    id: root

    property alias text: textLabel.text
    property alias imageSource: icon.name
    property alias buttonText: button.text

    property color textColor: "white"

    property bool rotatingIcon: false

    signal buttonClicked();

    contentItem: RowLayout {
        id: contentRow
        anchors { left: parent.left; top: parent.top; right: parent.right }

        Label {
            id: textLabel
            color: root.textColor
            font.pixelSize: app.smallFont
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            wrapMode: Text.WordWrap
        }
        ColorIcon {
            id: icon
            Layout.preferredHeight: Style.smallIconSize
            Layout.preferredWidth: height
            color: root.textColor
            visible: name.length > 0

            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 2000
                loops: Animation.Infinite
                running: root.rotatingIcon
                onStopped: icon.rotation = 0;
            }
        }

        Button {
            id: button
            Layout.leftMargin: app.margins
            visible: text.length > 0
            onClicked: root.buttonClicked()
        }
    }
}


