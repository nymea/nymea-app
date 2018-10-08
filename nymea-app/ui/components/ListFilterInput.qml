import QtQuick 2.6
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1
import "../components"
import "../delegates"
import Nymea 1.0

Item {
    id: root
    opacity: shown ? 1 : 0
    implicitWidth: searchColumn.implicitWidth
    implicitHeight: shown ? searchColumn.implicitHeight : 0
    Behavior on implicitHeight {NumberAnimation { duration: 130; easing.type: Easing.InOutQuad }}

    property bool shown: false
    property alias text: searchTextField.displayText

    ColumnLayout {
        id: searchColumn
        anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
        RowLayout {
            Layout.margins: app.margins
            spacing: app.margins
            TextField {
                id: searchTextField
                Layout.fillWidth: true
            }

            HeaderButton {
                imageSource: "../images/erase.svg"
                onClicked: searchTextField.text = ""
                enabled: searchTextField.displayText.length > 0
                color: enabled ? app.accentColor : keyColor
            }
        }
        ThinDivider {}
    }
}
