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

    ColumnLayout {
        anchors.fill: parent
        spacing: Style.margins

        Label {
            id: titleLabel
            Layout.fillWidth: true
            Layout.margins: Style.margins
            text: root.title
            font: Style.largeFont
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            id: textLabel
            Layout.fillWidth: true
            Layout.margins: Style.margins
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        Item {
            id: contentContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
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
                MouseArea {
                    id: extraButton
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    height: Style.delegateHeight
                    width: childrenRect.width
                    visible: false
                    Label {
                        id: extraButtonLabel
                        anchors.centerIn: parent
                    }
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
