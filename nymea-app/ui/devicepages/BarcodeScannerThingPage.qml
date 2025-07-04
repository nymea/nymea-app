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

    EmptyViewPlaceholder {
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        anchors.verticalCenter: parent.verticalCenter

        title: qsTr("No codes have been scanned yet.")
        text: qsTr("Scan a code to see it appearing here.")
        visible: logView.logsModel.count === 0
        buttonVisible: false
        imageSource: "qrc:/icons/qrcode.svg"
    }

    Connections {
        target: logsModelNg
        onCountChanged: {
            codeLabel.text = logsModelNg.get(0).value
            timestampLabel.text = Qt.formatDateTime(logsModelNg.get(0).timestamp)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: app.margins
        visible: logView.logsModel.count > 0

        Label {
            Layout.fillWidth: true
            Layout.topMargin: app.margins
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Last scan")
        }

        FontMetrics {
            id: fontMetrics
            font.pixelSize: app.largeFont
        }

        Label {
            id: codeLabel
            Layout.fillWidth: true
            font.pixelSize: fontMetrics.boundingRect(text).width < root.width ? app.largeFont * 2 : app.mediumFont
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Label {
            id: timestampLabel
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        ThinDivider {}

        GenericTypeLogView {
            id: logView
            Layout.fillWidth: true
            Layout.fillHeight: true

            logsModel: logsModelNg
            LogsModelNg {
                id: logsModelNg
                engine: _engine
                thingId: root.thing.id
                live: true
                typeIds: [root.thing.thingClass.eventTypes.findByName("codeScanned").id]
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
                    rule.eventDescriptors.addEventDescriptor(eventDescriptor);
                    rule.name = rule.name + " - " + value
                }
                var rulePage = pageStack.push(Qt.resolvedUrl("../magic/ThingRulesPage.qml"), {thing: root.thing});
                rulePage.addRule(rule);
            }

        }
    }

}
