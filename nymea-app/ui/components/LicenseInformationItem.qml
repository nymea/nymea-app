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
import QtQuick.Controls.Material
import Nymea

NymeaSwipeDelegate {
    id: root

    property string component
    property string description
    property string license
    property string url
    property string version
    property string platforms

    prominentSubText: false
    progressive: false
    text: root.component
    subText: root.description
    visible: platforms === "*" || platforms.indexOf(Qt.platform.os) >= 0
    onClicked: Qt.openUrlExternally(root.url)
    additionalItem: ColumnLayout {

        Label {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignRight
            text: root.license
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
        }
        Label {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignRight
            text: root.version
            font.pixelSize: app.extraSmallFont
            color: Material.color(Material.Grey)
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            visible: root.version.length > 0
        }
    }
}
