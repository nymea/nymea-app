// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
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

    iconName: root.thing ? (root.browserItemId ? "qrc:/icons/browser/BrowserIconFolder.svg" : "qrc:/icons/action.svg") : "qrc:/icons/action-interface.svg"
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
                    text = ruleActionParam.value === true ? qsTr("Yes") : qsTr("No")
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
