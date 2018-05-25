import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Mea 1.0
import "../components"
import "../delegates"

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
            text: qsTr("Delete Thing")
            onTriggered: Engine.deviceManager.removeDevice(root.device.id)
        }
        IconMenuItem {
            iconSource: "../images/edit.svg"
            text: qsTr("Rename Thing")
            onTriggered: {
                var popup = renameDialog.createObject(root);
                popup.open();
            }
        }
    }

    Connections {
        target: Engine.deviceManager
        onRemoveDeviceReply: {
            switch (params.deviceError) {
            case "DeviceErrorNoError":
                pageStack.pop();
                return;
            case "DeviceErrorDeviceInRule":
                var popup = removeMethodComponent.createObject(root, {rulesList: params["ruleIds"]});
                popup.open();
                return;
            default:
                var popup = errorDialog.createObject(root, {text: qsTr("Remove device error: %1").arg(JSON.stringify(params.deviceError)) })
                popup.open();
            }
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
                text: qsTr("Thing parameters").toUpperCase()
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

    Component {
        id: removeMethodComponent
        Dialog {
            id: removeMethodDialog
            width: Math.min(parent.width * .8, contentLabel.implicitWidth + app.margins * 2)
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true

            property var rulesList: null

            ColumnLayout {
                width: parent.width
                Label {
                    id: contentLabel
                    text: qsTr("This thing is currently used in one or more rules:")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                ThinDivider {}
                ListView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: app.iconSize * Math.min(count, 5)
                    model: rulesList
                    interactive: contentHeight > height
                    delegate: Label {
                        height: app.iconSize
                        width: parent.width
                        elide: Text.ElideRight
                        text: Engine.ruleManager.rules.getRule(modelData).name
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                ThinDivider {}

                Button {
                    text: qsTr("Remove all those rules")
                    Layout.fillWidth: true
                    onClicked: {
                        Engine.deviceManager.removeDevice(root.device.id, DeviceManager.RemovePolicyCascade)
                        removeMethodDialog.close()
                        removeMethodDialog.destroy();
                    }
                }
                Button {
                    text: qsTr("Update rules, removing this thing")
                    Layout.fillWidth: true
                    onClicked: {
                        Engine.deviceManager.removeDevice(root.device.id, DeviceManager.RemovePolicyUpdate)
                        removeMethodDialog.close()
                        removeMethodDialog.destroy();
                    }
                }
                Button {
                    text: qsTr("Don't remove this thing")
                    Layout.fillWidth: true
                    onClicked: {
                        removeMethodDialog.close()
                        removeMethodDialog.destroy();
                    }
                }
            }
        }
    }
}
