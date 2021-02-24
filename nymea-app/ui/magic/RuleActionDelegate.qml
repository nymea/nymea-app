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

NymeaSwipeDelegate {
    id: root
    implicitHeight: app.delegateHeight
    canDelete: true
    progressive: false

    property RuleAction ruleAction: null

    readonly property Thing thing: ruleAction.thingId ? engine.thingManager.things.getThing(ruleAction.thingId) : null
    readonly property Interface iface: ruleAction.interfaceName ? Interfaces.findByName(ruleAction.interfaceName) : null
    readonly property ActionType actionType: thing ? thing.thingClass.actionTypes.getActionType(ruleAction.actionTypeId)
                                         : iface ? iface.actionTypes.findByName(ruleAction.interfaceAction) : null
    readonly property string browserItemId: ruleAction.browserItemId
    readonly property BrowserItem browserItem: thing && browserItemId.length > 0 ? engine.thingManager.browserItem(thing.id, browserItemId) : null

    signal removeRuleAction()

    onDeleteClicked: root.removeRuleAction()

    iconName: root.thing ? (root.browserItemId ? "../images/browser/BrowserIconFolder.svg" : "../images/action.svg") : "../images/action-interface.svg"
    text: qsTr("%1 - %2")
        .arg(root.thing ? root.thing.name : root.iface.displayName)
        .arg(root.actionType ? root.actionType.displayName : (root.browserItem.displayName.length > 0 ? root.browserItem.displayName : qsTr("Unknown item")))
    subText: {
        var ret = [];
        for (var i = 0; i < root.ruleAction.ruleActionParams.count; i++) {
            var ruleActionParam = root.ruleAction.ruleActionParams.get(i)
            print("populating subtext:", ruleActionParam.eventTypeId, ruleActionParam.eventParamTypeId, ruleActionParam.stateThingId, ruleActionParam.stateTypeId, ruleActionParam.isValueBased, ruleActionParam.isEventParamBased, ruleActionParam.isStateValueBased)

            var paramType = root.actionType.paramTypes.getParamType(ruleActionParam.paramTypeId);
            var paramString = qsTr("%1: %2").arg(paramType.displayName)
            if (ruleActionParam.isValueBased) {
                var text = ""
                switch (paramType.type.toLowerCase()) {
                case "bool":
                    text = ruleActionParam.value === true ? qsTr("True") : qsTr("False")
                    break;
                case "color":
                    text = "<font color=\"" + ruleActionParam.value + "\">⬤</font>"
                    break;
                default:
                    text = ruleActionParam.value
                }
                paramString = paramString.arg(text)
            } else if (ruleActionParam.isEventParamBased) {
                paramString = paramString.arg(qsTr("value from event"))
            } else if (ruleActionParam.isStateValueBased) {
                var stateThing = engine.thingManager.things.getThing(ruleActionParam.stateThingId)
                var stateType = stateThing.thingClass.stateTypes.getStateType(ruleActionParam.stateTypeId)
                print("have state value based param:", stateThing.name)
                paramString = paramString.arg("{" + stateThing.name + " - " + stateType.displayName + "}")
            }

            ret.push(paramString)
        }
        return ret.join(', ')
    }
}
