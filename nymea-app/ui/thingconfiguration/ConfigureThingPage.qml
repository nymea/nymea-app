import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root
    property Device device: null
    readonly property DeviceClass deviceClass: device ? device.deviceClass : null

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
            onTriggered: engine.deviceManager.removeDevice(root.device.id)
        }
        IconMenuItem {
            iconSource: "../images/edit.svg"
            text: qsTr("Rename Thing")
            onTriggered: {
                var popup = renameDialog.createObject(root);
                popup.open();
            }
        }
        IconMenuItem {
            iconSource: "../images/configure.svg"
            text: qsTr("Reconfigure Thing")
            visible: root.device.deviceClass.paramTypes.count > 0
            onTriggered: {
                var configPage = pageStack.push(Qt.resolvedUrl("SetupWizard.qml"), {device: root.device})
                configPage.done.connect(function() {pageStack.pop(root)})
            }
        }
    }

    Connections {
        target: engine.deviceManager
        onRemoveDeviceReply: {
            switch (params.deviceError) {
            case "DeviceErrorNoError":
                pageStack.pop();
                return;
            case "DeviceErrorDeviceInRule":
                var popup = removeMethodComponent.createObject(root, {device: root.device, rulesList: params["ruleIds"]});
                popup.open();
                return;
            default:
                var popup = errorDialog.createObject(root, {errorCode: params.deviceError})
                popup.open();
            }
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.implicitHeight

        ColumnLayout {
            id: contentColumn
            width: parent.width

            Label {
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: qsTr("Thing information")
                color: app.accentColor
            }
            RowLayout {
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                Label {
                    text: qsTr("Vendor:")
                    Layout.fillWidth: true
                }
                Label {
                    text: engine.deviceManager.vendors.getVendor(root.deviceClass.vendorId).displayName
                }
            }
            RowLayout {
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                Label {
                    text: qsTr("Type")
                    Layout.fillWidth: true
                }
                Label {
                    text: root.deviceClass.displayName
                }
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: app.margins
                text: qsTr("Thing parameters")
                color: app.accentColor
                visible: root.deviceClass.paramTypes.count > 0
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

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: app.margins
                text: qsTr("Thing settings")
                color: app.accentColor
                visible: root.deviceClass.settingsTypes.count > 0
            }

            Repeater {
                id: settingsRepeater
                model: root.device.settings
                delegate: ParamDelegate {
                    Layout.fillWidth: true
                    paramType: root.deviceClass.settingsTypes.getParamType(model.id)
                    value: root.device.settings.get(index).value
                    writable: true
                    property bool dirty: root.device.settings.get(index).value !== value
                    onDirtyChanged: settingsRepeater.checkDirty()
                }
                function checkDirty() {
                    for (var i = 0; i < settingsRepeater.count; i++) {
                        if (settingsRepeater.itemAt(i).dirty) {
                            dirty = true;
                            return;
                        }
                    }
                    dirty = false;
                }
                property bool dirty: false
            }
            Button {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                text: qsTr("Apply")
                enabled: settingsRepeater.dirty
                visible: settingsRepeater.count > 0

                onClicked: {
                    var params = []
                    for (var i = 0; i < settingsRepeater.count; i++) {
                        if (!settingsRepeater.itemAt(i).dirty) {
                            continue;
                        }
                        var setting = {}
                        setting["paramTypeId"] = settingsRepeater.itemAt(i).param.paramTypeId
                        setting["value"] = settingsRepeater.itemAt(i).param.value
                        params.push(setting)
                    }

                    engine.deviceManager.setDeviceSettings(root.device.id, params);
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
                engine.deviceManager.editDevice(root.device.id, textField.text)
                dialog.destroy();
            }
        }
    }

    Component {
        id: removeMethodComponent
        RemoveDeviceMethodDialog {

        }
    }

}
