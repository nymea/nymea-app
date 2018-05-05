import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "../components"
import Mea 1.0

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
        }
        Graph {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            model: logsModel
            mode: settings.graphStyle
            color: app.interfaceToColor(root.interfaceName)
        }
    }
}

