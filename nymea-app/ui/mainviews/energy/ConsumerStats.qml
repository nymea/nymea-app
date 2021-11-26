import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.3
import QtCharts 2.3
import Nymea 1.0

ChartView {
    id: root
    backgroundColor: "transparent"
    legend.alignment: Qt.AlignBottom
    legend.font: Style.extraSmallFont
    legend.labelColor: !powerLogs.fetchingData && powerLogs.count > 0 ? Style.foregroundColor : Style.gray

//    margins.left: 0
    margins.right: 0
    margins.bottom: 0
    margins.top: 0

    title: qsTr("Consumer statistics")
    titleColor: Style.foregroundColor

    property EnergyManager energyManager: null


    readonly property date dayStart: {
        var d = new Date();
        d.setHours(0,0,0,0);
        return d;
    }

    readonly property var daysList: {
        var ret = []
        for (var i = 6; i >= 0; i--) {
            var last = new Date(dayStart)
            ret.push(last.setDate(last.getDate() - i))
        }
        return ret;
    }

    readonly property var daysListNames: {
        var ret = []
        for (var i = 0; i < daysList.length; i++) {
            ret.push(new Date(daysList[i]).toLocaleString(Qt.locale(), "ddd"))
        }
        return ret;
    }

    readonly property date weekStart: {
        var d = new Date();
        d.setHours(0, 0, 0, 0);
        d.setDate(d.getDate() - d.getDay());
        return d
    }
    readonly property date monthStart: {
        var d = new Date();
        d.setHours(0,0,0,0);
        d.setDate(1);
        return d;
    }
    readonly property date yearStart: {
        var d = new Date();
        d.setHours(0,0,0,0);
        d.setDate(1);
        d.setMonth(0);
        return d;
    }


    ThingsProxy {
        id: consumers
        engine: _engine
        shownInterfaces: ["smartmeterconsumer"]
        sortStateName: "totalEnergyConsumed"
        sortOrder: Qt.DescendingOrder

    }
    Connections {
        target: engine.thingManager
        onFetchingDataChanged: {
            var thingIds = []
            for (var i = 0; i < consumers.count; i++) {
                thingIds.push(consumers.get(i).id)
            }
            powerLogs.thingIds = thingIds
        }
    }

    ThingPowerLogs {
        id: powerLogs
        engine: _engine
        sampleRate: EnergyLogs.SampleRate1Day
        startTime: root.yearStart
        loadingInhibited: thingIds.length === 0

        onFetchingDataChanged: {
            if (!fetchingData) {
                barSeries.clear();
                for (var j = 0; j < consumers.count; j++) {
                    var consumer = consumers.get(j)
                    var consumptionValues = []
                    for (var i = 0; i < daysList.length; i++) {
                        var start = powerLogs.find(consumer.id, new Date(daysList[i]))
                        var startValue = start !== null ? start.totalConsumption : 0
                        var end = i < daysList.length -1 ? powerLogs.find(consumer.id, new Date(daysList[i+1])) : null
                        var endValue = end !== null ? end.totalConsumption : start !== null ? consumer.stateByName("totalEnergyConsumed").value : 0
                        var consumptionValue = endValue - startValue
                        consumptionValues.push(consumptionValue)
                        valueAxis.adjustMax(consumptionValue)
                    }
                    var barSet = barSeries.append(consumer.name, consumptionValues)
                    barSet.borderWidth = 0
                    barSet.borderColor = barSet.color
                }
            }
        }
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
                text: ((valueAxis.max - (index * valueAxis.max / (valueAxis.tickCount - 1)))).toFixed(0) + "kWh"
                verticalAlignment: Text.AlignTop
                font: Style.extraSmallFont
                color: !powerLogs.fetchingData && powerLogs.count > 0 ? Style.foregroundColor : Style.gray
            }
        }
    }

    BarSeries {
        id: barSeries
        axisX: BarCategoryAxis {
            id: categoryAxis
            categories: daysListNames
            labelsColor: !powerLogs.fetchingData && powerLogs.count > 0 ? Style.foregroundColor : Style.gray
            labelsFont: Style.extraSmallFont
            gridVisible: false
            gridLineColor: Style.tileOverlayColor
            lineVisible: false
            titleVisible: false
            shadesVisible: false

        }
        axisY: ValueAxis {
            id: valueAxis
            min: 0
            gridLineColor: Style.tileOverlayColor
            labelsVisible: false
            labelsColor: Style.foregroundColor
            labelsFont: Style.extraSmallFont
            lineVisible: false
            titleVisible: false
            shadesVisible: false

            function adjustMax(newValue) {
                if (max < newValue) {
                    max = Math.ceil(newValue)
                }
            }
        }
    }

    Label {
        x: root.plotArea.x
        y: root.plotArea.y
        width: root.plotArea.width
        height: root.plotArea.height
        wrapMode: Text.WordWrap
        text: qsTr("No data available")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        visible: !powerLogs.fetchingData && powerLogs.count == 0
    }
}
