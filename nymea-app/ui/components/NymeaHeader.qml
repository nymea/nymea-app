import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.1

Item {
    id: root
    implicitHeight: toolBar.implicitHeight + infoPane.height
    property string text
    property alias backButtonVisible: backButton.visible
    property alias menuButtonVisible: menuButton.visible
    default property alias children: layout.data

    signal backPressed();
    signal menuPressed();

    function showInfo(text, isError, isSticky) {
        if (isError === undefined) isError = false;
        if (isSticky === undefined) isSticky = false;

        infoPane.text = text;
        infoPane.isError = isError;
        infoPane.isSticky = isSticky;

        if (!isSticky) {
            infoPaneTimer.start();
        }
    }

    ToolBar {
        id: toolBar
        Material.elevation: 3
        anchors { left: parent.left; top: parent.top; right: parent.right }

        RowLayout {
            id: layout
            anchors { fill: parent; leftMargin: app.margins; rightMargin: app.margins }

            HeaderButton {
                id: menuButton
                objectName: "headerMenuButton"
                imageSource: "../images/navigation-menu.svg"
                visible: false
                onClicked: root.menuPressed();
            }

            HeaderButton {
                id: backButton
                objectName: "backButton"
                imageSource: "../images/back.svg"
                onClicked: root.backPressed();
            }
            Label {
                id: label
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: app.mediumFont
                elide: Text.ElideRight
                text: root.text
                color: app.headerForegroundColor
            }
        }
    }

    Pane {
        id: infoPane
        Material.elevation: 1

        property string text
        property bool isError: false
        property bool isSticky: false
        property bool shown: isSticky || infoPaneTimer.running

        visible: height > 0
        height: shown ? contentRow.implicitHeight : 0
        Behavior on height { NumberAnimation {} }
        anchors { left: parent.left; top: toolBar.bottom; right: parent.right }

        padding: 0
        contentItem: Rectangle {
            color: infoPane.isError ? "red" : app.accentColor
            implicitHeight: contentRow.implicitHeight
            RowLayout {
                id: contentRow
                anchors { left: parent.left; top: parent.top; right: parent.right; leftMargin: app.margins; rightMargin: app.margins }
                Item {
                    Layout.fillWidth: true
                    height: app.iconSize
                }

                Label {
                    text: infoPane.text
                    font.pixelSize: app.smallFont
                    color: "white"
                }

                ColorIcon {
                    height: app.iconSize / 2
                    width: height
                    visible: true
                    color: "white"
                    name: "../images/dialog-warning-symbolic.svg"
                }
            }
        }
    }

    Timer {
        id: infoPaneTimer
        interval: 5000
        repeat: false
        running: false
    }
}
