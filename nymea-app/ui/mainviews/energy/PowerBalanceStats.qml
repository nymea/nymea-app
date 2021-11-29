import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.3
import QtCharts 2.3
import Nymea 1.0
import "qrc:/ui/components/"

StatsBase {
    id: root

    property EnergyManager energyManager: null

    QtObject {
        id: d
        property BarSet consumptionSet: null
        property BarSet productionSet: null
        property BarSet acquisitionSet: null
        property BarSet returnSet: null
    }

    ColumnLayout {
        anchors.fill: parent

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
                Component.onCompleted: {
                    append({modelData: qsTr("Months"), config: "months" })
                    append({modelData: qsTr("Weeks"), config: "weeks" })
                    append({modelData: qsTr("Days"), config: "days" })
                    append({modelData: qsTr("Hours"), config: "hours" })
//                    append({modelData: qsTr("Minutes"), config: "minutes" })

                    selectionTabs.currentIndex = 2
                }
            }
            onCurrentValueChanged: {
                var config = root.configs[currentValue.config]
                print("config:", config.startTime(), config.sampleList(), config.sampleListNames())

                powerBalanceLogs.loadingInhibited = true
                powerBalanceLogs.sampleRate = config.sampleRate
                powerBalanceLogs.startTime = config.startTime()
                powerBalanceLogs.sampleList = config.sampleList()
                powerBalanceLogs.loadingInhibited = false

                barSeries.clear();

                d.consumptionSet = barSeries.append(qsTr("Consumed"), [])
                d.consumptionSet.color = Style.blue
                d.consumptionSet.borderWidth = 0
                d.productionSet = barSeries.append(qsTr("Produced"), [])
                d.productionSet.color = Style.green
                d.productionSet.borderWidth = 0
                d.acquisitionSet = barSeries.append(qsTr("From grid"), [])
                d.acquisitionSet.color = Style.red
                d.acquisitionSet.borderWidth = 0
                d.returnSet = barSeries.append(qsTr("To grid"), [])
                d.returnSet.color = Style.orange
                d.returnSet.borderWidth = 0


                valueAxis.max = 0
                categoryAxis.categories = config.sampleListNames()

                chartView.animationOptions = ChartView.SeriesAnimations
            }
        }

        Connections {
            target: energyManager
            onPowerBalanceChanged: {
                var start = powerBalanceLogs.get(powerBalanceLogs.count - 1)
    //            print("balance changed:", d.consumptionSet, powerBalanceLogs, powerBalanceLogs.count)
    //            print("updating", start.timestamp, root.energyManager.totalConsumption - (start ? start.totalConsumption : 0))
                d.consumptionSet.replace(d.consumptionSet.count - 1, root.energyManager.totalConsumption - (start ? start.totalConsumption : 0))
                d.productionSet.replace(d.productionSet.count - 1, root.energyManager.totalProduction - (start ? start.totalProduction : 0))
                d.acquisitionSet.replace(d.acquisitionSet.count - 1, root.energyManager.totalAcquisition - (start ? start.totalAcquisition : 0))
                d.returnSet.replace(d.returnSet.count - 1, root.energyManager.totalReturn - (start ? start.totalReturn : 0))
            }
        }

        PowerBalanceLogs {
            id: powerBalanceLogs
            engine: _engine
            loadingInhibited: true

            property var sampleList: minutesList

            onFetchingDataChanged: {
                if (!fetchingData) {
                    if (powerBalanceLogs.count == 0) {
                        valueAxis.adjustMax(root.energyManager.totalConsumption)
                        valueAxis.adjustMax(root.energyManager.totalAcquisition)
                        valueAxis.adjustMax(root.energyManager.totalProduction)
                        valueAxis.adjustMax(root.energyManager.totalReturn)

                        for (var i = 0; i < sampleList.length; i++) {
                            d.consumptionSet.append(i == sampleList.length - 1 ? root.energyManager.totalConsumption : 0)
                            d.productionSet.append(i == sampleList.length - 1 ? root.energyManager.totalProduction : 0)
                            d.acquisitionSet.append(i == sampleList.length - 1 ? root.energyManager.totalAcquisition : 0)
                            d.returnSet.append(i == sampleList.length - 1 ? root.energyManager.totalReturn : 0)
                        }
                        return;
                    }

                    for (var i = 0; i < sampleList.length; i++) {
                        var start = powerBalanceLogs.find(new Date(sampleList[i]))
                        var end = null;
                        if (i+1 < sampleList.length) {
                            end = powerBalanceLogs.find(new Date(sampleList[i+1]))
                        }
//                        print("** stats for:", new Date(sampleList[i]), /*start, end, */"start:", start ? start.totalConsumption : 0, "end:", end ? end.totalConsumption : root.energyManager.totalConsumption)
                        var consumptionValue = (end != null ? end.totalConsumption : root.energyManager.totalConsumption) - (start ? start.totalConsumption : 0)
                        var productionValue = (end != null ? end.totalProduction : root.energyManager.totalProduction) - (start ? start.totalProduction : 0)
                        var acquisitionValue = (end != null ? end.totalAcquisition : root.energyManager.totalAcquisition) - (start ? start.totalAcquisition : 0)
                        var returnValue = (end != null ? end.totalReturn : root.energyManager.totalReturn) - (start ? start.totalReturn : 0)

                        valueAxis.adjustMax(consumptionValue)
                        valueAxis.adjustMax(productionValue)
                        valueAxis.adjustMax(acquisitionValue)
                        valueAxis.adjustMax(returnValue)

                        d.consumptionSet.append(consumptionValue)
                        d.productionSet.append(productionValue)
                        d.acquisitionSet.append(acquisitionValue)
                        d.returnSet.append(returnValue)

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

                chartView.animationOptions = ChartView.NoAnimation
                categoryAxis.categories = configs[selectionTabs.currentValue.config].sampleListNames()
                d.consumptionSet.append(consumptionValue)
                d.productionSet.append(productionValue)
                d.acquisitionSet.append(acquisitionValue)
                d.returnSet.append(returnValue)
                d.consumptionSet.remove(0, 1);
                d.productionSet.remove(0, 1);
                d.acquisitionSet.remove(0, 1);
                d.returnSet.remove(0, 1);
                chartView.animationOptions = ChartView.SeriesAnimations
            }
        }


        ChartView {
            id: chartView
            Layout.fillWidth: true
            Layout.fillHeight: true
            animationOptions: ChartView.NoAnimations

            backgroundColor: "transparent"
            legend.alignment: Qt.AlignBottom
            legend.font: Style.extraSmallFont
            legend.labelColor: Style.foregroundColor

        //    margins.left: 0
            margins.right: 0
            margins.bottom: 0
            margins.top: 0

            Item {
                id: labelsLayout
                x: Style.smallMargins
                y: chartView.plotArea.y
                height: chartView.plotArea.height
                width: chartView.plotArea.x - x

                Repeater {
                    model: valueAxis.tickCount
                    delegate: Label {
                        y: parent.height / (valueAxis.tickCount - 1) * index - font.pixelSize / 2
                        width: parent.width - Style.smallMargins
                        horizontalAlignment: Text.AlignRight
                        text: ((valueAxis.max - (index * valueAxis.max / (valueAxis.tickCount - 1)))).toFixed(1) + "kWh"
                        verticalAlignment: Text.AlignTop
                        font: Style.extraSmallFont
                    }
                }
            }

            BarSeries {
                id: barSeries
                axisX: BarCategoryAxis {
                    id: categoryAxis
                    labelsColor: Style.foregroundColor
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
            }
        }
    }
}

