import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import QtCharts 2.3
import Nymea 1.0
import "qrc:/ui/components/"

StatsBase {
    id: root

    property EnergyManager energyManager: null
    property var colors: null

    property ThingsProxy consumers: null

    QtObject {
        id: d

        property var config: root.configs[selectionTabs.currentValue.config]

        property int startOffset: 0

        property date startTime: root.calculateTimestamp(config.startTime(), config.sampleRate, startOffset)
        property date endTime: root.calculateTimestamp(config.startTime(), config.sampleRate, startOffset + config.count)

        property bool fetchPending: false
        property bool loading: d.fetchPending || wheelStopTimer.running || logsLoader.fetchingData

        onConfigChanged: {
            for (var i = 0; i < consumersRepeater.count; i++) {
                consumersRepeater.itemAt(i).refreshLabels()
            }

            valueAxis.max = 1
        }

        onLoadingChanged: {
            if (!loading) {
                refresh()
            }
        }

        function refresh() {
            for (var i = 0; i < consumersRepeater.count; i++) {
                consumersRepeater.itemAt(i).refresh()
            }
        }
    }

    ThingPowerLogsLoader {
        id: logsLoader
        engine: _engine
        startTime: root.calculateTimestamp(d.startTime, d.config.sampleRate, -d.config.count)
        endTime: root.calculateTimestamp(d.startTime, d.config.sampleRate, d.config.count)
        sampleRate: d.config.sampleRate

        onFetchingDataChanged: {
            if (!fetchingData) {
                print("Logs fetched")
                d.fetchPending = false
            }
        }
    }

    Repeater {
        id: consumersRepeater
        model: root.consumers
        onCountChanged: {
            if (count == root.consumers.count) {
                logsLoader.fetchLogs();
            }
        }

        delegate: Item {
            id: consumerDelegate
            readonly property Thing thing: root.consumers.get(index)
            property BarSet barSet: null


            Connections {
                target: d
                onStartOffsetChanged: refresh()
            }

            function refreshLabels() {
                var values = []
                for (var i = 0; i < d.config.count; i++) {
                    values.push(0)
                }
                barSet.values = values;
            }

            function refresh() {
                var upcomingTimestamp = root.calculateTimestamp(d.config.startTime(), d.config.sampleRate, d.config.count)
//                print("refreshing", consumerDelegate.thing.name ,"config start", d.config.startTime(), "upcoming:", upcomingTimestamp, "fetchPending", d.fetchPending, d.loading)
                for (var i = 0; i < d.config.count; i++) {
                    var timestamp = root.calculateTimestamp(d.config.startTime(), d.config.sampleRate, d.startOffset + i + 1)
                    var previousTimestamp = root.calculateTimestamp(timestamp, d.config.sampleRate, -1)
//                    print("timestamp:", timestamp, "previous:", previousTimestamp)
                    var entry = thingPowerLogs.find(timestamp)
                    var previousEntry = thingPowerLogs.find(previousTimestamp);
                    if (entry && (previousEntry || !d.loading)) {
//                        print("found entry:", entry.timestamp, previousEntry)
                        var consumption = entry.totalConsumption
                        if (previousEntry) {
                            consumption -= previousEntry.totalConsumption
                        }
                        barSet.replace(i, consumption)
                        valueAxis.adjustMax(consumption)

                    } else if (timestamp.getTime() == upcomingTimestamp.getTime() && (previousEntry || !d.loading)) {
                        var consumption = thingPowerLogs.liveEntry().totalConsumption
//                        print("it's today for thing", thing.name, consumption, previousEntry)
                        if (previousEntry) {
//                            print("previous timestamp", previousEntry.timestamp, previousEntry.totalConsumption)
                            consumption -= previousEntry.totalConsumption
                        }
                        barSet.replace(i, consumption)
                        valueAxis.adjustMax(consumption)
                    } else {
                        barSet.replace(i, 0)
                    }
                }
            }

            readonly property ThingPowerLogs logs: ThingPowerLogs {
                id: thingPowerLogs
                engine: _engine
                startTime: root.calculateTimestamp(d.startTime, d.config.sampleRate, -d.config.count)
                endTime: root.calculateTimestamp(d.startTime, d.config.sampleRate, d.config.count)
                thingId: consumerDelegate.thing.id
                sampleRate: d.config.sampleRate
                loader: logsLoader

                onFetchingDataChanged: {
                    if (fetchingData) {
                        return;
                    }
                    consumerDelegate.refresh()
                }
            }

            Component.onCompleted: {
                var values = []
                for (var i = 0; i < d.config.count; i++) {
                    values.push(0)
                }

                barSet = barSeries.append(consumerDelegate.thing.name, values)
                barSet.color = NymeaUtils.generateColor(Style.generationBaseColor, index)
                barSet.borderColor = barSet.color
                barSet.borderWith = 0
            }
            Component.onDestruction: {
                barSeries.remove(barSet)
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

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
            currentIndex: 1
            model: ListModel {
                ListElement { modelData: qsTr("Hours"); config: "hours" }
                ListElement { modelData: qsTr("Days"); config: "days" }
                ListElement { modelData: qsTr("Weeks"); config: "weeks" }
                ListElement { modelData: qsTr("Months"); config: "months" }
                ListElement { modelData: qsTr("Years"); config: "years" }
//                ListElement { modelData: qsTr("Minutes"); config: "minutes" }
            }
            onTabSelected: {
                d.startOffset = 0
                logsLoader.fetchLogs();
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                x: chartView.x + chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                y: chartView.y + chartView.plotArea.y + Style.smallMargins
                text: d.config.toRangeLabel(d.startTime)
                font: Style.smallFont
                opacity: d.startOffset < -d.config.count ? .5 : 0
                Behavior on opacity { NumberAnimation {} }
            }

            ChartView {
                id: chartView
                anchors.fill: parent

                backgroundColor: "transparent"
                //    margins.left: 0
                margins.right: 0
                margins.bottom: 0
                margins.top: 0

                legend.alignment: Qt.AlignBottom
                legend.font: Style.extraSmallFont
                legend.labelColor: Style.foregroundColor

                ActivityIndicator {
                    x: chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                    y: chartView.plotArea.y + (chartView.plotArea.height - height) / 2 + (chartView.plotArea.height / 8)
                    visible: logsLoader.fetchingData
                    opacity: .5
                }
                Label {
                    x: chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                    y: chartView.plotArea.y + (chartView.plotArea.height - height) / 2 + (chartView.plotArea.height / 8)
                    text: qsTr("No data available")
                    opacity: {
                        if (logsLoader.fetchingData || d.startOffset == 0) {
                            return 0
                        }
                        var oldestEntry = new Date().getTime();
                        var haveItems = false;
                        for (var i = 0; i < consumersRepeater.count; i++) {
                            var logsModel = consumersRepeater.itemAt(i).logs
                            var firstEntry = logsModel.get(0)
                            if (firstEntry) {
                                haveItems = true;
                                oldestEntry = Math.min(oldestEntry, firstEntry.timestamp.getTime())
                            }
                        }

                        print("oldestEntry", new Date(oldestEntry), haveItems)
                        if (!haveItems || oldestEntry >= d.endTime.getTime()) {
                            return 0.5
                        }
                        return 0;
                    }
                    font: Style.smallFont
                    Behavior on opacity { NumberAnimation {}}
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
                            print("Updating categories from", d.config.startTime())
                            for (var i = 0; i < d.config.count; i++) {
                                var timestamp = root.calculateTimestamp(d.config.startTime(), d.config.sampleRate, d.startOffset + i);
                                print("*** adding", timestamp, d.startOffset, i)
                                ret.push(d.config.toLabel(timestamp))
                            }
                            return ret;
                        }
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
                    property int idx: Math.max(0, Math.min(categoryAxis.count -1, Math.floor(mouseArea.mouseX * categoryAxis.count / mouseArea.width)))
                    visible: toolTip.visible

                    x: idx * parent.width / categoryAxis.count
                    Behavior on x { enabled: toolTip.animationsEnabled; NumberAnimation { duration: Style.animationDuration } }
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
                preventStealing: tooltipping || dragging

                property int startMouseX: 0
                property bool dragging: false
                property bool tooltipping: false
                property int dragStartOffset: 0

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
                    if (mouseArea.dragging) {
                        logsLoader.fetchLogs();
                        d.refresh()
                        mouseArea.dragging = false;
                    }
                    mouseArea.tooltipping = false;
                }

                onPressed: {
                    startMouseX = mouseX
                    dragStartOffset = d.startOffset
                }

                onDoubleClicked: {
                    var idx = Math.ceil(mouseArea.mouseX * d.config.count / mouseArea.width) - 1
                    var timestamp = root.calculateTimestamp(d.config.startTime(), d.config.sampleRate, d.startOffset + idx)
                    selectionTabs.currentIndex--
                    var startTime = d.config.startTime()
                    d.startOffset = (timestamp.getTime() - startTime.getTime()) / (d.config.sampleRate * 60 * 1000)
                    logsLoader.fetchLogs();
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
                    var slotWidth = mouseArea.width / d.config.count
                    var offset = Math.floor(dragDelta / slotWidth);
                    d.startOffset = Math.min(dragStartOffset + offset, 0)
                    d.fetchPending = true;
                }

                property int wheelDelta: 0
                onWheel: {
                    wheelDelta += wheel.pixelDelta.x
                    var slotWidth = mouseArea.width / d.config.count
                    while (wheelDelta > slotWidth) {
                        d.startOffset--
                        wheelDelta -= slotWidth
                    }
                    while (wheelDelta < -slotWidth) {
                        d.startOffset = Math.min(d.startOffset + 1, 0)
                        wheelDelta += slotWidth
                    }
                    d.fetchPending = true;
                    wheelStopTimer.restart()
                }

                Timer {
                    id: wheelStopTimer
                    interval: 300
                    repeat: false
                    onTriggered: {
                        logsLoader.fetchLogs()
                        d.refresh()
                    }
                }

                NymeaToolTip {
                    id: toolTip

                    backgroundItem: chartView
                    backgroundRect: Qt.rect(chartView.plotArea.x + toolTip.x, chartView.plotArea.y + toolTip.y, toolTip.width, toolTip.height)

                    property int idx: visible ? Math.max(0, Math.min(d.config.count - 1, Math.ceil(mouseArea.mouseX * d.config.count / mouseArea.width) - 1)) : 0
                    property date timestamp: root.calculateTimestamp(d.config.startTime(), d.config.sampleRate, d.startOffset + idx)

                    visible: (mouseArea.containsMouse || mouseArea.tooltipping) && !mouseArea.dragging

                    property int chartWidth: chartView.plotArea.width
                    property int barWidth: chartWidth / categoryAxis.count
                    x: chartWidth - (idx * barWidth + barWidth + Style.smallMargins) > width ?
                           idx * barWidth + barWidth + Style.smallMargins
                         : idx * barWidth - Style.smallMargins - width
                    property double setMaxValue: {
                        var max = 0;
                        for (var i = 0; i < consumersRepeater.count; i++) {
                            max = Math.max(max, consumersRepeater.itemAt(i).barSet.at(idx))
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
                            text: d.config.toLongLabel(toolTip.timestamp)
                            font: Style.smallFont
                        }

                        Repeater {
                            model: ListModel {
                                id: toolTipModel
                                property var entries: {
                                    var unsorted = []
                                    for (var i = 0; i < consumers.count; i++) {
                                        var consumer = consumers.get(i)
                                        var entry = {
                                            name: consumer.name,
                                            value: consumersRepeater.itemAt(i).barSet.at(toolTip.idx).toFixed(2),
                                            indexInModel: i
                                        }
                                        unsorted.push(entry)
                                    }
                                    return unsorted
                                }
                                onEntriesChanged: {
                                    clear();
                                    var unsorted = entries;
                                    for (var i = 0; i < unsorted.length; i++) {
                                        var j = 0;
                                        while (j < count && get(j).value > unsorted[i].value) {
                                            j++;
                                        }
                                        insert(j, unsorted[i])
                                    }
                                }
                            }

                            delegate: RowLayout {
                                Rectangle {
                                    width: Style.extraSmallFont.pixelSize
                                    height: width
        //                            color: root.colors[model.indexInModel % root.colors.length]
                                    color: NymeaUtils.generateColor(Style.generationBaseColor, model.indexInModel)
                                }
                                Label {
                                    text: "%1: %2 kWh".arg(model.name).arg(model.value)
                                    font: Style.extraSmallFont
                                }
                            }
                        }
                    }
                }
            }
        }

    }

}
