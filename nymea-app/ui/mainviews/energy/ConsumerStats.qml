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
        powerLogs.startTime = new Date(config.startTime().getTime() - config.sampleRate * 60000)

        barSeries.clear();
        barSeries.thingBarSetMap = ({})

        valueAxis.max = 0

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
                var config = root.configs[selectionTabs.currentValue.config]

                // First grouping log entries by timestamp
                var groupedEntries = []
                var groupedEntry = {}
                for (var i = powerLogs.count - 1; i >= 0; i--) {
                    var entry = powerLogs.get(i);
//                    print("grouping entry:", entry.timestamp, "current group entry", groupedEntry.timestamp, groupedEntry.hasOwnProperty("timestamp"))
                    if (!groupedEntry.hasOwnProperty("timestamp")) {
                        groupedEntry.timestamp = entry.timestamp;
//                        print("Starting new groupentry", groupedEntry.timestamp, entry.timestamp)
                    }
                    if (groupedEntry.timestamp.getTime() !== entry.timestamp.getTime()) {
                        if (groupedEntries.length > config.count) {
                            break;
                        }
//                        print("finalizing grouped entry", groupedEntry.timestamp)
                        groupedEntries.unshift(groupedEntry);
                        groupedEntry = {
                            timestamp: entry.timestamp
                        }
//                        print("Starting new groupentry", groupedEntry.timestamp, entry.timestamp)
                    }
                    groupedEntry[entry.thingId] = entry.totalConsumption
                }
                if (groupedEntry.hasOwnProperty("timestamp") && groupedEntries.length <= config.count) {
//                    print("finalizing grouped entry", groupedEntry.timestamp)
                    groupedEntries.unshift(groupedEntry)
                }



                chartView.animationOptions = ChartView.NoAnimation


                var labels = []
                var entries = []

                var newestLogTimestamp = powerLogs.count > 0 ? powerLogs.get(powerLogs.count - 1).timestamp : new Date();

                for (var i = 0; i < config.count; i++) {
                    var groupedEntry = groupedEntries[groupedEntries.length - i - 1]
//                    print("have grouped entry:", groupedEntry ? groupedEntry.timestamp : "null")

                    // if it's the first, let's add a generated entry which shows the total from the newest log to the current live value
                    if (i == 0) {
                        var liveEntry = {}
                        for (var j = 0; j < consumers.count; j++) {
                            var consumer = consumers.get(j)
                            var liveLogEntry = powerLogs.liveEntry(consumer.id)
//                            print("Got consumer:", consumer.id, consumer.name, liveLogEntry ? liveLogEntry.timestamp : "-")
                            var value = liveLogEntry ? liveLogEntry.totalConsumption : 0;
                            if (groupedEntry) {
                                value -= groupedEntry.hasOwnProperty(consumer.id) ? groupedEntry[consumer.id] : 0
                            }
                            liveEntry[consumer.id] = value
                            valueAxis.adjustMax(value)
                        }

//                        print("Adding live entry", JSON.stringify(liveEntry))
                        entries.unshift(liveEntry)
                    }

                    // Add the actual entry
                    var graphEntry = {}
                    var labelTime = new Date();

                    if (groupedEntry) {
                        var previousGroupedEntry = groupedEntries[groupedEntries.length - i - 2]
                        for (var j = 0; j < consumers.count; j++) {
                            var consumer = consumers.get(j)
                            var value = groupedEntry.hasOwnProperty(consumer.id) ? groupedEntry[consumer.id] : 0
                            if (previousGroupedEntry) {
                                var previousValue = previousGroupedEntry.hasOwnProperty(consumer.id) ? previousGroupedEntry[consumer.id] : 0
                                value -= previousValue
                            }
                            graphEntry[consumer.id] = value
                            valueAxis.adjustMax(value)
                        }
                        labelTime = groupedEntry.timestamp
                    } else {
                        for (var j = 0; j < consumers.count; j++) {
                            var consumer = consumers.get(j)
                            graphEntry[consumer.id] = 0
                        }
                        labelTime = new Date(newestLogTimestamp.getTime() - config.sampleRate * i * 60000)
                    }

//                    print("Adding entry:", labelTime, config.toLabel(labelTime), JSON.stringify(graphEntry))
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

                }

