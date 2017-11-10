import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
//import QtCharts 2.1
import "../components"
import Guh 1.0

CustomViewBase {
    id: root
    implicitHeight: grid.implicitHeight + app.margins * 2

    property string interfaceName

    readonly property var stateType: deviceClass.stateTypes.findByName(interfaceName.replace("sensor", ""))
    readonly property var deviceState: device.states.getState(stateType.id)

    ValueLogsProxyModel {
        id: logsModel
        deviceId: root.device.id
        typeId: stateType.id
        average: zoomTabBar.currentItem.avg
        startTime: zoomTabBar.currentItem.startTime
        Component.onCompleted: updateTimer.start();
        onAverageChanged: updateTimer.start()
        onStartTimeChanged: updateTimer.start();

        onBusyChanged: {
            if (!busy) {

//                lineSeries1.clear()
//                splineSeries.clear()
//                print("---", axisX.min, axisX.max)
//                for (var i = 0; i < logsModel.count; i++) {
//                    print("adding", logsModel.get(i).timestamp, logsModel.get(i).value)
//                    lineSeries1.append(logsModel.get(i).timestamp, logsModel.get(i).value)
//                    splineSeries.append(logsModel.get(i).timestamp, logsModel.get(i).value)
//                }
            }
        }
    }

    Timer {
        id: updateTimer
        interval: 10
        repeat: false
        onTriggered: {
            print("updating:", logsModel.startTime)
            logsModel.update()
        }
    }

    ColumnLayout {
        id: grid
        anchors { left: parent.left; top: parent.top; right: parent.right }
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            spacing: app.margins
            ColorIcon {
                name: app.interfaceToIcon(root.interfaceName)
                height: app.iconSize
                width: height
                color: app.interfaceToColor(root.interfaceName)
            }
            Label {
                text: deviceState.value + " " + stateType.unitString
                font.pixelSize: app.largeFont
            }

            TabBar {
                id: zoomTabBar
                Layout.fillWidth: true
                TabButton {
                    text: "6 h"
                    property int avg: ValueLogsProxyModel.AverageQuarterHour
                    property date startTime: {
                        var date = new Date();
                        date.setHours(new Date().getHours() - 6)
                        return date;
                    }
                }
                TabButton {
                    text: "24 h"
                    property int avg: ValueLogsProxyModel.AverageHourly
                    property date startTime: {
                        var date = new Date();
                        date.setHours(new Date().getHours() - 24);
                        return date;
                    }
                }
                TabButton {
                    text: "7 d"
                    property int avg: ValueLogsProxyModel.AverageDayTime
                    property date startTime: {
                        var date = new Date();
                        date.setDate(new Date().getDate() - 7);
                        return date;
                    }
                }
            }
        }
        Graph {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            model: logsModel
            color: app.interfaceToColor(root.interfaceName)
        }

//        ChartView {
//            id: chartView
//            Layout.fillWidth: true
//            Layout.preferredHeight: 300
//            animationOptions: ChartView.SeriesAnimations
//            theme: ChartView.ChartThemeQt
//            backgroundColor: Material.background
//            property bool openGL: false
//            property bool openGLSupported: true
//            onOpenGLChanged: {
//                if (openGLSupported) {
//                    series("signal 1").useOpenGL = openGL;
//                    series("signal 2").useOpenGL = openGL;
//                }
//            }
//            Component.onCompleted: {
//                if (!series("signal 1").useOpenGL) {
//                    openGLSupported = false
//                    openGL = false
//                }
//            }

//            ValueAxis {
//                id: axisY1
//                min: logsModel.minimumValue - 1
//                max: logsModel.maximumValue + 1
//            }

//            DateTimeAxis {
//                id: axisX
//                min: logsModel.startTime
//                max: logsModel.endTime
//                format: {
//                    switch (logsModel.average) {
//                    case ValueLogsProxyModel.AverageMinute:
//                    case ValueLogsProxyModel.AverageHourly:
//                    case ValueLogsProxyModel.AverageQuarterHour:
//                        return "hh:mm"
//                    }
//                    return "ddd<br> dd.MM.<br>hh:mm"
//                }
//            }


//            AreaSeries {
//                axisX: axisX
//                axisY: axisY1
//                borderWidth: 0
//                name: app.interfaceToString(interfaceName)
//                borderColor: app.interfaceToColor(interfaceName)
//                color: Qt.rgba(borderColor.r, borderColor.g, borderColor.b, .4)
//                useOpenGL: chartView.openGL
//                upperSeries: LineSeries {
//                    id: lineSeries1
//                }
//            }
//            SplineSeries {
//                id: splineSeries
//                axisX: axisX
//                axisY: axisY1
//                width: 3
//                color: app.interfaceToColor(interfaceName)
//            }
//        }
    }
}
