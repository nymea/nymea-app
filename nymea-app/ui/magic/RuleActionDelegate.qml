/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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
