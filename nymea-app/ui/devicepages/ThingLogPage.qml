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
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

Page {
    id: root

    property Thing thing: null

    header: NymeaHeader {
        text: qsTr("History for %1").arg(root.thing.name)
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "qrc:/icons/filters.svg"
            color: logsModel.filterEnabled ? Style.accentColor : Style.iconColor
            onClicked: logsModel.filterEnabled = !logsModel.filterEnabled
            visible: root.filterTypeIds.length === 0
        }
    }

    NewLogsModel {
        id: logsModel
        engine: _engine
//        columns: [root.stateType.name]
        sources: {
            var ret = []
            if (filterEnabled) {
                if (isStateFilter) {
                    ret.push("state-" + root.thing.id + "-" + filterTypeName)
                } else if (isEventFilter) {
                    ret.push("event-" + root.thing.id + "-" + filterTypeName)
                } else if (isActionFilter) {
                    ret.push("action-" + root.thing.id + "-" + filterTypeName)
                }
                return ret;
            }

            for (var i = 0; i < root.thing.thingClass.stateTypes.count; i++) {
                var stateType = root.thing.thingClass.stateTypes.get(i)
                ret.push("state-" + root.thing.id + "-" + stateType.name)
            }
            for (var i = 0; i < root.thing.thingClass.eventTypes.count; i++) {
                var eventType = root.thing.thingClass.eventTypes.get(i)
                ret.push("event-" + root.thing.id + "-" + eventType.name)
            }
            for (var i = 0; i < root.thing.thingClass.actionTypes.count; i++) {
                var actionType = root.thing.thingClass.actionTypes.get(i)
                ret.push("action-" + root.thing.id + "-" + actionType.name)
            }
            return ret;
        }
        property string filterTypeName: filterDeviceModel.getData(filterComboBox.currentIndex, ThingModel.RoleName)
        property bool isStateFilter: thing.thingClass.stateTypes.findByName(filterTypeName) !== null
        property bool isEventFilter: thing.thingClass.eventTypes.findByName(filterTypeName) !== null
        property bool isActionFilter: thing.thingClass.actionTypes.findByName(filterTypeName) !== null

        onSourcesChanged: {
            logsModel.clear()
            logsModel.fetchLogs()
        }

//        thingId: root.thing.id
//        typeIds: root.filterTypeIds.length > 0
//                 ? root.filterTypeIds
//                 : filterEnabled
//                   ? [filterDeviceModel.getData(filterComboBox.currentIndex, ThingModel.RoleId)]
//                   : []
//        live: true

        onEntriesAdded: {
            console.log("entries added", JSON.stringify(entries))
        }

        property bool filterEnabled: false
    }

    ThingModel {
        id: filterDeviceModel
        thing: root.thing
    }

    Pane {
        id: filterPane
        anchors { left: parent.left; top: parent.top; right: parent.right }
        Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }

        height: logsModel.filterEnabled ? implicitHeight + app.margins * 2 : 0
        Material.elevation: 1

        leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
        contentItem: Item {
            clip: true
            RowLayout {
                anchors.fill: parent
                anchors.margins: app.margins
                spacing: app.margins
                Label {
                    text: qsTr("Filter by")
                }

                ComboBox {
                    id: filterComboBox
                    Layout.fillWidth: true
                    textRole: "displayName"
                    model: filterDeviceModel
                }
            }
        }
    }

    Loader {
        id: graphLoader
        anchors {
            left: parent.left
            top: filterPane.bottom
            right: parent.right
        }

        readonly property StateType stateType: root.thing.thingClass.stateTypes.getStateType(root.filterTypeIds[0])

        readonly property bool canShowGraph: {
            if (stateType === null) {
                return false
            }

            if (stateType.unit === Types.UnitUnixTime) {
                return false;
            }

            switch (stateType.type.toLowerCase()) {
            case "uint":
            case "int":
            case "double":
            case "bool":
                return true;
            }
            print("not showing graph for", stateType.type)
            return false;
        }

        Component.onCompleted: {
            if (root.filterTypeIds.length === 0) {
                return;
            }
            if (!canShowGraph) {
                return;
            }

            var source = Qt.resolvedUrl("../customviews/GenericTypeGraph.qml");
            setSource(source, {thing: root.thing, stateType: stateType})
        }
    }


    ListView {
        anchors { left: parent.left; top: graphLoader.bottom; right: parent.right; bottom: parent.bottom }
        clip: true
        model: logsModel
        ScrollBar.vertical: ScrollBar {}

        BusyIndicator {
            anchors.centerIn: parent
            visible: logsModel.busy
        }

        delegate: ItemDelegate {
            id: entryDelegate
            width: parent.width
            property NewLogEntry entry: logsModel.get(index)

            property StateType stateType: entry && entry.source.indexOf("state-") == 0 ? root.thing.thingClass.stateTypes.findByName(entry.source.replace(/.*-.*-/, "")) : null
            property EventType eventType: entry && entry.source.indexOf("event-") == 0 ? root.thing.thingClass.eventTypes.findByName(entry.source.replace(/.*-.*-/, "")) : null
            property ActionType actionType: entry && entry.source.indexOf("action-") == 0 ? root.thing.thingClass.actionTypes.findByName(entry.source.replace(/.*-.*-/, "")) : null

            contentItem: RowLayout {
                ColorIcon {
                    Layout.preferredWidth: Style.iconSize
                    Layout.preferredHeight: width
                    Layout.alignment: Qt.AlignVCenter
                    color: Style.accentColor
                    name: {
                        if (entryDelegate.stateType) {
                            return "qrc:/icons/state.svg"
                        }
                        if (entryDelegate.eventType) {
                            return "qrc:/icons/event.svg"
                        }
                        if (entryDelegate.actionType) {
                            return "qrc:/icons/action.svg"
                        }
                    }
                }
                ColumnLayout {
                    RowLayout {
                        Label {
                            text: {
                                if (entryDelegate.stateType) {
                                    return entryDelegate.stateType.displayName
                                }
                                if (entryDelegate.eventType) {
                                    return entryDelegate.eventType.displayName
                                }
                                if (entryDelegate.actionType) {
                                    return entryDelegate.actionType.displayName
                                }
                            }
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

                    RowLayout {
                        Loader {
                            id: valueLoader
                            Layout.fillWidth: true
                            sourceComponent: {
                                if (entryDelegate.stateType) {
                                    switch (entryDelegate.stateType.type.toLowerCase()) {
                                    case "bool":
                                        return boolComponent;
                                    case "color":
                                        return colorComponent
                                    case "double":
                                        return floatLabelComponent;
                                    default:
                                        if (entryDelegate.stateType.unit == Types.UnitUnixTime) {
                                            return dateTimeComponent
                                        }

                                        return labelComponent

                                    }

                                }

//                                switch (model.source) {
//                                case LogEntry.LoggingSourceStates:
//                                case LogEntry.LoggingSourceActions:
//                                    return labelComponent;
//                                case LogEntry.LoggingSourceEvents:

//                                    break;
//                                }

                                return labelComponent
                            }
                            Binding {
                                when: entryDelegate.stateType != null
                                target: valueLoader.item;
                                property: "value";
                                value: entryDelegate.stateType ? Types.toUiValue(entry.values[entryDelegate.stateType.name], entryDelegate.stateType.unit) : ""
                            }
                            Binding {
                                when: entryDelegate.stateType != null
                                target: entryDelegate.stateType && valueLoader.item.hasOwnProperty("unitString") ? valueLoader.item : null;
                                property: "unitString"
                                value: entryDelegate.stateType ? Types.toUiUnit(entryDelegate.stateType.unit) : ""
                            }
                            Binding {
                                when: entryDelegate.actionType != null
                                target: valueLoader.item;
                                property: "value";
                                value: {
                                    if (entryDelegate.actionType == null) {
                                        return ""
                                    }

                                    var ret = []
                                    var values = JSON.parse(model.values.params)
                                    for (var i = 0; i < entryDelegate.actionType.paramTypes.count; i++) {
                                        var paramType = entryDelegate.actionType.paramTypes.get(i)
                                        ret.push(paramType.displayName + ": " + Types.toUiValue(values[paramType.name], paramType.unit) + " " + Types.toUiUnit(paramType.unit))
                                    }
                                    return ret.join(", ")
                                }
                            }
                            Binding {
                                when: entryDelegate.eventType != null
                                target: valueLoader.item;
                                property: "value";
                                value: {
                                    if (entryDelegate.eventType == null) {
                                        return ""
                                    }

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
                }
            }
        }
    }

    Component {
        id: labelComponent
        Label {
            property var value
            property string unitString
            text: value + " " + unitString
            font: Style.smallFont
            elide: Text.ElideRight
        }
    }

    Component {
        id: floatLabelComponent
        Label {
            property double value
            property string unitString
            text: value.toFixed(value > 1000 ? 0 : 2) + " " + unitString
            font: Style.smallFont
            elide: Text.ElideRight
        }
    }

    Component {
        id: dateTimeComponent
        Label {
            property var value
            font: Style.smallFont
            text: Qt.formatDateTime(new Date(value * 1000), Qt.DefaultLocaleShortDate)
        }
    }

    Component {
        id: boolComponent
        RowLayout {
            id: boolLed
            property var value
            Led {
                implicitHeight: app.smallFont
                state: boolLed.value === "true" ? "on" : "off"
            }
            Label {
                font: Style.smallFont
                text: boolLed.value === "true" ? qsTr("Yes") : qsTr("No")
                Layout.fillWidth: true
            }
        }
    }

    Component {
        id: colorComponent
        Item {
            property var value
            implicitHeight: app.smallFont
            Rectangle {
                height: parent.height
                width: height * 2
                color: parent.value
                //                radius: width / 2
                border.color: Style.foregroundColor
                border.width: 1
            }
        }
    }
}
