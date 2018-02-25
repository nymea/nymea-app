import QtQuick 2.8
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import "../components"
import Guh 1.0

Page {
    id: root

    property var rule: null

    signal accept();

    onAccept: busyOverlay.opacity = 1

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
        var eventPage = pageStack.push(Qt.resolvedUrl("SelectEventDescriptorPage.qml"), {text: "Select event", eventDescriptor: eventDescriptor});
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
            enabled: actionsRepeater.count > 0 && root.rule.name.length > 0
            opacity: enabled ? 1 : .3
            onClicked: {
                root.accept()
            }
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.implicitHeight + app.margins

        ColumnLayout {
            id: contentColumn
            anchors { left: parent.left; top: parent.top; right: parent.right; topMargin: app.margins }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: app.margins
                Label {
                    Layout.fillWidth: true
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
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("This rule is enabled")
                    }
                    CheckBox {
                        checked: root.rule.enabled
                        onClicked: {
                            root.rule.enabled = checked
                        }
                    }
                }
            }

            ThinDivider {}

            Label {
                Layout.fillWidth: true
                Layout.margins: app.margins
                font.pixelSize: app.mediumFont
                text: "Events triggering this rule"
            }

            Repeater {
                id: eventsRepeater
                model: root.rule.eventDescriptors
                delegate: SwipeDelegate {
                    id: eventDelegate
                    Layout.fillWidth: true
                    readonly property var eventDescriptor: root.rule.eventDescriptors.get(index)
                    property var device: Engine.deviceManager.devices.getDevice(eventDescriptor.deviceId)
                    property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
                    property var iface: eventDescriptor.interfaceName ? Interfaces.findByName(eventDescriptor.interfaceName) : null
                    property var eventType: deviceClass ? deviceClass.eventTypes.getEventType(eventDescriptor.eventTypeId)
                                                        : iface ? iface.eventTypes.findByName(eventDescriptor.interfaceEvent) : null
                    contentItem: ColumnLayout {
                        Label {
                            text: qsTr("%1 - %2").arg(eventDelegate.device ? eventDelegate.device.name : eventDelegate.iface.displayName).arg(eventDelegate.eventType.displayName)
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: app.margins
                            Repeater {
                                model: root.rule.eventDescriptors.get(index).paramDescriptors
                                Label {
                                    text: {
                                        print("***", eventDelegate.iface, eventDelegate.eventDescriptor.interfaceName, Interfaces.findByName(eventDelegate.eventDescriptor.interfaceName), eventDescriptor.interfaceName ? Interfaces.findByName(eventDescriptor.interfaceName) : null)
                                        var ret = eventDelegate.eventType.paramTypes.getParamType(model.id).displayName
                                        switch (model.operator) {
                                        case ParamDescriptor.ValueOperatorEquals:
                                            ret += " = ";
                                            break;
                                        case ParamDescriptor.ValueOperatorNotEquals:
                                            ret += " != ";
                                            break;
                                        case ParamDescriptor.ValueOperatorGreater:
                                            ret += " > ";
                                            break;
                                        case ParamDescriptor.ValueOperatorGreaterOrEqual:
                                            ret += " >= ";
                                            break;
                                        case ParamDescriptor.ValueOperatorLess:
                                            ret += " < ";
                                            break;
                                        case ParamDescriptor.ValueOperatorLessOrEqual:
                                            ret += " <= ";
                                            break;
                                        default:
                                            ret += " ? ";
                                        }

                                        ret += model.value
                                        return ret;
                                    }
                                }
                            }

                        }

                    }
                    swipe.right: MouseArea {
                        height: eventDelegate.height
                        width: height
                        anchors.right: parent.right
                        ColorIcon {
                            anchors.fill: parent
                            anchors.margins: app.margins
                            name: "../images/delete.svg"
                            color: "red"
                        }
                        onClicked: root.rule.eventDescriptors.removeEventDescriptor(index)
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: eventsRepeater.count == 0 ? "Add an event..." : "Add another event..."
                onClicked: root.addEventDescriptor();
            }

            ThinDivider {}

            Label {
                text: "Actions to execute"
                font.pixelSize: app.mediumFont
                Layout.fillWidth: true
                Layout.margins: app.margins
            }

            Repeater {
                id: actionsRepeater
                model: root.rule.ruleActions
                delegate: SwipeDelegate {
                    id: actionDelegate
                    Layout.fillWidth: true
                    property var device: Engine.deviceManager.devices.getDevice(root.rule.ruleActions.get(index).deviceId)
                    property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
                    property var actionType: deviceClass ? deviceClass.actionTypes.getActionType(root.rule.ruleActions.get(index).actionTypeId) : null
                    contentItem: ColumnLayout {
                        Label {
                            Layout.fillWidth: true
                            text: qsTr("%1 - %2").arg(actionDelegate.device.name).arg(actionDelegate.actionType.displayName)
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: app.margins
                            Repeater {
                                model: root.rule.ruleActions.get(index).ruleActionParams
                                Label {
                                    text: actionType.paramTypes.getParamType(model.paramTypeId).displayName + " -> " + model.value
                                    font.pixelSize: app.smallFont
                                }
                            }
                        }
                    }
                    swipe.right: MouseArea {
                        height: actionDelegate.height
                        width: height
                        anchors.right: parent.right
                        ColorIcon {
                            anchors.fill: parent
                            anchors.margins: app.margins
                            name: "../images/delete.svg"
                            color: "red"
                        }
                        onClicked: root.rule.ruleActions.removeRuleAction(index)
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: actionsRepeater.count == 0 ? "Add an action..." : "Add another action..."
                onClicked: root.addRuleAction();
            }
        }
    }

    Rectangle {
        id: busyOverlay
        anchors.fill: parent
        color: "#55000000"
        opacity: 0
        Behavior on opacity { NumberAnimation {duration: 200 } }
        BusyIndicator {
            anchors.centerIn: parent
            running: parent.opacity > 0
        }
    }
}
