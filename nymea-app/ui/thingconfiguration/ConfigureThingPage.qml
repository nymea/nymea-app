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

Page {
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
            if (!root.device.isChild) {
                deviceMenu.addItem(menuEntryComponent.createObject(deviceMenu, {text: qsTr("Delete"), iconSource: "../images/delete.svg", functionName: "deleteThing"}))
            }
            if (!root.device.isChild) {
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

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.implicitHeight

        ColumnLayout {
            id: contentColumn
            width: parent.width

            Label {
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: qsTr("Information")
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
                text: qsTr("Parameters")
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
                text: qsTr("Settings")
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

}
