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
    legend.labelColor: !powerBalanceLogs.fetchingData && powerBalanceLogs.count > 0 ? Style.foregroundColor : Style.gray

//    margins.left: 0
    margins.right: 0
    margins.bottom: 0
    margins.top: 0

    title: qsTr("Energy consumption statistics")
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

    PowerBalanceLogs {
        id: powerBalanceLogs
        engine: _engine
        sampleRate: EnergyLogs.SampleRate1Day
        startTime: root.yearStart;

        onFetchingDataChanged: {
            if (!fetchingData) {
                for (var i = 0; i < daysList.length; i++) {
                    var start = powerBalanceLogs.find(new Date(daysList[i]))
                    var end = null;
                    if (i+1 < daysList.length) {
                        end = powerBalanceLogs.find(new Date(daysList[i+1]))
                    }
                    print("** stats for", daysList[i], new Date(daysList[i]), start.timestamp, start.totalConsumption)
                    var consumptionValue = (end != null ? end.totalConsumption : root.energyManager.totalConsumption) - (start ? start.totalConsumption : 0)
                    var productionValue = (end != null ? end.totalProduction : root.energyManager.totalProduction) - (start ? start.totalProduction : 0)
                    var acquisitionValue = (end != null ? end.totalAcquisition : root.energyManager.totalAcquisition) - (start ? start.totalAcquisition : 0)
                    var returnValue = (end != null ? end.totalReturn : root.energyManager.totalReturn) - (start ? start.totalReturn : 0)
                    consumptionSeries.append(consumptionValue)
                    productionSeries.append(productionValue)
                    acquisitionSeries.append(acquisitionValue)
                    returnSeries.append(returnValue)

                    valueAxis.adjustMax(consumptionValue)
                    valueAxis.adjustMax(productionValue)
                    valueAxis.adjustMax(acquisitionValue)
                    valueAxis.adjustMax(returnValue)
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
        enabled: !powerBalanceLogs.fetchingData && powerBalanceLogs.count > 0

        Repeater {
            model: valueAxis.tickCount
            delegate: Label {
                y: parent.height / (valueAxis.tickCount - 1) * index - font.pixelSize / 2
                width: parent.width - Style.smallMargins
                horizontalAlignment: Text.AlignRight
                text: ((valueAxis.max - (index * valueAxis.max / (valueAxis.tickCount - 1)))).toFixed(0) + "kWh"
                verticalAlignment: Text.AlignTop
                font: Style.extraSmallFont
            }
        }
    }

    BarSeries {
        axisX: BarCategoryAxis {
            id: categoryAxis
            categories: daysListNames
            labelsColor: !powerBalanceLogs.fetchingData && powerBalanceLogs.count > 0 ? Style.foregroundColor : Style.gray

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
                    max = Math.ceil(newValue / 100) * 100
                }
            }
        }

        BarSet {
            id: consumptionSeries
            label: qsTr("Consumed")
            borderWidth: 0
        }
        BarSet {
            id: productionSeries
            label: qsTr("Produced")
            color: Style.green
            borderWidth: 0
            borderColor: color
        }
        BarSet {
            id: acquisitionSeries
            label: qsTr("From grid")
            color: Style.red
            borderWidth: 0
            borderColor: color
        }
        BarSet {
            id: returnSeries
            label: qsTr("To grid")
            color: Style.orange
            borderWidth: 0
            borderColor: color
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
        visible: !powerBalanceLogs.fetchingData && powerBalanceLogs.count == 0
    }
}
