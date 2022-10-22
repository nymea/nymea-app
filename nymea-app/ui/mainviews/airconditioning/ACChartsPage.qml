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

        property int range: 60 * 24

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
    }


    ChartView {
        id: chartView
        anchors.fill: parent

        backgroundColor: "transparent"
        margins.left: 0
        margins.right: 0
        margins.top: 0
        margins.bottom: Style.smallIconSize + Style.margins

        legend.visible: false
        legend.alignment: Qt.AlignBottom
        legend.font: Style.extraSmallFont
        legend.labelColor: Style.foregroundColor

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
                //                switch (selectionTabs.currentValue.sampleRate) {
                //                case EnergyLogs.SampleRate1Min:
                //                case EnergyLogs.SampleRate15Mins:
                return "hh:mm"
                //                case EnergyLogs.SampleRate1Hour:
                //                case EnergyLogs.SampleRate3Hours:
                //                case EnergyLogs.SampleRate1Day:
                //                    return "dd.MM."
                //                }
            }
            tickCount: {
                //                switch (selectionTabs.currentValue.sampleRate) {
                //                case EnergyLogs.SampleRate1Min:
                //                case EnergyLogs.SampleRate15Mins:
                //                    return root.width > 500 ? 13 : 7
                //                case EnergyLogs.SampleRate1Hour:
                //                    return 7
                //                case EnergyLogs.SampleRate3Hours:
                //                case EnergyLogs.SampleRate1Day:
                return root.width > 500 ? 12 : 6
                //                }
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

                readonly property LogsModel logsModel: LogsModel {
                    objectName: "temp: " + thing.name
                    engine: typeIds.length > 0 ? _engine : null
                    thingId: thing.id
                    live: true
                    //                    graphSeries: series
                    viewStartTime: new Date(d.startTime.getTime() - d.range * 60000)

                    fetchBlockSize: 500

                    typeIds: {
                        var ret = [];
                        ret.push(thing.thingClass.stateTypes.findByName("temperature").id)
                        return ret;
                    }
                }

                XYSeriesAdapter {
                    logsModel: thermostatDelegate.logsModel
                    xySeries: series
                    sampleRate: XYSeriesAdapter.SampleRate10Minutes
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

                readonly property LogsModel logsModel: LogsModel {
                    objectName: "temp: " + thing.name
                    engine: typeIds.length > 0 ? _engine : null
                    thingId: thing.id
                    live: true
                    //                    graphSeries: series
                    viewStartTime: new Date(d.startTime.getTime() - d.range * 60000)

                    fetchBlockSize: 500

                    typeIds: {
                        var ret = [];
                        ret.push(thing.thingClass.stateTypes.findByName("temperature").id)
                        return ret;
                    }
                }

                XYSeriesAdapter {
                    logsModel: tempDelegate.logsModel
                    xySeries: series
                    sampleRate: XYSeriesAdapter.SampleRate10Minutes
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

                readonly property LogsModel logsModel: LogsModel {
                    objectName: "hum: " + thing.name
                    engine: typeIds.length > 0 ? _engine : null
                    thingId: thing.id
                    live: true
                    //                    graphSeries: series
                    viewStartTime: new Date(d.startTime.getTime() - d.range * 60000)
                    fetchBlockSize: 500

                    typeIds: {
                        var ret = [];
                        ret.push(thing.thingClass.stateTypes.findByName("humidity").id)
                        return ret;
                    }
                }

                XYSeriesAdapter {
                    logsModel: humidityDelegate.logsModel
                    xySeries: series
                    sampleRate: XYSeriesAdapter.SampleRate10Minutes
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
                readonly property LogsModel logsModel: LogsModel {
                    objectName: "voc: " + thing.name
                    engine: typeIds.length > 0 ? _engine : null
                    thingId: thing.id
                    live: true
                    //                    graphSeries: series
                    viewStartTime: new Date(d.startTime.getTime() - d.range * 60000)
                    fetchBlockSize: 500

                    typeIds: {
                        var ret = [];
                        ret.push(thing.thingClass.stateTypes.findByName("voc").id)
                        return ret;
                    }
                }

                XYSeriesAdapter {
                    logsModel: vocDelegate.logsModel
                    xySeries: series
                    sampleRate: XYSeriesAdapter.SampleRate10Minutes
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
                }

                readonly property LogsModel logsModel: LogsModel {
                    id: logsModelNg
                    engine: typeIds.length ? _engine : null
                    thingId: thing ? thing.id : ""
                    typeIds: {
                        var ret = [];
                        ret.push(thing.thingClass.stateTypes.findByName("closed").id)
                        return ret;
                    }
                    live: true
                    viewStartTime: new Date(d.startTime.getTime() - d.range * 60000)
                }

                BoolSeriesAdapter {
                    logsModel: closableDelegate.logsModel
                    xySeries: closableUpperSeries
                    inverted: true
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
                    XYPoint {x: dateTimeAxis.max.getTime(); y: 0}
                    XYPoint {x: dateTimeAxis.min.getTime(); y: 0}

                }

                readonly property LogsModel logsModel: LogsModel {
                    objectName: "heat: " + thing.name
                    engine: typeIds.length > 0 ? _engine : null
                    thingId: thing ? thing.id : ""
                    typeIds: {
                        var ret = [];
                        var heatingOnStateType = thing.thingClass.stateTypes.findByName("heatingOn")
                        print("**** has heatingOn")
                        if (heatingOnStateType) {
                            print("**** true")
                            ret.push(heatingOnStateType.id)
                        }
                        return ret;
                    }
                    live: true
                    //                    graphSeries: heatingUpperSeries
                    viewStartTime: dateTimeAxis.min
                }

                BoolSeriesAdapter {
                    logsModel: heatingDelegate.logsModel
                    xySeries: heatingUpperSeries
                }

                Component.onCompleted: {
                    series = chartView.createSeries(ChartView.SeriesTypeArea, thing.name, dateTimeAxis, boolAxis)
                    series.lowerSeries = heatingLowerSeries
                    series.upperSeries = heatingUpperSeries
                    series.color = Style.red
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
                //                for (var i = 0; i < consumersRepeater.count; i++) {
                //                    if (consumersRepeater.itemAt(i).logs.fetchingData) {
                //                        wheelStopTimer.start()
                //                        return;
                //                    }
                //                }

                //                powerBalanceLogs.fetchLogs()
                //                logsLoader.fetchLogs()
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
                entry: thermostatsRepeater.itemAt(index).logsModel.findClosest(tooltips.timestamp)
                color: app.interfaceToColor("temperaturesensor")
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
                entry: tempRepeater.itemAt(index).logsModel.findClosest(tooltips.timestamp)
                color: app.interfaceToColor("temperaturesensor")
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
                entry: humidityRepeater.itemAt(index).logsModel.findClosest(tooltips.timestamp)
                color: app.interfaceToColor("humiditysensor")
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
                entry: vocRepeater.itemAt(index).logsModel.findClosest(tooltips.timestamp)
                color: app.interfaceToColor("vocsensor")
                axis: vocAxis
                x: tooltips.tooltipX
                width: tooltips.tooltipWidth
                backgroundItem: chartView
                backgroundRect: Qt.rect(mouseArea.x + x, mouseArea.y + y, width, height)
                unit: Types.UnitPartsPerMillion
            }
        }
    }


    RowLayout {
        id: legend
        anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
        anchors.leftMargin: chartView.plotArea.x
        height: Style.smallIconSize
        anchors.margins: Style.margins

        Repeater {
            model: thermostatsRepeater.count
            delegate: LegendDelegate {
                thing: thermostatsRepeater.itemAt(index).thing
                iconName: app.interfaceToIcon("thermostat")
                color: app.interfaceToColor("temperaturesensor")
            }
        }
        Repeater {
            model: tempRepeater.count
            delegate: LegendDelegate {
                thing: tempRepeater.itemAt(index).thing
                iconName: app.interfaceToIcon("temperaturesensor")
                color: app.interfaceToColor("temperaturesensor")
            }
        }
        Repeater {
            model: humidityRepeater.count
            delegate: LegendDelegate {
                thing: humidityRepeater.itemAt(index).thing
                iconName: app.interfaceToIcon("humiditysensor")
                color: app.interfaceToColor("humiditysensor")
            }
        }
        Repeater {
            model: vocRepeater.count
            delegate: LegendDelegate {
                thing: vocRepeater.itemAt(index).thing
                iconName: app.interfaceToIcon("vocsensor")
                color: app.interfaceToColor("vocsensor")
            }
        }
    }
}

