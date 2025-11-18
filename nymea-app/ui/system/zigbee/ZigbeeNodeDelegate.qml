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
import Nymea 1.0
import QtQuick.Layouts 1.0
import "qrc:/ui/components"

ColumnLayout {
    id: root

    property ZigbeeManager zigbeeManager: null
    property ZigbeeNetwork zigbeeNetwork: null
    property ZigbeeNode node: null

    NymeaItemDelegate {
        id: thisNode
        Layout.fillWidth: true
        text: root.node.model + " - " + root.node.neighbors.length
    }

    Repeater {
        model: root.node.neighbors.length
        delegate: Text {
            Layout.fillWidth: true
            text: "fdsfdfasa, index" + index
        }
    }

    Repeater {
        model: root.node.neighbors.length
        delegate: Loader {
            id: loader
            Layout.fillWidth: true
            Layout.preferredHeight: item ? item.implicitHeight : 0
            source: Qt.resolvedUrl("ZigbeeNodeDelegate.qml")
//            ZigbeeNodeDelegate {
            Binding {
                target: loader.item
                property: "zigbeeManager"
                value: root.zigbeeManager
            }
            Binding {
                target: loader.item
                property: "zigbeeNetwork"
                value: root.zigbeeNetwork
            }

            Binding {
                target: loader.item
                property: "node"
                value: root.zigbeeNetwork.nodes.getNodeByNetworkAddress(root.node.neighbors[index].networkAddress)
            }
        }
    }
}
