import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

NymeaListItemDelegate {
    id: root
    implicitHeight: app.delegateHeight
    canDelete: true
    progressive: false

    property RuleAction ruleAction: null

    readonly property Device device: ruleAction.deviceId ? engine.deviceManager.devices.getDevice(ruleAction.deviceId) : null
    readonly property Interface iface: ruleAction.interfaceName ? Interfaces.findByName(ruleAction.interfaceName) : null
    readonly property DeviceClass deviceClass: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
    readonly property ActionType actionType: deviceClass ? deviceClass.actionTypes.getActionType(ruleAction.actionTypeId)
                                         : iface ? iface.actionTypes.findByName(ruleAction.interfaceAction) : null
    readonly property string browserItemId: ruleAction.browserItemId
    readonly property BrowserItem browserItem: device && browserItemId.length > 0 ? engine.deviceManager.browserItem(device.id, browserItemId) : null

    signal removeRuleAction()

    onDeleteClicked: root.removeRuleAction()

    iconName: root.device ? (root.browserItemId ? "../images/browser/BrowserIconFolder.svg" : "../images/action.svg") : "../images/action-interface.svg"
    text: qsTr("%1 - %2")
        .arg(root.device ? root.device.name : root.iface.displayName)
        .arg(root.actionType ? root.actionType.displayName : (root.browserItem.displayName.length > 0 ? root.browserItem.displayName : qsTr("Unknown item")))
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
                paramString = paramString.arg("{" + stateDevice.name + " - " + stateType.displayName + "}")
            }

            ret.push(paramString)
        }
        return ret.join(', ')
    }
}
