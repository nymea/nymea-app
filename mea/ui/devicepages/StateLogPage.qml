import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Mea 1.0
import "../components"
import "../customviews"

Page {
    id: root

    property var device: null
    property var stateType: null

    header: GuhHeader {
        text: qsTr("History")
        onBackPressed: pageStack.pop()
    }

    GenericTypeLogView {
        anchors.fill: parent
        device: root.device
        typeId: root.stateType.id
        text: qsTr("%1, %2 has changed %3 times in the last 24h").arg(device.name).arg(stateType.displayName)

        onAddRuleClicked: {
            var rule = Engine.ruleManager.createNewRule();
            rule.createStateEvaluator();
            rule.stateEvaluator.stateDescriptor.deviceId = device.id;
            rule.stateEvaluator.stateDescriptor.stateTypeId = root.stateType.id;
            rule.stateEvaluator.stateDescriptor.value = value;
            rule.stateEvaluator.stateDescriptor.valueOperator = StateDescriptor.ValueOperatorEquals;
            rule.name = root.device.name + " - " + stateType.displayName + " = " + value;

            var rulePage = pageStack.push(Qt.resolvedUrl("../magic/DeviceRulesPage.qml"), {device: root.device});
            rulePage.addRule(rule);
        }

    }
}

