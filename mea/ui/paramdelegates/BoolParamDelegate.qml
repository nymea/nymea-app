import QtQuick 2.8
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1

ParamDelegateBase {
    id: root
    contentItem: RowLayout {

        Label {
            id: label
            Layout.fillWidth: true
            text: root.paramType.displayName + "- " + root.value
        }
        Switch {
            id: theSwitch
            checked: root.value == true
            onClicked: root.value = checked
        }
    }
}

