import QtQuick 2.8
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import "../components"
import Guh 1.0

Page {
    id: root

    property var rule: null

    signal accept();

    function addEventDescriptor() {
        var eventDescriptor = root.rule.eventDescriptors.createNewEventDescriptor();
        var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"));
        page.onBackPressed.connect(function() { pageStack.pop(); });
        page.onThingSelected.connect(function(device) {
            eventDescriptor.deviceId = device.id;
            selectEventDescriptorData(eventDescriptor)
        })
        page.onInterfaceSelected.connect(function(interfaceName) {
            eventDescriptor.interfaceName = interfaceName;
            selectEventDescriptorData(eventDescriptor)
        })
    }

    function selectEventDescriptorData(eventDescriptor) {
        var eventPage = pageStack.push(Qt.resolvedUrl("SelectEventPage.qml"), {text: "Select event", eventDescriptor: eventDescriptor});
        eventPage.onBackPressed.connect(function() {pageStack.pop()})
        eventPage.onDone.connect(function() {
            root.rule.eventDescriptors.addEventDescriptor(eventPage.eventDescriptor);
            pageStack.pop(root)
        })
    }

    function addRuleAction() {
        var ruleAction = root.rule.ruleActions.createNewRuleAction();
        var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"));
        page.onBackPressed.connect(function() { pageStack.pop() })
        page.onThingSelected.connect(function(device) {
            ruleAction.deviceId = device.id;
            selectRuleActionData(ruleAction)
        })
        page.onInterfaceSelected.connect(function(interfaceName) {
            ruleAction.interfaceName = interfaceName;
            selectRuleActionData(ruleAction)
        })
    }
    function selectRuleActionData(ruleAction) {
        var ruleActionPage = pageStack.push(Qt.resolvedUrl("SelectRuleActionPage.qml"), {text: "Select action", ruleAction: ruleAction });
        ruleActionPage.onBackPressed.connect(function() {
            ruleAction.destroy();
            pageStack.pop(root);
        })
        ruleActionPage.onDone.connect(function() {
            root.rule.ruleActions.addRuleAction(ruleAction)
            pageStack.pop(root);
        })
    }

    header: GuhHeader {
        text: "New rule"
        onBackPressed: pageStack.pop()
        HeaderButton {
            imageSource: "../images/tick.svg"
            onClicked: {
                root.accept()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        Label {
            text: "Rule name"
        }
        TextField {
            Layout.fillWidth: true
            text: root.rule.name
            onTextChanged: {
                root.rule.name = text;

            }
        }

        RowLayout {
            Layout.fillWidth: true
            RadioButton {
                id: whenButton
                text: "When"
                checked: true
            }
            RadioButton {
                id: whileButton
                text: "While"
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: eventsRepeater.count == 0
            Label {
                Layout.fillWidth: true
                text: "Add an event which should trigger the execution of the rule"
            }
            Button {
                text: "+"
                onClicked: root.addEventDescriptor();
            }
        }

        Repeater {
            id: eventsRepeater
            model: root.rule.eventDescriptors
            delegate: ItemDelegate {
                id: eventDelegate
                property var device: Engine.deviceManager.devices.getDevice(root.rule.eventDescriptors.get(index).deviceId)
                property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
                property var eventType: deviceClass ? deviceClass.eventTypes.getEventType(root.rule.eventDescriptors.get(index).eventTypeId) : null
                contentItem: ColumnLayout {
                    Label {
                        text: eventDelegate.device ? eventDelegate.device.name : "Unknown device" + root.rule.eventDescriptors.get(index).deviceId
                        Layout.fillWidth: true
                    }
                    Label {
                        text: eventDelegate.eventType ? eventDelegate.eventType.displayName : "Unknown event" + root.rule.eventDescriptors.get(index).eventTypeId
                    }
                }
            }
        }

        Label {
            text: "do the following:" + root.rule.ruleActions.count
        }

        RowLayout {
            Layout.fillWidth: true
            visible: actionsRepeater.count == 0
            Label {
                Layout.fillWidth: true
                text: "Add action which should be executed when the rule is triggered"
                wrapMode: Text.WordWrap
            }
            Button {
                text: "+"
                onClicked: root.addRuleAction();
            }
        }

        Repeater {
            id: actionsRepeater
            model: root.rule.ruleActions
            delegate: ItemDelegate {
                id: actionDelegate
                property var device: Engine.deviceManager.devices.getDevice(root.rule.ruleActions.get(index).deviceId)
                property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
                property var actionType: deviceClass ? deviceClass.actionTypes.getActionType(root.rule.ruleActions.get(index).actionTypeId) : null
                contentItem: ColumnLayout {
                    Label {
                        text: actionDelegate.device.name
                    }
                    Label {
                        text: actionDelegate.actionType.displayName
                    }
                }
            }
        }
    }
}
