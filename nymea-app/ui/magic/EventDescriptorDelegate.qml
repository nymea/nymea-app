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

    property EventDescriptor eventDescriptor: null
    readonly property Thing thing: eventDescriptor ? engine.thingManager.things.getThing(eventDescriptor.thingId) : null
    readonly property ThingClass thingClass: thing ? engine.thingManager.thingClasses.getThingClass(thing.thingClassId) : null
    readonly property Interface iface: eventDescriptor.interfaceName ? Interfaces.findByName(eventDescriptor.interfaceName) : null
    readonly property EventType eventType: thingClass ? thingClass.eventTypes.getEventType(eventDescriptor.eventTypeId)
                                                 : iface ? iface.eventTypes.findByName(eventDescriptor.interfaceEvent) : null

    signal removeEventDescriptor()

    onDeleteClicked: root.removeEventDescriptor()

    iconName: root.thing ? "../images/event.svg" : "../images/event-interface.svg"
    text: qsTr("%1 - %2").arg(root.thing ? root.thing.name : root.iface.displayName).arg(root.eventType.displayName)
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

            var paramType = paramDescriptor.paramName
                    ? root.eventType.paramTypes.findByName(paramDescriptor.paramName)
                    : root.eventType.paramTypes.getParamType(paramDescriptor.paramTypeId)

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
