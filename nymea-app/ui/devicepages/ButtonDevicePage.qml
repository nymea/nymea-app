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

DevicePageBase {
    id: root

    EmptyViewPlaceholder {
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        anchors.verticalCenter: parent.verticalCenter

        title: qsTr("This switch has not been used yet.")
        text: qsTr("Press a button on the switch to see logs appearing here.")
        visible: logView.logsModel.count === 0
        buttonVisible: false
        imageSource: "../images/system-shutdown.svg"
    }

    GenericTypeLogView {
        id: logView
        anchors.fill: parent

        logsModel: engine.jsonRpcClient.ensureServerVersion("1.10") ? logsModelNg : logsModel
        LogsModelNg {
            id: logsModelNg
            engine: _engine
            deviceId: root.device.id
            live: true
            typeIds: {
                var ret = [];
                ret.push(root.deviceClass.eventTypes.findByName("pressed").id)
                if (root.deviceClass.eventTypes.findByName("longPressed")) {
                    ret.push(root.deviceClass.eventTypes.findByName("longPressed").id)
                }
                return ret;
            }
        }
        LogsModel {
            id: logsModel
            engine: _engine
            deviceId: root.device.id
            live: true
            typeIds: {
                var ret = [];
                ret.push(root.deviceClass.eventTypes.findByName("pressed").id)
                if (root.deviceClass.eventTypes.findByName("longPressed")) {
                    ret.push(root.deviceClass.eventTypes.findByName("longPressed").id)
                }
                return ret;
            }
            Component.onCompleted: update()
        }

        onAddRuleClicked: {
            var value = logView.logsModel.get(index).value
            var typeId = logView.logsModel.get(index).typeId
            var rule = engine.ruleManager.createNewRule();
            var eventDescriptor = rule.eventDescriptors.createNewEventDescriptor();
            eventDescriptor.deviceId = device.id;
            var eventType = root.deviceClass.eventTypes.getEventType(typeId);
            eventDescriptor.eventTypeId = eventType.id;
            rule.name = root.device.name + " - " + eventType.displayName;
            if (eventType.paramTypes.count === 1) {
                var paramType = eventType.paramTypes.get(0);
                eventDescriptor.paramDescriptors.setParamDescriptor(paramType.id, value, ParamDescriptor.ValueOperatorEquals);
                rule.eventDescriptors.addEventDescriptor(eventDescriptor);
                rule.name = rule.name + " - " + value
            }
            var rulePage = pageStack.push(Qt.resolvedUrl("../magic/DeviceRulesPage.qml"), {device: root.device});
            rulePage.addRule(rule);
        }
    }
}
