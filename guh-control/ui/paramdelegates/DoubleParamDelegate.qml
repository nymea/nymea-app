import QtQuick 2.8
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1

ParamDelegateBase {
    id: root

    contentItem: RowLayout {
        width: parent.width

        Label {
            id: label
            text: root.paramType.displayName
        }
        TextField {
            id: textField
            Layout.fillWidth: true
            text: root.value ? root.value : root.paramType.defaultValue
            onTextChanged: {
                root.value = text;
            }
        }
    }
}
