import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Guh 1.0
import "../components"

Page {
    id: root
    property var device: null
    readonly property var deviceClass: Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId)


    header: GuhHeader {
        text: device.name
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/info.svg"
            onClicked: pageStack.push(Qt.resolvedUrl("GenericDeviceStateDetailsPage.qml"), {device: root.device})
        }
    }

    ColumnLayout {
        anchors { fill: parent }
        spacing: app.margins
        Label {
            Layout.fillWidth: true
            Layout.margins: app.margins
            text: "When this switch is pressed..."
            visible: actionListView.count > 0
        }

        ListView {
            id: actionListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: RulesFilterModel {
                id: rulesFilterModel
                rules: Engine.ruleManager.rules
                filterEventDeviceId: root.device.id
            }
            delegate: SwipeDelegate {
                width: parent.width
                property var ruleActions: rulesFilterModel.get(index).ruleActions
                property var ruleAction: ruleActions.count == 1 ? ruleActions.get(0) : null
                property var ruleActionType: ruleAction ? ruleActionDeviceClass.actionTypes.getActionType(ruleAction.actionTypeId) : null
                property var ruleActionDevice: ruleAction ? Engine.deviceManager.devices.getDevice(ruleAction.deviceId) : null
                property var ruleActionDeviceClass: ruleActionDevice ? Engine.deviceManager.deviceClasses.getDeviceClass(ruleActionDevice.deviceClassId) : null
                property var ruleActionParams: ruleAction ? ruleAction.ruleActionParams : null
                property var ruleActionParam: ruleActionParams.count == 1 ? ruleActionParams.get(0) : null
                text: ruleActions.count > 1 ? "Multiple actions" : qsTr("%1: Set %2 to %3").arg(ruleActionDevice.name).arg(ruleActionType.name).arg(ruleActionParam.value)
                swipe.right: MouseArea {
                    anchors.right: parent.right
                    height: parent.height
                    width: height
                    ColorIcon {
                        anchors.fill: parent
                        anchors.margins: app.margins
                        name: "../images/delete.svg"
                        color: "red"
                    }
                    onClicked: {
                        Engine.ruleManager.removeRule(rulesFilterModel.get(index).id)
                    }
                }
            }

            Label {
                width: parent.width - (app.margins * 2)
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                anchors.centerIn: parent
                text: "No actions configured for this switch. You may add some actions for this switch by using the \"Add action\" button at the bottom."
                visible: actionListView.count == 0
            }
        }

        Button {
            Layout.fillWidth: true
            Layout.margins: app.margins
            text: "Add an action"
            onClicked: {
                var page = pageStack.push(Qt.resolvedUrl("../magic/SelectActionPage.qml"), {text: "When this switch is pressed..."});
                page.complete.connect(function() {
                    print("have action:", page.device, page.actionType, page.params)
                    var rule = {};
                    rule["name"] = root.device.name + " pressed"
                    var events = [];
                    var event = {};
                    event["deviceId"] = root.device.id;
                    var eventDeviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(root.device.deviceClassId)
                    event["eventTypeId"] = eventDeviceClass.eventTypes.findByName("pressed").id;
                    events.push(event);
                    rule["eventDescriptors"] = events;
                    var actions = [];
                    var action = {};
                    action["actionTypeId"] = page.actionType.id;
                    action["deviceId"] = page.device.id;
                    action["ruleActionParams"] = page.params;
                    actions.push(action);
                    rule["actions"] = actions;
                    Engine.ruleManager.addRule(rule);
                    pageStack.pop(root)
                })
            }
        }
    }
}
