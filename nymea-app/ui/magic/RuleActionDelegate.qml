import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

MeaListItemDelegate {
    id: root
    implicitHeight: app.delegateHeight
    canDelete: true
    progressive: false

    property RuleAction ruleAction: null

    property var device: ruleAction.deviceId ? engine.deviceManager.devices.getDevice(ruleAction.deviceId) : null
    property var iface: ruleAction.interfaceName ? Interfaces.findByName(ruleAction.interfaceName) : null
    property var deviceClass: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
    property var actionType: deviceClass ? deviceClass.actionTypes.getActionType(ruleAction.actionTypeId)
                                         : iface ? iface.actionTypes.findByName(ruleAction.interfaceAction) : null

    signal removeRuleAction()

    onDeleteClicked: root.removeRuleAction()

    iconName: root.device ? "../images/action.svg" : "../images/action-interface.svg"
    text: qsTr("%1 - %2").arg(root.device ? root.device.name : root.iface.displayName).arg(root.actionType.displayName)
    subText: {
        var ret = [];
        for (var i = 0; i < root.ruleAction.ruleActionParams.count; i++) {
            var ruleActionParam = root.ruleAction.ruleActionParams.get(i)
            print("populating subtext:", ruleActionParam.eventTypeId, ruleActionParam.eventParamTypeId, ruleActionParam.stateDeviceId, ruleActionParam.stateTypeId, ruleActionParam.isValueBased, ruleActionParam.isEventParamBased, ruleActionParam.isStateValueBased)


            var paramString = qsTr("%1: %2").arg(root.actionType.paramTypes.getParamType(ruleActionParam.paramTypeId).displayName)
            if (ruleActionParam.isValueBased) {
                paramString = paramString.arg(ruleActionParam.value)
            } else if (ruleActionParam.isEventParamBased) {
                paramString = paramString.arg(qsTr("value from event"))
            } else if (ruleActionParam.isStateValueBased) {
                var stateDevice = engine.deviceManager.devices.getDevice(ruleActionParam.stateDeviceId)
                var stateType = stateDevice.deviceClass.stateTypes.getStateType(ruleActionParam.stateTypeId)
                print("have state value based param:", stateDevice.name)
                paramString = paramString.arg(stateDevice.name + "." + stateType.displayName)

            }

            ret.push(paramString)
        }
        return ret.join(', ')
    }
}
