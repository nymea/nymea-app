import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

ColumnLayout {
    id: root

    property var device: null
    property var stateType: null

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
