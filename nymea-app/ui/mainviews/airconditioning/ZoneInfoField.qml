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

import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import "qrc:/ui/components"
import "qrc:/ui/customviews"
import "qrc:/ui/delegates"
import Nymea 1.0
import Nymea.AirConditioning 1.0

RowLayout {
    id: root
    implicitHeight: Style.bigIconSize

    property alias imageSource: icon.name
    property alias iconColor: icon.color
    property alias text: label.text

    property ZoneInfo zone: null
    property int flag: ZoneInfo.ZoneStatusFlagNone
    property bool active: zone && ((zone.zoneStatus & flag) > 0)

    ColorIcon {
        id: icon
        size: Style.bigIconSize
        color: root.active ? root.iconColor : Style.iconColor
    }
    Label {
        id: label
        Layout.fillWidth: true
    }
}
