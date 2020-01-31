/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "../components"
import Nymea 1.0

CustomViewBase {
    id: root
    implicitHeight: grid.implicitHeight + app.margins * 2

    property string interfaceName

    readonly property string stateTypeName: {
        switch (interfaceName) {
        case "lightsensor":
            return "lightIntensity";
        default:
            return interfaceName.replace("sensor", "");
        }
    }

    readonly property var stateType: deviceClass.stateTypes.findByName(stateTypeName)
    readonly property var deviceState: device.states.getState(stateType.id)

    ValueLogsProxyModel {
        id: logsModel
        engine: _engine
        deviceId: root.device.id
        typeIds: [stateType.id]
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
                text: Types.toUiValue(deviceState.value, stateType.unit) + " " + Types.toUiUnit(stateType.unit)
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

