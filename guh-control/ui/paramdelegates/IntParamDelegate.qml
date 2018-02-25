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
            Layout.fillWidth: true
        }
        TextField {
            id: textField
            text: root.value ? root.value : root.paramType.defaultValue
            Layout.preferredWidth: implicitWidth
            onTextChanged: {
                root.value = text;
            }
        }
    }
}
