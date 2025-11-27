import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import NymeaApp.Utils 1.0
import "../components"
import "../customviews"
import QtCharts 2.2

Item {
    id: root
    implicitHeight: width * .6
    implicitWidth: 400

    property Thing thing: null
    property StateType stateType: null
    property int roundTo: 2
    property color color: Style.accentColor
    property string iconSource: ""
    property alias title: titleLabel.text
    property bool titleVisible: true
    property bool inverted: false

    readonly property State valueState: thing && stateType ? thing.states.getState(stateType.id) : null
    readonly property StateType connectedStateType: hasConnectable ? thing.thingClass.stateTypes.findByName("connected") : null
    readonly property bool hasConnectable: connectedStateType != null

    QtObject {
        id: d
        property date now: new Date()

        readonly property int range: selectionTabs.currentValue.range
        readonly property int sampleRate: root.stateType == null || root.stateType.type.toLowerCase() == "bool" ? NewLogsModel.SampleRateAny : selectionTabs.currentValue.sampleRate

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
            return timestamp
        }
    }

    NewLogsModel {
        id: logsModel
        engine: _engine
        source: root.thing ? "state-" + thing.id + "-" + root.stateType.name : ""
        startTime: new Date(d.startTime.getTime() - d.range * 1.1 * 60000)
        endTime: new Date(d.endTime.getTime() + d.range * 1.1 * 60000)
        sampleRate: d.sampleRate
        sortOrder: Qt.AscendingOrder

        Component.onCompleted: {
//            print("****** completed")
            ready = true
            update()
        }
        property bool ready: false
        onSourceChanged: {
//            print("***** source changed")
            update()
        }

        function update() {
//            print("*********+ source", source, "start", startTime, "end", endTime, ready)
            if (ready && source != "") {
                fetchLogs()
            }
        }

        property double minValue
        property double maxValue

        onEntriesAddedIdx: {
//            print("**** entries added", index, count, "entries in series:", valueSeries.count, "in model", logsModel.count)
            for (var i = 0; i < count; i++) {
                var entry = logsModel.get(i)
//                                print("entry", entry.timestamp, entry.source, JSON.stringify(entry.values))
                zeroSeries.ensureValue(entry.timestamp)

                if (root.stateType.type.toLowerCase() == "bool") {
                    var value = entry.values[root.stateType.name]
                    if (value == null) {
                        value = false;
                    }
                    value *= root.inverted ? -1 : 1
                    var previousEntry = i > 0 ? logsModel.get(i-1) : null;
                    var previousValue = previousEntry ? previousEntry.values[root.stateType.name] : false
                    if (previousValue == null) {
                        previousValue = false
                    }

                    // for booleans, we'll insert the previous value right before the new one so the position is doubled
                    var insertIdx = (index + i) * 2
//                    print("inserting bool 1", insertIdx, entry.timestamp.getTime() - 500, !value, new Date(entry.timestamp.getTime() - 500))
                    valueSeries.insert(insertIdx, entry.timestamp.getTime() - 500, previousValue)
//                    print("inserting bool 2", insertIdx + 1, entry.timestamp.getTime(), value, entry.timestamp)
                    valueSeries.insert(insertIdx+1, entry.timestamp, value)

                } else {
                    var value = entry.values[root.stateType.name]
                    if (value == null) {
                        value = 0;
                    }
                    value *= root.inverted ? -1 : 1

                    minValue = minValue == undefined ? value : Math.min(minValue, value)
                    maxValue = maxValue == undefined ? value : Math.max(maxValue, value)

                    var insertIdx = index + i
                    valueSeries.insert(insertIdx, entry.timestamp, value)
                }
            }

            if (root.stateType.type.toLowerCase() == "bool") {
                var last = valueSeries.at(valueSeries.count-1);
                if (last.x < d.endTime) {
                    valueSeries.append(d.endTime, last.y)
                    zeroSeries.ensureValue(d.endTime)
                }
            }

            print("added entries. now in series:", valueSeries.count)
        }
        onEntriesRemoved: {
            print("removing:", index, count, valueSeries.count)
            if (root.stateType.type.toLowerCase() == "bool") {
                valueSeries.removePoints(index * 2, count * 2)
                if (valueSeries.count == 1) {
                    valueSeries.removePoints(0, 1);
                }
            } else {
                valueSeries.removePoints(index, count)
            }

            zeroSeries.shrink()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Label {
            id: titleLabel
            Layout.fillWidth: true
            Layout.margins: Style.smallMargins
            horizontalAlignment: Text.AlignHCenter
            text: root.stateType.displayName
            visible: root.titleVisible
            elide: Text.ElideMiddle
            //            MouseArea {
            //                anchors.fill: parent
            //                onClicked: {
            //                    pageStack.push(Qt.resolvedUrl("PowerBalanceHistoryPage.qml"))
            //                }
            //            }
        }

        SelectionTabs {
            id: selectionTabs
            Layout.fillWidth: true
            Layout.leftMargin: Style.smallMargins
            Layout.rightMargin: Style.smallMargins
            currentIndex: 1
            model: ListModel {
                ListElement {
                    modelData: qsTr("Hours")
                    sampleRate: NewLogsModel.SampleRate1Min
                    range: 180 // 3 Hours: 3 * 60
                }
                ListElement {
                    modelData: qsTr("Days")
                    sampleRate: NewLogsModel.SampleRate15Mins
                    range: 1440 // 1 Day: 24 * 60
                }
                ListElement {
                    modelData: qsTr("Weeks")
                    sampleRate: NewLogsModel.SampleRate1Hour
                    range: 10080 // 7 Days: 7 * 24 * 60
                }
                ListElement {
                    modelData: qsTr("Months")
                    sampleRate: NewLogsModel.SampleRate3Hours
                    range: 43200 // 30 Days: 30 * 24 * 60
                }
            }
            onTabSelected: {
                d.now = new Date()
                logsModel.clear()
                print("*** tab selected")
                logsModel.fetchLogs()
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true


            ChartView {
                id: chartView
                anchors.fill: parent
                //                backgroundColor: "transparent"
                margins.left: 0
                margins.right: 0
                margins.bottom: Style.smallMargins //Style.smallIconSize + Style.margins
                margins.top: 0

                backgroundColor: Style.tileBackgroundColor
                backgroundRoundness: Style.cornerRadius

                legend.alignment: Qt.AlignBottom
                legend.labelColor: Style.foregroundColor
                legend.font: Style.extraSmallFont
                legend.visible: false

                ActivityIndicator {
                    anchors.centerIn: parent
                    visible: logsModel.busy
                    opacity: .5
                }

                Label {
                    anchors.centerIn: parent
                    visible: !logsModel.busy && logsModel.count == 0
                    text: qsTr("No data")
                    font: Style.smallFont
                    opacity: .5
                }

                Label {
                    x: chartView.x + chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                    y: chartView.y + chartView.plotArea.y + Style.smallMargins
                    text: {
                        switch (d.sampleRate) {
                        case NewLogsModel.SampleRate1Min:
                            return d.startTime.toLocaleDateString(Qt.locale(), Locale.LongFormat)
                        case NewLogsModel.SampleRate15Mins:
                        case NewLogsModel.SampleRate1Hour:
                        case NewLogsModel.SampleRate3Hours:
                        case NewLogsModel.SampleRate1Day:
                        case NewLogsModel.SampleRate1Week:
                        case NewLogsModel.SampleRate1Month:
                        case NewLogsModel.SampleRate1Year:
                            return d.startTime.toLocaleDateString(Qt.locale(), Locale.ShortFormat) + " - " + d.endTime.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
                        }
                    }
                    font: Style.smallFont
                    opacity: ((new Date().getTime() - d.now.getTime()) / d.sampleRate / 60000) > d.visibleValues ? .5 : 0
                    Behavior on opacity { NumberAnimation {} }
                }
                ValueAxis {
                    id: valueAxis
                    min: logsModel.minValue == undefined || logsModel.minValue == 0
                         ? 0
                         : root.stateType.minValue ? Math.max(logsModel.minValue - 5, root.stateType.minValue) : logsModel.minValue - 5
                    max: logsModel.maxValue == undefined || logsModel.maxValue == 0
                         ? 0
                         : root.stateType.maxValue ? Math.min(logsModel.maxValue + 5, root.stateType.maxValue) : logsModel.maxValue + 5

                    labelFormat: "%0." + labelsLayout.precision + "f " + Types.toUiUnit(root.stateType.unit)
                    gridLineColor: Style.tileOverlayColor
                    labelsVisible: false
                    lineVisible: false
                    titleVisible: false
                    shadesVisible: false
                    labelsFont: Style.extraSmallFont
                    labelsColor: Style.foregroundColor

                }
                // Overriding the labels with our own as printf struggles with special chars
                Item {
                    id: labelsLayout
                    x: Style.smallMargins
                    y: chartView.plotArea.y
                    height: chartView.plotArea.height
                    width: chartView.plotArea.x - x
                    visible: root.stateType.type.toLowerCase() != "bool" && logsModel.minValue != logsModel.maxValue
                    property double range: Math.abs(valueAxis.max - valueAxis.min)
                    property double stepSize: range / (valueAxis.tickCount - 1)
                    property int precision: valueAxis.max - valueAxis.min < 5 ? 2 : 0

                    Repeater {
                        model: valueAxis.tickCount
                        delegate: Label {
                            y: parent.height / (valueAxis.tickCount - 1) * index - font.pixelSize / 2
                            width: parent.width - Style.smallMargins
                            horizontalAlignment: Text.AlignRight
                            property double offset: (valueAxis.tickCount - index - 1) * labelsLayout.stepSize
                            property double value: valueAxis.min + offset
                            text: root.stateType ? Types.toUiValue(value, root.stateType.unit).toFixed(labelsLayout.precision) + " " + Types.toUiUnit(root.stateType.unit) : ""
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
                        case NewLogsModel.SampleRate1Min:
                        case NewLogsModel.SampleRate15Mins:
                            return "hh:mm"
                        case NewLogsModel.SampleRate1Hour:
                        case NewLogsModel.SampleRate3Hours:
                        case NewLogsModel.SampleRate1Day:
                            return "dd.MM."
                        }
                    }
                    tickCount: {
                        switch (selectionTabs.currentValue.sampleRate) {
                        case NewLogsModel.SampleRate1Min:
                        case NewLogsModel.SampleRate15Mins:
                            return root.width > 500 ? 13 : 7
                        case NewLogsModel.SampleRate1Hour:
                            return 7
                        case NewLogsModel.SampleRate3Hours:
                        case NewLogsModel.SampleRate1Day:
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
                    id: mainSeries
                    axisX: dateTimeAxis
                    axisY: valueAxis
                    name: root.stateType ? root.stateType.displayName : ""
                    color: Qt.rgba(root.color.r, root.color.g, root.color.b, .5)
                    borderColor: root.color
                    borderWidth: 2
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
                                if (timestamp.getTime() > at(0).x) {
                                    remove(1)
                                    append(timestamp, 0)
                                } else if (timestamp.getTime() < at(1).x) {
                                    remove(0)
                                    insert(0, timestamp, 0)
                                }
                            }
                        }
                        function shrink() {
                            clear();
                            if (logsModel.count > 0) {
                                ensureValue(logsModel.get(0).timestamp)
                                ensureValue(logsModel.get(logsModel.count-1).timestamp)
                            }
                        }
                    }

                    upperSeries: LineSeries {
                        id: valueSeries
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
                propagateComposedEvents: true

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
                        logsModel.fetchLogs()
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
//                    print("dragging", dragDelta, totalTime, mouseArea.width)
                    d.now = new Date(Math.min(new Date(), new Date(startDatetime.getTime() + timeDelta)))
                }

                onWheel: {
                    startDatetime = d.now
                    var totalTime = d.endTime.getTime() - d.startTime.getTime()
                    // pixelDelta : timeDelta = width : totalTime
                    var timeDelta = wheel.pixelDelta.x * totalTime / mouseArea.width
//                    print("wheeling", wheel.pixelDelta.x, totalTime, mouseArea.width)
                    d.now = new Date(Math.min(new Date(), new Date(startDatetime.getTime() - timeDelta)))
                    wheelStopTimer.restart()
                }
                Timer {
                    id: wheelStopTimer
                    interval: 300
                    repeat: false
                    onTriggered: logsModel.fetchLogs()
                }

                Rectangle {
                    height: parent.height
                    width: 1
                    color: Style.foregroundColor
                    x: Math.min(mouseArea.width, Math.max(0, toolTip.entryX))
                    visible: toolTip.visible
                }

                NymeaToolTip {
                    id: toolTip
                    visible: (mouseArea.containsMouse || mouseArea.tooltipping) && !mouseArea.dragging && logsModel.count > 0

                    backgroundItem: chartView
                    backgroundRect: Qt.rect(mouseArea.x + toolTip.x, mouseArea.y + toolTip.y, toolTip.width, toolTip.height)

                    property var timestamp: new Date(d.startTime.getTime() + (mouseArea.mouseX * (d.endTime.getTime() - d.startTime.getTime()) / mouseArea.width) )
                    property NewLogEntry entry: logsModel.count > 0 ? logsModel.find(timestamp) : null

                    // eX : eT = w : duration
                    property int entryX: entry ? (entry.timestamp.getTime() - d.startTime.getTime()) * mouseArea.width / (d.endTime.getTime() - d.startTime.getTime()) : 0
                    property int xOnRight: Math.max(0, entryX) + Style.smallMargins
                    property int xOnLeft: Math.min(entryX, mouseArea.width) - Style.smallMargins - width
                    x: xOnRight + width < mouseArea.width ? xOnRight : xOnLeft
                    property var value: entry ? entry.values[root.stateType.name] * (root.inverted ? -1 : 1) : null
                    y: Math.min(Math.max(mouseArea.height - (value * mouseArea.height / valueAxis.max) - height - Style.margins, 0), mouseArea.height - height)

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
                            text: toolTip.entry ? toolTip.entry.timestamp.toLocaleString(Qt.locale(), Locale.ShortFormat) : ""
                            font: Style.smallFont
                        }

                        RowLayout {

                            ColorIcon {
                                id: icon
                                size: Style.smallIconSize
                                name: root.iconSource
                                color: root.color
                                visible: name != ""
                            }

                            Rectangle {
                                width: Style.extraSmallFont.pixelSize
                                height: width
                                color: root.color
                                visible: !icon.visible
                            }

                            Label {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                text: toolTip.value === null
                                      ? qsTr("No data")
                                      : root.stateType.type.toLowerCase() == "bool"
                                        ? root.stateType.displayName + ": " + (toolTip.value ? qsTr("Yes") : qsTr("No"))
                                        : Types.toUiValue(toolTip.value, root.stateType.unit).toFixed(root.roundTo) + Types.toUiUnit(root.stateType.unit)
                                font: Style.extraSmallFont
                            }
                        }

                    }
                }
            }
        }
    }

}
