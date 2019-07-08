import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

Item {
    id: root

    property alias iconName: colorIcon.name
    property alias fallbackIconName: fallbackIcon.name
    property alias iconColor: colorIcon.color
    property alias backgroundImage: background.source
    property string text
    property bool disconnected: false
    property bool batteryCritical: false

    property alias contentItem: innerContent.children

    signal clicked();
    signal pressAndHold();

    Pane {
        anchors.fill: parent
        anchors.margins: app.margins / 2
        Material.elevation: 1
        padding: 0

        Image {
            id: background
            anchors.fill: parent
            anchors.margins: 1
            z: -1
            fillMode: Image.PreserveAspectCrop
//            horizontalAlignment: Image.AlignTop
//            opacity: .5
//            Rectangle {
//                anchors.fill: parent
//                color: Material.background
//                opacity: .5
//            }
        }

        contentItem: ItemDelegate {
            padding: 0; topPadding: 0; bottomPadding: 0
            onClicked: root.clicked()
            onPressAndHold: root.pressAndHold()

            contentItem: ColumnLayout {
                spacing: 0
                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.margins: app.margins
                    Item {
                        visible: background.status !== Image.Ready
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColorIcon {
                            id: colorIcon
                            anchors.centerIn: parent
                            height: app.iconSize * 1.3
                            width: height
                            ColorIcon {
                                id: fallbackIcon
                                anchors.fill: parent
                                color: root.iconColor
                                visible: parent.status === Image.Error
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: background.status !== Image.Ready

                        Label {
                            id: label
                            anchors.centerIn: parent
                            width: parent.width
                            text: root.text.toUpperCase()
                            font.pixelSize: app.smallFont
                            font.letterSpacing: 1
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                    }

                }
                MouseArea {
                    id: innerContent
                    Layout.fillWidth: true
                    Layout.preferredHeight: app.iconSize + app.margins * 2
                    visible: root.contentItem.length > 1

                    Rectangle {
                        anchors.fill: parent
                        color: Material.background
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: Material.foreground
                        opacity: 0.05
                    }
                }
            }
        }
    }

    Row {
        id: quickAlertPane
        anchors { top: parent.top; right: parent.right; margins: app.margins }
        ColorIcon {
            height: app.iconSize / 2
            width: height
            name: "../images/dialog-warning-symbolic.svg"
            color: "red"
            visible: root.disconnected
        }
        ColorIcon {
            height: app.iconSize / 2
            width: height
            name: "../images/battery/battery-010.svg"
            visible: root.batteryCritical
        }
    }
}

