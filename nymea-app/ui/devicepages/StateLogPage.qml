import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"
import QtCharts 2.2

Page {
    id: root

    property var device: null
    property var stateType: null

    readonly property bool canShowGraph: {
        switch (root.stateType.type) {
        case "Int":
        case "Double":
            return true;
        }
        print("not showing graph for", root.stateType.type)
        return false;
    }

    header: GuhHeader {
        text: qsTr("History")
        onBackPressed: pageStack.pop()
    }

    LogsModel {
        id: logsModel
        engine: _engine
        deviceId: root.device.id
        live: true
        Component.onCompleted: {
            update()
        }
        typeIds: [root.stateType.id]
    }

    LogsModelNg {
        id: logsModelNg
        engine: _engine
        deviceId: root.device.id
        typeIds: [root.stateType.id]
        live: true
        graphSeries: lineSeries1
        viewStartTime: xAxis.min
    }

    ColumnLayout {
        anchors.fill: parent

        TabBar {
            id: tabBar
            Layout.fillWidth: true
            visible: root.canShowGraph
            TabButton {
                text: qsTr("Log")
            }
            TabButton {
                text: qsTr("Graph")
            }
            TabButton {
                text: qsTr("Graph NG")
            }
        }

        SwipeView {
            id: swipeView
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex
            interactive: false

            GenericTypeLogView {
                id: logView
                width: swipeView.width
                height: swipeView.height

                logsModel: engine.jsonRpcClient.ensureServerVersion("1.10") ? logsModelNg : logsModel

                onAddRuleClicked: {
                    var rule = engine.ruleManager.createNewRule();
                    var stateEvaluator = rule.createStateEvaluator();
                    stateEvaluator.stateDescriptor.deviceId = device.id;
                    stateEvaluator.stateDescriptor.stateTypeId = root.stateType.id;
                    stateEvaluator.stateDescriptor.value = value;
                    stateEvaluator.stateDescriptor.valueOperator = StateDescriptor.ValueOperatorEquals;
                    rule.setStateEvaluator(stateEvaluator);
                    rule.name = root.device.name + " - " + stateType.displayName + " = " + value;

                    var rulePage = pageStack.push(Qt.resolvedUrl("../magic/DeviceRulesPage.qml"), {device: root.device});
                    rulePage.addRule(rule);
                }
            }

            ColumnLayout {
                width: swipeView.width
                height: swipeView.height
                TabBar {
                    id: zoomTabBar
                    Layout.fillWidth: true
                    TabButton {
                        text: qsTr("6 h")
                        property int avg: ValueLogsProxyModel.AverageQuarterHour
                        property date startTime: {
                            var date = new Date();
                            date.setHours(new Date().getHours() - 6)
                            date.setMinutes(0)
                            date.setSeconds(0)
                            return date;
                        }
                    }
                    TabButton {
                        text: qsTr("24 h")
                        property int avg: ValueLogsProxyModel.AverageHourly
                        property date startTime: {
                            var date = new Date();
                            date.setHours(new Date().getHours() - 24);
                            date.setMinutes(0)
                            date.setSeconds(0)
                            return date;
                        }
                    }
                    TabButton {
                        text: qsTr("7 d")
                        property int avg: ValueLogsProxyModel.AverageDayTime
                        property date startTime: {
                            var date = new Date();
                            date.setDate(new Date().getDate() - 7);
                            date.setHours(0)
                            date.setMinutes(0)
                            date.setSeconds(0)
                            return date;
                        }
                    }
                }

                Graph {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    mode: settings.graphStyle
                    color: app.accentColor

                    Timer {
                        id: updateTimer
                        interval: 10
                        repeat: false
                        onTriggered: {
                            graphModel.update()
                        }
                    }

                    model: ValueLogsProxyModel {
                        id: graphModel
                        deviceId: root.device.id
                        typeIds: [stateType.id]
                        average: zoomTabBar.currentItem.avg
                        startTime: zoomTabBar.currentItem.startTime
                        Component.onCompleted: updateTimer.start();
                        onAverageChanged: updateTimer.start()
                        onStartTimeChanged: updateTimer.start();
                        engine: _engine

                        // Live doesn't work yet with ValueLogsProxyModel
                        //                    live: true
                    }
                }
            }


            Item {
                width: swipeView.width
                height: swipeView.height

                ColumnLayout {
                    anchors.fill: parent
                    RowLayout {
                        Layout.alignment: Qt.AlignRight
                        HeaderButton {
                            imageSource: "../images/zoom-in.svg"
                            onClicked: {
                                var diff = xAxis.max.getTime() - xAxis.min.getTime()
                                var newTime = new Date(xAxis.min.getTime() + (diff / 4))
                                xAxis.min = newTime;
                            }
                        }
                        HeaderButton {
                            imageSource: "../images/zoom-out.svg"
                            onClicked: {
                                var diff = xAxis.max.getTime() - xAxis.min.getTime()
                                var newTime = new Date(xAxis.min.getTime() - (diff / 4))
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
                        animationDuration: 300
                        animationOptions: ChartView.SeriesAnimations

                        ValueAxis {
                            id: yAxis
                            min: logsModelNg.minValue
                            max: logsModelNg.maxValue
                            labelsFont.pixelSize: app.smallFont
                            tickCount: chartView.height / 40
                        }

                        DateTimeAxis {
                            id: xAxis
                            gridVisible: false
                            tickCount: chartView.width / 70
                            labelsFont.pixelSize: app.smallFont
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
                            axisY: yAxis
                            name: root.stateType.displayName
                            borderColor: app.accentColor
                            borderWidth: 4
                            upperSeries: LineSeries {
                                id: lineSeries1
                                width: 4
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
                                print("overshoot is:", overshoot, "oldMax", xAxis.max, "newMax", now, "oldMin", xAxis.min, "newMin", new Date(xAxis.min.getTime() - overshoot))
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
        }
    }
}

