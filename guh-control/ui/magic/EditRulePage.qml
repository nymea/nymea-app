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

    readonly property bool isStateBased: rule.eventDescriptors.count === 0
    readonly property bool actionsVisible: rule.eventDescriptors.count > 0 || rule.stateEvaluator !== null
    readonly property bool exitActionsVisible: actionsVisible && isStateBased
    readonly property bool hasExitActions: rule.exitActions.count > 0

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

    function editStateEvaluator() {
        print("opening page", root.rule.stateEvaluator)
        var page = pageStack.push(Qt.resolvedUrl("EditStateEvaluatorPage.qml"), { stateEvaluator: root.rule.stateEvaluator })
    }

    function addAction() {
        var ruleAction = root.rule.actions.createNewRuleAction();
        var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"));
        page.onBackPressed.connect(function() { pageStack.pop() })
        page.onThingSelected.connect(function(device) {
            print("thing selected", device.name, device.id)
            ruleAction.deviceId = device.id;
            selectRuleActionData(root.rule.actions, ruleAction)
        })
        page.onInterfaceSelected.connect(function(interfaceName) {
            print("interface selected", interfaceName)
            ruleAction.interfaceName = interfaceName;
            selectRuleActionData(root.rule.actions, ruleAction)
        })
    }
    function addExitAction() {
        var ruleAction = root.rule.exitActions.createNewRuleAction();
        var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"));
        page.onBackPressed.connect(function() { pageStack.pop() })
        page.onThingSelected.connect(function(device) {
            print("thing selected", device.name, device.id)
            ruleAction.deviceId = device.id;
            selectRuleActionData(root.rule.exitActions, ruleAction)
        })
        page.onInterfaceSelected.connect(function(interfaceName) {
            print("interface selected", interfaceName)
            ruleAction.interfaceName = interfaceName;
            selectRuleActionData(root.rule.exitActions, ruleAction)
        })
    }

    function selectRuleActionData(ruleActions, ruleAction) {
        print("opening with ruleAction", ruleAction)
        var ruleActionPage = pageStack.push(Qt.resolvedUrl("SelectRuleActionPage.qml"), {text: "Select action", ruleAction: ruleAction });
        ruleActionPage.onBackPressed.connect(function() {
            pageStack.pop(root);
            ruleAction.destroy();
        })
        ruleActionPage.onDone.connect(function() {
            ruleActions.addRuleAction(ruleAction)
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

            ThinDivider { visible: !root.hasExitActions }

            Label {
                Layout.fillWidth: true
                Layout.margins: app.margins
                font.pixelSize: app.mediumFont
                text: "Events triggering this rule"
                visible: !root.hasExitActions
            }

            Repeater {
                id: eventsRepeater
                model: root.hasExitActions ? null : root.rule.eventDescriptors
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
                                model: eventDelegate.eventDescriptor.paramDescriptors
                                Label {
                                    text: {
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
                visible: !root.hasExitActions
            }

            ThinDivider {}

            Label {
                text: "Conditions to be met"
                font.pixelSize: app.mediumFont
                Layout.fillWidth: true
                Layout.margins: app.margins
            }

            StateEvaluatorDelegate {
                Layout.fillWidth: true
                stateEvaluator: root.rule.stateEvaluator
                visible: root.rule.stateEvaluator !== null
            }

            Button {
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: "Add a condition"
                visible: root.rule.stateEvaluator === null
                onClicked: {
                    root.rule.createStateEvaluator();
//                    root.editStateEvaluator()
                }
            }

            ThinDivider { visible: root.actionsVisible }

            Label {
                text: root.isStateBased ? "Active state enter actions" : "Actions to execute"
                font.pixelSize: app.mediumFont
                Layout.fillWidth: true
                Layout.margins: app.margins
                visible: root.actionsVisible
            }

            Repeater {
                id: actionsRepeater
                model: root.actionsVisible ? root.rule.actions : null
                delegate: SwipeDelegate {
                    id: actionDelegate
                    Layout.fillWidth: true
                    property var ruleAction: root.rule.actions.get(index)
                    property var device: ruleAction.deviceId ? Engine.deviceManager.devices.getDevice(ruleAction.deviceId) : null
                    property var iface: ruleAction.interfaceName ? Interfaces.findByName(ruleAction.interfaceName) : null
                    property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
                    property var actionType: deviceClass ? deviceClass.actionTypes.getActionType(ruleAction.actionTypeId)
                                                         : iface ? iface.actionTypes.findByName(ruleAction.interfaceAction) : null
                    contentItem: ColumnLayout {
                        Label {
                            Layout.fillWidth: true
                            text: qsTr("%1 - %2").arg(actionDelegate.device ? actionDelegate.device.name : actionDelegate.iface.displayName).arg(actionDelegate.actionType.displayName)
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: app.margins
                            Repeater {
                                model: actionDelegate.ruleAction.ruleActionParams
                                Label {
                                    text: actionDelegate.actionType.paramTypes.getParamType(model.paramTypeId).displayName + " -> " + model.value
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
                        onClicked: root.rule.actions.removeRuleAction(index)
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: actionsRepeater.count == 0 ? "Add an action..." : "Add another action..."
                onClicked: root.addAction();
                visible: root.actionsVisible
            }

            ThinDivider { visible: root.exitActionsVisible }

            Label {
                text: "Active state exit actions"
                font.pixelSize: app.mediumFont
                Layout.fillWidth: true
                Layout.margins: app.margins
                visible: root.exitActionsVisible
            }


            Repeater {
                id: exitActionsRepeater
                model: root.exitActionsVisible ? root.rule.exitActions : null
                delegate: SwipeDelegate {
                    id: exitActionDelegate
                    Layout.fillWidth: true
                    property var ruleAction: root.rule.exitActions.get(index)
                    property var device: ruleAction.deviceId ? Engine.deviceManager.devices.getDevice(ruleAction.deviceId) : null
                    property var iface: ruleAction.interfaceName ? Interfaces.findByName(ruleAction.interfaceName) : null
                    property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
                    property var actionType: deviceClass ? deviceClass.actionTypes.getActionType(ruleAction.actionTypeId)
                                                         : iface ? iface.actionTypes.findByName(ruleAction.interfaceAction) : null
                    contentItem: ColumnLayout {
                        Label {
                            Layout.fillWidth: true
                            text: qsTr("%1 - %2").arg(exitActionDelegate.device ? exitActionDelegate.device.name : exitActionDelegate.iface.displayName).arg(exitActionDelegate.actionType.displayName)
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: app.margins
                            Repeater {
                                model: exitActionDelegate.ruleAction.ruleActionParams
                                Label {
                                    text: exitActionDelegate.actionType.paramTypes.getParamType(model.paramTypeId).displayName + " -> " + model.value
                                    font.pixelSize: app.smallFont
                                }
                            }
                        }
                    }
                    swipe.right: MouseArea {
                        height: exitActionDelegate.height
                        width: height
                        anchors.right: parent.right
                        ColorIcon {
                            anchors.fill: parent
                            anchors.margins: app.margins
                            name: "../images/delete.svg"
                            color: "red"
                        }
                        onClicked: root.rule.exitActions.removeRuleAction(index)
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: actionsRepeater.count == 0 ? "Add an action..." : "Add another action..."
                onClicked: root.addExitAction();
                visible: root.exitActionsVisible
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
