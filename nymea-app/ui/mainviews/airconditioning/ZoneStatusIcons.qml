// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick
import QtQuick.Layouts
import Nymea
import Nymea.AirConditioning

import "qrc:/ui/components"

RowLayout {
    id: root
    Layout.fillWidth: true

    property ZoneInfo  zone: null
    property int iconSize: Style.iconSize

    signal clicked(int flag)

    Repeater {
        id: zoneStatusRepeater
        model: zoneStatusModel
        property var zoneStatusModel: [
            {
                value: ZoneInfo.ZoneStatusFlagSetpointOverrideActive,
                icon: "dial",
                activeColor: Style.accentColor
            },
            {
                value: ZoneInfo.ZoneStatusFlagTimeScheduleActive,
                icon: "calendar",
                activeColor: Style.orange
            },
            {
                value: ZoneInfo.ZoneStatusFlagWindowOpen,
                icon: "sensors/window-closed",
                activeIcon: "sensors/window-open",
                activeColor: Style.red
            },
            {
                value: ZoneInfo.ZoneStatusFlagHighHumidity,
                icon: "sensors/humidity",
                activeColor: Style.lightBlue
            },
            {
                value: ZoneInfo.ZoneStatusFlagBadAir,
                icon: "weathericons/weather-clouds",
                activeColor: Style.purple
            }
        ]
        delegate: Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.bigIconSize
            property var entry: zoneStatusRepeater.zoneStatusModel[index]
            ColorIcon {
                id: zoneStatusIcon
                anchors.centerIn: parent
                name: entry.hasOwnProperty("activeIcon") && active ? entry.activeIcon : entry.icon
                size: root.iconSize
                property bool active: (root.zone.zoneStatus & entry.value) > 0
                color: active ? entry.activeColor : Style.iconColor
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.clicked(entry.value)
                }
            }
        }
    }
}
