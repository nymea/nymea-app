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
            imageSource: "../images/navigation-menu.svg"
            onClicked: deviceMenu.open()
        }
    }

    Menu {
        id: deviceMenu
        width: implicitWidth + app.margins
        x: parent.width - width
        IconMenuItem {
            iconSource: "../images/delete.svg"
            text: "Delete Thing"
            onTriggered: Engine.deviceManager.removeDevice(root.device.id)
        }
        IconMenuItem {
            iconSource: "../images/edit.svg"
            text: "Rename Thing"
            onTriggered: {
                var popup = renameDialog.createObject(root);
                popup.open();
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

    Flickable {
        anchors.fill: parent

        ColumnLayout {
            width: parent.width

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: app.margins
                text: "Thing parameters".toUpperCase()
                color: app.guhAccent
            }

            Repeater {
                model: root.device.params
                delegate: ParamDelegate {
                    Layout.fillWidth: true
                    paramType: root.deviceClass.paramTypes.getParamType(model.id)
                    param: root.device.params.get(index)
                    writable: false
                }
            }

//            ThinDivider {}
        }

    }

    Component {
        id: errorDialog
        ErrorDialog { }
    }

    Component {
        id: renameDialog
        Dialog {
            id: dialog
            width: parent.width * .8
            x: (parent.width - width) / 2
            y: app.margins

            standardButtons: Dialog.Ok | Dialog.Cancel

            TextField {
                id: textField
                text: root.device.name
                width: parent.width
            }

            onAccepted: {
                Engine.deviceManager.editDevice(root.device.id, textField.text)
                dialog.destroy();
            }
        }
    }
}