//                print("assigning categories:", labels)
                categoryAxis.timestamps = labels

                var map = {}
                for (var j = 0; j < consumers.count; j++) {
                    var consumer = consumers.get(j)
                    var barSet = barSeries.append(consumer.name, [])
                    barSet.color = root.colors[j % root.colors.length]
                    barSet.borderColor = barSet.color
                    barSet.borderWith = 0
                    map[consumer.id] = barSet
                }
                barSeries.thingBarSetMap = map

                chartView.animationOptions = ChartView.SeriesAnimations

                for (var i = 0; i < entries.length; i++) {
                    var entry = entries[i]
//                    print("Adding entry", JSON.stringify(entry))
                    for (var j = 0; j < consumers.count; j++) {
                        var consumer = consumers.get(j)
                        barSeries.thingBarSetMap[consumer.id].append(entry[consumer.id])
                    }
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
//                print("Timestamp:", entry.timestamp, entry.totalConsumption)
                // update current last
                var barSet = barSeries.thingBarSetMap[thing.id]
                var lastTimestamp = categoryAxis.timestamps[categoryAxis.count - 1]
                var previous = powerLogs.find(entry.thingId, lastTimestamp)
                var previousValue = previous ? previous.totalConsumption : 0
//                print("previousValue:", previousValue, "newValue:", entry.totalConsumption, "diff", entry.totalConsumption - previousValue)
                barSet.replace(barSet.count - 1, entry.totalConsumption - previousValue)

                // remove the oldest
                barSet.remove(0, 1)

                // and add a new one (always 0 for a start)
                barSet.append(0)
            }

            var labels = categoryAxis.timestamps
            labels.splice(0, 1)
            labels.push(entries[0].timestamp)
            categoryAxis.timestamps = labels

            chartView.animationOptions = ChartView.SeriesAnimations
        }

        onLiveEntryChanged: {
            if (powerLogs.fetchingData) {
                return
            }

//            print("live entry changed", entry.thingId, entry.timestamp)
            var previous = powerLogs.find(entry.thingId, new Date(categoryAxis.timestamps[categoryAxis.timestamps.length - 1]))
            var previousValue = previous ? previous.totalConsumption : 0
            var barSet = barSeries.thingBarSetMap[entry.thingId]

            if (!barSet) {
                return
            }

            barSet.replace(barSet.count - 1, entry.totalConsumption - previousValue)
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Label {
            Layout.fillWidth: true
            Layout.margins: Style.smallMargins
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Consumers totals")

        }

        SelectionTabs {
            id: selectionTabs
            Layout.fillWidth: true
            Layout.leftMargin: Style.smallMargins
            Layout.rightMargin: Style.smallMargins
            currentIndex: 0
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
                            max = Math.ceil(newValue)
                        }
                    }
                }

                property var thingBarSetMap: ({})
            }
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

            property int idx: Math.floor(mouseArea.mouseX * categoryAxis.count / mouseArea.width)
            visible: mouseArea.containsMouse

            x: Math.min(idx * mouseArea.width / categoryAxis.count, mouseArea.width - width)
            property double setMaxValue: {
                var max = 0;
                for (var i = 0; i < consumers.count; i++) {
                    var consumer = consumers.get(i)
                    max = barSeries.thingBarSetMap.hasOwnProperty(consumer.id) ? Math.max(max, barSeries.thingBarSetMap[consumer.id].at(idx)) : 0
                }
                return max
            }
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

                Repeater {
                    model: consumers
                    delegate: RowLayout {
                        Rectangle {
                            width: Style.extraSmallFont.pixelSize
                            height: width
                            color: index >= 0 ? root.colors[index % root.colors.length] : "white"
                        }
                        Label {
                            text: barSeries.thingBarSetMap.hasOwnProperty(model.id) ? "%1: %2 kWh".arg(model.name).arg(barSeries.thingBarSetMap[model.id].at(toolTip.idx).toFixed(2)) : ""
                            font: Style.extraSmallFont
                        }
                    }
                }
            }
        }
    }
}
