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

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

ThingPageBase {
    id: root

    property var interfaceEventMap: {
        "inputtrigger": "triggered",
        "vibrationsensor": "vibrationDetected"
    }

    readonly property string interfaceName: {
        var supportedInterfaces = Object.keys(interfaceEventMap)
        for (var i = 0; i < supportedInterfaces.length; i++) {
            if (root.thing.thingClass.interfaces.indexOf(supportedInterfaces[i]) >= 0) {
                return supportedInterfaces[i]
            }
        }
        return ""
    }

    readonly property string eventName: interfaceEventMap[interfaceName]

    GridLayout {
        anchors.fill: parent
        columns: app.landscape ? 2 : 1
        rowSpacing: 0
        columnSpacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: width
            Layout.margins: Style.hugeMargins

            CircleBackground {
                id: iconView
                width: Math.min(parent.width, parent.height)
                height: width
                anchors.centerIn: parent
                iconSource: app.interfaceToIcon(root.interfaceName)
                onColor: app.interfaceToColor(root.interfaceName)
                on: false
                Timer {
                    running: parent.on
                    repeat: false
                    interval: 1000
                    onTriggered: {
                        parent.on = false
                    }
                }
            }
        }


        GenericTypeLogView {
            id: logView
            Layout.fillWidth: true
            Layout.fillHeight: true

            logsModel: logsModel
            LogsModel {
                id: logsModel
                engine: _engine
                thingId: root.thing.id
                live: true
                typeIds: [root.thing.thingClass.eventTypes.findByName(root.eventName).id];
                onCountChanged: {
                    if (!logsModel.busy) {
                        iconView.on = true
                    }
                }
            }

            onAddRuleClicked: {
                var value = logView.logsModel.get(index).value
                var typeId = logView.logsModel.get(index).typeId
                var rule = engine.ruleManager.createNewRule();
                var eventDescriptor = rule.eventDescriptors.createNewEventDescriptor();
                eventDescriptor.thingId = thing.id;
                var eventType = root.thing.thingClass.eventTypes.getEventType(typeId);
                eventDescriptor.eventTypeId = eventType.id;
                rule.name = root.thing.name + " - " + eventType.displayName;
                if (eventType.paramTypes.count === 1) {
                    var paramType = eventType.paramTypes.get(0);
                    eventDescriptor.paramDescriptors.setParamDescriptor(paramType.id, value, ParamDescriptor.ValueOperatorEquals);
                }
                rule.eventDescriptors.addEventDescriptor(eventDescriptor);
                rule.name = rule.name + " - " + value
                var rulePage = pageStack.push(Qt.resolvedUrl("../magic/ThingRulesPage.qml"), {thing: root.thing});
                rulePage.addRule(rule);
            }
        }
    }


}
