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

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../delegates"
import "../mainviews"

Page {
    id: root
    header: NymeaHeader {
        text: root.groupTag.substring(6)
        onBackPressed: pageStack.pop()
    }

    property string groupTag

    ThingsProxy {
        id: thingsInGroup
        engine: _engine
        filterTagId: root.groupTag
    }

    GridView {
        id: interfacesGridView
        anchors.fill: parent
        anchors.margins: app.margins / 2

        model: InterfacesSortModel {
            interfacesModel: InterfacesModel {
                engine: _engine
                things: thingsInGroup
                shownInterfaces: app.supportedInterfaces
                showUncategorized: true
            }
        }

        readonly property int minTileWidth: 172
        readonly property int tilesPerRow: root.width / minTileWidth

        cellWidth: width / tilesPerRow
        cellHeight: cellWidth
//        delegate: InterfaceTile {
//            width: interfacesGridView.cellWidth
//            height: interfacesGridView.cellHeight
//        }

        delegate: InterfaceTile {
            width: interfacesGridView.cellWidth
            height: interfacesGridView.cellHeight
            iface: Interfaces.findByName(model.name)
            filterTagId: root.groupTag
        }
    }

}
