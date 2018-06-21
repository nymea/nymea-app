import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Mea 1.0
import "../components"

MeaListItemDelegate {
    id: root
    implicitHeight: app.delegateHeight
    canDelete: true
    progressive: false

    property var ruleAction: null

    property var device: ruleAction.deviceId ? Engine.deviceManager.devices.getDevice(ruleAction.deviceId) : null
    property var iface: ruleAction.interfaceName ? Interfaces.findByName(ruleAction.interfaceName) : null
    property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
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
            var paramString = qsTr("%1: %2")
            .arg(root.actionType.paramTypes.getParamType(ruleActionParam.paramTypeId).displayName)
            .arg(ruleActionParam.eventParamTypeId.length > 0 ? qsTr("value from event") : ruleActionParam.value)
            ret.push(paramString)
        }
        return ret.join(', ')
    }
}
