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

    readonly property var device: ruleAction && ruleAction.deviceId ? Engine.deviceManager.devices.getDevice(ruleAction.deviceId) : null
    readonly property var iface: ruleAction && ruleAction.interfaceName ? Interfaces.findByName(ruleAction.interfaceName) : null
    readonly property var actionType: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId).actionTypes.getActionType(ruleAction.actionTypeId)
                                            : iface ? iface.actionTypes.findByName(ruleAction.interfaceAction) : null

    signal backPressed();
    signal completed();

    header: GuhHeader {
        text: "params"
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
                        return ""
                    }

                    property alias paramType: paramDelegate.paramType
                    property alias value: paramDelegate.value
                    property alias eventType: eventParamsComboBox.eventType
                    property alias eventParamTypeId: eventParamsComboBox.currentParamTypeId

                    RadioButton {
                        id: staticParamRadioButton
                        text: qsTr("Use static value as parameter")
                        checked: true
                    }
                    ParamDelegate {
                        id: paramDelegate
                        Layout.fillWidth: true
                        paramType: root.actionType.paramTypes.get(index)
                        enabled: staticParamRadioButton.checked
                    }

                    RadioButton {
                        id: eventParamRadioButton
                        text: qsTr("Use event parameter")
                        visible: eventParamsComboBox.count > 0
                    }
                    ComboBox {
                        id: eventParamsComboBox
                        Layout.fillWidth: true
                        Layout.margins: app.margins
                        enabled: eventParamRadioButton.checked
                        visible: count > 0
                        Component.onCompleted: currentIndex = 0;
                        property var eventDescriptor: root.rule.eventDescriptors.count === 1 ? root.rule.eventDescriptors.get(0) : null
                        property var device: eventDescriptor ? Engine.deviceManager.devices.getDevice(eventDescriptor.deviceId) : null
                        property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
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

                    ThinDivider {}
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
                        }
                    }
                    root.completed()
                }
            }
        }
    }

}
