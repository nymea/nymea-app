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
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root
    header: NymeaHeader {
        text: root.groupTag.substring(6)
        onBackPressed: pageStack.pop()
    }

    property string groupTag


    DevicesProxy {
        id: devicesInGroup
        engine: _engine
        filterTagId: root.groupTag
    }

    InterfacesProxy {
        id: interfacesInGroup
        devicesProxyFilter: devicesInGroup
        showStates: true
    }

    DevicesProxy {
        id: lightsInGroup
        engine: _engine
        sourceModel: devicesInGroup
        filterTagId: root.groupTag
        shownInterfaces: "light"
    }
    DevicesProxy {
        id: dimmableLightsInGroup
        engine: _engine
        sourceModel: devicesInGroup
        filterTagId: root.groupTag
        shownInterfaces: "dimmablelight"
    }
    DevicesProxy {
        id: colorLightsInGroup
        engine: _engine
        sourceModel: devicesInGroup
        filterTagId: root.groupTag
        shownInterfaces: "colorlight"
    }
    DevicesProxy {
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
                    imageSource: "../images/powersocket.svg"
                    visible: socketsInGroup.count > 0
                }
                HeaderButton {
                    imageSource: "../images/light-on.svg"
                    visible: lightsInGroup.count > 0
                }
                HeaderButton {
                    imageSource: "../images/radiator.svg"
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

                onClicked: pageStack.push(Qt.resolvedUrl("../devicepages/" + NymeaUtils.interfaceListToDevicePage(deviceClass.interfaces)), {device: device})

            }
        }
    }


}
