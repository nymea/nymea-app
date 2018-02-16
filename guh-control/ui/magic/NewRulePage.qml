import QtQuick 2.8
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import "../components"
import Guh 1.0

Page {
    id: root

    property var rule: null

    StackView {
        id: internalPageStack
        anchors.fill: parent
        initialItem: newRulePage1
    }

    function addEventDescriptor() {
        var eventDescriptor = root.rule.eventDescriptors.createNewEventDescriptor();
        var page = internalPageStack.push(Qt.resolvedUrl("SelectThingPage.qml"));
        page.onBackPressed.connect(function() { internalPageStack.pop(); });
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
        var eventPage = internalPageStack.push(Qt.resolvedUrl("SelectEventPage.qml"), {text: "Select event", eventDescriptor: eventDescriptor});
        eventPage.onBackPressed.connect(function() {internalPageStack.pop()})
        eventPage.onDone.connect(function() {
            root.rule.eventDescriptors.addEventDescriptor(eventPage.eventDescriptor);
            internalPageStack.pop(newRulePage1)
        })
    }

    function addAction() {

    }

    Page {
        id: newRulePage1

        header: GuhHeader {
            text: "New rule"
            onBackPressed: pageStack.pop()
        }

        ColumnLayout {
            anchors.fill: parent
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
                text: "do the following:"
            }

            RowLayout {
                Layout.fillWidth: true
                visible: actionsRepeater.count == 0
                Label {
                    Layout.fillWidth: true
                    text: "Add action which should be executed when the rule is triggered"
                }
                Button {
                    text: "+"
                    onClicked: root.addAction();
                }
            }

            Repeater {
                id: actionsRepeater
                model: root.rule.actions
                delegate: ItemDelegate {
                    id: actionDelegate
                    contentItem: ColumnLayout {
                        Label {
                            text: "bla"
                        }
                    }
                }
            }
        }
    }
}
