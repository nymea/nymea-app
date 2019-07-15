import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../delegates"

MeaDialog {
    id: root

    property Device device
    property string itemId
    property alias actionTypeIds: actionListView.model

    signal activated(var actionTypeId, var params)

    standardButtons: Dialog.NoButton

    StackView {
        id: stackView
        Layout.fillWidth: true
        Layout.minimumHeight: actionListView.implicitHeight

        property var actionTypeId

        initialItem: ListView {
            id: actionListView
            width: parent.width
            implicitHeight: contentHeight

            interactive: contentHeight > height
            clip: true
            delegate: NymeaListItemDelegate {
                width: parent.width
                text: actionType.displayName
                progressive: false
                property ActionType actionType: root.device.deviceClass.browserItemActionTypes.getActionType(modelData)
                onClicked: {
                    var hasParams = actionType.paramTypes.count > 0
                    if (hasParams) {
                        stackView.actionTypeId = actionType.id
                        stackView.push(paramComponent, {model: actionType.paramTypes})
                        return;
                    }

                    var params = []
                    root.activated(actionType.id, params)
                    root.accept()
                }
            }
        }

        Component {
            id: paramComponent

            Repeater {
                id: paramListView

                delegate: ParamDelegate {
                    width: parent.width
                    paramType: paramListView.model.get(index)
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true

        Button {
            text: qsTr("Cancel")
            onClicked: root.reject()
        }
        Item { Layout.fillWidth: true }
        Button {
            text: qsTr("OK")
            visible: stackView.depth > 1
            onClicked: {
                var params = []
                print("k", stackView.currentItem.count)
                for (var i = 0; i < stackView.currentItem.count; i++) {
                    print("juhu", i)
                    var param =  {}
                    param["paramTypeId"] = stackView.currentItem.itemAt(i).paramType.id
                    param["value"] = stackView.currentItem.itemAt(i).value
                    params.push(param)
                }
                print("have params", params.length)
                root.activated(stackView.actionTypeId, params)
                root.accept();
            }
        }
    }
}
