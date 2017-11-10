import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Guh 1.0
import "../components"

Page {
    id: root
    property var device: null
    readonly property var deviceClass: Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId)

    header: GuhHeader {
        text: root.device.name
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/delete.svg"
            color: "red"
            onClicked: {
                Engine.deviceManager.removeDevice(root.device.id)
            }
        }
    }

    Connections {
        target: Engine.deviceManager
        onRemoveDeviceReply: {
            if (params.deviceError === "DeviceErrorNoError") {
                pageStack.pop();
                return;
            }
            print("Remove device error!", params)
        }
    }

    ListView {
        anchors.fill: parent
        model: root.device.params
        delegate: ItemDelegate {
            width: parent.width
            contentItem: RowLayout {
                Label {
                    text: root.deviceClass.paramTypes.getParamType(model.id).displayName
                }
                Label {
                    Layout.fillWidth: true
                    text: model.value
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }
}
