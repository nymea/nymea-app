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

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

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
