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
import QtQuick.Controls
import Nymea

BigTile {
    id: root

    property Thing thing: null

    readonly property State connectedState: thing.thingClass.interfaces.indexOf("connectable") >= 0 ? thing.stateByName("connected") : null
    readonly property bool isConnected: connectedState === null || connectedState.value === true
    readonly property bool isEnabled: thing.setupStatus == Thing.ThingSetupStatusComplete && isConnected

    onPressAndHold: {
        var contextMenuComponent = Qt.createComponent("../components/ThingContextMenu.qml");
        var contextMenu = contextMenuComponent.createObject(root, { thing: root.thing })
        contextMenu.x = Qt.binding(function() { return (root.width - contextMenu.width) / 2 })
        contextMenu.open()
    }    

    header: RowLayout {
        id: headerRow
        visible: root.showHeader
        width: parent.width
        Layout.margins: Style.margins / 2
        Label {
            Layout.fillWidth: true
            text: root.thing.name
            elide: Text.ElideRight
        }
        ThingStatusIcons {
            thing: root.thing
        }
    }
}
