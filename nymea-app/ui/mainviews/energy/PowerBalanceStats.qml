import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.3
import QtCharts 2.3
import Nymea 1.0
import "qrc:/ui/components/"

ColumnLayout {
    id: root

    property EnergyManager energyManager: null

    readonly property date minuteStart: {
        var d = new Date();
        d.setSeconds(0, 0)
        return d;
    }
    readonly property var minutesList: {
        var ret = []
        for (var i = 15; i >= 0; i--) {
            var last = new Date(minuteStart)
            ret.push(last.setTime(last.getTime() - i * 60 * 1000))
        }
        return ret;
    }
    readonly property var minutesListNames: {
        var ret = []
        for (var i = 0; i < minutesList.length; i++) {
            ret.push(new Date(minutesList[i]).toLocaleString(Qt.locale(), "hh:mm"))
        }
        return ret;
    }

    readonly property date hourStart: {
        var d = new Date();
        d.setMinutes(0, 0, 0);
        return d;
    }

    readonly property var hoursList: {
        var ret = []
        for (var i = 24; i >= 0; i--) {
            var last = new Date(hourStart)
        }
        return ret;
    }
    readonly property var hoursListNames: {
        var ret = [];
        for (var i = 0; i < hoursList.length; i++) {
            ret.push(new Date(hoursList[i]).toLocaleString(Qt.locale(), "dd"));
        }
        return ret;
    }

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



    Label {
        Layout.fillWidth: true
        Layout.margins: Style.smallMargins
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("Energy consumption statistics")

    }

    SelectionTabs {
        id: selectionTabs
        Layout.fillWidth: true
        Layout.leftMargin: Style.smallMargins
        Layout.rightMargin: Style.smallMargins
        model: ListModel {
//            ListElement {
//                modelData: qsTr("Year")
//                sampleRate: EnergyLogs.SampleRate1Year
//            }
//            ListElement {
//                text: qsTr("Month")
//                sampleRate: EnergyLogs.SampleRate1Month
//            }
//            ListElement {
//                text: qsTr("Week")
//                sampleRate: EnergyLogs.SampleRate1Week
//            }

            Component.onCompleted: {
                append({modelData: qsTr("Day"), config: "days", sampleRate: EnergyLogs.SampleRate1Day, startTime: yearStart, sampleList: daysList, sampleListNames: daysListNames })
                append({modelData: qsTr("Hour"), config: "hours", sampleRate: EnergyLogs.SampleRate1Hour, startTime: monthStart, sampleList: hoursList, sampleListNames: hoursListNames })
            }

//            ListElement {
//                modelData: qsTr("Day")
//                sampleRate: EnergyLogs.SampleRate1Day
//                startTime: weekStart
//            }
//            ListElement {
//                modelData: qsTr("Hour")
//                sampleRate: EnergyLogs.SampleRate1Hour
//                startTime: dayStart
//            }
        }
//        currentIndex: 3
        onCurrentValueChanged: {
            print("Selecging model:", currentValue)
            powerBalanceLogs.loadingInhibited = true
            powerBalanceLogs.sampleRate = currentValue.sampleRate
            powerBalanceLogs.startTime = currentValue.startTime
            powerBalanceLogs.loadingInhibited = false

            consumptionSeries.remove(0, consumptionSeries.count-1)
            productionSeries.remove(0, productionSeries.count-1)
            acquisitionSeries.remove(0, acquisitionSeries.count-1)
            returnSeries.remove(0, returnSeries.count-1)

            print("sample list names:", currentValue.sampleListNames)
            categoryAxis.categories = currentValue.sampleListNames

        }
    }

    Connections {
        target: energyManager
        onPowerBalanceChanged: {
            var start = powerBalanceLogs.get(powerBalanceLogs.count - 1)
            print("updating", start.timestamp, root.energyManager.totalConsumption - (start ? start.totalConsumption : 0))
            consumptionSeries.replace(consumptionSeries.count - 1, root.energyManager.totalConsumption - (start ? start.totalConsumption : 0))
            productionSeries.replace(productionSeries.count - 1, root.energyManager.totalProduction - (start ? start.totalProduction : 0))
            acquisitionSeries.replace(acquisitionSeries.count - 1, root.energyManager.totalAcquisition - (start ? start.totalAcquisition : 0))
            returnSeries.replace(returnSeries.count - 1, root.energyManager.totalReturn - (start ? start.totalReturn : 0))
        }
    }

    PowerBalanceLogs {
        id: powerBalanceLogs
        engine: _engine
//        sampleRate: EnergyLogs.SampleRate1Day
//        startTime: root.yearStart;
        sampleRate: selectionTabs.currentValue.sampleRate// EnergyLogs.SampleRate1Min
        startTime: selectionTabs.currentValue.startTime // root.weekStart;

        property var sampleList: minutesList

        onFetchingDataChanged: {
            if (!fetchingData) {
                for (var i = 0; i < sampleList.length; i++) {
                    var start = powerBalanceLogs.find(new Date(sampleList[i]))
                    var end = null;
                    if (i+1 < sampleList.length) {
                        end = powerBalanceLogs.find(new Date(sampleList[i+1]))
                    }
                    print("** stats for:", new Date(sampleList[i]), start.timestamp, start.totalConsumption)
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

        onEntryAdded: {
            if (fetchingData) {
                return
            }

            var start = entry
            var consumptionValue = root.energyManager.totalConsumption - (start ? start.totalConsumption : 0)
            var productionValue = root.energyManager.totalProduction - (start ? start.totalProduction : 0)
            var acquisitionValue = root.energyManager.totalAcquisition - (start ? start.totalAcquisition : 0)
            var returnValue = root.energyManager.totalReturn - (start ? start.totalReturn : 0)
            consumptionSeries.append(consumptionValue)
            productionSeries.append(productionValue)
            acquisitionSeries.append(acquisitionValue)
            returnSeries.append(returnValue)
            consumptionSeries.remove(0, 1);
            productionSeries.remove(0, 1);
            acquisitionSeries.remove(0, 1);
            returnSeries.remove(0, 1);
        }
    }


    ChartView {
        id: chartView
        Layout.fillWidth: true
        Layout.fillHeight: true

        backgroundColor: "transparent"
        legend.alignment: Qt.AlignBottom
        legend.font: Style.extraSmallFont
        legend.labelColor: !powerBalanceLogs.fetchingData && powerBalanceLogs.count > 0 ? Style.foregroundColor : Style.gray

    //    margins.left: 0
        margins.right: 0
        margins.bottom: 0
        margins.top: 0

//        title: qsTr("Energy consumption statistics")
//        titleColor: "red"// Style.foregroundColor

        Item {
            id: labelsLayout
            x: Style.smallMargins
            y: chartView.plotArea.y
            height: chartView.plotArea.height
            width: chartView.plotArea.x - x
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
    //            categories: daysListNames
//                categories: minutesListNames
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
                        max = newValue // Math.ceil(newValue / 100) * 100
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
            x: chartView.plotArea.x
            y: chartView.plotArea.y
            width: chartView.plotArea.width
            height: chartView.plotArea.height
            wrapMode: Text.WordWrap
            text: qsTr("No data available")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            visible: !powerBalanceLogs.fetchingData && powerBalanceLogs.count == 0
        }
    }
}

