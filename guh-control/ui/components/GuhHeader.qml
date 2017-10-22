import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

ToolBar {
    id: root

    property alias text: label.text
    property alias backButtonVisible: backButton.visible
    default property alias data: layout.data

    signal backPressed();

    RowLayout {
        id: layout
        anchors { fill: parent; leftMargin: app.margins; rightMargin: app.margins }

        HeaderButton {
            id: backButton
            imageSource: "../images/back.svg"
            onClicked: root.backPressed();
        }
        Label {
            id: label
            Layout.fillWidth: true
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: app.largeFont
        }
    }
}
