import QtQuick 2.0
import QtCharts 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.3
import Nymea 1.0

ChartView {
    id: root
    backgroundColor: "transparent"
    margins.left: 0
    margins.right: 0
    margins.bottom: 0
    margins.top: 0

    title: qsTr("Consumers history")
    titleColor: Style.foregroundColor

    legend.alignment: Qt.AlignBottom
    legend.labelColor: Style.foregroundColor
    legend.font: Style.extraSmallFont

    ThingPowerLogs {
        id: thingPowerLogs
        engine: _engine
        startTime: dateTimeAxis.min
        sampleRate: EnergyLogs.SampleRate15Mins
        thingIds: []
        loadingInhibited: thingIds.length === 0

        onEntriesAdded: {
            var thingValues = ({})
            var timestamp = entries[0].timestamp
            for (var i = 0; i < entries.length; i++) {
                var entry = entries[i]
                var thing = engine.thingManager.things.getThing(entries[i].thingId)
                thingValues[entry.thingId] = entry.currentPower
            }

            // Add them in the order of the chart (same as proxy), summing it up
            var totalValue = 0;
            for (var i = 0; i < consumers.count; i++) {
                var consumer = consumers.get(i);
                var value = thingValues.hasOwnProperty(consumer.id) ? thingValues[consumer.id] : 0
                totalValue += thingValues.hasOwnProperty(consumer.id) ? thingValues[consumer.id] : 0;
                var series = d.thingsSeriesMap[consumer.id];
                series.upperSeries.append(timestamp, totalValue)
            }
        }
    }

    property PowerBalanceLogs powerBalanceLogs: PowerBalanceLogs {
        engine: _engine
        startTime: dateTimeAxis.min
        sampleRate: EnergyLogs.SampleRate15Mins

        onEntryAdded: {
            consumptionSeries.addEntry(entry)

            if (dateTimeAxis.now < entry.timestamp) {
                dateTimeAxis.now = entry.timestamp
                zeroSeries.update(entry.timestamp)
            }
        }
    }

    Timer {
        interval: 60000
        repeat: true
        onTriggered: {
            var now = new Date()
            if (dateTimeAxis.now < now) {
                dateTimeAxis.now = now
                zeroSeries.update(now)
            }
        }
    }

    ThingsProxy {
        id: consumers
        engine: _engine
        shownInterfaces: ["smartmeterconsumer"]
    }
    Connections {
        target: engine.thingManager
        onFetchingDataChanged: d.updateConsumers()
    }


    Component.onCompleted: {
        for (var i = 0; i < powerBalanceLogs.count; i++) {
            var entry = powerBalanceLogs.get(i);
            consumptionSeries.addEntry(entry)
        }

        d.updateConsumers();
    }

    QtObject {
        id: d
        property var thingsSeriesMap: ({})

        function updateConsumers() {
            if (engine.thingManager.fetchingData) {
                return;
            }

            for (var thingId in d.thingsSeriesMap) {
                root.removeSeries(d.thingsSeriesMap[thingId])
            }
            d.thingsSeriesMap = ({})

            var consumerThingIds = []
            for (var i = 0; i < consumers.count; i++) {
                var thing = consumers.get(i);

                var baseSeries = zeroSeries;
                if (i > 0) {
                    baseSeries = d.thingsSeriesMap[consumerThingIds[i-1]].upperSeries
                    print("base for:", thing.name, "is", engine.thingManager.things.getThing(consumerThingIds[i-1]).name)
                }

                var series = root.createSeries(ChartView.SeriesTypeArea, thing.name, dateTimeAxis, valueAxis)
                series.lowerSeries = baseSeries
                series.upperSeries = lineSeriesComponent.createObject(series)
                series.borderWidth = 0;
                series.borderColor = series.color

                print("Adding thingId series", thing.id, thing.name)
                d.thingsSeriesMap[thing.id] = series
                consumerThingIds.push(thing.id)
            }
            thingPowerLogs.thingIds = consumerThingIds;
        }
    }

    Component {
        id: lineSeriesComponent
        LineSeries { }
    }

    ValueAxis {
        id: valueAxis
        min: 0
        max: Math.ceil(powerBalanceLogs.maxValue / 1000) * 1000
        labelFormat: ""
        gridLineColor: Style.tileOverlayColor
        labelsVisible: false
        lineVisible: false
        titleVisible: false
        shadesVisible: false
        //        visible: false

    }

    Item {
        id: labelsLayout
        x: Style.smallMargins
        y: root.plotArea.y
        height: root.plotArea.height
        width: plotArea.x - x
        Repeater {
            model: valueAxis.tickCount
            delegate: Label {
                y: parent.height / (valueAxis.tickCount - 1) * index - font.pixelSize / 2
                width: parent.width - Style.smallMargins
                horizontalAlignment: Text.AlignRight
                text: ((valueAxis.max - (index * valueAxis.max / (valueAxis.tickCount - 1))) / 1000).toFixed(2) + "kW"
                verticalAlignment: Text.AlignTop
                font: Style.extraSmallFont
            }
        }

    }

    DateTimeAxis {
        id: dateTimeAxis
        property date now: new Date()
        min: {
            var date = new Date(now);
            date.setTime(date.getTime() - (1000 * 60 * 60 * 24) + 2000);
            return date;
        }
        max: {
            var date = new Date(now);
            date.setTime(date.getTime() + 2000)
            return date;
        }
        format: "hh:mm"
        labelsFont: Style.extraSmallFont
        gridVisible: false
        minorGridVisible: false
        lineVisible: false
        shadesVisible: false
        labelsColor: Style.foregroundColor
    }

    AreaSeries {
        id: consumptionSeries
        axisX: dateTimeAxis
        axisY: valueAxis
//        color: Style.accentColor
        borderWidth: 0
        borderColor: color
        name: qsTr("Unknown")

        lowerSeries: LineSeries {
            id: zeroSeries
            XYPoint { x: dateTimeAxis.min.getTime(); y: 0 }
            XYPoint { x: dateTimeAxis.max.getTime(); y: 0 }
            function update(timestamp) {
                append(timestamp, 0);
                removePoints(1,1);
            }
        }
        upperSeries: LineSeries {
            id: consumptionUpperSeries
        }

        function addEntry(entry) {
            consumptionUpperSeries.append(entry.timestamp.getTime(), entry.consumption)
        }
    }
}
