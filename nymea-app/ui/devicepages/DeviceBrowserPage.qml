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
import Nymea

import "../components"
import "../delegates"

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("Browse %1").arg(root.thing.name)
        onBackPressed: pageStack.pop()
    }
    property Thing thing: null
    property alias device: root.thing
    property string nodeId: ""

    Component.onCompleted: {
        d.model = engine.thingManager.browseThing(root.thing.id, root.nodeId);
    }

    function executeBrowserItem(itemId) {
        d.pendingItemId = itemId
        d.pendingBrowserItemId = engine.thingManager.executeBrowserItem(root.thing.id, itemId)
    }
    function executeBrowserItemAction(itemId, actionTypeId, params) {
        d.pendingItemId = itemId
        d.pendingBrowserItemId = engine.thingManager.executeBrowserItemAction(root.thing.id, itemId, actionTypeId, params)
    }

    QtObject {
        id: d
        property BrowserItems model: null
        property int pendingBrowserItemId: -1
        property string pendingItemId: ""
    }

    Connections {
        target: engine.thingManager
        onExecuteBrowserItemReply: actionExecuted(commandId, thingError, displayMessage)
        onExecuteBrowserItemActionReply: actionExecuted(commandId, thingError, displayMessage)
    }
    function actionExecuted(commandId, thingError, displayMessage) {
        if (commandId === d.pendingBrowserItemId) {
            d.pendingBrowserItemId = -1;
            d.pendingItemId = ""
            if (thingError !== Thing.ThingErrorNoError) {
                if (displayMessage.length > 0) {
                    header.showInfo(qsTr("Error: %1").arg(displayMessage), true)
                } else {
                    header.showInfo(qsTr("Error: %1").arg(thingError), true)
                }
            }
        }
        engine.thingManager.refreshBrowserItems(d.model)
    }

    ListView {
        id: listView
        anchors.fill: parent
        model: d.model
        ScrollBar.vertical: ScrollBar {}

        delegate: BrowserItemDelegate {
            id: delegate
            busy: d.pendingItemId === model.id
            thing: root.thing

            onClicked: {
                print("clicked:", model.id)
                if (model.executable) {
                    root.executeBrowserItem(model.id)
                } else if (model.browsable) {
                    pageStack.push(Qt.resolvedUrl("DeviceBrowserPage.qml"), {thing: root.thing, nodeId: model.id})
                }
            }

            onContextMenuActionTriggered: {
                root.executeBrowserItemAction(model.id, actionTypeId, params)
            }
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: listView.model.busy
            visible: running
        }
    }

}
