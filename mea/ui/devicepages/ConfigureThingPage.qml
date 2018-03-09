import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Mea 1.0
import "../components"
import "../paramdelegates-ng"

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
            var popup = errorDialog.createObject(root, {text: "Remove device error: " + JSON.stringify(params.deviceError) })
            popup.open();
        }
    }

    ListView {
        anchors.fill: parent
        model: root.device.params
        delegate: ParamDelegate {
            width: parent.width
            paramType: root.deviceClass.paramTypes.getParamType(model.id)
            param: root.device.params.get(index)
            writable: false
        }
    }

    Component {
        id: errorDialog
        ErrorDialog { }
    }
}
