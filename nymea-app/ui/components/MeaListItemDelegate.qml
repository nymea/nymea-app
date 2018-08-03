import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

SwipeDelegate {
    id: root

    property string subText
    property bool progressive: true
    property bool canDelete: false

    property string iconName
    property int iconSize: app.iconSize
    property color iconColor: app.accentColor
    property alias secondaryIconName: secondaryIcon.name
    property alias secondaryIconColor: secondaryIcon.color
    property alias tertiaryIconName: tertiaryIcon.name
    property alias tertiaryIconColor: tertiaryIcon.color

    signal deleteClicked()

    contentItem: RowLayout {
        spacing: app.margins
        ColorIcon {
            id: icon
            Layout.preferredHeight: root.iconSize
            Layout.preferredWidth: height
            name: root.iconName
            color: root.iconColor
            visible: root.iconName
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.text
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.subText
                font.pixelSize: app.smallFont
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                visible: root.subText.length > 0
            }
        }

        ColorIcon {
            id: secondaryIcon
            Layout.preferredHeight: app.iconSize * .5
            Layout.preferredWidth: height
            visible: name.length > 0
        }

        ColorIcon {
            id: tertiaryIcon
            Layout.preferredHeight: app.iconSize * .5
            Layout.preferredWidth: height
            visible: name.length > 0
        }

        ColorIcon {
            id: progressionIcon
            Layout.preferredHeight: app.iconSize * .6
            Layout.preferredWidth: height
            name: "../images/next.svg"
            visible: root.progressive
        }
    }

    swipe.enabled: canDelete
    swipe.right: MouseArea {
        height: root.height
        width: height
        anchors.right: parent.right
        Rectangle {
            anchors.fill: parent
            color: "red"
        }

        ColorIcon {
            anchors.fill: parent
            anchors.margins: app.margins
            name: "../images/delete.svg"
            color: "white"
        }
        onClicked: {
            swipe.close();
            root.deleteClicked()
        }
    }
}
