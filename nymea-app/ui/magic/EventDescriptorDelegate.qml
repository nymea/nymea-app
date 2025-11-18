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

    property EventDescriptor eventDescriptor: null
    readonly property Thing thing: eventDescriptor ? engine.thingManager.things.getThing(eventDescriptor.thingId) : null
    readonly property ThingClass thingClass: thing ? engine.thingManager.thingClasses.getThingClass(thing.thingClassId) : null
    readonly property Interface iface: eventDescriptor.interfaceName ? Interfaces.findByName(eventDescriptor.interfaceName) : null
    readonly property EventType eventType: thingClass ? thingClass.eventTypes.getEventType(eventDescriptor.eventTypeId)
                                                 : iface ? iface.eventTypes.findByName(eventDescriptor.interfaceEvent) : null
    readonly property StateType stateType: thingClass ? thingClass.stateTypes.getStateType(eventDescriptor.eventTypeId)
                                                      : iface ? iface.stateTypes.findByName(eventDescriptor.interfaceEvent) : null
    readonly property var actualEventType: eventType || stateType

    signal removeEventDescriptor()

    onDeleteClicked: root.removeEventDescriptor()

    iconName: root.thing ? "qrc:/icons/event.svg" : "qrc:/icons/event-interface.svg"
    text: "%1 - %2".arg(root.thing ? root.thing.name : root.iface.displayName).arg(root.actualEventType.displayName)
    subText: {
        var ret = qsTr("anytime");
        for (var i = 0; i < root.eventDescriptor.paramDescriptors.count; i++) {
            var paramDescriptor = root.eventDescriptor.paramDescriptors.get(i)
            var operatorString;
            switch (paramDescriptor.operatorType) {
            case ParamDescriptor.ValueOperatorEquals:
                operatorString = " = ";
                break;
            case ParamDescriptor.ValueOperatorNotEquals:
                operatorString = " != ";
                break;
            case ParamDescriptor.ValueOperatorGreater:
                operatorString = " > ";
                break;
            case ParamDescriptor.ValueOperatorGreaterOrEqual:
                operatorString = " >= ";
                break;
            case ParamDescriptor.ValueOperatorLess:
                operatorString = " < ";
                break;
            case ParamDescriptor.ValueOperatorLessOrEqual:
                operatorString = " <= ";
                break;
            default:
                operatorString = " ? ";
            }

            print("**", root.eventType, root.stateType, paramDescriptor.paramName, paramDescriptor.paramTypeId)
            var paramType = root.eventType ?
                        (paramDescriptor.paramName ? root.eventType.paramTypes.findByName(paramDescriptor.paramName) : root.eventType.paramTypes.getParamType(paramDescriptor.paramTypeId) )
                      : root.stateType

            if (i === 0) {
                // TRANSLATORS: example: "only if temperature > 5"
                ret = qsTr("only if %1 %2 %3")
                .arg(paramType.displayName)
                .arg(operatorString)
                .arg(paramDescriptor.value)
            } else {
                // TRANSLATORS: example: "and temperature > 5"
                ret += " " + qsTr("and %1 %2 %3")
                .arg(paramType.displayName)
                .arg(operatorString)
                .arg(paramDescriptor.value)
            }
        }

        return ret;
    }
}
