import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.1

ToolBar {
    id: root
    Material.elevation: 1

    property string text
    property alias backButtonVisible: backButton.visible
    property alias menuButtonVisible: menuButton.visible
    default property alias children: layout.data

    signal backPressed();
    signal menuPressed();

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
        }
    }
}
