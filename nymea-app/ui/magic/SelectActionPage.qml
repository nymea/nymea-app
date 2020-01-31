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

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../paramdelegates"

Page {
    id: root

    // input
    property string text

    // output
    property var actions: []
    signal complete();

    header: NymeaHeader {
        text: "Select action"
        onBackPressed: pageStack.pop()
    }

    ListModel {
        id: actionModel
        ListElement { interfaceName: "light"; text: qsTr("Switch lights..."); identifier: "switchLights" }
        ListElement { interfaceName: "mediacontroller"; text: qsTr("Control media playback..."); identifier: "controlMedia" }
        ListElement { interfaceName: "extendedvolumecontroller"; text: qsTr("Mute media playback..."); identifier: "muteMedia" }
        ListElement { interfaceName: "notifications"; text: qsTr("Notify me..."); identifier: "notify" }
        ListElement { interfaceName: ""; text: qsTr("Manually configure an action..."); identifier: "manualAction" }
    }

    DevicesProxy {
        id: ifaceFilterModel
        engine: _engine
    }

    Component.onCompleted: {
        actualModel.clear()
        for (var i = 0; i < actionModel.count; i++) {
            ifaceFilterModel.shownInterfaces = [actionModel.get(i).interfaceName];
            if (actionModel.get(i).interfaceName === "" || ifaceFilterModel.count > 0) {
                actualModel.append(actionModel.get(i))
            }
        }
    }

    function actionSelected(identifier) {
        switch (identifier) {
        case "switchLights":
            pageStack.push(switchLightsCompoent)
            break;
        case "controlMedia":
            break;
        case "muteMedia":
            break;
        case "manualAction":
            pageStack.push(selectDeviceComponent)
            break;
        case "notify":
            pageStack.push(notificationActionComponent)
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Label {
            Layout.fillWidth: true
            Layout.margins: app.margins
            text: root.text
            font.pixelSize: app.largeFont
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: ListModel {
                id: actualModel
            }
            delegate: ItemDelegate {
                width: parent.width
                text: model.text
                onClicked: {
                    root.actionSelected(model.identifier)
                }
            }
        }
    }

    Component {
        id: selectDeviceComponent
        Page {
            header: NymeaHeader {
                text: qsTr("Select device")
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent

                ListView {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    model: engine.deviceManager.devices
                    delegate: ItemDelegate {
                        width: parent.width
                        Label {
                            anchors.fill: parent
                            anchors.margins: app.margins
                            text: model.name
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            var device = engine.deviceManager.devices.get(index)
                            pageStack.push(selectDeviceActionComponent, {device: device})
                        }
                    }
                }
            }
        }
    }

    Component {
        id: selectDeviceActionComponent
        Page {
            id: page
            property var device
            readonly property var deviceClass: engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId)

            header: NymeaHeader {
                text: qsTr("Select action")
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent
                ListView {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    model: page.deviceClass.actionTypes

                    delegate: ItemDelegate {
                        width: parent.width
                        Label {
                            anchors.fill: parent
                            anchors.margins: app.margins
                            text: model.name
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            var actionType = page.deviceClass.actionTypes.get(index)
                            if (page.deviceClass.actionTypes.get(index).paramTypes.count === 0) {
                                // We're all set.
                                var action = {}
                                action["deviceId"] = page.device.id
                                action["actionTypeId"] = actionType.id
                                root.actions.push(action)
                                root.complete();
                            } else {
                                // need to fill in params
                                pageStack.push(selectDeviceActionParamComponent, {device: page.device, actionType: actionType})
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: selectDeviceActionParamComponent
        Page {
            id: page
            property var device
            property var actionType
            header: NymeaHeader {
                text: qsTr("params")
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent
                Repeater {
                    id: delegateRepeater
                    model: page.actionType.paramTypes
                    delegate: ParamDelegate {
                        paramType: page.actionType.paramTypes.get(index)
                        value: paramType.defaultValue

                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
                Button {
                    text: qsTr("OK")
                    Layout.fillWidth: true
                    Layout.margins: app.margins
                    onClicked: {
                        var params = [];
                        for (var i = 0; i < delegateRepeater.count; i++) {
                            var paramDelegate = delegateRepeater.itemAt(i);
                            var param = {}
                            param["paramTypeId"] = paramDelegate.paramType.id
                            param["value"] = paramDelegate.value
                            params.push(param)
                        }
                        var action = {};
                        action["deviceId"] = page.device.id
                        action["actionTypeId"] = page.actionType.id
                        action["ruleActionParams"] = params
                        root.actions.push(action)
                        root.complete()
                    }
                }
            }
        }
    }

    Component {
        id: switchLightsCompoent
        Page {
            header: NymeaHeader {
                text: qsTr("Switch lights")
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent

                SwitchDelegate {
                    id: switchDelegate
                    Layout.fillWidth: true
                    text: qsTr("Set selected lights power to")
                    position: 0
                }
                ThinDivider {}

                Flickable {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    interactive: contentHeight > height
                    clip: true

                    Column {
                        width: parent.width

                        Repeater {
                            id: lightsRepeater

                            model: DevicesProxy {
                                id: lightsModel
                                engine: _engine
                                shownInterfaces: ["light"]
                            }
                            delegate: CheckDelegate {
                                width: parent.width
                                text: model.name
                            }
                        }
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.margins: app.margins
                    text: qsTr("OK")
                    onClicked:  {
                        for (var i = 0; i < lightsRepeater.count; i++) {
                            if (lightsRepeater.itemAt(i).checkState === Qt.Unchecked) {
                                continue;
                            }
                            var device = lightsModel.get(i);
                            var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId)

                            var action = {}
                            action["deviceId"] = device.id

                            var actionType = deviceClass.actionTypes.findByName("power")
                            action["actionTypeId"] = actionType.id

                            var params = [];
                            var paramType = actionType.paramTypes.getParamType("power");
                            var param = {}
                            param["paramTypeId"] = paramType.id
                            param["value"] = switchDelegate.position === 1 ? true : false;
                            params.push(param)

                            action["ruleActionParams"] = params
                            root.actions.push(action)
                        }
                        root.complete();
                    }
                }
            }
        }
    }

    Component {
        id: notificationActionComponent
        Page {
            header: NymeaHeader {
                text: qsTr("Send notification")
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: app.margins
                Label {
                    Layout.fillWidth: true
                    text: qsTr("Notification text")
                    Layout.topMargin: app.margins
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                }
                TextField {
                    id: notificationTextField
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                }
                ThinDivider {}
                Flickable {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    interactive: contentHeight > height
                    clip: true

                    Column {
                        width: parent.width

                        Repeater {
                            id: notificationsRepeater

                            model: DevicesProxy {
                                id: notificationsModel
                                engine: _engine
                                shownInterfaces: ["notifications"]
                            }
                            delegate: CheckDelegate {
                                width: parent.width
                                text: model.name
                                checked: true
                            }
                        }
                    }
                }
                Button {
                    Layout.fillWidth: true
                    Layout.margins: app.margins
                    text: qsTr("OK")
                    onClicked: {
                        var action = {}
                        action["interface"] = "notifications";
                        action["interfaceAction"] = "notify";
                        action["ruleActionParams"] = [];
                        var ruleActionParam = {};
                        ruleActionParam["paramName"] = "title";
                        ruleActionParam["value"] = notificationTextField.text
                        action["ruleActionParams"].push(ruleActionParam)
                        root.actions.push(action)
                        root.complete()
                    }
                }
            }
        }
    }
}
