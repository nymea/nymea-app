import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

SwipeDelegate {
    id: root
    implicitWidth: 200

    property string subText
    property bool progressive: true
    property bool canDelete: false

    property bool wrapTexts: true
    property bool prominentSubText: true

    property string iconName
    property string fallbackIcon
    property int iconSize: app.iconSize
    property color iconColor: app.accentColor
    property alias iconKeyColor: icon.keyColor
    property alias secondaryIconName: secondaryIcon.name
    property alias secondaryIconColor: secondaryIcon.color
    property alias secondaryIconKeyColor: secondaryIcon.keyColor
    property alias secondaryIconClickable: secondaryIconMouseArea.enabled
    property alias tertiaryIconName: tertiaryIcon.name
    property alias tertiaryIconColor: tertiaryIcon.color
    property alias tertiaryIconKeyColor: tertiaryIcon.keyColor
    property alias tertiaryIconClickable: tertiaryIconMouseArea.enabled

    property alias additionalItem: additionalItemContainer.children

    property alias busy: busyIndicator.running

    signal deleteClicked()
    signal secondaryIconClicked()

    contentItem: RowLayout {
        id: innerLayout
        spacing: app.margins
        Item {
            Layout.preferredHeight: root.iconSize
            Layout.preferredWidth: height
            visible: root.iconName || root.fallbackIcon

            ColorIcon {
                id: icon
                anchors.fill: parent
                name: root.iconName
                color: root.iconColor
                visible: root.iconName
            }

            ColorIcon {
                anchors.fill: parent
                name: root.fallbackIcon
                color: root.iconColor
                visible: root.fallbackIcon && (!root.iconName || icon.status === Image.Error)
            }

            BusyIndicator {
                id: busyIndicator
                anchors.centerIn: parent
                visible: running
                running: false
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.text
                wrapMode: root.wrapTexts ? Text.WordWrap : Text.NoWrap
                maximumLineCount: root.wrapTexts ? 2 : 1
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.subText
                font.pixelSize: root.prominentSubText ? app.smallFont : app.extraSmallFont
                color: root.prominentSubText ? Material.foreground : Material.color(Material.Grey)
                wrapMode: root.wrapTexts ? Text.WordWrap : Text.NoWrap
                maximumLineCount: root.wrapTexts ? 2 : 1
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
            MouseArea {
                id: secondaryIconMouseArea
                enabled: false
                anchors.fill: parent
                anchors.margins: -app.margins
                onClicked: root.secondaryIconClicked();
            }
        }

        ColorIcon {
            id: tertiaryIcon
            Layout.preferredHeight: app.iconSize * .5
            Layout.preferredWidth: height
            visible: name.length > 0
            MouseArea {
                id: tertiaryIconMouseArea
                enabled: false
                anchors.fill: parent
                anchors.margins: -app.margins
                onClicked: root.tertiaryIconClicked();
            }
        }

        ColorIcon {
            id: progressionIcon
            Layout.preferredHeight: app.iconSize * .6
            Layout.preferredWidth: height
            name: "../images/next.svg"
            visible: root.progressive
        }

        Item {
            id: additionalItemContainer
            Layout.fillHeight: true
            Layout.preferredWidth: childrenRect.width
            visible: children.length > 0
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
