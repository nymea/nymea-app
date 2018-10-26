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

    property var device: null
    property var stateType: null
    readonly property var deviceClass: engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
    readonly property bool hasConnectable: deviceClass.interfaces.indexOf("connectable") >= 0
    readonly property var connectedStateType: hasConnectable ? deviceClass.stateTypes.findByName("connected") : null

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
        typeIds: [root.connectedStateType.id]
        live: true
        graphSeries: connectedLineSeries
        viewStartTime: xAxis.min
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            HeaderButton {
                imageSource: "../images/zoom-out.svg"
                onClicked: {
                    var diff = xAxis.max.getTime() - xAxis.min.getTime()
                    var newTime = new Date(xAxis.min.getTime() - (diff / 4))
                    xAxis.min = newTime;
                }
            }

            Label {
                Layout.preferredWidth: 100
                horizontalAlignment: Text.AlignHCenter
                text: {
                    var timeDiff = (xAxis.max.getTime() - xAxis.min.getTime()) / 1000;
                    if (timeDiff < 60) {
                        return qsTr("%1 seconds").arg(Math.round(timeDiff));
                    }
                    timeDiff = timeDiff / 60
                    if (timeDiff < 60) {
                        return qsTr("%1 minutes").arg(Math.round(timeDiff));
                    }
                    timeDiff = timeDiff / 60
                    if (timeDiff < 48) {
                        return qsTr("%1 hours").arg(Math.round(timeDiff));
                    }
                    timeDiff = timeDiff / 24;
                    if (timeDiff < 14) {
                        return qsTr("%1 days").arg(Math.round(timeDiff));
                    }
                    timeDiff = timeDiff / 7
                    if (timeDiff < 5) {
                        return qsTr("%1 weeks").arg(Math.round(timeDiff));
                    }
                    timeDiff * timeDiff * 7 / 30
                    if (timeDiff < 24) {
                        return qsTr("%1 months").arg(Math.round(timeDiff));
                    }
                    timeDiff = timeDiff * 30 / 356
                    return qsTr("%1 years").arg(Math.round(timeDiff))
                }
            }

            HeaderButton {
                imageSource: "../images/zoom-in.svg"
                onClicked: {
                    var diff = xAxis.max.getTime() - xAxis.min.getTime()
                    var newTime = new Date(xAxis.min.getTime() + (diff / 4))
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
            legend.labelColor: app.foregroundColor

            animationDuration: 300
            animationOptions: ChartView.SeriesAnimations

            ValueAxis {
                id: yAxis
                min: logsModelNg.minValue
                max: logsModelNg.maxValue
                labelsFont.pixelSize: app.smallFont
                labelsColor: app.foregroundColor
                tickCount: chartView.height / 40
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
                titleText: {
                    if (xAxis.min.getYear() === xAxis.max.getYear()
                            && xAxis.min.getMonth() === xAxis.max.getMonth()
                            && xAxis.min.getDate() === xAxis.max.getDate()) {
                        return Qt.formatDate(xAxis.min)
                    }
                    return Qt.formatDate(xAxis.min) + " - " + Qt.formatDate(xAxis.max)
                }
                titleBrush: app.foregroundColor
                format: {
                    var timeDiff = (xAxis.max.getTime() - xAxis.min.getTime()) / 1000
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
                    date.setHours(date.getHours() - 6);
                    return date;
                }
                max: new Date()
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
            }

            AreaSeries {
                axisX: xAxis
                axisY: yAxis
                name: root.stateType.displayName
                borderColor: app.accentColor
                borderWidth: 4
                upperSeries: LineSeries {
                    id: lineSeries1
                }
                color: Qt.rgba(app.accentColor.r, app.accentColor.g, app.accentColor.b, .3)
            }


            MouseArea {
                anchors.fill: parent
                property int lastX: 0
                property int lastY: 0

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
                    var timeDiff = xAxis.max.getTime() - oldMax.getTime()
                    xAxis.min = new Date(xAxis.min.getTime() - timeDiff * 2)
                    chartView.animationOptions = ChartView.SeriesAnimations
                }

                onPressed: {
                    lastX = mouse.x
                    lastY = mouse.y
                }

                onWheel: {
                    scrollRightLimited(-wheel.pixelDelta.x)
//                                zoomInLimited(wheel.pixelDelta.y)
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
