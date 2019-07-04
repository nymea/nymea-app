import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

DevicePageBase {
    id: root

    GenericTypeLogView {
        id: logView
        anchors.fill: parent

        logsModel: engine.jsonRpcClient.ensureServerVersion("1.10") ? logsModelNg : logsModel
        LogsModelNg {
            id: logsModelNg
            engine: _engine
            deviceId: root.device.id
            live: true
            typeIds: [root.deviceClass.eventTypes.findByName("triggered").id];
        }
        LogsModel {
            id: logsModel
            engine: _engine
            deviceId: root.device.id
            live: true
            Component.onCompleted: update()
            typeIds: [root.deviceClass.eventTypes.findByName("triggered").id];
        }

//        delegate: NymeaListItemDelegate {
//            width: parent.width
//            iconName: app.interfaceToIcon("inputtrigger")
//            text: model.value.trim()
//            subText: Qt.formatDateTime(model.timestamp)
//            progressive: false

//            onClicked: {
//                print("a", model.value.trim())
//                var parts = model.value.trim().split(', ')
//                print("b", parts)
//                var popup = detailsPopup.createObject(root, {timestamp: model.timestamp, notificationTitle: parts[1], notificationBody: parts[0]});
//                popup.open();
//            }
//        }

        onAddRuleClicked: {
            var value = logView.logsModel.get(index).value
            var typeId = logView.logsModel.get(index).typeId
            var rule = engine.ruleManager.createNewRule();
            var eventDescriptor = rule.eventDescriptors.createNewEventDescriptor();
            eventDescriptor.deviceId = device.id;
            var eventType = root.deviceClass.eventTypes.getEventType(typeId);
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
