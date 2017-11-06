import QtQuick 2.8
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1

RowLayout {
    id: root

    property alias text: label.text
    property alias value: theSwitch.checked

    Label {
        id: label
        Layout.fillWidth: true
    }
    Switch {
        id: theSwitch
        checked: root.value === true
        onClicked: root.value = checked
    }
}
