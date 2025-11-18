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

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

ThingPageBase {
    id: root

    readonly property bool isVirtualButton: thing.thingClassId.toString().indexOf("820b2f2d-0d92-48c8-8fd4-f94ce8fc4103") >= 0
    readonly property bool isVirtualSwitch: thing.thingClassId.toString().indexOf("8ea0a168-74ff-4445-8c13-74aab195af4e") >= 0
    readonly property bool isVirtual: isVirtualButton || isVirtualSwitch

    readonly property State powerState: thing ? thing.stateByName("power") : null

    Loader {
        anchors.fill: parent
        visible: !root.isVirtual
        sourceComponent: {
            if (engine.jsonRpcClient.ensureServerVersion("8.0")) {
                return logViewComponent
            } else {
                return logViewComponentPre80
            }
        }
    }

    Component {
        id: logViewComponent

        ListView {
            id: logView
            anchors.fill: parent
            ScrollBar.vertical: ScrollBar {}

            model: NewLogsModel {
                id: logsModel
                engine: _engine
                sources: ["event-" + root.thing.id + "-pressed", "event-" + root.thing.id + "-longPressed"]
                live: true
                sortOrder: Qt.DescendingOrder
                fetchBlockSize: 200 // As paging doesn't work with multiple sources
            }

            Component.onCompleted: print("**************** created", logsModel.sources)

            delegate: NymeaItemDelegate {
                id: entryDelegate
                width: logView.width

                property NewLogEntry entry: logsModel.get(index)
                property EventType eventType: {
                    switch (entry.source) {
                    case "event-" + root.thing.id + "-pressed":
                        return root.thing.thingClass.eventTypes.findByName("pressed")
                    case "event-" + root.thing.id + "-longPressed":
                        return root.thing.thingClass.eventTypes.findByName("longPressed")
                    }
                    return null
                }

                contentItem: ColumnLayout {
                    RowLayout {
                        Label {
                            text: entryDelegate.eventType.displayName
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            font: Style.smallFont
                        }
                        Label {
                            text: Qt.formatDateTime(model.timestamp,"dd.MM.yy hh:mm:ss")
                            elide: Text.ElideRight
                            font.pixelSize: app.smallFont
                            enabled: false
                        }
                    }
                    Label {
                        Layout.fillWidth: true
                        text: {
                            var ret = []
                            var values = JSON.parse(entry.values.params)
                            for (var i = 0; i < entryDelegate.eventType.paramTypes.count; i++) {
                                var paramType = entryDelegate.eventType.paramTypes.get(i)
                                ret.push(paramType.displayName + ": " + Types.toUiValue(values[paramType.name], paramType.unit) + " " + Types.toUiUnit(paramType.unit))
                            }
                            return ret.join(", ")
                        }
                    }
                }
            }

//            onAddRuleClicked: {
//                var value = logView.logsModel.get(index).value
//                var typeId = logView.logsModel.get(index).typeId
//                var rule = engine.ruleManager.createNewRule();
//                var eventDescriptor = rule.eventDescriptors.createNewEventDescriptor();
//                eventDescriptor.thingId = root.thing.id;
//                var eventType = root.thing.thingClass.eventTypes.getEventType(typeId);
//                eventDescriptor.eventTypeId = eventType.id;
//                rule.name = root.thing.name + " - " + eventType.displayName;
//                if (eventType.paramTypes.count === 1) {
//                    var paramType = eventType.paramTypes.get(0);
//                    eventDescriptor.paramDescriptors.setParamDescriptor(paramType.id, value, ParamDescriptor.ValueOperatorEquals);
//                    rule.eventDescriptors.addEventDescriptor(eventDescriptor);
//                    rule.name = rule.name + " - " + value
//                }
//                var rulePage = pageStack.push(Qt.resolvedUrl("../magic/ThingRulesPage.qml"), {thing: root.thing});
//                rulePage.addRule(rule);
//            }

            EmptyViewPlaceholder {
                anchors { left: parent.left; right: parent.right; margins: app.margins }
                anchors.verticalCenter: parent.verticalCenter

                title: qsTr("This switch has not been used yet.")
                text: qsTr("Press a button on the switch to see logs appearing here.")
                visible: !logsModel.busy && logsModel.count === 0
                buttonVisible: false
                imageSource: "qrc:/icons/system-shutdown.svg"
            }
        }
    }

    Component {
        id: logViewComponentPre80

        GenericTypeLogView {
            id: logView
            anchors.fill: parent

            logsModel: LogsModel {
                id: logsModel
                engine: _engine
                thingId: root.thing.id
                live: true
                typeIds: {
                    var ret = [];
                    ret.push(root.thing.thingClass.eventTypes.findByName("pressed").id)
                    if (root.thing.thingClass.eventTypes.findByName("longPressed")) {
                        ret.push(root.thing.thingClass.eventTypes.findByName("longPressed").id)
                    }
                    return ret;
                }
            }

            onAddRuleClicked: {
                var value = logView.logsModel.get(index).value
                var typeId = logView.logsModel.get(index).typeId
                var rule = engine.ruleManager.createNewRule();
                var eventDescriptor = rule.eventDescriptors.createNewEventDescriptor();
                eventDescriptor.thingId = root.thing.id;
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

            EmptyViewPlaceholder {
                anchors { left: parent.left; right: parent.right; margins: app.margins }
                anchors.verticalCenter: parent.verticalCenter

                title: qsTr("This switch has not been used yet.")
                text: qsTr("Press a button on the switch to see logs appearing here.")
                visible: !logsModel.busy && logsModel.count === 0 && !root.isVirtual
                buttonVisible: false
                imageSource: "qrc:/icons/system-shutdown.svg"
            }
        }
    }

    CircleBackground {
        id: background
        anchors.fill: parent
        anchors.margins: Style.hugeMargins
        iconSource: "system-shutdown"
        visible: root.isVirtual
        onColor: Style.accentColor
        on: root.isVirtualButton ? pressAnimationTimer.running : root.powerState && root.powerState.value === true
        onClicked: {
            PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
            if (root.isVirtualButton) {
                root.thing.executeAction("press", [])
                pressAnimationTimer.start()
            } else {
                root.thing.executeAction("power", [{paramName: "power", value: !background.on}])
            }
        }
        Timer {
            id: pressAnimationTimer
            interval: Style.animationDuration
        }
    }
}
