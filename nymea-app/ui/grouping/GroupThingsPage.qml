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
import QtQuick.Controls.Material
import QtQuick.Layouts
import Nymea
import NymeaApp.Utils

import "../components"
import "../delegates"

Page {
    id: root
    header: NymeaHeader {
        text: root.groupTag.substring(6)
        onBackPressed: pageStack.pop()
    }

    property string groupTag


    ThingsProxy {
        id: devicesInGroup
        engine: _engine
        filterTagId: root.groupTag
    }

    InterfacesProxy {
        id: interfacesInGroup
        thingsProxyFilter: devicesInGroup
        showStates: true
    }

    ThingsProxy {
        id: lightsInGroup
        engine: _engine
        sourceModel: devicesInGroup
        filterTagId: root.groupTag
        shownInterfaces: "light"
    }
    ThingsProxy {
        id: dimmableLightsInGroup
        engine: _engine
        sourceModel: devicesInGroup
        filterTagId: root.groupTag
        shownInterfaces: "dimmablelight"
    }
    ThingsProxy {
        id: colorLightsInGroup
        engine: _engine
        sourceModel: devicesInGroup
        filterTagId: root.groupTag
        shownInterfaces: "colorlight"
    }
    ThingsProxy {
        id: socketsInGroup
        engine: _engine
        sourceModel: devicesInGroup
        filterTagId: root.groupTag
        shownInterfaces: "powersocket"
    }

    ColumnLayout {
        anchors.fill: parent

        Pane {
            Layout.fillWidth: true
            Material.elevation: 1
            RowLayout {
                HeaderButton {
                    imageSource: "qrc:/icons/powersocket.svg"
                    visible: socketsInGroup.count > 0
                }
                HeaderButton {
                    imageSource: "qrc:/icons/light-on.svg"
                    visible: lightsInGroup.count > 0
                }
                HeaderButton {
                    imageSource: "qrc:/icons/radiator.svg"
                }
            }
        }

        GridView {
            id: gridView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            model: devicesInGroup

            readonly property int minTileWidth: 180
            readonly property int minTileHeight: 240
            readonly property int tilesPerRow: root.width / minTileWidth

            cellWidth: gridView.width / tilesPerRow
            cellHeight: cellWidth

            delegate: ThingTile {
                width: gridView.cellWidth
                height: gridView.cellHeight

                device: devicesInGroup.get(index)

                onClicked: pageStack.push(Qt.resolvedUrl("../devicepages/" + NymeaUtils.interfaceListToDevicePage(thing.thingClass.interfaces)), {device: device})
            }
        }
    }
}
