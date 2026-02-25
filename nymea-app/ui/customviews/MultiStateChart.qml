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
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtCharts
import Nymea
import NymeaApp.Utils

import "../components"
import "../customviews"

Item {
    id: root
    implicitHeight: width * .6
    implicitWidth: 400

    // A model with roles:
    // - thingId: uuid/string
    // - stateName: string
    // - color: color
    // - fillArea: bool (default false)
    property var statesModel: []
    property string title: ""


    QtObject {
        id: d

        readonly property int range: selectionTabs.currentValue.range
        readonly property int sampleRate: selectionTabs.currentValue.sampleRate
        readonly property int visibleValues: range / sampleRate

        property date now: new Date()

        readonly property var startTime: {
            var date = new Date(fixTime(now));
            date.setTime(date.getTime() - range * 60000 + 2000);
            return date;
        }

        readonly property var endTime: {
            var date = new Date(fixTime(now));
            date.setTime(date.getTime() + 2000)
            return date;
        }

        function fixTime(timestamp) {
            return timestamp
        }

        function ensureValue(series, timestamp) {
            if (!series) return;
            if (series.count == 0) {
                series.append(timestamp, 0)
            } else if (series.count == 1) {
                if (timestamp.getTime() < series.at(0).x) {
                    series.insert(0, timestamp, 0)
                } else {
                    series.append(timestamp, 0)
                }
            } else {
                if (timestamp.getTime() > series.at(0).x) {
                    series.remove(1)
                    series.append(timestamp, 0)
                } else if (timestamp.getTime() < series.at(1).x) {
                    series.remove(0)
                    series.insert(0, timestamp, 0)
                }
            }
        }
        function shrink(series, logsModel) {
            if (!series) return;
            series.clear();
            if (logsModel.count > 0) {
                ensureValue(series, logsModel.get(0).timestamp)
                ensureValue(series, logsModel.get(logsModel.count-1).timestamp)
            }
        }

        function refreshAll() {
            for (var i = 0; i < root.statesModel.length; i++) {
                modelsRepeater.itemAt(i).logsModel.fetchLogs()
            }
        }
    }

    Repeater {
        id: modelsRepeater
        model: root.statesModel
        delegate: Item {
            id: modelDelegate
            readonly property string thingId: root.statesModel[index].thingId
            readonly property string stateName: root.statesModel[index].stateName
            readonly property color color: root.statesModel[index].color
            readonly property bool fillArea: root.statesModel[index].hasOwnProperty("fillArea") ? root.statesModel[index].fillArea : false

            readonly property Thing thing: engine.thingManager.things.getThing(root.statesModel[index].thingId)
            readonly property StateType stateType: thing.thingClass.stateTypes.findByName(stateName)
            readonly property State thingState: thing.stateByName(stateName)
            property XYSeries series: null
            property XYSeries zeroSeries: null
            property AreaSeries areaSeries: null
            property ValueAxis axis: null

            readonly property bool isBool: stateType.type.toLowerCase() === "bool"

            Component {
                id: valueAxisComponent
                ValueAxis {
                    labelFormat: isBool ? " " : "%0.2" /*+ labelsLayout.precision*/ + "f " + Types.toUiUnit(stateType.unit)
                    gridLineColor: Style.tileOverlayColor
//                    labelsVisible: false
                    lineVisible: false
                    titleVisible: false
                    shadesVisible: false
                    labelsFont: Style.extraSmallFont
                    labelsColor: Style.foregroundColor

                    //                // Overriding the labels with our own as printf struggles with special chars
                    //                Item {
                    //                    id: labelsLayout
                    //                    x: Style.smallMargins
                    //                    y: chartView.plotArea.y
                    //                    height: chartView.plotArea.height
                    //                    width: chartView.plotArea.x - x
                    //                    visible: root.stateType.type.toLowerCase() != "bool" && logsModel.minValue != logsModel.maxValue
                    //                    property double range: Math.abs(valueAxis.max - valueAxis.min)
                    //                    property double stepSize: range / (valueAxis.tickCount - 1)
                    //                    property int precision: valueAxis.max - valueAxis.min < 5 ? 2 : 0

                    //                    Repeater {
                    //                        model: valueAxis.tickCount
                    //                        delegate: Label {
                    //                            y: parent.height / (valueAxis.tickCount - 1) * index - font.pixelSize / 2
                    //                            width: parent.width - Style.smallMargins
                    //                            horizontalAlignment: Text.AlignRight
                    //                            property double offset: (valueAxis.tickCount - index - 1) * labelsLayout.stepSize
                    //                            property double value: valueAxis.min + offset
                    //                            text: root.stateType ? Types.toUiValue(value, root.stateType.unit).toFixed(labelsLayout.precision) + " " + Types.toUiUnit(root.stateType.unit) : ""
                    //                            verticalAlignment: Text.AlignTop
                    //                            font: Style.extraSmallFont
                    //                        }
                    //                    }
                    //                }

                }
            }

            Component.onCompleted: {
//                var axis = isBool ? boolAxis : valueAxis

                axis = valueAxisComponent.createObject(chartView)
                axis.min = Qt.binding(function() {return logsModel.minValue})
                axis.max = Qt.binding(function() {return logsModel.maxValue})

                series = chartView.createSeries(ChartView.SeriesTypeLine, thing.name, dateTimeAxis, axis)
                series.color = color
                series.width = isBool ? 0 : 2

                if (fillArea) {
                    print("creating zero series")
                    zeroSeries = chartView.createSeries(ChartView.SeriesTypeLine, thing.name, dateTimeAxis, axis)
                    zeroSeries.color = color

                    areaSeries = chartView.createSeries(ChartView.SeriesTypeArea, thing.name, dateTimeAxis, axis)
                    areaSeries.upperSeries = series
                    areaSeries.lowerSeries = zeroSeries
                    areaSeries.color = Qt.rgba(color.r, color.g, color.b, color.a * .5)
                    areaSeries.borderColor = color
                    areaSeries.borderWidth = isBool ? 0 : 2
                }
            }
            Component.onDestruction: {
                if (fillArea) {
                    chartView.removeSeries(zeroSeries)
                    chartView.removeSeries(areaSeries)
                }
                chartView.removeSeries(series)
                axis.destroy()
            }

            Connections {
                target: selectionTabs
                onTabSelected: {
                    logsModel.clear()
                    logsModel.fetchLogs()
                }
            }

            property NewLogsModel logsModel: NewLogsModel {
//                id: logsModel
                engine: _engine
                source: thing ? "state-" + thing.id + "-" + stateName : ""
                startTime: new Date(d.startTime.getTime() - d.range * 1.1 * 60000)
                endTime: new Date(d.endTime.getTime() + d.range * 1.1 * 60000)
                sampleRate: stateType.type.toLowerCase() === "bool" ? NewLogsModel.SampleRateAny : d.sampleRate
                sortOrder: Qt.AscendingOrder

                Component.onCompleted: {
                    print("****** completed",  modelDelegate.thingId)
                    ready = true
                    update()
                }
                property bool ready: false
                onSourceChanged: {
        //            print("***** source changed")
                    update()
                }

                function update() {
        //            print("*********+ source", source, "start", startTime, "end", endTime, ready)
                    if (ready && source != "") {
                        fetchLogs()
                    }
                }

                property double minValue
                property double maxValue

                onBusyChanged: (busy) => {
                    if (busy) {
                        chartView.busyCounter++
                    } else {
                        chartView.busyCounter--
                    }
                }

                onEntriesAddedIdx: (index, count) => {
                    print("**** entries added", index, count, "entries in series:", series.count, "in model", logsModel.count)
                    for (var i = 0; i < count; i++) {
                        var entry = logsModel.get(i)
                        print("entry", entry.timestamp, entry.source, JSON.stringify(entry.values))
                        d.ensureValue(zeroSeries, entry.timestamp)

                        if (stateType.type.toLowerCase() == "bool") {
                            var value = entry.values[stateType.name]
                            if (value == null) {
                                value = false;
                            }
                            value *= root.inverted ? -1 : 1
                            var previousEntry = i > 0 ? logsModel.get(i-1) : null;
                            var previousValue = previousEntry ? previousEntry.values[stateType.name] : false
                            if (previousValue == null) {
                                previousValue = false
                            }

                            // for booleans, we'll insert the previous value right before the new one so the position is doubled
                            var insertIdx = (index + i) * 2
        //                    print("inserting bool 1", insertIdx, entry.timestamp.getTime() - 500, !value, new Date(entry.timestamp.getTime() - 500))
                            series.insert(insertIdx, entry.timestamp.getTime() - 500, previousValue)
        //                    print("inserting bool 2", insertIdx + 1, entry.timestamp.getTime(), value, entry.timestamp)
                            series.insert(insertIdx+1, entry.timestamp, value)

                        } else {
                            var value = entry.values[stateType.name]
                            if (value == null) {
                                value = 0;
                            }
                            value *= root.inverted ? -1.1 : 1.1

                            minValue = minValue == undefined ? value : Math.min(minValue, value)
                            maxValue = maxValue == undefined ? value : Math.max(maxValue, value)

                            var insertIdx = index + i
                            series.insert(insertIdx, entry.timestamp, value)
                        }
                    }

                    if (stateType.type.toLowerCase() == "bool") {

                        var last = series.at(series.count-1);
                        if (last.x < d.endTime) {
                            series.append(d.endTime, last.y)
                            d.ensureValue(zeroSeries, d.endTime)
                        }
                    }

                    print("added entries. now in series:", series.count)

                }
                onEntriesRemoved: (index, count) => {
                    print("removing:", index, count, series.count)
                    if (stateType.type.toLowerCase() == "bool") {
                        series.removePoints(index * 2, count * 2)
                        if (series.count == 1) {
                            series.removePoints(0, 1);
                        }
                    } else {
                        series.removePoints(index, count)
                    }

                    d.shrink(zeroSeries, logsModel)
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Label {
            id: titleLabel
            Layout.fillWidth: true
            Layout.margins: Style.smallMargins
            horizontalAlignment: Text.AlignHCenter
            text: root.title
            visible: root.title != ""
        }

        SelectionTabs {
            id: selectionTabs
            Layout.fillWidth: true
            Layout.leftMargin: Style.smallMargins
            Layout.rightMargin: Style.smallMargins
            currentIndex: 1
            model: ListModel {
                ListElement {
                    modelData: qsTr("Hours")
                    sampleRate: NewLogsModel.SampleRate1Min
                    range: 180 // 3 Hours: 3 * 60
                }
                ListElement {
                    modelData: qsTr("Days")
                    sampleRate: NewLogsModel.SampleRate15Mins
                    range: 1440 // 1 Day: 24 * 60
                }
                ListElement {
                    modelData: qsTr("Weeks")
                    sampleRate: NewLogsModel.SampleRate1Hour
                    range: 10080 // 7 Days: 7 * 24 * 60
                }
                ListElement {
                    modelData: qsTr("Months")
                    sampleRate: NewLogsModel.SampleRate3Hours
                    range: 43200 // 30 Days: 30 * 24 * 60
                }
            }
            onTabSelected: {
                d.now = new Date()
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true



            ChartView {
                id: chartView
                anchors.fill: parent
                //                backgroundColor: "transparent"
                margins.left: 0
                margins.right: 0
                margins.bottom: Style.smallMargins //Style.smallIconSize + Style.margins
                margins.top: 0

                backgroundColor: Style.tileBackgroundColor
                backgroundRoundness: Style.cornerRadius

                legend.alignment: Qt.AlignBottom
                legend.labelColor: Style.foregroundColor
                legend.font: Style.extraSmallFont
                legend.visible: false

                property int busyCounter: 0

                ActivityIndicator {
                    anchors.centerIn: parent
                    visible: chartView.busyCounter > 0
                    opacity: .5
                }

                Label {
                    anchors.centerIn: parent
                    visible: {
                        if (chartView.busyCounter > 0) {
                            return false
                        }
                        for (var i = 0; i < modelsRepeater.count; i++) {
                            if (modelsRepeater.itemAt(i).logsModel.count > 0) {
                                return false
                            }
                        }
                        return true
                    }
                    text: qsTr("No data")
                    font: Style.smallFont
                    opacity: .5
                }

                Label {
                    x: chartView.x + chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                    y: chartView.y + chartView.plotArea.y + Style.smallMargins
                    text: {
                        switch (d.sampleRate) {
                        case NewLogsModel.SampleRate1Min:
                            return d.startTime.toLocaleDateString(Qt.locale(), Locale.LongFormat)
                        case NewLogsModel.SampleRate15Mins:
                        case NewLogsModel.SampleRate1Hour:
                        case NewLogsModel.SampleRate3Hours:
                        case NewLogsModel.SampleRate1Day:
                        case NewLogsModel.SampleRate1Week:
                        case NewLogsModel.SampleRate1Month:
                        case NewLogsModel.SampleRate1Year:
                            return d.startTime.toLocaleDateString(Qt.locale(), Locale.ShortFormat) + " - " + d.endTime.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
                        }
                    }
                    font: Style.smallFont
                    opacity: ((new Date().getTime() - d.now.getTime()) / d.sampleRate / 60000) > d.visibleValues ? .5 : 0
                    Behavior on opacity { NumberAnimation {} }
                }



                DateTimeAxis {
                    id: dateTimeAxis

                    min: d.startTime
                    max: d.endTime
                    format: {
                        switch (selectionTabs.currentValue.sampleRate) {
                        case NewLogsModel.SampleRate1Min:
                        case NewLogsModel.SampleRate15Mins:
                            return "hh:mm"
                        case NewLogsModel.SampleRate1Hour:
                        case NewLogsModel.SampleRate3Hours:
                        case NewLogsModel.SampleRate1Day:
                            return "dd.MM."
                        }
                    }
                    tickCount: {
                        switch (selectionTabs.currentValue.sampleRate) {
                        case NewLogsModel.SampleRate1Min:
                        case NewLogsModel.SampleRate15Mins:
                            return root.width > 500 ? 13 : 7
                        case NewLogsModel.SampleRate1Hour:
                            return 7
                        case NewLogsModel.SampleRate3Hours:
                        case NewLogsModel.SampleRate1Day:
                            return root.width > 500 ? 12 : 6
                        }
                    }
                    labelsFont: Style.extraSmallFont
                    gridVisible: false
                    minorGridVisible: false
                    lineVisible: false
                    shadesVisible: false
                    labelsColor: Style.foregroundColor
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                anchors.leftMargin: chartView.plotArea.x
                anchors.topMargin: chartView.plotArea.y
                anchors.rightMargin: chartView.width - chartView.plotArea.width - chartView.plotArea.x
                anchors.bottomMargin: chartView.height - chartView.plotArea.height - chartView.plotArea.y

                hoverEnabled: true
                preventStealing: tooltipping || dragging
                propagateComposedEvents: true

                property int startMouseX: 0
                property bool dragging: false
                property bool tooltipping: false

                property var startDatetime: null

                Timer {
                    interval: 300
                    running: mouseArea.pressed
                    onTriggered: {
                        if (!mouseArea.dragging) {
                            mouseArea.tooltipping = true
                        }
                    }
                }
                onReleased: {
                    if (mouseArea.dragging) {
                        logsModel.fetchLogs()
                        mouseArea.dragging = false;
                    }

                    mouseArea.tooltipping = false;
                }

                onPressed: {
                    startMouseX = mouseX
                    startDatetime = d.now
                }

                onDoubleClicked: {
                    if (selectionTabs.currentIndex == 0) {
                        return;
                    }

                    var idx = Math.ceil(mouseArea.mouseX * d.visibleValues / mouseArea.width)
                    var timestamp = new Date(d.startTime.getTime() + (idx * d.sampleRate * 60000))
                    selectionTabs.currentIndex--
                    d.now = new Date(Math.min(new Date().getTime(), timestamp.getTime() + (d.visibleValues / 2) * d.sampleRate * 60000))
                    powerBalanceLogs.fetchLogs()
                }

                onMouseXChanged: {
                    if (!pressed || mouseArea.tooltipping) {
                        return;
                    }
                    if (Math.abs(startMouseX - mouseX) < 10) {
                        return;
                    }
                    dragging = true

                    var dragDelta = startMouseX - mouseX
                    var totalTime = d.endTime.getTime() - d.startTime.getTime()
                    // dragDelta : timeDelta = width : totalTime
                    var timeDelta = dragDelta * totalTime / mouseArea.width
//                    print("dragging", dragDelta, totalTime, mouseArea.width)
                    d.now = new Date(Math.min(new Date(), new Date(startDatetime.getTime() + timeDelta)))
                }

                onWheel: (wheel) => {
                    startDatetime = d.now
                    var totalTime = d.endTime.getTime() - d.startTime.getTime()
                    // pixelDelta : timeDelta = width : totalTime
                    var timeDelta = wheel.pixelDelta.x * totalTime / mouseArea.width
//                    print("wheeling", wheel.pixelDelta.x, totalTime, mouseArea.width)
                    d.now = new Date(Math.min(new Date(), new Date(startDatetime.getTime() - timeDelta)))
                    wheelStopTimer.restart()
                }
                Timer {
                    id: wheelStopTimer
                    interval: 300
                    repeat: false
                    onTriggered: d.refreshAll()
                }

                Rectangle {
                    height: parent.height
                    width: 1
                    color: Style.foregroundColor
                    x: Math.min(mouseArea.width, Math.max(0, mouseArea.mouseX))
                    visible: tooltipRepeater.tooltipsVisible
                }

                Timer {
                    id: updateTimer
                    interval: 0
                    onTriggered: tooltipRepeater.update()
                }

                Repeater {
                    id: tooltipRepeater
                    model: root.statesModel.length
                    property var timestamp: new Date(((d.endTime.getTime() - d.startTime.getTime()) * mouseArea.mouseX / mouseArea.width) + d.startTime.getTime())
                    property int tooltipWidth: 130
                    property int xOnRight: Math.max(0, mouseArea.mouseX) + Style.smallMargins
                    property int xOnLeft: Math.min(mouseArea.width, mouseArea.mouseX) - Style.smallMargins - tooltipWidth
                    property int tooltipX: xOnLeft < 0 ? xOnRight : xOnLeft
                    property bool tooltipsVisible: (mouseArea.containsMouse || mouseArea.tooltipping) && !mouseArea.dragging


                    onTimestampChanged: {
                        updateTimer.start();
                    }

                    function update() {
                        var ordered = []
                        insert(tooltipRepeater, ordered);

                        for (var i = ordered.length - 1; i >= 0; i--) {
                            var item = ordered[i]
                            var newY = item.realY

                            if (i < ordered.length-1) {
                                var previous = ordered[i+1]
                                newY = Math.min(newY, previous.fixedY - item.height/* - Style.extraSmallMargins*/)
                            }

                            ordered[i].fixedY = newY
                        }
                    }

                    function insert(repeater, array) {
                        for (var i = 0; i < repeater.count; i++) {
                            var item = repeater.itemAt(i);
                            var insertIdx = 0;
                            while (array.length > insertIdx && item.realY > array[insertIdx].realY) {
                                insertIdx++
                            }
                            array.splice(insertIdx, 0, item)
                        }
                    }


                    delegate: NymeaToolTip {
                        id: tooltip
                        width: tooltipRepeater.tooltipWidth
                        height: layout.implicitHeight + Style.smallMargins * 2

                        visible: tooltipRepeater.tooltipsVisible && entry != null
                        x: tooltipRepeater.tooltipX
                        backgroundItem: chartView
                        backgroundRect: Qt.rect(mouseArea.x + x, mouseArea.y + y, width, height)

                        property Item chartDelegate: modelsRepeater.count > 0 ? modelsRepeater.itemAt(index) : null
                        property Thing thing: chartDelegate ? chartDelegate.thing : null
                        property NewLogEntry entry: chartDelegate ? chartDelegate.logsModel.find(tooltipRepeater.timestamp) : null
                        property string valueName: chartDelegate ? chartDelegate.stateType.name : ""
//                        property alias iconSource: icon.name
                        property ValueAxis axis: chartDelegate ? chartDelegate.axis : null
                        property int unit: chartDelegate ? chartDelegate.stateType.unit : Types.UnitNone

                        readonly property var value: entry ? entry.values[valueName] : null
                        readonly property int realY: entry ? Math.min(Math.max(mouseArea.height - (value * mouseArea.height / axis.max) - height / 2 /*- Style.margins*/, 0), mouseArea.height - height) : 0
                        property int fixedY: 0
                        y: fixedY // Animated

                        RowLayout {
                            id: layout
                            anchors.fill: parent
                            anchors.margins: Style.smallMargins

                            ColorIcon {
                                id: icon
                                size: Style.smallIconSize
                                color: chartDelegate ? chartDelegate.color : "red"
                                visible: name != ""
                            }

                            Rectangle {
                                id: rect
                                width: Style.extraSmallFont.pixelSize
                                height: width
                                color: chartDelegate ? chartDelegate.color : "red"
                                visible: !icon.visible
                            }
                            Label {
                                text: root.statesModel[index].hasOwnProperty("tooltipFunction")
                                      ? root.statesModel[index].tooltipFunction(tooltip.value)
                                      : "%1: %2%3".arg(thing.name).arg(entry ? round(Types.toUiValue(tooltip.value, unit)) : "-").arg(Types.toUiUnit(tooltip.unit))
                                Layout.fillWidth: true
                                font: Style.extraSmallFont
                                elide: Text.ElideMiddle
                                function round(value) {
                                    return Math.round(value * 100) / 100
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
