import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import "qrc:/ui/components"
import "qrc:/ui/customviews"
import Nymea 1.0
import Nymea.AirConditioning 1.0
import QtCharts 2.3

Page {
    id: root
    property AirConditioningManager acManager: null
    property ZoneInfoWrapper zoneWrapper: null
    readonly property ZoneInfo zone: zoneWrapper.zone


    header: NymeaHeader {
        text: root.zone.name

        onBackPressed: {
            pageStack.pop()
        }
    }

    Component {
        id: lineSeriesComponent
        LineSeries { }
    }

    QtObject {
        id: d

        property date now: new Date()
        property int sampleRate: selectionTabs.currentValue.sampleRate

        readonly property int range: selectionTabs.currentValue.range
        readonly property int visibleValues: range / sampleRate

        readonly property var startTime: {
            var date = new Date(now);
            date.setTime(date.getTime() - range * 60000 + 2000);
            return date;
        }

        readonly property var endTime: {
            var date = new Date(now);
            date.setTime(date.getTime() + 2000)
            return date;
        }

        function refreshAll() {
            for (var i = 0; i < thermostatsRepeater.count; i++) {
                thermostatsRepeater.itemAt(i).logsModel.fetchLogs()
            }
            for (var i = 0; i < tempRepeater.count; i++) {
                tempRepeater.itemAt(i).logsModel.fetchLogs()
            }
            for (var i = 0; i < humidityRepeater.count; i++) {
                humidityRepeater.itemAt(i).logsModel.fetchLogs()
            }
            for (var i = 0; i < vocRepeater.count; i++) {
                vocRepeater.itemAt(i).logsModel.fetchLogs()
            }

            for (var i = 0; i < windowOpenRepeater.count; i++) {
                windowOpenRepeater.itemAt(i).logsModel.fetchLogs()
            }
            for (var i = 0; i < heatingRepeater.count; i++) {
                heatingRepeater.itemAt(i).logsModel.fetchLogs()
            }
        }
    }


    ColumnLayout {
        anchors.fill: parent

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
                print("*** tab selected")
                d.now = new Date()
                d.refreshAll();
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true


            ChartView {
                id: chartView
                anchors.fill: parent

                backgroundColor: "transparent"
                margins.left: 0
                margins.right: 0
                margins.top: 0
                margins.bottom: 0

                legend.visible: false
                legend.alignment: Qt.AlignBottom
                legend.font: Style.extraSmallFont
                legend.labelColor: Style.foregroundColor

                property int busyCounter: 0

                ActivityIndicator {
                    anchors.centerIn: parent
                    visible: chartView.busyCounter > 0
                    opacity: .5
                }

    //            Label {
    //                anchors.centerIn: parent
    //                visible: !logsModel.busy && logsModel.count == 0
    //                text: qsTr("No data")
    //                font: Style.smallFont
    //                opacity: .5
    //            }

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

                ValueAxis {
                    id: temperatureAxis
                    min: 0
                    max: 50
                    labelFormat: ""
                    gridLineColor: Style.tileOverlayColor
                    labelsVisible: false
                    lineVisible: false
                    titleVisible: false
                    shadesVisible: false
                }

                ValueAxis {
                    id: humidityAxis
                    min: 0
                    max: 100
                    labelFormat: ""
                    gridLineColor: Style.tileOverlayColor
                    labelsVisible: false
                    lineVisible: false
                    titleVisible: false
                    shadesVisible: false
                    visible: false
                }

                ValueAxis {
                    id: vocAxis
                    min: 0
                    max: 1000
                    //            max: vocRepeater.count > 0 ? vocRepeater.itemAt(0).logsModel.maxValue : 0
                    labelFormat: ""
                    gridLineColor: Style.tileOverlayColor
                    labelsVisible: false
                    lineVisible: false
                    titleVisible: false
                    shadesVisible: false
                    visible: false
                }

                ValueAxis {
                    id: boolAxis
                    min: 0
                    max: 1
                    labelFormat: ""
                    gridLineColor: Style.tileOverlayColor
                    labelsVisible: false
                    lineVisible: false
                    titleVisible: false
                    shadesVisible: false
                    visible: false
                }

                Item {
                    id: labelsLayout
                    x: Style.smallMargins
                    y: chartView.plotArea.y
                    height: chartView.plotArea.height
                    width: chartView.plotArea.x - x
                    Repeater {
                        model: temperatureAxis.tickCount
                        delegate: ColumnLayout {
                            y: index == temperatureAxis.tickCount - 1
                               ? parent.height - height
                               : index == 0
                                 ? 0
                                 : parent.height / (temperatureAxis.tickCount - 1) * index - height / 2
                            Label {
                                width: parent.width - Style.smallMargins
                                horizontalAlignment: Text.AlignRight
                                text: (temperatureAxis.max - (index * temperatureAxis.max / (temperatureAxis.tickCount - 1))) + "°C"
                                verticalAlignment: Text.AlignTop
                                font: Style.extraSmallFont
                                visible: tempRepeater.count > 0 || thermostatsRepeater.count > 0
                                color: app.interfaceToColor("temperaturesensor")
                            }
                            Label {
                                width: parent.width - Style.smallMargins
                                horizontalAlignment: Text.AlignRight
                                text: (humidityAxis.max - (index * humidityAxis.max / (humidityAxis.tickCount - 1))).toFixed(0) + "%"
                                verticalAlignment: Text.AlignTop
                                font: Style.extraSmallFont
                                visible: humidityRepeater.count > 0
                                color: app.interfaceToColor("humiditysensor")
                            }
                            Label {
                                width: parent.width - Style.smallMargins
                                horizontalAlignment: Text.AlignRight
                                text: (vocAxis.max - (index * vocAxis.max / (vocAxis.tickCount - 1))).toFixed(0) + "ppm"
                                verticalAlignment: Text.AlignTop
                                font: Style.extraSmallFont
                                visible: vocRepeater.count > 0
                                color: app.interfaceToColor("vocsensor")
                            }
                        }
                    }
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

                Repeater {
                    id: thermostatsRepeater
                    model: zoneWrapper.thermostats
                    delegate: Item {
                        id: thermostatDelegate
                        readonly property Thing thing: zoneWrapper.thermostats.get(index)
                        property XYSeries series: null

                        readonly property NewLogsModel logsModel: NewLogsModel {
                            objectName: "temp: " + thing.name
                            engine: _engine
                            source: "state-" + thing.id + "-temperature"
                            startTime: new Date(d.startTime.getTime() - d.range * 60000)
                            endTime: new Date(d.endTime.getTime() + d.range * 60000)
                            sampleRate: d.sampleRate
                            onBusyChanged: {
                                if (busy) {
                                    chartView.busyCounter++
                                } else {
                                    chartView.busyCounter--
                                }
                            }

                            onEntriesAdded: {
                                for (var i = 0; i < entries.length; i++) {
                                    var entry = entries[i]
                                    var value = entry.values["temperature"]
                                    if (value == null) {
                                        value = 0;
                                    }
                                    series.insert(index + i, entry.timestamp, value)
                                }
                            }
                            onEntriesRemoved: {
                                series.removePoints(index, count)
                            }
                            Component.onCompleted: fetchLogs()
                        }

                        Component.onCompleted: {
                            series = chartView.createSeries(ChartView.SeriesTypeLine, thing.name, dateTimeAxis, temperatureAxis)
                            series.color = app.interfaceToColor("temperaturesensor")
                            series.width = 2

                            //                    series.opacity = Qt.binding(function() {
                            //                        return d.selectedSeries == null || d.selectedSeries == series ? 1 : 0.3
                            //                    })
                            series.borderWidth = 0;
                            series.borderColor = series.color
                        }
                        Component.onDestruction: {
                            chartView.removeSeries(series)
                        }

                    }
                }

                Repeater {
                    id: tempRepeater
                    model: zoneWrapper.indoorTempSensors
                    delegate: Item {
                        id: tempDelegate
                        readonly property Thing thing: zoneWrapper.indoorTempSensors.get(index)
                        property XYSeries series: null

                        readonly property NewLogsModel logsModel: NewLogsModel {
                            objectName: "temp: " + thing.name
                            engine: _engine
                            source: "state-" + thing.id + "-temperature"
                            startTime: new Date(d.startTime.getTime() - d.range * 60000)
                            endTime: new Date(d.endTime.getTime() + d.range * 60000)
                            sampleRate: d.sampleRate
                            onBusyChanged: {
                                if (busy) {
                                    chartView.busyCounter++
                                } else {
                                    chartView.busyCounter--
                                }
                            }

                            onEntriesAdded: {
                                for (var i = 0; i < entries.length; i++) {
                                    var entry = entries[i]
                                    var value = entry.values["temperature"]
                                    if (value == null) {
                                        value = 0;
                                    }
                                    series.insert(index + i, entry.timestamp, value)
                                }
                            }
                            onEntriesRemoved: {
                                series.removePoints(index, count)
                            }
                            Component.onCompleted: fetchLogs()

                        }

                        Component.onCompleted: {
                            series = chartView.createSeries(ChartView.SeriesTypeLine, thing.name, dateTimeAxis, temperatureAxis)
                            series.color = app.interfaceToColor("temperaturesensor")
                            series.width = 1

                            //                    series.opacity = Qt.binding(function() {
                            //                        return d.selectedSeries == null || d.selectedSeries == series ? 1 : 0.3
                            //                    })
                            series.borderWidth = 0;
                            series.borderColor = series.color
                        }
                        Component.onDestruction: {
                            chartView.removeSeries(series)
                        }

                    }
                }

                Repeater {
                    id: humidityRepeater
                    model: zoneWrapper.indoorHumiditySensors
                    delegate: Item {
                        id: humidityDelegate
                        readonly property Thing thing: zoneWrapper.indoorHumiditySensors.get(index)
                        property XYSeries series: null

                        readonly property NewLogsModel logsModel: NewLogsModel {
                            objectName: "hum: " + thing.name
                            engine: _engine
                            source: "state-" + thing.id + "-humidity"
                            startTime: new Date(d.startTime.getTime() - d.range * 60000)
                            endTime: new Date(d.endTime.getTime() + d.range * 60000)
                            sampleRate: d.sampleRate
                            onBusyChanged: {
                                if (busy) {
                                    chartView.busyCounter++
                                } else {
                                    chartView.busyCounter--
                                }
                            }

                            onEntriesAdded: {
                                for (var i = 0; i < entries.length; i++) {
                                    var entry = entries[i]
                                    var value = entry.values["humidity"]
                                    if (value == null) {
                                        value = 0;
                                    }
                                    series.insert(index + i, entry.timestamp, value)
                                }
                            }
                            onEntriesRemoved: {
                                series.removePoints(index, count)
                            }
                            Component.onCompleted: fetchLogs()
                        }

                        Component.onCompleted: {
                            series = chartView.createSeries(ChartView.SeriesTypeLine, thing.name, dateTimeAxis, humidityAxis)
                            series.color = app.interfaceToColor("humiditysensor")
                            series.width = 1
                            //                    series.opacity = Qt.binding(function() {
                            //                        return d.selectedSeries == null || d.selectedSeries == series ? 1 : 0.3
                            //                    })
                            series.borderWidth = 0;
                            series.borderColor = series.color
                        }
                        Component.onDestruction: {
                            chartView.removeSeries(series)
                        }
                    }
                }

                Repeater {
                    id: vocRepeater
                    model: zoneWrapper.indoorVocSensors
                    delegate: Item {
                        id: vocDelegate
                        readonly property Thing thing: zoneWrapper.indoorVocSensors.get(index)
                        property XYSeries series: null
                        readonly property NewLogsModel logsModel: NewLogsModel {
                            objectName: "voc: " + thing.name
                            engine: _engine
                            source: "state-" + thing.id + "-voc"
                            startTime: new Date(d.startTime.getTime() - d.range * 60000)
                            endTime: new Date(d.endTime.getTime() + d.range * 60000)
                            sampleRate: d.sampleRate
                            onBusyChanged: {
                                if (busy) {
                                    chartView.busyCounter++
                                } else {
                                    chartView.busyCounter--
                                }
                            }
                            onEntriesAdded: {
                                for (var i = 0; i < entries.length; i++) {
                                    var entry = entries[i]
                                    var value = entry.values["voc"]
                                    if (value == null) {
                                        value = 0;
                                    }
                                    series.insert(index + i, entry.timestamp, value)
                                }
                            }
                            onEntriesRemoved: {
                                series.removePoints(index, count)
                            }
                            Component.onCompleted: fetchLogs()
                        }

                        Component.onCompleted: {
                            series = chartView.createSeries(ChartView.SeriesTypeLine, thing.name, dateTimeAxis, vocAxis)
                            series.color = app.interfaceToColor("vocsensor")
                            series.width = 1
                            //                    series.opacity = Qt.binding(function() {
                            //                        return d.selectedSeries == null || d.selectedSeries == series ? 1 : 0.3
                            //                    })
                            series.borderWidth = 0;
                            series.borderColor = series.color
                        }
                        Component.onDestruction: {
                            chartView.removeSeries(series)
                        }

                    }
                }

                Repeater {
                    id: windowOpenRepeater
                    model: zoneWrapper.windowSensors
                    delegate: Item {
                        id: closableDelegate
                        readonly property Thing thing: zoneWrapper.windowSensors.get(index)
                        property AreaSeries series: null

                        LineSeries {
                            id: closableUpperSeries
                        }
                        LineSeries {
                            id: closableLowerSeries
                            XYPoint {x: dateTimeAxis.min.getTime(); y: 0}
                            XYPoint {x: dateTimeAxis.max.getTime(); y: 0}
                            function ensureValue(timestamp) {
                                if (count == 0) {
                                    append(timestamp, 0)
                                } else if (count == 1) {
                                    if (timestamp.getTime() < at(0).x) {
                                        insert(0, timestamp, 0)
                                    } else {
                                        append(timestamp, 0)
                                    }
                                } else {
                                    if (timestamp.getTime() < at(0).x) {
                                        remove(0)
                                        insert(0, timestamp, 0)
                                    } else if (timestamp.getTime() > at(1).x) {
                                        remove(1)
                                        append(timestamp, 0)
                                    }
                                }
                            }
                            function shrink() {
                                clear();
                                if (logsModel.count > 0) {
                                    ensureValue(logsModel.get(0).timestamp)
                                    ensureValue(logsModel.get(logsModel.count-1).timestamp)
                                }
                            }
                        }

                        readonly property NewLogsModel logsModel: NewLogsModel {
                            engine: _engine
                            source: "state-" + thing.id + "-closed"
                            startTime: new Date(d.startTime.getTime() - d.range * 60000)
                            endTime: new Date(d.endTime.getTime() + d.range * 60000)
                            property bool haveGeneratedLast: false
                            onBusyChanged: {
                                if (busy) {
                                    chartView.busyCounter++
                                } else {
                                    chartView.busyCounter--
                                }
                            }
                            onEntriesAdded: {
                                for (var i = 0; i < entries.length; i++) {
                                    var entry = entries[i]
                                    var value = entry.values["closed"]
                                    if (value == null) {
                                        value = false;
                                    }

                                    closableLowerSeries.ensureValue(entry.timestamp)

                                    // for booleans, we'll insert the opposite value right before the new one so the position is doubled
                                    var insertIdx = (index + i) * 2
                                    closableUpperSeries.insert(insertIdx, entry.timestamp.getTime() - 500, value)
                                    closableUpperSeries.insert(insertIdx+1, entry.timestamp, !value)
                                }

                                var last = closableUpperSeries.at(closableUpperSeries.count-1);
                                if (last.x < d.endTime) {
                                    closableUpperSeries.append(d.endTime, last.y)
                                    haveGeneratedLast = true
                                }
                            }
                            onEntriesRemoved: {
                                closableUpperSeries.removePoints(index * 2, count * 2)
                                if (haveGeneratedLast) {
                                    closableUpperSeries.removePoints(series.count - 1, 1)
                                    haveGeneratedLast = false
                                }
                            }
                            Component.onCompleted: fetchLogs()

                        }

                        Component.onCompleted: {
                            series = chartView.createSeries(ChartView.SeriesTypeArea, thing.name, dateTimeAxis, boolAxis)
                            series.lowerSeries = closableLowerSeries
                            series.upperSeries = closableUpperSeries
                            series.color = Style.green
                            series.opacity = 0.1
                            //                    series.opacity = Qt.binding(function() {
                            //                        return d.selectedSeries == null || d.selectedSeries == series ? 1 : 0.3
                            //                    })

                            series.borderWidth = 0;
                            series.borderColor = series.color
                        }
                        Component.onDestruction: {
                            chartView.removeSeries(series)
                        }
                    }
                }

                Repeater {
                    id: heatingRepeater
                    model: zoneWrapper.thermostats.count
                    delegate: Item {
                        id: heatingDelegate
                        readonly property Thing thing: zoneWrapper.thermostats.get(index)
                        property AreaSeries series: null


                        LineSeries {
                            id: heatingUpperSeries
                        }
                        LineSeries {
                            id: heatingLowerSeries
                            XYPoint {x: dateTimeAxis.min.getTime(); y: 0}
                            XYPoint {x: dateTimeAxis.max.getTime(); y: 0}
                            function ensureValue(timestamp) {
                                if (count == 0) {
                                    append(timestamp, 0)
                                } else if (count == 1) {
                                    if (timestamp.getTime() < at(0).x) {
                                        insert(0, timestamp, 0)
                                    } else {
                                        append(timestamp, 0)
                                    }
                                } else {
                                    if (timestamp.getTime() < at(0).x) {
                                        remove(0)
                                        insert(0, timestamp, 0)
                                    } else if (timestamp.getTime() > at(1).x) {
                                        remove(1)
                                        append(timestamp, 0)
                                    }
                                }
                            }
                            function shrink() {
                                clear();
                                if (logsModel.count > 0) {
                                    ensureValue(logsModel.get(0).timestamp)
                                    ensureValue(logsModel.get(logsModel.count-1).timestamp)
                                }
                            }
                        }

                        readonly property NewLogsModel logsModel: NewLogsModel {
                            objectName: "heat: " + thing.name
                            engine: _engine
                            source: "state-" + thing.id + "-heatingOn"
                            startTime: new Date(d.startTime.getTime() - d.range * 60000)
                            endTime: new Date(d.endTime.getTime() + d.range * 60000)
                            property bool haveGeneratedLast: false
                            onBusyChanged: {
                                if (busy) {
                                    chartView.busyCounter++
                                } else {
                                    chartView.busyCounter--
                                }
                            }
                            onEntriesAdded: {
                                for (var i = 0; i < entries.length; i++) {
                                    var entry = entries[i]
                                    var value = entry.values["heatingOn"]
                                    if (value == null) {
                                        value = false;
                                    }

                                    heatingLowerSeries.ensureValue(entry.timestamp)

                                    // for booleans, we'll insert the opposite value right before the new one so the position is doubled
                                    var insertIdx = (index + i) * 2
                                    heatingUpperSeries.insert(insertIdx, entry.timestamp.getTime() - 500, !value)
                                    heatingUpperSeries.insert(insertIdx+1, entry.timestamp, value)
                                }

                                var last = heatingUpperSeries.at(heatingUpperSeries.count-1);
                                if (last.x < d.endTime) {
                                    heatingUpperSeries.append(d.endTime, last.y)
                                    heatingLowerSeries.ensureValue(d.endTime)
                                    haveGeneratedLast = true
                                }
                            }
                            onEntriesRemoved: {
                                heatingUpperSeries.removePoints(index * 2, count * 2)
                                if (haveGeneratedLast) {
                                    heatingUpperSeries.removePoints(series.count - 1, 1)
                                    haveGeneratedLast = false
                                }
                                heatingLowerSeries.shrink()
                            }
                            Component.onCompleted: fetchLogs()
                        }

                        Component.onCompleted: {
                            series = chartView.createSeries(ChartView.SeriesTypeArea, thing.name, dateTimeAxis, boolAxis)
                            series.lowerSeries = heatingLowerSeries
                            series.upperSeries = heatingUpperSeries
                            series.color = Style.red
                            series.opacity = 0.1
                            series.borderWidth = 0;
                            series.borderColor = series.color
                        }
                        Component.onDestruction: {
                            chartView.removeSeries(series)
                        }
                    }
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
                    mouseArea.tooltipping = false;

                    if (mouseArea.dragging) {
                        d.refreshAll()
                        mouseArea.dragging = false;
                    }
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
                    logsLoader.fetchLogs()
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
                    print("dragging", dragDelta, totalTime, mouseArea.width)
                    d.now = new Date(Math.min(new Date(), new Date(startDatetime.getTime() + timeDelta)))
                }

                onWheel: {
                    startDatetime = d.now
                    var totalTime = d.endTime.getTime() - d.startTime.getTime()
                    // pixelDelta : timeDelta = width : totalTime
                    var timeDelta = wheel.pixelDelta.x * totalTime / mouseArea.width
                    print("wheeling", wheel.pixelDelta.x, totalTime, mouseArea.width)
                    d.now = new Date(Math.min(new Date(), new Date(startDatetime.getTime() - timeDelta)))
                    wheelStopTimer.restart()
                }
                Timer {
                    id: wheelStopTimer
                    interval: 300
                    repeat: false
                    onTriggered: {
                        d.refreshAll();
                    }
                }

                Rectangle {
                    height: parent.height
                    width: 1
                    color: Style.foregroundColor
                    x: Math.min(mouseArea.width - 1, Math.max(0, mouseArea.mouseX))
                    visible: (mouseArea.containsMouse || mouseArea.tooltipping) && !mouseArea.dragging
                }

                Item {
                    id: tooltips
                    anchors.fill: parent
                    property var timestamp: new Date(((d.endTime.getTime() - d.startTime.getTime()) * mouseArea.mouseX / mouseArea.width) + d.startTime.getTime())
                    property int xOnRight: Math.max(0, mouseArea.mouseX) + Style.smallMargins
                    property int xOnLeft: Math.min(mouseArea.width, mouseArea.mouseX) - Style.smallMargins - tooltipWidth

                    property int tooltipWidth: 130
                    property int tooltipX: xOnLeft < 0 ? xOnRight : xOnLeft

                    onTimestampChanged: {
                        updateTimer.start();
                    }
                    Timer {
                        id: updateTimer
                        interval: 0
                        onTriggered: tooltips.update()
                    }

                    function update() {
                        var ordered = []
                        insert(thermostatTooltipRepeater, ordered);
                        insert(tempTooltipRepeater, ordered);
                        insert(humidityTooltipRepeater, ordered);
                        insert(vocTooltipRepeater, ordered);

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
                }


                Repeater {
                    id: thermostatTooltipRepeater
                    model: thermostatsRepeater.count

                    delegate: TooltipDelegate {
                        visible: (mouseArea.containsMouse || mouseArea.tooltipping) && !mouseArea.dragging
                        thing: thermostatsRepeater.itemAt(index).thing
                        entry: thermostatsRepeater.itemAt(index).logsModel.find(tooltips.timestamp)
                        color: app.interfaceToColor("temperaturesensor")
                        iconSource: app.interfaceToIcon("temperaturesensor")
                        valueName: "temperature"
                        axis: temperatureAxis
                        x: tooltips.tooltipX
                        width: tooltips.tooltipWidth
                        backgroundItem: chartView
                        backgroundRect: Qt.rect(mouseArea.x + x, mouseArea.y + y, width, height)
                        unit: Types.UnitDegreeCelsius
                    }
                }

                Repeater {
                    id: tempTooltipRepeater
                    model: tempRepeater.count

                    delegate: TooltipDelegate {
                        visible: (mouseArea.containsMouse || mouseArea.tooltipping) && !mouseArea.dragging
                        thing: tempRepeater.itemAt(index).thing
                        entry: tempRepeater.itemAt(index).logsModel.find(tooltips.timestamp)
                        valueName: "temperature"
                        color: app.interfaceToColor("temperaturesensor")
                        iconSource: app.interfaceToIcon("temperaturesensor")
                        axis: temperatureAxis
                        x: tooltips.tooltipX
                        width: tooltips.tooltipWidth
                        backgroundItem: chartView
                        backgroundRect: Qt.rect(mouseArea.x + x, mouseArea.y + y, width, height)
                        unit: Types.UnitDegreeCelsius
                    }
                }

                Repeater {
                    id: humidityTooltipRepeater
                    model: humidityRepeater.count

                    delegate: TooltipDelegate {
                        visible: (mouseArea.containsMouse || mouseArea.tooltipping) && !mouseArea.dragging
                        thing: humidityRepeater.itemAt(index).thing
                        entry: humidityRepeater.itemAt(index).logsModel.find(tooltips.timestamp)
                        color: app.interfaceToColor("humiditysensor")
                        iconSource: app.interfaceToIcon("humiditysensor")
                        valueName: "humidity"
                        axis: humidityAxis
                        x: tooltips.tooltipX
                        width: tooltips.tooltipWidth
                        backgroundItem: chartView
                        backgroundRect: Qt.rect(mouseArea.x + x, mouseArea.y + y, width, height)
                        unit: Types.UnitPercentage
                    }
                }

                Repeater {
                    id: vocTooltipRepeater
                    model: vocRepeater.count

                    delegate: TooltipDelegate {
                        visible: (mouseArea.containsMouse || mouseArea.tooltipping) && !mouseArea.dragging
                        thing: vocRepeater.itemAt(index).thing
                        entry: vocRepeater.itemAt(index).logsModel.find(tooltips.timestamp)
                        valueName: "voc"
                        color: app.interfaceToColor("vocsensor")
                        iconSource: app.interfaceToIcon("vocsensor")
                        axis: vocAxis
                        x: tooltips.tooltipX
                        width: tooltips.tooltipWidth
                        backgroundItem: chartView
                        backgroundRect: Qt.rect(mouseArea.x + x, mouseArea.y + y, width, height)
                        unit: Types.UnitPartsPerMillion
                    }
                }
            }
        }

        GridLayout {
            id: legend
            Layout.fillWidth: true
            Layout.leftMargin: chartView.plotArea.x
            Layout.rightMargin: Style.smallMargins
            Layout.bottomMargin: Style.smallMargins
            columns: Math.min(Math.max(1, width / 100),
                              thermostatsRepeater.count
                              + tempRepeater.count
                              + humidityRepeater.count
                              + vocRepeater.count
                              + (windowOpenRepeater.count > 0 ? 1 : 0)
                              + (heatingRepeater.count > 0 ? 1 : 0))

            Repeater {
                model: thermostatsRepeater.count
                delegate: LegendDelegate {
                    Layout.fillWidth: true
                    text: thermostatsRepeater.itemAt(index).thing.name
                    iconName: app.interfaceToIcon("thermostat")
                    color: app.interfaceToColor("temperaturesensor")
                }
            }
            Repeater {
                model: tempRepeater.count
                delegate: LegendDelegate {
                    Layout.fillWidth: true
                    text: tempRepeater.itemAt(index).thing.name
                    iconName: app.interfaceToIcon("temperaturesensor")
                    color: app.interfaceToColor("temperaturesensor")
                }
            }
            Repeater {
                model: humidityRepeater.count
                delegate: LegendDelegate {
                    Layout.fillWidth: true
                    text: humidityRepeater.itemAt(index).thing.name
                    iconName: app.interfaceToIcon("humiditysensor")
                    color: app.interfaceToColor("humiditysensor")
                }
            }
            Repeater {
                model: vocRepeater.count
                delegate: LegendDelegate {
                    Layout.fillWidth: true
                    text: vocRepeater.itemAt(index).thing.name
                    iconName: app.interfaceToIcon("vocsensor")
                    color: app.interfaceToColor("vocsensor")
                }
            }
            LegendDelegate {
                Layout.fillWidth: true
                color: Qt.rgba(Style.green.r, Style.green.g, Style.green.b, 0.2)
                text: qsTr("Window open")
            }
            LegendDelegate {
                Layout.fillWidth: true
                color: Qt.rgba(Style.red.r, Style.red.g, Style.red.b, 0.2)
                text: qsTr("Heating on")
            }
        }
    }

}

