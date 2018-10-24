import QtQuick 2.5
import QtQuick.Controls 2.1
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
        lineSeries: lineSeries1
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

                ChartView {
                    id: chartView
                    anchors.fill: parent
                    ValueAxis {
                        id: yAxis
                        min: 0
                        max: 50
                    }

                    ValueAxis {
                        id: xAxis
                        min: Math.floor(startTime.getTime() / 1000)
                        max: Math.floor(endTime.getTime() / 1000)

                        property date startTime: {
                            var date = new Date();
                            date.setHours(date.getHours() - 6);
                            return date;
                        }

                        property date endTime: new Date()
                        Component.onCompleted: print("creating axis:", startTime, endTime)
                    }

                    LineSeries {
                        id: lineSeries1
                        axisX: xAxis
                        axisY: yAxis
                    }

                    MouseArea {
                            anchors.fill: parent
                            property int lastX: 0
                            property int lastY: 0
                            onPressed: {
                                lastX = mouse.x
                                lastY = mouse.y
                            }

                            onPositionChanged: {
                                if (lastX !== mouse.x) {
                                    chartView.scrollRight(lastX - mouse.x)
                                    lastX = mouse.x
                                }
                                if (lastY !== mouse.y) {
                                    chartView.scrollDown(lastY - mouse.y)
                                    lastY = mouse.y
                                }
                            }
                        }
                }
            }
        }
    }
}

