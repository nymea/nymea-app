import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "../components"
import Nymea 1.0

Page {
    id: root

    property alias text: textLabel.text
    property alias content: contentContainer.children

    property alias showNextButton: nextButton.visible
    property alias nextButtonText: nextLabel.text
    property alias showBackButton: backButton.visible
    property alias backButtonText: backLabel.text
    property alias showExtraButton: extraButton.visible
    property alias extraButtonText: extraButtonLabel.text

    signal next();
    signal back();
    signal extraButtonPressed();

    readonly property int visibleContentHeight: contentFlickable.height - contentContainer.y

    property var headerButtons: []

    ColumnLayout {
        anchors.fill: parent
        spacing: Style.margins

        RowLayout {
            Layout.margins: Style.margins
            ProgressButton {
                imageSource: "/ui/images/navigation-menu.svg"
                longpressEnabled: false
                onClicked: mainMenu.open()
            }

            Label {
                id: titleLabel
                Layout.fillWidth: true
                text: root.title
                font: Style.bigFont
                horizontalAlignment: Text.AlignHCenter
            }
            Item {
                Layout.preferredHeight: Style.iconSize + Style.smallMargins * 2
                Layout.preferredWidth: Style.iconSize + Style.smallMargins * 2
            }

            Row {
                id: additionalIcons
                anchors { right: parent.right; top: parent.top }
                visible: !d.configOverlay
                width: visible ? implicitWidth : 0
                Repeater {
                    model: headerButtons
                    delegate: HeaderButton {
                        imageSource: root.headerButtons[index].iconSource
                        onClicked: root.headerButtons[index].trigger()
                        visible: root.headerButtons[index].visible
                        color: root.headerButtons[index].color
                    }
                }
            }
        }

        Flickable {
            id: contentFlickable
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            interactive: contentHeight > height
            contentHeight: outerContentContainer.childrenRect.height
            Column {
                id: outerContentContainer
                width: parent.width
                spacing: Style.margins
                Label {
                    id: textLabel
                    width: parent.width - Style.margins * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                ColumnLayout {
                    id: contentContainer
                    width: parent.width
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Style.margins
            Layout.rightMargin: Style.margins

            MouseArea {
                id: backButton
                Layout.preferredHeight: Style.delegateHeight
                Layout.preferredWidth: childrenRect.width
                Layout.alignment: Qt.AlignLeft
                RowLayout {
                    anchors.centerIn: parent
                    ColorIcon {
                        Layout.alignment: Qt.AlignRight
                        size: Style.iconSize
                        name: "back"
                    }
                    Label {
                        id: backLabel
                        Layout.fillWidth: true
                        text: qsTr("Back")
                    }
                }
                onClicked: root.back()
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.delegateHeight
                Label {
                    id: extraButtonLabel
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                }
                MouseArea {
                    id: extraButton
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    height: Style.delegateHeight
                    width: extraButtonLabel.width
                    visible: false
                    onClicked: root.extraButtonPressed()
                }
            }

            MouseArea {
                id: nextButton
                Layout.preferredHeight: Style.delegateHeight
                Layout.preferredWidth: childrenRect.width
                Layout.alignment: Qt.AlignRight
                RowLayout {
                    anchors.centerIn: parent
                    Label {
                        id: nextLabel
                        Layout.fillWidth: true
                        text: qsTr("Next")
                    }
                    ColorIcon {
                        Layout.alignment: Qt.AlignRight
                        size: Style.iconSize
                        name: "next"
                    }
                }
                onClicked: root.next()
            }
        }
    }
}
