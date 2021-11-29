import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.3
import QtCharts 2.3
import Nymea 1.0
import "qrc:/ui/components/"

StatsBase {
    id: root

    property EnergyManager energyManager: null
    property var colors: null

    property ThingsProxy consumers: null

    Connections {
        target: consumers
        onCountChanged: root.update()
    }

    Connections {
        target: engine.thingManager
        onFetchingDataChanged: root.update()
    }
    Connections {
        target: engine.tagsManager
        onBusyChanged: root.update()
    }

    function update() {
        if (engine.thingManager.fetchingData || engine.tagsManager.busy) {
            return
        }
        powerLogs.loadingInhibited = true

        var thingIds = []
        for (var i = 0; i < consumers.count; i++) {
            thingIds.push(consumers.get(i).id)
        }
        powerLogs.thingIds = thingIds

        var config = root.configs[selectionTabs.currentValue.config]
//                print("config:", config.startTime(), config.sampleList(), config.sampleListNames())

        powerLogs.sampleRate = config.sampleRate
        powerLogs.startTime = config.startTime()
        powerLogs.sampleList = config.sampleList()

        barSeries.clear();
        barSeries.thingBarSetMap = ({})

        valueAxis.max = 0
        categoryAxis.categories = config.sampleListNames()

        chartView.animationOptions = ChartView.SeriesAnimations

        powerLogs.loadingInhibited = false
    }

    ThingPowerLogs {
        id: powerLogs
        engine: _engine
        loadingInhibited: true

        property var sampleList: null

        onFetchingDataChanged: {
            if (!fetchingData) {
                barSeries.clear();
                for (var j = 0; j < consumers.count; j++) {
                    // Note: Needs to be let, not var so the lambda capture below copies it instead of capturing the reference
                    let consumer = consumers.get(j)
//                    print("ConsumerStats: Adding thing:", consumer.name)
                    let totalEnergyConsumedState = consumer.stateByName("totalEnergyConsumed")
//                    print("Adding consumer:", consumer.name, consumer.id)
                    var consumptionValues = []
                    for (var i = 0; i < sampleList.length; i++) {
                        var start = powerLogs.find(consumer.id, new Date(sampleList[i]))
                        var startValue = start !== null ? start.totalConsumption : 0
                        var end = i < sampleList.length -1 ? powerLogs.find(consumer.id, new Date(sampleList[i+1])) : null
                        var endValue = end !== null ? end.totalConsumption : 0
                        if (i == sampleList.length - 1) {
                            endValue = totalEnergyConsumedState.value
                        }

//                        print("adding sample", new Date(sampleList[i]), start ? start.timestamp : "X", " - ", end ? end.timestamp : "X")
//                        print("values. start:", startValue, "end", endValue, "diff", endValue - startValue)
                        var consumptionValue = endValue - startValue
//                        print("Value", consumptionValue)
                        consumptionValues.push(consumptionValue)
                        valueAxis.adjustMax(consumptionValue)
                    }
                    let barSet = barSeries.append(consumer.name, consumptionValues)
                    barSet.color = root.colors[j % root.colors.length]
                    barSet.borderWidth = 0
                    barSet.borderColor = barSet.color
                    barSeries.thingBarSetMap[consumer] = barSet

                    totalEnergyConsumedState.onValueChanged.connect(function() {
                        var sampleList = root.configs[selectionTabs.currentValue.config].sampleList()
                        var lastSample = sampleList[sampleList.length - 1]
//                        print("sampleList:", powerLogs.sampleList)
                        var start = powerLogs.find(consumer.id, new Date(lastSample))
//                        print("consumer value changed:", consumer.name, totalEnergyConsumedState.value, start.timestamp, start.totalConsumption)
                        var barSet = barSeries.thingBarSetMap[consumer]
                        barSet.replace(barSet.count - 1, totalEnergyConsumedState.value - start.totalConsumption)
                    })
                }
            }
        }

        onEntriesAdded: {
            if (fetchingData) {
                return
            }

            chartView.animationOptions = ChartView.NoAnimation

            for (var i = 0; i < entries.length; i++) {
                var entry = entries[i]
                var thing = engine.thingManager.things.getThing(entry.thingId)
//                print("Adding new sample. thing:", thing.name);
//                print("Timestamp:", entry.timestamp)
                var totalEnergyConsumedState = thing.stateByName("totalEnergyConsumed")
//                print("current total:", entry.totalConsumption)

                var consumptionValue = totalEnergyConsumedState.value - entry.totalConsumption
//                print("new slot total:", consumptionValue)

                categoryAxis.categories = configs[selectionTabs.currentValue.config].sampleListNames()
                barSeries.thingBarSetMap[thing].append(consumptionValue)
                barSeries.thingBarSetMap[thing].remove(0, 1);
            }

            chartView.animationOptions = ChartView.SeriesAnimations
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Label {
            Layout.fillWidth: true
            Layout.margins: Style.smallMargins
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Consumers statistics")

        }

        SelectionTabs {
            id: selectionTabs
            Layout.fillWidth: true
            Layout.leftMargin: Style.smallMargins
            Layout.rightMargin: Style.smallMargins
            currentIndex: 0
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
                root.update()
            }
        }


        ChartView {
            id: chartView
            Layout.fillWidth: true
            Layout.fillHeight: true

            //    margins.left: 0
            margins.right: 0
            margins.bottom: 0
            margins.top: 0

            backgroundColor: "transparent"
            legend.alignment: Qt.AlignBottom
            legend.font: Style.extraSmallFont
            legend.labelColor: Style.foregroundColor


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
                        color: Style.foregroundColor
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
                            max = Math.ceil(newValue)
                        }
                    }
                }

                property var thingBarSetMap: ({})
            }
        }
    }
}
