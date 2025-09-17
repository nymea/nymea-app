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
import QtQuick.Controls
import QtQuick.Layouts
import QtCharts
import Nymea
import Nymea.AirConditioning

import "qrc:/ui/components"
import "qrc:/ui/customviews"

Item {
    id: root
    implicitHeight: Style.smallIconSize + Style.smallMargins
    property alias text: textLabel.text
    property alias iconName: icon.name
    property color color: "white"

    MouseArea {
        anchors.fill: parent
        anchors.topMargin: -Style.smallMargins
        anchors.bottomMargin: -Style.smallMargins
    }
    Row {
        anchors.centerIn: parent
        spacing: Style.smallMargins
        ColorIcon {
            id: icon
            size: Style.smallIconSize
            color: root.color
            visible: root.iconName != ""
        }
        Rectangle {
            width: Style.smallIconSize
            height: Style.smallIconSize
            color: root.color
            visible: root.iconName == ""
        }

        Label {
            id: textLabel
            width: parent.parent.width - x
            elide: Text.ElideRight
            visible: root.width > 60
            anchors.verticalCenter: parent.verticalCenter
            font: Style.smallFont
        }
    }
}

