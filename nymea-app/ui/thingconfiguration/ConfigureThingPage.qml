/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"

SettingsPageBase {
    id: root
    property Device device: null
    readonly property DeviceClass deviceClass: device ? device.deviceClass : null

    header: NymeaHeader {
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

        Component.onCompleted: {
            deviceMenu.addItem(menuEntryComponent.createObject(deviceMenu, {text: qsTr("Rename"), iconSource: "../images/edit.svg", functionName: "renameThing"}))
            // FIXME: This isn't entirely correct... we should have a way to know if a particular thing is in fact autocreated
            // This check might be wrong for thingClasses with multiple create methods...
            if (!root.device.isChild || root.deviceClass.createMethods.indexOf("CreateMethodAuto") < 0) {
                deviceMenu.addItem(menuEntryComponent.createObject(deviceMenu, {text: qsTr("Delete"), iconSource: "../images/delete.svg", functionName: "deleteThing"}))
            }
            // FIXME: This isn't entirely correct... we should have a way to know if a particular thing is in fact autocreated
            // This check might be wrong for thingClasses with multiple create methods...
            if (!root.device.isChild || root.deviceClass.createMethods.indexOf("CreateMethodAuto") < 0) {
                deviceMenu.addItem(menuEntryComponent.createObject(deviceMenu, {text: qsTr("Reconfigure"), iconSource: "../images/configure.svg", functionName: "reconfigureThing"}))
            }
        }

        function renameThing() {
            var popup = renameDialog.createObject(root);
            popup.open();
        }

        function deleteThing() {
            engine.deviceManager.removeDevice(root.device.id)
        }

        function reconfigureThing() {
            var configPage = pageStack.push(Qt.resolvedUrl("SetupWizard.qml"), {device: root.device})
            configPage.done.connect(function() {pageStack.pop(root)})
        }

        Component {
            id: menuEntryComponent
            IconMenuItem {
                property string functionName: ""
                onTriggered: deviceMenu[functionName]()
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

    SettingsPageSectionHeader {
        text: qsTr("Information")
    }

    NymeaListItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Vendor:")
        subText: engine.deviceManager.vendors.getVendor(root.deviceClass.vendorId).displayName
        progressive: false
    }
    NymeaListItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Type:")
        subText: root.deviceClass.displayName
        progressive: false
    }

    NymeaListItemDelegate {
        Layout.fillWidth: true
        text: qsTr("ID:")
        subText: root.device.id.toString().replace(/[{}]/g, "")
        progressive: false
        onClicked: {
            PlatformHelper.toClipBoard(root.device.id.toString().replace(/[{}]/g, ""));
            ToolTip.show(qsTr("ID copied to clipboard"), 500);
        }
    }

    NymeaListItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Thing class")
        subText: qsTr("View the type definition for this thing")
        onClicked: {
            pageStack.push(Qt.resolvedUrl("ThingClassDetailsPage.qml"), {device: root.device})
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Parameters")
        visible: root.device.params.count > 0
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

    SettingsPageSectionHeader {
        text: qsTr("Input/Output Connections")
        visible: ioModel.count > 0
    }

    StateTypesProxy {
        id: ioModel
        stateTypes: root.deviceClass.stateTypes
        digitalInputs: true
        digitalOutputs: true
        analogInputs: true
        analogOutputs: true
    }
    Repeater {
        model: ioModel
        delegate: NymeaListItemDelegate {
            Layout.fillWidth: true

            iconName: "../images/io-connections.svg"
            text: model.displayName
            subText: {
                if (ioStateType.ioType == Types.IOTypeDigitalInput || ioStateType.ioType == Types.IOTypeAnalogInput) {
                    if (inputConnectionWatcher.ioConnection) {
                        return "%1: %2".arg(inputConnectionWatcher.outputThing.name).arg(inputConnectionWatcher.outputStateType.displayName)
                    }
                } else {
                    if (outputConnectionWatcher.ioConnection) {
                        return "%1: %2".arg(outputConnectionWatcher.inputThing.name).arg(outputConnectionWatcher.inputStateType.displayName)
                    }
                }
                return qsTr("Not connected")
            }


            property StateType ioStateType: ioModel.get(index)

            IOInputConnectionWatcher {
                id: inputConnectionWatcher
                ioConnections: engine.deviceManager.ioConnections
                inputThingId: root.device.id
                inputStateTypeId: ioStateType.id
                property Device outputThing: ioConnection ? engine.deviceManager.devices.getDevice(ioConnection.outputThingId) : null
                property StateType outputStateType: ioConnection ? outputThing.deviceClass.stateTypes.getStateType(ioConnection.outputStateTypeId) : null
            }
            IOOutputConnectionWatcher {
                id: outputConnectionWatcher
                ioConnections: engine.deviceManager.ioConnections
                outputThingId: root.device.id
                outputStateTypeId: ioStateType.id
                property Device inputThing: ioConnection ? engine.deviceManager.devices.getDevice(ioConnection.inputThingId) : null
                property StateType inputStateType: ioConnection ? inputThing.deviceClass.stateTypes.getStateType(ioConnection.inputStateTypeId) : null
            }

            onClicked: {
                var popup = ioConnectionsDialogComponent.createObject(app, {ioStateType: ioStateType, inputWatcher: inputConnectionWatcher, outputWatcher: outputConnectionWatcher})
                popup.open()
            }
        }
    }


    SettingsPageSectionHeader {
        text: qsTr("Settings")
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
            // NOTE: If CloseOnPressOutside is active (default) it will break the QtVirtualKeyboard
            // https://bugreports.qt.io/browse/QTBUG-56918
            closePolicy: Popup.CloseOnEscape

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

    Component {
        id: ioConnectionsDialogComponent
        MeaDialog {
            id: ioConnectionDialog
            standardButtons: Dialog.NoButton
            title: qsTr("Connect Inputs/Outputs")

            property StateType ioStateType: null
            property IOInputConnectionWatcher inputWatcher: null
            property IOOutputConnectionWatcher outputWatcher: null

            readonly property bool isInput: ioConnectionDialog.ioStateType.ioType == Types.IOTypeDigitalInput || ioConnectionDialog.ioStateType.ioType == Types.IOTypeAnalogInput

            Label {
                Layout.fillWidth: true
                text: qsTr("Connect \"%1\" to:").arg(ioConnectionDialog.ioStateType.displayName)
                wrapMode: Text.WordWrap
            }
            Label { text: "\n" } // Fake in some spacing

            GridLayout {
                columns: (ioConnectionDialog.width / 400) * 2

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Thing")
                }

                ComboBox {
                    id: ioThingComboBox
                    model: DevicesProxy {
                        id: connectableIODevices
                        engine: _engine
                        showDigitalInputs: ioConnectionDialog.ioStateType.ioType == Types.IOTypeDigitalOutput
                        showDigitalOutputs: ioConnectionDialog.ioStateType.ioType == Types.IOTypeDigitalInput
                        showAnalogInputs: ioConnectionDialog.ioStateType.ioType == Types.IOTypeAnalogOutput
                        showAnalogOutputs: ioConnectionDialog.ioStateType.ioType == Types.IOTypeAnalogInput
                    }
                    textRole: "name"
                    Layout.fillWidth: true
                    Component.onCompleted: {
                        for (var i = 0; i < connectableIODevices.count; i++) {
                            if (ioConnectionDialog.ioStateType.ioType == Types.IOTypeDigitalInput || ioConnectionDialog.ioStateType.ioType == Types.IOTypeAnalogInput) {
                                if (connectableIODevices.get(i).id === ioConnectionDialog.inputWatcher.ioConnection.outputThingId) {
                                    ioThingComboBox.currentIndex = i;
                                    break;
                                }
                            } else {
                                if (connectableIODevices.get(i).id === ioConnectionDialog.outputWatcher.ioConnection.inputThingId) {
                                    ioThingComboBox.currentIndex = i;
                                    break;
                                }
                            }
                        }
                    }
                }

                Label {
                    Layout.fillWidth: true
                    text: (ioConnectionDialog.ioStateType.ioType == Types.IOTypeDigitalInput || ioConnectionDialog.ioStateType.ioType == Types.IOTypeAnalogInput) ? qsTr("Output") : qsTr("Input")
                }

                ComboBox {
                    id: ioStateComboBox
                    model: StateTypesProxy {
                        id: connectableStateTypes
                        stateTypes: connectableIODevices.get(ioThingComboBox.currentIndex).deviceClass.stateTypes
                        digitalInputs: ioConnectionDialog.ioStateType.ioType == Types.IOTypeDigitalOutput
                        digitalOutputs: ioConnectionDialog.ioStateType.ioType == Types.IOTypeDigitalInput
                        analogInputs: ioConnectionDialog.ioStateType.ioType == Types.IOTypeAnalogOutput
                        analogOutputs: ioConnectionDialog.ioStateType.ioType == Types.IOTypeAnalogInput
                    }
                    textRole: "displayName"
                    Layout.fillWidth: true
                    onCountChanged: {
//                        print("loading for:", ioConnectionDialog.inputWatcher.ioConnection.outputStateTypeId)
                        for (var i = 0; i < connectableStateTypes.count; i++) {
                            print("checking:", connectableStateTypes.get(i).id)
                            if (ioConnectionDialog.ioStateType.ioType == Types.IOTypeDigitalInput || ioConnectionDialog.ioStateType.ioType == Types.IOTypeAnalogInput) {
                                if (connectableStateTypes.get(i).id === ioConnectionDialog.inputWatcher.ioConnection.outputStateTypeId) {
                                    ioStateComboBox.currentIndex = i;
                                    break;
                                }
                            } else {
                                if (connectableStateTypes.get(i).id === ioConnectionDialog.outputWatcher.ioConnection.inputStateTypeId) {
                                    ioStateComboBox.currentIndex = i;
                                    break;
                                }
                            }
                        }
                    }
                }

                Label {
                    text: qsTr("Inverted")
                    Layout.fillWidth: true
                }

                CheckBox {
                    id: invertCheckBox
                    checked: ioConnectionDialog.isInput ? ioConnectionDialog.inputWatcher.ioConnection.inverted : ioConnectionDialog.outputWatcher.ioConnection.inverted
                }
            }

            RowLayout {
                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: qsTr("Cancel")
                    onClicked: ioConnectionDialog.reject();
                }
                Button {
                    text: qsTr("Disconnect")
                    enabled: ioConnectionDialog.isInput ? ioConnectionDialog.inputWatcher.ioConnection != null : ioConnectionDialog.outputWatcher.ioConnection != null

                    onClicked: {
                        if (ioConnectionDialog.ioStateType.ioType == Types.IOTypeDigitalInput
                                || ioConnectionDialog.ioStateType.ioType == Types.IOTypeAnalogInput) {
                            engine.deviceManager.disconnectIO(ioConnectionDialog.inputWatcher.ioConnection.id);
                        } else {
                            engine.deviceManager.disconnectIO(ioConnectionDialog.outputWatcher.ioConnection.id);
                        }

                        ioConnectionDialog.reject();
                    }
                }
                Button {
                    text: qsTr("Connect")
                    enabled: ioThingComboBox.currentIndex >= 0 && ioStateComboBox.currentIndex >= 0

                    onClicked: {
                        var inputThingId;
                        var inputStateTypeId;
                        var outputThingId;
                        var outputStateTypeId;
                        if (ioConnectionDialog.ioStateType.ioType == Types.IOTypeDigitalInput
                                || ioConnectionDialog.ioStateType.ioType == Types.IOTypeAnalogInput) {
                            inputThingId = root.device.id;
                            inputStateTypeId = ioConnectionDialog.ioStateType.id;
                            outputThingId = connectableIODevices.get(ioThingComboBox.currentIndex).id;
                            outputStateTypeId = connectableStateTypes.get(ioStateComboBox.currentIndex).id;
                        } else {
                            inputThingId = connectableIODevices.get(ioThingComboBox.currentIndex).id;
                            inputStateTypeId = connectableStateTypes.get(ioStateComboBox.currentIndex).id;
                            outputThingId = root.device.id;
                            outputStateTypeId = ioConnectionDialog.ioStateType.id;
                        }
                        var inverted = invertCheckBox.checked

                        print("connecting", inputThingId, inputStateTypeId, outputThingId, outputStateTypeId, inverted)
                        engine.deviceManager.connectIO(inputThingId, inputStateTypeId, outputThingId, outputStateTypeId, inverted);

                        ioConnectionDialog.accept();
                    }
                }
            }


        }
    }
}
