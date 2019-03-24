import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "../components"
import "../delegates"
import Nymea 1.0

Page {
    id: root
    // Needs to be set and have rule.ruleActions filled in with deviceId and actionTypeId or interfaceName and interfaceAction
    property var ruleAction: null

    // optionally a rule which will be used to propose event's params as param values
    property var rule: null

    readonly property var device: ruleAction && ruleAction.deviceId ? engine.deviceManager.devices.getDevice(ruleAction.deviceId) : null
    readonly property var iface: ruleAction && ruleAction.interfaceName ? Interfaces.findByName(ruleAction.interfaceName) : null
    readonly property var actionType: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId).actionTypes.getActionType(ruleAction.actionTypeId)
                                            : iface ? iface.actionTypes.findByName(ruleAction.interfaceAction) : null

    signal backPressed();
    signal completed();

    header: GuhHeader {
        text: actionType.displayName
        onBackPressed: root.backPressed();
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentCol.height

        ColumnLayout {
            id: contentCol
            width: parent.width

            Repeater {
                id: delegateRepeater
                model: root.actionType.paramTypes
                delegate: ColumnLayout {
                    Layout.fillWidth: true
                    property string type: {
                        if (staticParamRadioButton.checked) {
                            return "static"
                        }
                        if (eventParamRadioButton.checked) {
                            return "event"
                        }
                        if (stateValueRadioButton.checked) {
                            return "state"
                        }
                        return ""
                    }

                    property alias paramType: paramDelegate.paramType
                    property alias value: paramDelegate.value
                    property alias eventType: eventParamsComboBox.eventType
                    property alias eventParamTypeId: eventParamsComboBox.currentParamTypeId
                    property alias stateDeviceId: statePickerDelegate.deviceId
                    property alias stateTypeId: statePickerDelegate.stateTypeId

                    GroupBox {
                        Layout.fillWidth: true
                        Layout.margins: app.margins
                        title: paramType.displayName
                        ColumnLayout {
                            anchors.fill: parent
                            RadioButton {
                                id: staticParamRadioButton
                                text: qsTr("Use static value as parameter")
                                checked: true
                                font.pixelSize: app.smallFont
                            }
                            RadioButton {
                                id: eventParamRadioButton
                                text: qsTr("Use event parameter")
                                visible: eventParamsComboBox.count > 0
                                font.pixelSize: app.smallFont
                            }
                            RadioButton {
                                id: stateValueRadioButton
                                text: qsTr("Use a thing's state value")
                                font.pixelSize: app.smallFont
                            }

                            ThinDivider {}

                            ParamDelegate {
                                id: paramDelegate
                                Layout.fillWidth: true
                                paramType: root.actionType.paramTypes.get(index)
                                enabled: staticParamRadioButton.checked
                                nameVisible: false
                                visible: staticParamRadioButton.checked
                                placeholderText: qsTr("Insert value here")
                            }

                            ComboBox {
                                id: eventParamsComboBox
                                Layout.fillWidth: true
                                visible: eventParamRadioButton.checked && count > 0
                                Component.onCompleted: currentIndex = 0;
                                property var eventDescriptor: root.rule.eventDescriptors.count === 1 ? root.rule.eventDescriptors.get(0) : null
                                property var device: eventDescriptor ? engine.deviceManager.devices.getDevice(eventDescriptor.deviceId) : null
                                property var deviceClass: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
                                property var eventType: deviceClass ? deviceClass.eventTypes.getEventType(eventDescriptor.eventTypeId) : null

                                property var currentParamDescriptor: eventType.paramTypes.get(eventParamsComboBox.currentIndex)
                                property var currentParamTypeId: currentParamDescriptor.id

                                model: eventType.paramTypes
                                delegate: ItemDelegate {
                                    width: parent.width
                                    text: eventParamsComboBox.device.name + " - " + eventParamsComboBox.eventType.displayName + " - " + eventParamsComboBox.eventType.paramTypes.getParamType(model.id).displayName
                                }
                                contentItem: Label {
                                    id: eventParamsComboBoxContentItem
                                    anchors.fill: parent
                                    anchors.margins: app.margins
                                    text: eventParamsComboBox.device.name + " - " + eventParamsComboBox.eventType.displayName + " - " + eventParamsComboBox.currentParamDescriptor.displayName
                                    elide: Text.ElideRight
                                }
                            }

                            MeaListItemDelegate {
                                id: statePickerDelegate
                                Layout.fillWidth: true
                                text: deviceId === null || stateTypeId === null
                                      ? qsTr("Select a state")
                                      : dev.name + " - " + dev.deviceClass.stateTypes.getStateType(stateTypeId).displayName
                                visible: stateValueRadioButton.checked

                                property var deviceId: null
                                property var stateTypeId: null

                                readonly property Device dev: engine.deviceManager.devices.getDevice(deviceId)

                                onClicked: {
                                    var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {showStates: true, showEvents: false, showActions: false });
                                    page.thingSelected.connect(function(device) {
                                        print("Thing selected", device.name);
                                        statePickerDelegate.deviceId = device.id
                                        var selectStatePage = pageStack.replace(Qt.resolvedUrl("SelectStatePage.qml"), {device: device})
                                        selectStatePage.stateSelected.connect(function(stateTypeId) {
                                            print("State selected", stateTypeId)
                                            pageStack.pop();
                                            statePickerDelegate.stateTypeId = stateTypeId;
                                        })
                                    })
                                }
                            }
                        }
                    }

//                    Label {
//                        id: paramNameLabel
//                        Layout.fillWidth: true
//                        Layout.leftMargin: app.margins
//                        Layout.rightMargin: app.margins
//                        Layout.topMargin: app.margins
//                        elide: Text.ElideRight
//                        text: paramType.displayName
//                        font.pixelSize: app.largeFont
//                    }


//                    ThinDivider {}
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
                        if (paramDelegate.type === "static") {
                            if (root.device) {
                                root.ruleAction.ruleActionParams.setRuleActionParam(paramDelegate.paramType.id, paramDelegate.value)
                            } else if (root.iface) {
                                root.ruleAction.ruleActionParams.setRuleActionParamByName(root.actionType.paramTypes.get(i).name, paramDelegate.value)
                            }
                        } else if (paramDelegate.type === "event") {
                            print("adding event based rule action param", paramDelegate.paramType.id, paramDelegate.eventType.id, paramDelegate.eventParamTypeId)
                            root.ruleAction.ruleActionParams.setRuleActionParamEvent(paramDelegate.paramType.id, paramDelegate.eventType.id, paramDelegate.eventParamTypeId)
                        } else if (paramDelegate.type === "state") {
                            print("adding state value based rule action param", paramDelegate.paramType.id, paramDelegate.stateDeviceId, paramDelegate.stateTypeId)
                            root.ruleAction.ruleActionParams.setRuleActionParamState(paramDelegate.paramType.id, paramDelegate.stateDeviceId, paramDelegate.stateTypeId)
                        }
                    }
                    root.completed()
                }
            }
        }
    }
}
