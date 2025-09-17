// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

import "../components"
import "../delegates"

SettingsPageBase {
    id: root
    property Thing thing: null
    busy: d.pendingCommand != -1

    header: NymeaHeader {
        text: root.thing.name
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "qrc:/icons/navigation-menu.svg"
            onClicked: deviceMenu.open()
        }
    }

    ThingInfoPane {
        id: infoPane
        Layout.fillWidth: true
        thing: root.thing
    }

    Menu {
        id: deviceMenu
        width: implicitWidth + app.margins
        x: parent.width - width

        Component.onCompleted: {
            deviceMenu.addItem(menuEntryComponent.createObject(deviceMenu, {text: qsTr("Rename"), iconSource: "qrc:/icons/edit.svg", functionName: "renameThing"}))
            // FIXME: This isn't entirely correct... we should have a way to know if a particular thing is in fact autocreated
            // This check might be wrong for thingClasses with multiple create methods...
            if (!root.thing.isChild || root.thing.thingClass.createMethods.indexOf("CreateMethodAuto") < 0) {
                deviceMenu.addItem(menuEntryComponent.createObject(deviceMenu, {text: qsTr("Delete"), iconSource: "qrc:/icons/delete.svg", functionName: "deleteThing"}))
            }
            // FIXME: This isn't entirely correct... we should have a way to know if a particular thing is in fact autocreated
            // This check might be wrong for thingClasses with multiple create methods...
            if (!root.thing.isChild || root.thingClass.createMethods.indexOf("CreateMethodAuto") < 0) {
                deviceMenu.addItem(menuEntryComponent.createObject(deviceMenu, {text: qsTr("Reconfigure"), iconSource: "qrc:/icons/configure.svg", functionName: "reconfigureThing"}))
            }

            deviceMenu.addItem(menuEntryComponent.createObject(deviceMenu, {text: qsTr("Details"), iconSource: "qrc:/icons/info.svg", functionName: "thingDetails"}))
        }

        function renameThing() {
            var popup = renameDialog.createObject(root);
            popup.open();
        }

        function deleteThing() {
            var popup = removeDialogComponent.createObject(root)
            popup.open()
        }

        function reconfigureThing() {
            var configPage = pageStack.push(Qt.resolvedUrl("SetupWizard.qml"), {thing: root.thing})
            configPage.done.connect(function() {pageStack.pop(root)})
            configPage.aborted.connect(function() {pageStack.pop(root)})
        }

        function thingDetails() {
            pageStack.push(Qt.resolvedUrl("qrc:/ui/devicepages/DeviceDetailsPage.qml"), {thing: root.thing})
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
        target: engine.thingManager
        onRemoveThingReply: {
            if (d.pendingCommand != commandId) {
                return;
            }

            d.pendingCommand = -1

            switch (thingError) {
            case Thing.ThingErrorNoError:
                pageStack.pop();
                return;
            default:
                var popup = errorDialog.createObject(root, {error: thingError})
                popup.open();
            }
        }
    }

    QtObject {
        id: d
        property int pendingCommand: -1
    }

    SettingsPageSectionHeader {
        text: qsTr("Information")
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: engine.thingManager.vendors.getVendor(root.thing.thingClass.vendorId).displayName
        subText: qsTr("Vendor")
        prominentSubText: false
        progressive: false
    }
    NymeaItemDelegate {
        Layout.fillWidth: true
        text: root.thing.thingClass.displayName
        subText: qsTr("Type")
        prominentSubText: false
        progressive: false
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: root.thing.id.toString().replace(/[{}]/g, "")
        subText: qsTr("ID")
        prominentSubText: false
        progressive: false
        onClicked: {
            PlatformHelper.toClipBoard(root.thing.id.toString().replace(/[{}]/g, ""));
            ToolTip.show(qsTr("ID copied to clipboard"), 1000);
        }
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Thing class")
        subText: qsTr("View the type definition for this thing")
        onClicked: {
            pageStack.push(Qt.resolvedUrl("ThingClassDetailsPage.qml"), {thing: root.thing})
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Parameters")
        visible: root.thing.params.count > 0
    }

    Repeater {
        model: root.thing.params
        delegate: ParamDelegate {
            Layout.fillWidth: true
            paramType: root.thing.thingClass.paramTypes.getParamType(model.id)
            param: root.thing.params.get(index)
            writable: false
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Input/Output Connections")
        visible: ioModel.count > 0
    }

    StateTypesProxy {
        id: ioModel
        stateTypes: root.thing.thingClass.stateTypes
        digitalInputs: true
        digitalOutputs: true
        analogInputs: true
        analogOutputs: true
    }
    Repeater {
        model: ioModel
        delegate: NymeaSwipeDelegate {
            Layout.fillWidth: true

            iconName: "qrc:/icons/io-connections.svg"
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
                ioConnections: engine.thingManager.ioConnections
                inputThingId: root.thing.id
                inputStateTypeId: ioStateType.id
                property Thing outputThing: ioConnection ? engine.thingManager.things.getThing(ioConnection.outputThingId) : null
                property StateType outputStateType: ioConnection ? outputThing.thingClass.stateTypes.getStateType(ioConnection.outputStateTypeId) : null
            }
            IOOutputConnectionWatcher {
                id: outputConnectionWatcher
                ioConnections: engine.thingManager.ioConnections
                outputThingId: root.thing.id
                outputStateTypeId: ioStateType.id
                property Thing inputThing: ioConnection ? engine.thingManager.things.getThing(ioConnection.inputThingId) : null
                property StateType inputStateType: ioConnection ? inputThing.thingClass.stateTypes.getStateType(ioConnection.inputStateTypeId) : null
            }

            onClicked: {
                var popup = ioConnectionsDialogComponent.createObject(app, {ioStateType: ioStateType, inputWatcher: inputConnectionWatcher, outputWatcher: outputConnectionWatcher})
                popup.open()
            }
        }
    }


    SettingsPageSectionHeader {
        text: qsTr("Settings")
        visible: root.thing.thingClass.settingsTypes.count > 0
    }

    Repeater {
        id: settingsRepeater
        model: root.thing.settings
        delegate: ParamDelegate {
            Layout.fillWidth: true
            paramType: root.thing.thingClass.settingsTypes.getParamType(model.id)
            value: root.thing.settings.get(index).value
            writable: true
            property bool dirty: root.thing.settings.get(index).value !== value
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

            engine.thingManager.setThingSettings(root.thing.id, params);
        }
    }

    Component {
        id: errorDialog
        ErrorDialog { }
    }

    Component {
        id: removeDialogComponent
        NymeaDialog {
            id: removeDialog
            title: qsTr("Remove thing?")
            text: qsTr("Are you sure you want to remove %1 and all associated settings?").arg(root.thing.name)
            standardButtons: Dialog.Yes | Dialog.No

            onAccepted: {
                d.pendingCommand = engine.thingManager.removeThing(root.thing.id)
            }
        }
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
                text: root.thing.name
                width: parent.width
            }

            onAccepted: {
                engine.thingManager.editThing(root.thing.id, textField.text)
                dialog.destroy();
            }
        }
    }

    Component {
        id: ioConnectionsDialogComponent
        NymeaDialog {
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
//            Label { text: "\n" } // Fake in some spacing

            GridLayout {
                columns: (ioConnectionDialog.width / 400) * 2

//                Label {
//                    Layout.fillWidth: true
//                    text: qsTr("Thing")
//                }

                ComboBox {
                    id: ioThingComboBox
                    model: ThingsProxy {
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

//                Label {
//                    Layout.fillWidth: true
//                    text: (ioConnectionDialog.ioStateType.ioType == Types.IOTypeDigitalInput || ioConnectionDialog.ioStateType.ioType == Types.IOTypeAnalogInput) ? qsTr("Output") : qsTr("Input")
//                }

                ComboBox {
                    id: ioStateComboBox
                    model: StateTypesProxy {
                        id: connectableStateTypes
                        stateTypes: connectableIODevices.get(ioThingComboBox.currentIndex).thingClass.stateTypes
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

                RowLayout {

                    Label {
                        text: qsTr("Inverted")
                        Layout.fillWidth: true
                    }

                    CheckBox {
                        id: invertCheckBox
                        checked: ioConnectionDialog.isInput ? ioConnectionDialog.inputWatcher.ioConnection.inverted : ioConnectionDialog.outputWatcher.ioConnection.inverted
                    }
                }
                }


            GridLayout {
                id: buttonGrid
                columns: width > (cancelButton.implicitWidth + disconnectButton.implicitWidth + connectButton.implicitWidth)
                         ? 4 : 1
                layoutDirection: columns == 1 ? Qt.RightToLeft : Qt.LeftToRight
                Item {
                    Layout.fillWidth: true
                }

                Button {
                    id: cancelButton
                    text: qsTr("Cancel")
                    Layout.fillWidth: buttonGrid.columns === 1
                    onClicked: ioConnectionDialog.reject();
                }
                Button {
                    id: disconnectButton
                    text: qsTr("Disconnect")
                    enabled: ioConnectionDialog.isInput ? ioConnectionDialog.inputWatcher.ioConnection != null : ioConnectionDialog.outputWatcher.ioConnection != null
                    Layout.fillWidth: buttonGrid.columns === 1

                    onClicked: {
                        if (ioConnectionDialog.ioStateType.ioType == Types.IOTypeDigitalInput
                                || ioConnectionDialog.ioStateType.ioType == Types.IOTypeAnalogInput) {
                            engine.thingManager.disconnectIO(ioConnectionDialog.inputWatcher.ioConnection.id);
                        } else {
                            engine.thingManager.disconnectIO(ioConnectionDialog.outputWatcher.ioConnection.id);
                        }

                        ioConnectionDialog.reject();
                    }
                }
                Button {
                    id: connectButton
                    text: qsTr("Connect")
                    enabled: ioThingComboBox.currentIndex >= 0 && ioStateComboBox.currentIndex >= 0
                    Layout.fillWidth: buttonGrid.columns === 1

                    onClicked: {
                        var inputThingId;
                        var inputStateTypeId;
                        var outputThingId;
                        var outputStateTypeId;
                        if (ioConnectionDialog.ioStateType.ioType == Types.IOTypeDigitalInput
                                || ioConnectionDialog.ioStateType.ioType == Types.IOTypeAnalogInput) {
                            inputThingId = root.thing.id;
                            inputStateTypeId = ioConnectionDialog.ioStateType.id;
                            outputThingId = connectableIODevices.get(ioThingComboBox.currentIndex).id;
                            outputStateTypeId = connectableStateTypes.get(ioStateComboBox.currentIndex).id;
                        } else {
                            inputThingId = connectableIODevices.get(ioThingComboBox.currentIndex).id;
                            inputStateTypeId = connectableStateTypes.get(ioStateComboBox.currentIndex).id;
                            outputThingId = root.thing.id;
                            outputStateTypeId = ioConnectionDialog.ioStateType.id;
                        }
                        var inverted = invertCheckBox.checked

                        print("connecting", inputThingId, inputStateTypeId, outputThingId, outputStateTypeId, inverted)
                        engine.thingManager.connectIO(inputThingId, inputStateTypeId, outputThingId, outputStateTypeId, inverted);

                        ioConnectionDialog.accept();
                    }
                }
            }


        }
    }
}
