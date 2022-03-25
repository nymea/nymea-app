import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import QtCharts 2.3
import Nymea 1.0
import "qrc:/ui/components/"

StatsBase {
    id: root

    property EnergyManager energyManager: null

    // Can be overridden to use a shared model and spare some resources
    property ThingsProxy producers: ThingsProxy {
        id: producers
        engine: _engine
        shownInterfaces: ["smartmeterproducer"]
    }
    Connections { target: producers; onCountChanged: d.load() }
    Connections { target: engine.thingManager; onFetchingDataChanged: d.load() }

    QtObject {
        id: d
        property BarSet consumptionSet: null
        property BarSet productionSet: null
        property BarSet acquisitionSet: null
        property BarSet returnSet: null

        function load() {
            if (selectionTabs.currentValue === undefined || engine.thingManager.fetchingData) {
                return
            }

            var config = root.configs[selectionTabs.currentValue.config]
            print("config:", config.startTime(), config.sampleRate)

            powerBalanceLogs.loadingInhibited = true
            powerBalanceLogs.sampleRate = config.sampleRate
            powerBalanceLogs.startTime = new Date(config.startTime().getTime() - config.sampleRate * 60000)
            powerBalanceLogs.loadingInhibited = false

            chartView.reset();
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Label {
            Layout.fillWidth: true
            Layout.margins: Style.smallMargins
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Totals")

        }

        SelectionTabs {
            id: selectionTabs
            Layout.fillWidth: true
            Layout.leftMargin: Style.smallMargins
            Layout.rightMargin: Style.smallMargins
            model: ListModel {
                Component.onCompleted: {
                    append({modelData: qsTr("Hours"), config: "hours" })
                    append({modelData: qsTr("Days"), config: "days" })
                    append({modelData: qsTr("Weeks"), config: "weeks" })
                    append({modelData: qsTr("Months"), config: "months" })
                    append({modelData: qsTr("Years"), config: "years" })
//                    append({modelData: qsTr("Minutes"), config: "minutes" })

                    selectionTabs.currentIndex = 1
                }
            }
            onCurrentValueChanged: {
                d.load();
            }
        }

        Connections {
            target: energyManager
            onPowerBalanceChanged: {
                var start = powerBalanceLogs.get(powerBalanceLogs.count - 1 )
//                print("balance changed:", d.consumptionSet, powerBalanceLogs, powerBalanceLogs.count)
//                print("updating", start ? start.timestamp : "", start ? start.totalConsumption : 0, root.energyManager.totalConsumption, root.energyManager.totalConsumption - (start ? start.totalConsumption : 0))
                d.consumptionSet.replace(d.consumptionSet.count - 1, root.energyManager.totalConsumption - (start ? start.totalConsumption : 0))
                if (producers.count > 0) {
                    d.productionSet.replace(d.productionSet.count - 1, root.energyManager.totalProduction - (start ? start.totalProduction : 0))
                    d.acquisitionSet.replace(d.acquisitionSet.count - 1, root.energyManager.totalAcquisition - (start ? start.totalAcquisition : 0))
                    d.returnSet.replace(d.returnSet.count - 1, root.energyManager.totalReturn - (start ? start.totalReturn : 0))
                }
            }
        }

        PowerBalanceLogs {
            id: powerBalanceLogs
            engine: _engine
            loadingInhibited: true

            onFetchingDataChanged: {
                if (!fetchingData) {
                    chartView.animationOptions = ChartView.NoAnimation

                    chartView.reset();

//                    print("Logs fetched")
                    var config = root.configs[selectionTabs.currentValue.config]

                    var labels = []
                    var entries = []

                    var newestLogTimestamp = powerBalanceLogs.count > 0 ? powerBalanceLogs.get(powerBalanceLogs.count - 1).timestamp : new Date();
                    for (var i = 0; i < config.count; i++) {
                        var entry = powerBalanceLogs.get(powerBalanceLogs.count - i - 1)

                        // if it's the first, let's add a generated entry which shows the total from the newest log to the current live value
                        if (i == 0) {
                            var liveEntry = {
                                consumption: energyManager.totalConsumption,
                                production: energyManager.totalProduction,
                                acquisition: energyManager.totalAcquisition,
                                returned: energyManager.totalReturn
                            }
                            if (entry) {
                                liveEntry.consumption -= entry.totalConsumption
                                liveEntry.production -= entry.totalProduction
                                liveEntry.acquisition -= entry.totalAcquisition
                                liveEntry.returned -= entry.totalReturn
                            }
//                            print("Adding live entry:", liveEntry.consumption, root.energyManager.totalConsumption, entry ? entry.totalConsumption : 0)
                            entries.unshift(liveEntry)
                            valueAxis.adjustMax(liveEntry.consumption)
                            valueAxis.adjustMax(liveEntry.production)
                            valueAxis.adjustMax(liveEntry.acquisition)
                            valueAxis.adjustMax(liveEntry.returned)
                        }

                        // Add the actual entry
                        var graphEntry = {
                            consumption: 0,
                            production: 0,
                            acquisition: 0,
                            returned: 0
                        }
                        var labelTime = new Date();
                        if (entry) {
//                            print("Have entry:", entry.timestamp, config.toLabel(entry.timestamp))
                            var previous = powerBalanceLogs.get(powerBalanceLogs.count - i - 2)
                            if (previous) {
                                graphEntry.consumption = entry.totalConsumption - previous.totalConsumption
                                graphEntry.production = entry.totalProduction - previous.totalProduction
                                graphEntry.acquisition = entry.totalAcquisition - previous.totalAcquisition
                                graphEntry.returned = entry.totalReturn - previous.totalReturn
                            } else {
                                graphEntry.consumption = entry.totalConsumption
                                graphEntry.production = entry.totalProduction
                                graphEntry.acquisition = entry.totalAcquisition
                                graphEntry.returned = entry.totalReturn
                            }
                            labelTime = entry.timestamp
                        } else {
                            labelTime = calculateSampleStart(newestLogTimestamp, config.sampleRate, i)
                        }

//                        print("Adding entry:", labelTime, graphEntry.consumption, config.toLabel(labelTime))
                        entries.unshift(graphEntry)
                        labels.unshift(labelTime)

                        // Given we've added 2 entries for the first run but only one label, we'll add the missing label
                        // at the end. This will shift the labels by one entries but that's ok because the logs timestamp
                        // is when the sample was created, but for the user it's better to show the the consumption values
                        // *during* that sample, not *before* the sample
                        if (i == config.count - 1) {
                            labelTime = new Date(labelTime.getTime() - config.sampleRate * 60000)
//                            print("Adding oldest entry label", labelTime, config.sampleRate, config.toLabel(labelTime))
                            labels.unshift(labelTime)
                        }

                        valueAxis.adjustMax(graphEntry.consumption)
                        valueAxis.adjustMax(graphEntry.production)
                        valueAxis.adjustMax(graphEntry.acquisition)
                        valueAxis.adjustMax(graphEntry.returned)
                    }

//                    print("assigning categories:", labels)
                    categoryAxis.timestamps = labels

                    chartView.animationOptions = NymeaUtils.chartsAnimationOptions

                    for (var i = 0; i < entries.length; i++) {
//                        print("Appending to set", JSON.stringify(entries[i]))
                        d.consumptionSet.append(entries[i].consumption)
                        if (producers.count > 0) {
                            d.productionSet.append(entries[i].production)
                            d.acquisitionSet.append(entries[i].acquisition)
                            d.returnSet.append(entries[i].returned)
                        }
                    }
                }
            }

            onEntryAdded: {
                if (fetchingData) {
                    return
                }

//                print("Entry added")
                var config = root.configs[selectionTabs.currentValue.config]


                var start = entry
                var consumptionValue = root.energyManager.totalConsumption - (start ? start.totalConsumption : 0)
                var productionValue = root.energyManager.totalProduction - (start ? start.totalProduction : 0)
                var acquisitionValue = root.energyManager.totalAcquisition - (start ? start.totalAcquisition : 0)
                var returnValue = root.energyManager.totalReturn - (start ? start.totalReturn : 0)
//                print("Entry added:", entry.timestamp, entry.totalConsumption, consumptionValue)

                chartView.animationOptions = ChartView.NoAnimation

                var timestamps = categoryAxis.timestamps;
                timestamps.push(entry.timestamp)
                timestamps.splice(0, 1)
                categoryAxis.timestamps = timestamps

                d.consumptionSet.remove(0, 1);
                d.consumptionSet.append(consumptionValue)

                if (producers.count > 0) {
                    d.productionSet.remove(0, 1);
                    d.productionSet.append(productionValue)
                    d.acquisitionSet.remove(0, 1);
                    d.acquisitionSet.append(acquisitionValue)
                    d.returnSet.remove(0, 1);
                    d.returnSet.append(returnValue)
                }

                chartView.animationOptions = NymeaUtils.chartsAnimationOptions
            }
        }


        ChartView {
            id: chartView
            Layout.fillWidth: true
            Layout.fillHeight: true
            animationOptions: ChartView.NoAnimation

            backgroundColor: "transparent"
            legend.alignment: Qt.AlignBottom
            legend.font: Style.extraSmallFont
            legend.labelColor: Style.foregroundColor

        //    margins.left: 0
            margins.right: 0
            margins.bottom: 0
            margins.top: 0

            function reset() {
                barSeries.clear();
                valueAxis.max = 0
                d.consumptionSet = barSeries.append(qsTr("Consumed"), [])
                d.consumptionSet.color = Style.blue
                d.consumptionSet.borderColor = d.consumptionSet.color
                d.consumptionSet.borderWidth = 0
                if (producers.count > 0) {
                    d.productionSet = barSeries.append(qsTr("Produced"), [])
                    d.productionSet.color = Style.green
                    d.productionSet.borderColor = d.productionSet.color
                    d.productionSet.borderWidth = 0
                    d.acquisitionSet = barSeries.append(qsTr("From grid"), [])
                    d.acquisitionSet.color = Style.red
                    d.acquisitionSet.borderColor = d.acquisitionSet.color
                    d.acquisitionSet.borderWidth = 0
                    d.returnSet = barSeries.append(qsTr("To grid"), [])
                    d.returnSet.color = Style.orange
                    d.returnSet.borderColor = d.returnSet.color
                    d.returnSet.borderWidth = 0
                }
            }

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

                    categories: {
                        var ret = []
                        for (var i = 0; i < timestamps.length; i++) {
                            ret.push(root.configs[selectionTabs.currentValue.config].toLabel(timestamps[i]))
                        }
                        return ret
                    }

                    property var timestamps: []

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

    Item {
        anchors.fill: parent
        anchors.leftMargin: chartView.x + chartView.plotArea.x
        anchors.topMargin: chartView.y + chartView.plotArea.y
        anchors.rightMargin: chartView.width - chartView.plotArea.width - chartView.plotArea.x
        anchors.bottomMargin: chartView.height - chartView.plotArea.height - chartView.plotArea.y
        z: -1

        Rectangle {
            height: parent.height + Style.margins * 2
            y: -Style.smallMargins
            radius: Style.smallCornerRadius
            width: chartView.plotArea.width / categoryAxis.count
            color: Style.tileBackgroundColor
            property int idx: Math.min(Math.max(0,Math.floor(mouseArea.mouseX * categoryAxis.count / mouseArea.width)), categoryAxis.count - 1)
            visible: toolTip.visible

            x: idx * parent.width / categoryAxis.count
            Behavior on x { NumberAnimation { duration: Style.animationDuration } }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.leftMargin: chartView.x + chartView.plotArea.x
        anchors.topMargin: chartView.y + chartView.plotArea.y
        anchors.rightMargin: chartView.width - chartView.plotArea.width - chartView.plotArea.x
        anchors.bottomMargin: chartView.height - chartView.plotArea.height - chartView.plotArea.y

        hoverEnabled: true

        Timer {
            interval: 300
            running: mouseArea.pressed
            onTriggered: mouseArea.preventStealing = true
        }
        onReleased: mouseArea.preventStealing = false

        NymeaToolTip {
            id: toolTip

            backgroundItem: chartView
            backgroundRect: Qt.rect(chartView.plotArea.x + toolTip.x, chartView.plotArea.y + toolTip.y, toolTip.width, toolTip.height)

            property int idx: Math.min(Math.max(0,Math.floor(mouseArea.mouseX * categoryAxis.count / mouseArea.width)), categoryAxis.count - 1)
            visible: mouseArea.containsMouse || mouseArea.preventStealing

            property int chartWidth: chartView.plotArea.width
            property int barWidth: chartWidth / categoryAxis.count

            x: chartWidth - (idx * barWidth + barWidth + Style.smallMargins) > width ?
                   idx * barWidth + barWidth + Style.smallMargins
                 : idx * barWidth - Style.smallMargins - width
            property double setMaxValue: producers.count == 0 && d.consumptionSet
                                         ? d.consumptionSet.at(idx)
                                         : d.consumptionSet && d.productionSet && d.acquisitionSet && d.returnSet ?
                                             Math.max(d.consumptionSet.at(idx), Math.max(d.productionSet.at(idx), Math.max(d.acquisitionSet.at(idx), d.returnSet.at(idx))))
                                           : 0
            y: Math.min(Math.max(mouseArea.height - (setMaxValue * mouseArea.height / valueAxis.max) - height - Style.smallMargins, 0), mouseArea.height - height)
            width: tooltipLayout.implicitWidth + Style.smallMargins * 2
            height: tooltipLayout.implicitHeight + Style.smallMargins * 2

            ColumnLayout {
                id: tooltipLayout
                anchors {
                    left: parent.left
                    top: parent.top
                    margins: Style.smallMargins
                }

                Label {
                    text: toolTip.idx >= 0 && categoryAxis.timestamps.length > toolTip.idx ? root.configs[selectionTabs.currentValue.config].toLongLabel(categoryAxis.timestamps[toolTip.idx]) : ""
                    font: Style.smallFont
                }

                RowLayout {
                    Rectangle {
                        width: Style.extraSmallFont.pixelSize
                        height: width
                        color: Style.blue
                    }
                    Label {
                        text: d.consumptionSet ? qsTr("Consumed: %1 kWh").arg(d.consumptionSet.at(toolTip.idx).toFixed(2)) : ""
                        font: Style.extraSmallFont
                    }
                }
                RowLayout {
                    visible: d.productionSet
                    Rectangle {
                        width: Style.extraSmallFont.pixelSize
                        height: width
                        color: Style.green
                    }
                    Label {
                        text: d.productionSet ? qsTr("Produced: %1 kWh").arg(d.productionSet.at(toolTip.idx).toFixed(2)) : ""
                        font: Style.extraSmallFont
                    }
                }
                RowLayout {
                    visible: d.acquisitionSet
                    Rectangle {
                        width: Style.extraSmallFont.pixelSize
                        height: width
                        color: Style.red
                    }
                    Label {
                        text: d.acquisitionSet ? qsTr("From grid: %1 kWh").arg(d.acquisitionSet.at(toolTip.idx).toFixed(2)) : ""
                        font: Style.extraSmallFont
                    }
                }
                RowLayout {
                    visible: d.returnSet
                    Rectangle {
                        width: Style.extraSmallFont.pixelSize
                        height: width
                        color: Style.orange
                    }
                    Label {
                        text: d.returnSet ? qsTr("To grid: %1 kWh").arg(d.returnSet.at(toolTip.idx).toFixed(2)) : ""
                        font: Style.extraSmallFont
                    }
                }
            }
        }
    }
}

