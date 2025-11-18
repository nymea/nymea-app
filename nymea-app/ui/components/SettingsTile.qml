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

import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import Nymea 1.0

BigTile {
    id: root

    property alias iconSource: icon.name
    property alias text: textLabel.text
    property alias subText: subTextLabel.text

    contentItem: RowLayout {
        spacing: Style.margins
        ColorIcon {
            id: icon
            size: Style.iconSize
            color: Style.accentColor
        }
        ColumnLayout {
            Label {
                id: textLabel
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
            Label {
                id: subTextLabel
                Layout.fillWidth: true
                font: Style.extraSmallFont
                elide: Text.ElideRight
                color: Style.unobtrusiveForegroundColor
            }
        }
    }
}
