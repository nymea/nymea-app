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
