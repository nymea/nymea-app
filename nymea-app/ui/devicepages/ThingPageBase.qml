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

Page {
    id: root
    property Thing thing: null

    property bool showDetailsButton: true
    property bool showBrowserButton: true
    property bool popStackOnBackButton: true

    default property alias data: contentItem.data

    signal backPressed()

    header: NymeaHeader {
        text: root.thing.name
        onBackPressed: {
            root.backPressed();
            if (root.popStackOnBackButton) {
                pageStack.pop()
            }
        }

        HeaderButton {
            imageSource: "qrc:/icons/folder.svg"
            visible: root.thing.thingClass.browsable && root.showBrowserButton
            onClicked: {
                pageStack.push(Qt.resolvedUrl("DeviceBrowserPage.qml"), {thing: root.thing})
            }
        }

        HeaderButton {
            imageSource: "qrc:/icons/navigation-menu.svg"
            onClicked: thingMenu.open();
        }
    }

    ThingContextMenu {
        id: thingMenu
        x: parent.width - width
        thing: root.thing
        showDetails: root.showDetailsButton
    }

    Connections {
        target: engine.thingManager.things
        onThingRemoved:{
            if (thing == root.thing) {
                print("Thing destroyed")
                pageStack.pop()
            }
        }
    }

    ThingInfoPane {
        id: infoPane
        anchors { left: parent.left; top: parent.top; right: parent.right }
        thing: root.thing
    }

    Item {
        id: contentItem
        anchors.fill: parent
        anchors.topMargin: infoPane.height
        clip: true
    }
}
