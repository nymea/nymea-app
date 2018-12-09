import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"
import QtCharts 2.2

Item {
    id: root
    implicitHeight: width * .6

    property Device device: null
    property StateType stateType: null
    property int roundTo: 2
    readonly property var valueState: device.states.getState(stateType.id)
    readonly property var deviceClass: engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
    readonly property bool hasConnectable: deviceClass.interfaces.indexOf("connectable") >= 0
    readonly property var connectedStateType: hasConnectable ? deviceClass.stateTypes.findByName("connected") : null

    property color color: app.accentColor
    property string iconSource: ""

    LogsModelNg {
        id: logsModelNg
        engine: _engine
        deviceId: root.device.id
        typeIds: [root.stateType.id]
        live: true
        graphSeries: lineSeries1
        viewStartTime: xAxis.min
    }

    LogsModelNg {
        id: connectedLogsModel
        engine: root.hasConnectable ? _engine : null // don't even try to poll if we don't have a connectable interface
        deviceId: root.device.id
        typeIds: root.hasConnectable ? [root.connectedStateType.id] : []
        live: true
        graphSeries: connectedLineSeries
        viewStartTime: xAxis.min
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        RowLayout {
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            ColorIcon {
                Layout.preferredHeight: app.iconSize
                Layout.preferredWidth: app.iconSize
                name: root.iconSource
                visible: root.iconSource.length > 0
                color: root.color
            }

            Led {
                visible: root.stateType.type.toLowerCase() === "bool"
                on: root.valueState.value === true
            }

            Label {
                Layout.fillWidth: true
                text: root.stateType.type.toLowerCase() === "bool"
                      ? root.stateType.displayName
                      : 1.0 * Math.round(root.valueState.value * Math.pow(10, root.roundTo)) / Math.pow(10, root.roundTo) + " " + root.stateType.unitString
                font.pixelSize: app.largeFont
            }


            HeaderButton {
                imageSource: "../images/zoom-out.svg"
                onClicked: {
                    var newTime = new Date(xAxis.min.getTime() - (xAxis.timeDiff * 1000 / 4))
                    xAxis.min = newTime;
                }
            }

            HeaderButton {
                imageSource: "../images/zoom-in.svg"
                enabled: xAxis.timeDiff > (60 * 30)
                onClicked: {
                    var newTime = new Date(Math.min(xAxis.min.getTime() + (xAxis.timeDiff * 1000 / 4), xAxis.max.getTime() - (1000 * 60 * 30)))
                    xAxis.min = newTime;
                }
            }
        }

        ChartView {
            id: chartView
            Layout.fillWidth: true
            Layout.fillHeight: true
            margins.top: 0
            margins.bottom: 0
            margins.left: 0
            margins.right: 0
            backgroundColor: Material.background
            legend.visible: false
            legend.labelColor: app.foregroundColor

            animationDuration: 300
            animationOptions: ChartView.SeriesAnimations

            ValueAxis {
                id: yAxis
                max: Math.ceil(logsModelNg.maxValue + Math.abs(logsModelNg.maxValue * .05))
                min: Math.floor(logsModelNg.minValue - Math.abs(logsModelNg.minValue * .05))
                labelsFont.pixelSize: app.smallFont
                labelFormat: {
                    switch (root.stateType.type.toLowerCase()) {
                    case "bool":
                        return "x";
                    default:
                        return "%d";
                    }
                }
                labelsColor: app.foregroundColor
                tickCount: root.stateType.type.toLowerCase() === "bool" ? 2 : chartView.height / 40
                color: Qt.rgba(app.foregroundColor.r, app.foregroundColor.g, app.foregroundColor.b, .2)
                gridLineColor: color
            }

            ValueAxis {
                id: connectedAxis
                min: 0
                max: 1
                visible: false
            }

            DateTimeAxis {
                id: xAxis
                gridVisible: false
                color: Qt.rgba(app.foregroundColor.r, app.foregroundColor.g, app.foregroundColor.b, .2)
                tickCount: chartView.width / 70
                labelsFont.pixelSize: app.smallFont
                labelsColor: app.foregroundColor
                property int timeDiff: (xAxis.max.getTime() - xAxis.min.getTime()) / 1000
                onTimeDiffChanged: print("timeDiff is:", timeDiff)

                function getTimeSpanString() {
                    var td = timeDiff
                    if (td < 60) {
                        return qsTr("%1 seconds").arg(Math.round(td));
                    }
                    td = td / 60
                    if (td < 60) {
                        return qsTr("%1 minutes").arg(Math.round(td));
                    }
                    td = td / 60
                    if (td < 48) {
                        return qsTr("%1 hours").arg(Math.round(td));
                    }
                    td = td / 24;
                    if (td < 14) {
                        return qsTr("%1 days").arg(Math.round(td));
                    }
                    td = td / 7
                    if (td < 9) {
                        return qsTr("%1 weeks").arg(Math.round(td));
                    }
                    td = td * 7 / 30
                    if (td < 24) {
                        return qsTr("%1 months").arg(Math.round(td));
                    }
                    td = td * 30 / 356
                    return qsTr("%1 years").arg(Math.round(td))
                }

                titleText: {
                    if (xAxis.min.getYear() === xAxis.max.getYear()
                            && xAxis.min.getMonth() === xAxis.max.getMonth()
                            && xAxis.min.getDate() === xAxis.max.getDate()) {
                        return Qt.formatDate(xAxis.min) + " (" + getTimeSpanString() + ")"
                    }
                    return Qt.formatDate(xAxis.min) + " - " + Qt.formatDate(xAxis.max) + " (" + getTimeSpanString() + ")"
                }
                titleBrush: app.foregroundColor
                format: {
                    if (timeDiff < 60) { // one minute
                        return "mm:ss"
                    }
                    if (timeDiff < 60 * 60) { // one hour
                        return "hh:mm"
                    }
                    if (timeDiff < 60 * 60 * 24 * 2) { // two day
                        return "hh:mm"
                    }
                    if (timeDiff < 60 * 60 * 24 * 7) { // one week
                        return "ddd hh:mm"
                    }
                    if (timeDiff < 60 * 60 * 24 * 7 * 30) { // one month
                        return "dd.MM."
                    }
                    return "MMM yy"
                }

                min: {
                    var date = new Date();
                    date.setTime(date.getTime() - (1000 * 60 * 60 * 6) + 2000);
                    return date;
                }
                max: {
                    var date = new Date();
                    date.setTime(date.getTime() + 2000)
                    return date;
                }
            }

            AreaSeries {
                axisX: xAxis
                axisY: connectedAxis
                name: qsTr("Not connected")
                visible: root.hasConnectable
                upperSeries: LineSeries {
                    XYPoint {x: xAxis.min.getTime(); y: 1}
                    XYPoint {x: xAxis.max.getTime(); y: 1}
                }

                lowerSeries: LineSeries {
                    id: connectedLineSeries
                }
                color: "#55ff0000"
                borderWidth: 0
            }

            AreaSeries {
                id: mainSeries
                axisX: xAxis
                axisY: yAxis
                name: root.stateType.displayName
                borderColor: root.color
                borderWidth: 4
                lowerSeries: LineSeries {
                    id: lineSeries0
                    XYPoint { x: xAxis.max.getTime(); y: 0 }
                    XYPoint { x: xAxis.min.getTime(); y: 0 }
                }

                upperSeries: LineSeries {
                    id: lineSeries1
                    onPointAdded: {
                        var newPoint = lineSeries1.at(index)

                        if (newPoint.x > lineSeries0.at(0).x) {
                            lineSeries0.replace(0, newPoint.x, 0)
                        }
                        if (newPoint.x < lineSeries0.at(1).x) {
                            lineSeries0.replace(1, newPoint.x, 0)
                        }

                        if (newPoint.x <= xAxis.max.getTime() || logsModelNg.busy) {
                            return;
                        }

                        var diffMaxToNew = newPoint.x - xAxis.max.getTime();
                        print("diffToNew is", diffMaxToNew)
                        if (diffMaxToNew < 1000 * 60 * 5) {
                            chartView.animationOptions = ChartView.NoAnimation
                            var newMin = xAxis.min.getTime()  + diffMaxToNew;
                            xAxis.max = new Date(newPoint.x);
                            xAxis.min = new Date(newMin)
                            chartView.animationOptions = ChartView.SeriesAnimations
                        }
                    }
                }
                color: Qt.rgba(root.color.r, root.color.g, root.color.b, .3)
                onHovered: {
                    markClosestPoint(point)
                }

                function markClosestPoint(point) {
                    var found = false;
                    if (lineSeries1.count == 1) {
                        selectedHighlights.removePoints(0, selectedHighlights.count)
                        selectedHighlights.append(lineSeries1.at(0).x, lineSeries1.at(1).y)
                        return;
                    }

                    var searchIndex = Math.floor(lineSeries1.count / 2)
                    var previousIndex = 0;
                    var nextIndex = lineSeries1.count - 1;

                    while (previousIndex + 1 != nextIndex) {
                        if (point.x < lineSeries1.at(searchIndex).x) {
                            previousIndex = searchIndex;
                        } else if (point.x > lineSeries1.at(searchIndex).x) {
                            nextIndex = searchIndex;
                        }
                        searchIndex = previousIndex + Math.floor((nextIndex - previousIndex) / 2);
                    }
                    var diffToPrevious = Math.abs(point.x - lineSeries1.at(previousIndex).x)
                    var diffToNext = Math.abs(point.x - lineSeries1.at(nextIndex).x)
                    var closestPoint = diffToPrevious < diffToNext ? lineSeries1.at(previousIndex) : lineSeries1.at(nextIndex);

                    selectedHighlights.removePoints(0, selectedHighlights.count)
                    selectedHighlights.append(closestPoint.x, closestPoint.y)
                }
            }

            ScatterSeries {
                id: selectedHighlights
                color: root.color
                markerSize: 10
                borderWidth: 2
                borderColor: root.color
                axisX: xAxis
                axisY: yAxis
                pointLabelsVisible: true
                pointLabelsColor: app.foregroundColor
                pointLabelsFont.pixelSize: app.smallFont
                pointLabelsFormat: "@yPoint"
                pointLabelsClipping: false
            }

            BusyIndicator {
                anchors.centerIn: parent
                visible: logsModelNg.busy
            }


            MouseArea {
                x: chartView.plotArea.x
                y: chartView.plotArea.y
                width: chartView.plotArea.width
                height: chartView.plotArea.height
                property int lastX: 0
                property int lastY: 0
                preventStealing: false

                function scrollRightLimited(dx) {
                    chartView.animationOptions = ChartView.NoAnimation
                    var now = new Date()
                    // if we're already at the limit, don't even start scrolling
                    if (dx < 0 || xAxis.max < now) {
                        chartView.scrollRight(dx)
                    }
                    // figure out if we scrolled too far
                    var overshoot = xAxis.max.getTime() - now.getTime()
//                    print("overshoot is:", overshoot, "oldMax", xAxis.max, "newMax", now, "oldMin", xAxis.min, "newMin", new Date(xAxis.min.getTime() - overshoot))
                    if (overshoot > 0) {
                        var range = xAxis.max - xAxis.min
                        xAxis.max = now
                        xAxis.min = new Date(xAxis.max.getTime() - range)
                    }
                    chartView.animationOptions = ChartView.SeriesAnimations
                }

                function zoomInLimited(dy) {
                    chartView.animationOptions = ChartView.NoAnimation
                    var oldMax = xAxis.max;
                    chartView.scrollRight(dy);
                    xAxis.min = new Date(xAxis.min.getTime() - xAxis.timeDiff * 1000 * 2)
                    chartView.animationOptions = ChartView.SeriesAnimations
                }

                onPressed: {
                    lastX = mouse.x
                    lastY = mouse.y
                }
                onClicked: {
                    var pt = chartView.mapToValue(Qt.point(mouse.x + chartView.plotArea.x, mouse.y + chartView.plotArea.y), mainSeries)
                    mainSeries.markClosestPoint(pt)
                }

                onWheel: {
                    scrollRightLimited(-wheel.pixelDelta.x)
//                    zoomInLimited(wheel.pixelDelta.y)
                }

                onPositionChanged: {
                    if (lastX !== mouse.x) {
                        scrollRightLimited(lastX - mouseX)
                        lastX = mouse.x
                    }
                }
            }
        }
    }
}
