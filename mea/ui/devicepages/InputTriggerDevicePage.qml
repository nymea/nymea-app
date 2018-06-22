import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Mea 1.0
import "../components"
import "../customviews"

GenericDevicePage {
    id: root

    GenericTypeLogView {
        anchors.fill: parent
        text: qsTr("This event has appeared %1 times in the last 24 hours.")

        logsModel: LogsModel {
            deviceId: root.device.id
            live: true
            Component.onCompleted: update()
            typeIds: [root.deviceClass.eventTypes.findByName("triggered").id];
        }

        onAddRuleClicked: {
            var rule = Engine.ruleManager.createNewRule();
            var eventDescriptor = rule.eventDescriptors.createNewEventDescriptor();
            eventDescriptor.deviceId = device.id;
            var eventType = root.deviceClass.eventTypes.findByName("triggered");
            eventDescriptor.eventTypeId = eventType.id;
            rule.name = root.device.name + " - " + eventType.displayName;
            if (eventType.paramTypes.count === 1) {
                var paramType = eventType.paramTypes.get(0);
                eventDescriptor.paramDescriptors.setParamDescriptor(paramType.id, value, ParamDescriptor.ValueOperatorEquals);
                rule.eventDescriptors.addEventDescriptor(eventDescriptor);
                rule.name = rule.name + " - " + value
            }
            var rulePage = pageStack.push(Qt.resolvedUrl("../magic/DeviceRulesPage.qml"), {device: root.device});
            rulePage.addRule(rule);
        }
    }
}
