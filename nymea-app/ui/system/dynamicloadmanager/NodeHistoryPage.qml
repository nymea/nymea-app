// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
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
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCharts

import Nymea
import Nymea.DynamicLoadManager

import "qrc:/ui/components"

Page {
    id: root

    // The DynamicLoadManagerManager to query history/events from.
    property var manager: null
    // The topology layout entry of the node to show history for.
    property var node: ({})

    readonly property bool isCharger: node.nodeType === "charger"

    // Phase colors, reused for the chart series and legend.
    readonly property var phaseColors: [Style.blue, Style.orange, Style.green]

    header: NymeaHeader {
        text: root.node.displayName ? root.node.displayName : qsTr("History")
        onBackPressed: pageStack.pop()
    }

    // Human-readable event description from the backend (eventType, reason) pair.
    function reasonText(eventType, reason) {
        switch (reason) {
        case "staleFuseMeter": return qsTr("Fuse meter value was stale. Fallback behavior was applied.")
        case "staleTemperatureSensor": return qsTr("Temperature sensor value was stale. Fallback behavior was applied.")
        case "temperatureDerating": return qsTr("Fuse was derated because of temperature.")
        case "SafetyReduction": return qsTr("Charging current was reduced for safety.")
        case "SafetyOff": return qsTr("Charging was switched off for safety.")
        case "NormalCurrentChange": return qsTr("Charging current was adjusted.")
        case "lastCommandFailed": return qsTr("Command failed.")
        case "configurationApplied": return qsTr("Configuration changed.")
        }
        // Fallback for unmapped events so nothing shows as raw JSON.
        return eventType ? qsTr("Event: %1").arg(eventType) : qsTr("Event")
    }

    function severityColor(severity) {
        switch (severity) {
        case "error": return Style.red
        case "warning": return Style.orange
        }
        return Style.iconColor
    }

    // Secondary detail line tailored to the most relevant fields of each event.
    function detailText(reason, details) {
        if (!details)
            return ""
        var parts = []
        if (details.temperature !== undefined)
            parts.push(qsTr("Temperature: %1 °C").arg(Math.round(details.temperature * 10) / 10))
        if (details.maxChargingCurrent !== undefined)
            parts.push(qsTr("Max current: %1 A").arg(Math.round(details.maxChargingCurrent * 10) / 10))
        if (details.desiredPhaseCount !== undefined)
            parts.push(qsTr("Phases: %1").arg(details.desiredPhaseCount))
        if (details.message !== undefined && details.message !== "")
            parts.push(details.message)
        return parts.join(" · ")
    }

    // Resolve a node's display name by walking the configuration tree.
    function nodeName(nodeId) {
        if (!manager || !manager.configuration)
            return nodeId
        return findNodeName(manager.configuration.root, nodeId) || nodeId
    }
    function findNodeName(node, nodeId) {
        if (!node)
            return ""
        if (node.id === nodeId)
            return node.displayName
        var children = node.children || []
        for (var i = 0; i < children.length; i++) {
            var name = findNodeName(children[i], nodeId)
            if (name)
                return name
        }
        return ""
    }

    QtObject {
        id: d
        property date now: new Date()

        readonly property int range: selectionTabs.currentValue.range // minutes
        readonly property int autoSampleRate: selectionTabs.currentValue.sampleRate

        // "Auto" follows the selected range, otherwise an explicit override.
        readonly property int sampleRate: sampleRateCombo.currentIndex === 0
                                          ? autoSampleRate
                                          : sampleRateCombo.model.get(sampleRateCombo.currentIndex).value

        readonly property var startTime: new Date(now.getTime() - range * 60000)
        readonly property var endTime: now
    }

    DynamicLoadManagerHistory {
        id: historyModel
        manager: root.manager
        nodeId: root.node.id !== undefined ? root.node.id : ""
        from: d.startTime
        to: d.endTime
        sampleRate: d.sampleRate
        includeCurrent: true
        live: true
        onCountChanged: chart.rebuild()
    }

    DynamicLoadManagerEvents {
        id: eventsModel
        manager: root.manager
        nodeId: root.node.id !== undefined ? root.node.id : ""
        from: d.startTime
        to: d.endTime
        includeDescendants: descendantsCheck.checked
        live: true
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Style.smallMargins

        // ---- Controls ----
        SelectionTabs {
            id: selectionTabs
            Layout.fillWidth: true
            Layout.leftMargin: Style.smallMargins
            Layout.rightMargin: Style.smallMargins
            Layout.topMargin: Style.smallMargins
            currentIndex: 1
            model: ListModel {
                ListElement {
                    modelData: qsTr("Hour")
                    sampleRate: DynamicLoadManagerHistory.SampleRate1Min
                    range: 60
                }
                ListElement {
                    modelData: qsTr("24h")
                    sampleRate: DynamicLoadManagerHistory.SampleRate15Mins
                    range: 1440
                }
                ListElement {
                    modelData: qsTr("7d")
                    sampleRate: DynamicLoadManagerHistory.SampleRate1Hour
                    range: 10080
                }
            }
            onTabSelected: d.now = new Date()
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Style.smallMargins
            Layout.rightMargin: Style.smallMargins
            spacing: Style.smallMargins

            Label {
                text: qsTr("Sample rate")
                font: Style.smallFont
            }
            ComboBox {
                id: sampleRateCombo
                Layout.preferredWidth: 120
                textRole: "text"
                currentIndex: 0
                model: ListModel {
                    ListElement { text: qsTr("Auto"); value: 0 }
                    ListElement { text: qsTr("1 min"); value: DynamicLoadManagerHistory.SampleRate1Min }
                    ListElement { text: qsTr("15 min"); value: DynamicLoadManagerHistory.SampleRate15Mins }
                    ListElement { text: qsTr("1 hour"); value: DynamicLoadManagerHistory.SampleRate1Hour }
                    ListElement { text: qsTr("1 day"); value: DynamicLoadManagerHistory.SampleRate1Day }
                }
            }
            Item { Layout.fillWidth: true }
            CheckBox {
                id: descendantsCheck
                visible: !root.isCharger
                checked: !root.isCharger
                text: qsTr("Include sub-nodes")
                font: Style.smallFont
            }
        }

        // Stale-data warning banner.
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Style.smallMargins
            Layout.rightMargin: Style.smallMargins
            visible: chart.hasStale || chart.hasFault
            spacing: Style.smallMargins
            Rectangle {
                Layout.preferredWidth: Style.smallFont.pixelSize
                Layout.preferredHeight: width
                radius: width / 2
                color: chart.hasFault ? Style.red : Style.orange
            }
            Label {
                Layout.fillWidth: true
                font: Style.smallFont
                wrapMode: Text.WordWrap
                text: chart.hasFault
                      ? qsTr("This node reported a fault during this period. Some values may be unreliable.")
                      : qsTr("Some measurements in this period were stale and should not be read as reliable.")
            }
        }

        // ---- Chart ----
        Item {
            id: chart
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.42
            Layout.leftMargin: Style.smallMargins
            Layout.rightMargin: Style.smallMargins

            property bool hasStale: false
            property bool hasFault: false

            // Key for the dashed reference series: charger compares to allocation, fuse to its effective limit.
            readonly property string referenceKey: root.isCharger ? "allocation" : "effectiveLimit"

            function rebuild() {
                msL1.clear(); msL2.clear(); msL3.clear()
                refL1.clear(); refL2.clear(); refL3.clear()
                var stale = false
                var fault = false
                var maxV = 0
                for (var i = 0; i < historyModel.count; i++) {
                    var e = historyModel.get(i)
                    var t = e.timestamp.getTime()
                    msL1.append(t, e.measuredLoadL1)
                    msL2.append(t, e.measuredLoadL2)
                    msL3.append(t, e.measuredLoadL3)
                    refL1.append(t, e[chart.referenceKey + "L1"])
                    refL2.append(t, e[chart.referenceKey + "L2"])
                    refL3.append(t, e[chart.referenceKey + "L3"])
                    if (!e.inputFresh) stale = true
                    if (e.faulted) fault = true
                }
                hasStale = stale
                hasFault = fault
            }

            ChartView {
                id: chartView
                anchors.fill: parent
                legend.visible: false
                margins.left: 0
                margins.right: 0
                margins.top: 0
                margins.bottom: 0
                backgroundColor: Style.tileBackgroundColor
                backgroundRoundness: Style.cornerRadius
                antialiasing: true

                ActivityIndicator {
                    anchors.centerIn: parent
                    visible: historyModel.busy
                    opacity: .5
                }

                DateTimeAxis {
                    id: timeAxis
                    min: d.startTime
                    max: d.endTime
                    format: d.range <= 1440 ? "hh:mm" : "dd.MM."
                    tickCount: root.width > 500 ? 7 : 5
                    labelsFont: Style.extraSmallFont
                    labelsColor: Style.foregroundColor
                    gridVisible: false
                    lineVisible: false
                }

                ValueAxis {
                    id: valueAxis
                    min: 0
                    max: historyModel.maxValue > 0 ? historyModel.maxValue * 1.15 : 16
                    labelFormat: "%.0f A"
                    labelsFont: Style.extraSmallFont
                    labelsColor: Style.foregroundColor
                    gridLineColor: Style.tileOverlayColor
                }

                // Measured load per phase (solid).
                LineSeries { id: msL1; axisX: timeAxis; axisY: valueAxis; color: root.phaseColors[0]; width: 2 }
                LineSeries { id: msL2; axisX: timeAxis; axisY: valueAxis; color: root.phaseColors[1]; width: 2 }
                LineSeries { id: msL3; axisX: timeAxis; axisY: valueAxis; color: root.phaseColors[2]; width: 2 }

                // Reference (effective limit / allocation) per phase (dashed).
                LineSeries { id: refL1; axisX: timeAxis; axisY: valueAxis; color: root.phaseColors[0]; width: 1; style: Qt.DashLine }
                LineSeries { id: refL2; axisX: timeAxis; axisY: valueAxis; color: root.phaseColors[1]; width: 1; style: Qt.DashLine }
                LineSeries { id: refL3; axisX: timeAxis; axisY: valueAxis; color: root.phaseColors[2]; width: 1; style: Qt.DashLine }
            }

            Label {
                anchors.centerIn: parent
                visible: !historyModel.busy && historyModel.count === 0
                text: qsTr("No history recorded for this time range.")
                font: Style.smallFont
                opacity: .6
            }
        }

        // Legend.
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Style.smallMargins
            Layout.rightMargin: Style.smallMargins
            spacing: Style.margins
            Repeater {
                model: ["L1", "L2", "L3"]
                delegate: RowLayout {
                    spacing: Style.smallMargins / 2
                    Rectangle {
                        width: Style.smallFont.pixelSize; height: 3
                        color: root.phaseColors[index]
                    }
                    Label { text: modelData; font: Style.extraSmallFont }
                }
            }
            Item { Layout.fillWidth: true }
            Label {
                font: Style.extraSmallFont
                opacity: .7
                text: root.isCharger ? qsTr("dashed: allocation") : qsTr("dashed: effective limit")
            }
        }

        // ---- Event timeline ----
        Label {
            Layout.fillWidth: true
            Layout.leftMargin: Style.smallMargins
            text: qsTr("Events")
            font: Style.smallFont
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
            id: eventList
            anchors.fill: parent
            clip: true
            model: eventsModel
            ScrollBar.vertical: ScrollBar {}

            delegate: ItemDelegate {
                id: eventDelegate
                width: eventList.width
                leftPadding: Style.smallMargins
                rightPadding: Style.smallMargins
                topPadding: Style.smallMargins / 2
                bottomPadding: Style.smallMargins / 2
                property bool expanded: false
                onClicked: expanded = !expanded

                contentItem: RowLayout {
                    spacing: Style.smallMargins
                    Rectangle {
                        Layout.alignment: Qt.AlignTop
                        Layout.topMargin: Style.smallMargins / 2
                        width: Style.smallFont.pixelSize
                        height: width
                        radius: width / 2
                        color: root.severityColor(model.severity)
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Label {
                            Layout.fillWidth: true
                            text: root.reasonText(model.eventType, model.reason)
                            wrapMode: Text.WordWrap
                        }
                        Label {
                            Layout.fillWidth: true
                            font: Style.extraSmallFont
                            opacity: .7
                            wrapMode: Text.WordWrap
                            text: {
                                var ts = Qt.formatDateTime(model.timestamp, "dd.MM.yy hh:mm:ss")
                                var line = ts + " · " + root.nodeName(model.nodeId)
                                var detail = root.detailText(model.reason, model.details)
                                return detail.length > 0 ? line + " · " + detail : line
                            }
                        }
                        // Expandable raw details for installers / developers.
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.topMargin: Style.smallMargins / 2
                            visible: eventDelegate.expanded
                            spacing: 0
                            Repeater {
                                model: root.detailKeys(model.details)
                                delegate: Label {
                                    Layout.fillWidth: true
                                    font: Style.extraSmallFont
                                    opacity: .8
                                    wrapMode: Text.WrapAnywhere
                                    text: modelData.key + ": " + modelData.value
                                }
                            }
                        }
                    }
                    ColorIcon {
                        Layout.alignment: Qt.AlignVCenter
                        size: Style.smallIconSize
                        name: eventDelegate.expanded ? "up" : "down"
                        color: Style.foregroundColor
                        opacity: .5
                    }
                }
            }
            }

            EmptyViewPlaceholder {
                anchors.centerIn: parent
                width: parent.width - app.margins * 2
                visible: !eventsModel.busy && eventsModel.count === 0
                title: qsTr("No events")
                text: qsTr("No history recorded for this time range.")
                imageSource: "qrc:/icons/logs.svg"
                buttonVisible: false
            }
        }
    }

    // Flatten the details map to a list of {key, value} rows for the expanded view.
    function detailKeys(details) {
        var rows = []
        if (!details)
            return rows
        for (var key in details)
            rows.push({ "key": key, "value": "" + details[key] })
        return rows
    }
}
