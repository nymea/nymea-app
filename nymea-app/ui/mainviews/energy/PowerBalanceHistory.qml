import QtQuick 2.0
import QtCharts 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import Nymea 1.0
import "qrc:/ui/components"

Item {
    id: root

    PowerBalanceLogs {
        id: powerBalanceLogs
        engine: _engine
        startTime: new Date(d.startTime.getTime() - d.range * 60000)
        endTime: new Date(d.endTime.getTime() + d.range * 60000)
        sampleRate: d.sampleRate
        Component.onCompleted: fetchLogs()
    }

    property ThingsProxy batteries: ThingsProxy {
        engine: _engine
        shownInterfaces: ["energystorage"]
    }

    QtObject {
        id: d
        property date now: new Date()

        readonly property int range: selectionTabs.currentValue.range
        readonly property int sampleRate: selectionTabs.currentValue.sampleRate
        readonly property int visibleValues: range / sampleRate

        readonly property var startTime: {
            var date = new Date(fixTime(now));
            date.setTime(date.getTime() - range * 60000 + 2000);
            return date;
        }

        readonly property var endTime: {
            var date = new Date(fixTime(now));
            date.setTime(date.getTime() + 2000)
            return date;
        }

        function fixTime(timestamp) {
            switch (sampleRate) {
            case EnergyLogs.SampleRate1Min:
                timestamp.setSeconds(0, 0)
                break;
            case EnergyLogs.SampleRate15Mins:
                timestamp.setMinutes(timestamp.getMinutes() - timestamp.getMinutes() % 15, 0, 0)
                break;
            case EnergyLogs.SampleRate1Hour:
                timestamp.setMinutes(0, 0, 0);
                break;
            case EnergyLogs.SampleRate3Hours:
                timestamp.setHours(timestamp.getHours() % 3, 0, 0, 0);
                break;
            case EnergyLogs.SampleRate1Day:
                timestamp.setHours(0, 0, 0, 0)
                break;
            }
            return timestamp
        }

    }

    Connections {
        target: powerBalanceLogs

        onEntriesAdded: {
//            print("entries added", index, entries.length)
            for (var i = 0; i < entries.length; i++) {
                var entry = entries[i]
//                print("got entry", entry.timestamp)

                zeroSeries.ensureValue(entry.timestamp)
                // For debugging, to see if the other maths line up with the plain production graph
                productionSeries.insertEntry(index + i, entry)
                consumptionSeries.insertEntry(index + i, entry)
                selfProductionConsumptionSeries.insertEntry(index + i, entry)
                toStorageSeries.insertEntry(index + i, entry)
                fromStorageSeries.insertEntry(index + i, entry)
                returnSeries.insertEntry(index + i, entry)
                acquisitionSeries.insertEntry(index + i, entry)
                if (entry.timestamp > d.now && new Date().getTime() - d.now.getTime() < 120000) {
                    d.now = entry.timestamp
                }
            }
        }

        onEntriesRemoved: {
            acquisitionUpperSeries.removePoints(index, count)
            returnUpperSeries.removePoints(index, count)
            fromStorageUpperSeries.removePoints(index, count)
            toStorageUpperSeries.removePoints(index, count)
            selfProductionConsumptionUpperSeries.removePoints(index, count)
            productionSeries.removePoints(index, count)
            consumptionSeries.removePoints(index, count)
            zeroSeries.shrink()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

//        Label {
//            Layout.fillWidth: true
//            Layout.margins: Style.smallMargins
//            horizontalAlignment: Text.AlignHCenter
//            text: qsTr("My production history")
//        }

        SelectionTabs {
            id: selectionTabs
            Layout.fillWidth: true
            Layout.leftMargin: Style.smallMargins
            Layout.rightMargin: Style.smallMargins
            currentIndex: 1
            model: ListModel {
                ListElement {
                    modelData: qsTr("Hours")
                    sampleRate: EnergyLogs.SampleRate1Min
                    range: 180 // 3 Hours: 3 * 60
                }
                ListElement {
                    modelData: qsTr("Days")
                    sampleRate: EnergyLogs.SampleRate15Mins
                    range: 1440 // 1 Day: 24 * 60
                }
                ListElement {
                    modelData: qsTr("Weeks")
                    sampleRate: EnergyLogs.SampleRate1Hour
                    range: 10080 // 7 Days: 7 * 24 * 60
                }
                ListElement {
                    modelData: qsTr("Months")
                    sampleRate: EnergyLogs.SampleRate3Hours
                    range: 43200 // 30 Days: 30 * 24 * 60
                }
            }
            onTabSelected: {
                d.now = new Date()
                powerBalanceLogs.fetchLogs()
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                x: chartView.x + chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                y: chartView.y + chartView.plotArea.y + Style.smallMargins
                text: {
                    switch (d.sampleRate) {
                    case EnergyLogs.SampleRate1Min:
                        return d.startTime.toLocaleDateString(Qt.locale(), Locale.LongFormat)
                    case EnergyLogs.SampleRate15Mins:
                    case EnergyLogs.SampleRate1Hour:
                    case EnergyLogs.SampleRate3Hours:
                    case EnergyLogs.SampleRate1Day:
                    case EnergyLogs.SampleRate1Week:
                    case EnergyLogs.SampleRate1Month:
                    case EnergyLogs.SampleRate1Year:
                        return d.startTime.toLocaleDateString(Qt.locale(), Locale.ShortFormat) + " - " + d.endTime.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
                    }
                }
                font: Style.smallFont
                opacity: ((new Date().getTime() - d.now.getTime()) / d.sampleRate / 60000) > d.visibleValues ? .5 : 0
                Behavior on opacity { NumberAnimation {} }
            }

            ChartView {
                id: chartView
                anchors.fill: parent
                backgroundColor: "transparent"
                margins.left: 0
                margins.right: 0
                margins.bottom: Style.smallIconSize + Style.margins
                margins.top: 0

                legend.alignment: Qt.AlignBottom
                legend.labelColor: Style.foregroundColor
                legend.font: Style.extraSmallFont
                legend.visible: false

                ActivityIndicator {
                    x: chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                    y: chartView.plotArea.y + (chartView.plotArea.height - height) / 2 + (chartView.plotArea.height / 8)
                    visible: powerBalanceLogs.fetchingData && (powerBalanceLogs.count == 0 || powerBalanceLogs.get(0).timestamp > d.startTime)
                    opacity: .5
                }
                Label {
                    x: chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                    y: chartView.plotArea.y + (chartView.plotArea.height - height) / 2 + (chartView.plotArea.height / 8)
                    text: qsTr("No data available")
                    visible: !powerBalanceLogs.fetchingData && (powerBalanceLogs.count == 0 || powerBalanceLogs.get(0).timestamp > d.now)
                    font: Style.smallFont
                    opacity: .5
                }

                ValueAxis {
                    id: valueAxis
                    min: 0
                    max: Math.ceil(Math.max(-powerBalanceLogs.minValue, powerBalanceLogs.maxValue) / 100) * 100
                    labelFormat: ""
                    gridLineColor: Style.tileOverlayColor
                    labelsVisible: false
                    lineVisible: false
                    titleVisible: false
                    shadesVisible: false
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
                            text: ((valueAxis.max - (index * valueAxis.max / (valueAxis.tickCount - 1))) / 1000).toFixed(2) + "kW"
                            verticalAlignment: Text.AlignTop
                            font: Style.extraSmallFont
                        }
                    }
                }

                DateTimeAxis {
                    id: dateTimeAxis
                    min: d.startTime
                    max: d.endTime
                    format: {
                        switch (selectionTabs.currentValue.sampleRate) {
                        case EnergyLogs.SampleRate1Min:
                        case EnergyLogs.SampleRate15Mins:
                            return "hh:mm"
                        case EnergyLogs.SampleRate1Hour:
                        case EnergyLogs.SampleRate3Hours:
                        case EnergyLogs.SampleRate1Day:
                            return "dd.MM."
                        }
                    }
                    tickCount: {
                        switch (selectionTabs.currentValue.sampleRate) {
                        case EnergyLogs.SampleRate1Min:
                        case EnergyLogs.SampleRate15Mins:
                            return root.width > 500 ? 13 : 7
                        case EnergyLogs.SampleRate1Hour:
                            return 7
                        case EnergyLogs.SampleRate3Hours:
                        case EnergyLogs.SampleRate1Day:
                            return root.width > 500 ? 12 : 6
                        }
                    }
                    labelsFont: Style.extraSmallFont
                    gridVisible: false
                    minorGridVisible: false
                    lineVisible: false
                    shadesVisible: false
                    labelsColor: Style.foregroundColor
                }
                AreaSeries {
                    id: selfProductionConsumptionSeries
                    axisX: dateTimeAxis
                    axisY: valueAxis
                    color: Style.green
//                    borderWidth: 2
                    borderColor: color
                    name: qsTr("From self production")
            //        visible: false

                    lowerSeries: LineSeries {
                        id: zeroSeries
                        XYPoint { x: dateTimeAxis.min.getTime(); y: 0 }
                        XYPoint { x: dateTimeAxis.max.getTime(); y: 0 }
                        function ensureValue(timestamp) {
                            if (count == 0) {
                                append(timestamp, 0)
                            } else if (count == 1) {
                                if (timestamp.getTime() < at(0).x) {
                                    insert(0, timestamp, 0)
                                } else {
                                    append(timestamp, 0)
                                }
                            } else {
                                if (timestamp.getTime() < at(0).x) {
                                    remove(0)
                                    insert(0, timestamp, 0)
                                } else if (timestamp.getTime() > at(1).x) {
                                    remove(1)
                                    append(timestamp, 0)
                                }
                            }
                        }
                        function shrink() {
                            clear();
                            if (powerBalanceLogs.count > 0) {
                                ensureValue(powerBalanceLogs.get(0).timestamp)
                                ensureValue(powerBalanceLogs.get(powerBalanceLogs.count-1).timestamp)
                            }
                        }
                    }

                    upperSeries: LineSeries {
                        id: selfProductionConsumptionUpperSeries
                    }


                    function calculateValue(entry) {
                        return Math.max(0, -entry.production) - Math.max(0, -entry.acquisition) - Math.max(0, entry.storage)
                    }

                    function addEntry(entry) {
                        selfProductionConsumptionUpperSeries.append(entry.timestamp.getTime(), calculateValue(entry))
                    }
                    function insertEntry(index, entry) {
                        selfProductionConsumptionUpperSeries.insert(index, entry.timestamp.getTime(), calculateValue(entry))
                    }
                }

                AreaSeries {
                    id: toStorageSeries
                    axisX: dateTimeAxis
                    axisY: valueAxis
                    color: Style.purple
                    borderWidth: 0
                    borderColor: color
                    visible: root.batteries.count > 0
                    name: qsTr("To battery")


                    function calculateValue(entry) {
                        return selfProductionConsumptionSeries.calculateValue(entry) + Math.max(0, entry.storage);
                    }

                    function addEntry(entry) {
                        toStorageUpperSeries.append(entry.timestamp.getTime(), calculateValue(entry))
                    }
                    function insertEntry(index, entry) {
                        toStorageUpperSeries.insert(index, entry.timestamp.getTime(), calculateValue(entry))
                    }

                    lowerSeries: selfProductionConsumptionUpperSeries
                    upperSeries: LineSeries {
                        id: toStorageUpperSeries
                    }
                }


                AreaSeries {
                    id: returnSeries
                    axisX: dateTimeAxis
                    axisY: valueAxis
                    color: Style.yellow
                    borderWidth: 0
                    borderColor: color
                    name: qsTr("To grid")
            //        visible: false

                    function calculateValue(entry) {
                        return toStorageSeries.calculateValue(entry) + Math.max(0, -entry.acquisition)
                    }
                    function addEntry(entry) {
                        returnUpperSeries.append(entry.timestamp.getTime(), calculateValue(entry))
                    }
                    function insertEntry(index, entry) {
                        returnUpperSeries.insert(index, entry.timestamp.getTime(), calculateValue(entry))
                    }

                    lowerSeries: toStorageUpperSeries
                    upperSeries: LineSeries {
                        id: returnUpperSeries
                    }
                }

                AreaSeries {
                    id: fromStorageSeries
                    axisX: dateTimeAxis
                    axisY: valueAxis
                    color: Style.orange
                    borderWidth: 0
                    borderColor: color
                    name: qsTr("From battery")
                    visible: root.batteries.count > 0

                    lowerSeries: selfProductionConsumptionUpperSeries
                    upperSeries: LineSeries {
                        id: fromStorageUpperSeries
                    }

                    function calculateValue(entry) {
                        return selfProductionConsumptionSeries.calculateValue(entry) + Math.abs(Math.min(0, entry.storage));
                    }

                    function addEntry(entry) {
                        fromStorageUpperSeries.append(entry.timestamp.getTime(), calculateValue(entry))
                    }
                    function insertEntry(index, entry) {
                        fromStorageUpperSeries.insert(index, entry.timestamp.getTime(), calculateValue(entry))
                    }
                }


                AreaSeries {
                    id: acquisitionSeries
                    axisX: dateTimeAxis
                    axisY: valueAxis
                    color: Style.red
                    borderWidth: 0
                    borderColor: color
                    name: qsTr("From grid")
            //      visible: false

                    lowerSeries: fromStorageUpperSeries
                    upperSeries: LineSeries {
                        id: acquisitionUpperSeries
                    }

                    function calculateValue(entry) {
                        return fromStorageSeries.calculateValue(entry) + Math.max(0, entry.acquisition)
                    }
                    function addEntry(entry) {
                        acquisitionUpperSeries.append(entry.timestamp.getTime(), calculateValue(entry))
                    }
                    function insertEntry(index, entry) {
                        acquisitionUpperSeries.insert(index, entry.timestamp.getTime(), calculateValue(entry))
                    }
                }

                LineSeries {
                    id: productionSeries
                    axisX: dateTimeAxis
                    axisY: valueAxis
                    color: Style.white
                    width: 1
                    name: "Total production"

                    function calculateValue(entry) {
                        return Math.abs(Math.min(0, entry.production))
                    }
                    function addEntry(entry) {
                        append(entry.timestamp.getTime(), calculateValue(entry))
                    }
                    function insertEntry(index, entry) {
                        insert(index, entry.timestamp.getTime(), calculateValue(entry))
                    }
                }

                LineSeries {
                    id: consumptionSeries
                    axisX: dateTimeAxis
                    axisY: valueAxis
                    color: Style.red
                    width: 1
                    name: "Total consumption"
                    visible: false

                    function calculateValue(entry) {
                        return Math.max(0, entry.consumption)
                    }
                    function addEntry(entry) {
                        append(entry.timestamp.getTime(), calculateValue(entry))
                    }
                    function insertEntry(index, entry) {
                        insert(index, entry.timestamp.getTime(), calculateValue(entry))
                    }
                }


            }

            RowLayout {
                anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
                anchors.leftMargin: chartView.plotArea.x
                height: Style.smallIconSize
                anchors.margins: Style.margins

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ColorIcon {
                        name: "weathericons/weather-clear-day"
                        size: Style.smallIconSize
                        color: Style.green
                        anchors.centerIn: parent
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Row {
                        anchors.centerIn: parent
                        ColorIcon {
                            name: "power-grid"
                            size: Style.smallIconSize
                            color: Style.red
                        }
                        ColorIcon {
                            name: "arrow-down"
                            size: Style.smallIconSize
                            color: Style.red
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Row {
                        anchors.centerIn: parent
                        ColorIcon {
                            name: "power-grid"
                            size: Style.smallIconSize
                            color: Style.yellow
                        }
                        ColorIcon {
                            name: "arrow-up"
                            size: Style.smallIconSize
                            color: Style.yellow
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: batteries.count > 0
                    Row {
                        anchors.centerIn: parent
                        ColorIcon {
                            name: "battery/battery-080"
                            size: Style.smallIconSize
                            color: Style.purple
                        }
                        ColorIcon {
                            name: "plus"
                            size: Style.smallIconSize
                            color: Style.purple
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: batteries.count > 0
                    Row {
                        anchors.centerIn: parent
                        ColorIcon {
                            name: "battery/battery-040"
                            size: Style.smallIconSize
                            color: Style.orange
                        }
                        ColorIcon {
                            name: "minus"
                            size: Style.smallIconSize
                            color: Style.orange
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
                    if (mouseArea.dragging) {
                        powerBalanceLogs.fetchLogs()
                        mouseArea.dragging = false;
                    }

                    mouseArea.tooltipping = false;
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
                    onTriggered: powerBalanceLogs.fetchLogs()
                }

                Rectangle {
                    height: parent.height
                    width: 1
                    color: Style.foregroundColor
                    x: Math.min(mouseArea.width, Math.max(0, mouseArea.mouseX))
                    visible: (mouseArea.containsMouse || mouseArea.tooltipping) && !mouseArea.dragging
                }

                NymeaToolTip {
                    id: toolTip
                    visible: (mouseArea.containsMouse || mouseArea.tooltipping) && !mouseArea.dragging

                    backgroundItem: chartView
                    backgroundRect: Qt.rect(mouseArea.x + toolTip.x, mouseArea.y + toolTip.y, toolTip.width, toolTip.height)

                    property int idx: Math.min(d.visibleValues, Math.max(0, Math.round(mouseArea.mouseX * d.visibleValues / mouseArea.width)))
                    property var timestamp: new Date(Math.min(d.endTime.getTime(), Math.max(d.startTime, d.startTime.getTime() + (idx * d.sampleRate * 60000))))
                    property PowerBalanceLogEntry entry: powerBalanceLogs.find(timestamp)

                    property int xOnRight: Math.max(0, mouseArea.mouseX) + Style.smallMargins
                    property int xOnLeft: Math.min(mouseArea.mouseX, mouseArea.width) - Style.smallMargins - width
                    x: xOnRight + width < mouseArea.width ? xOnRight : xOnLeft
                    property double maxValue: toolTip.entry ? Math.max(0, -entry.production) : 0
                    y: Math.min(Math.max(mouseArea.height - (maxValue * mouseArea.height / valueAxis.max) - height - Style.margins, 0), mouseArea.height - height)

                    width: tooltipLayout.implicitWidth + Style.smallMargins * 2
                    height: tooltipLayout.implicitHeight + Style.smallMargins * 2

                    ColumnLayout {
                        id: tooltipLayout
                        width: parent.width
                        anchors {
                            left: parent.left
                            top: parent.top
                            margins: Style.smallMargins
                        }
                        Label {
                            text: toolTip.entry.timestamp.toLocaleString(Qt.locale(), Locale.ShortFormat)
                            font: Style.smallFont
                        }

                        Label {
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            property double value: toolTip.entry
                                                   ? (toolTip.entry.acquisition >= 0 ? toolTip.entry.consumption : Math.max(0, -toolTip.entry.production))
                                                   : 0
                            property bool translate: value >= 1000
                            property double translatedValue: value / (translate ? 1000 : 1)
                            text: toolTip.entry.acquisition >= 0 ? qsTr("Consumed: %1 %2").arg(translatedValue.toFixed(2)).arg(translate ? "kW" : "W")
                                                                 : qsTr("Produced: %1 %2").arg(translatedValue.toFixed(2)).arg(translate ? "kW" : "W")
                            font: Style.smallFont
                        }
//                        Label {
//                            property double value: toolTip.entry ? toolTip.entry.consumption : 0
//                            property bool translate: value >= 1000
//                            property double translatedValue: value / (translate ? 1000 : 1)
//                            text: qsTr("Total consumption: %1 %2").arg(translatedValue.toFixed(2)).arg(translate ? "kW" : "W")
//                            font: Style.extraSmallFont
//                        }

                        RowLayout {
                            Rectangle {
                                width: Style.extraSmallFont.pixelSize
                                height: width
                                color: toolTip.entry.acquisition >= 0 ? Style.red : Style.yellow
                            }

                            Label {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                // Workaround for Qt bug that lowerSeries is non-notifyable and throws warnings
                                Component.onCompleted: lowerSeries = returnSeries.lowerSeries
                                property XYSeries lowerSeries: null

                                property double value: toolTip.entry ? Math.abs(toolTip.entry.acquisition) : 0
                                property bool translate: value >= 1000
                                property double translatedValue: value / (translate ? 1000 : 1)
                                text: toolTip.entry.acquisition >= 0 ? qsTr("From grid: %1 %2").arg(translatedValue.toFixed(2)).arg(translate ? "kW" : "W")
                                                                     : qsTr("To grid: %1 %2").arg(translatedValue.toFixed(2)).arg(translate ? "kW" : "W")
                                font: Style.extraSmallFont
                            }
                        }
                        RowLayout {
                            Rectangle {
                                width: Style.extraSmallFont.pixelSize
                                height: width
                                color: Style.green
                            }

                            Label {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                // Workaround for Qt bug that lowerSeries is non-notifyable and throws warnings
                                Component.onCompleted: lowerSeries = selfProductionConsumptionSeries.lowerSeries
                                property XYSeries lowerSeries: null

                                property double value: toolTip.entry ? Math.min(Math.max(0, toolTip.entry.consumption), -toolTip.entry.production) : 0
                                property bool translate: value >= 1000
                                property double translatedValue: value / (translate ? 1000 : 1)
                                text: toolTip.entry.acquisition >= 0 ? qsTr("From self production: %1 %2").arg(translatedValue.toFixed(2)).arg(translate ? "kW" : "W")
                                                                     : qsTr("Consumed: %1 %2").arg(translatedValue.toFixed(2)).arg(translate ? "kW" : "W")
                                font: Style.extraSmallFont
                            }
                        }
                        RowLayout {
                            visible: root.batteries.count > 0
                            Rectangle {
                                width: Style.extraSmallFont.pixelSize
                                height: width
                                color: toolTip.entry.storage > 0 ? Style.purple : Style.orange
                            }

                            Label {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                // Workaround for Qt bug that lowerSeries is non-notifyable and throws warnings
                                Component.onCompleted: lowerSeries = toStorageSeries.lowerSeries
                                property XYSeries lowerSeries: null

                                property double value: toolTip.entry ? Math.abs(toolTip.entry.storage) : 0
                                property bool translate: value >= 1000
                                property double translatedValue: value / (translate ? 1000 : 1)
                                text: toolTip.entry.storage > 0 ? qsTr("To battery: %1 %2").arg(translatedValue.toFixed(2)).arg(translate ? "kW" : "W") :
                                                                    qsTr("From battery: %1 %2").arg(translatedValue.toFixed(2)).arg(translate ? "kW" : "W")
                                font: Style.extraSmallFont
                            }
                        }
                    }
                }
            }

        }
    }


}



