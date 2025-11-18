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

import QtQuick 2.4
import QtQuick.Controls 2.1
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root

    property Thing thing: null
    property string itemId: ""

    signal selected(string selectedItemId)

    header: NymeaHeader {
        onBackPressed: pageStack.pop()
        text: qsTr("Select item")
    }

    Component.onCompleted: {
        listView.model = engine.thingManager.browseThing(root.thing.id, root.itemId)
    }

    ListView {
        id: listView
        anchors.fill: parent
        ScrollBar.vertical: ScrollBar {}

        BusyIndicator {
            anchors.centerIn: parent
            running: listView.model.busy
            visible: running
        }

        delegate: BrowserItemDelegate {
            width: parent.width
            thing: root.thing
            secondaryIconName: "" // We don't support BrowserItemActions in rules yet

            onClicked: {
                if (model.browsable) {
                    var page = pageStack.push(Qt.resolvedUrl("SelectBrowserItemActionPage.qml"), {thing: root.thing, itemId: model.id});
                    page.selected.connect(function(selectedItemId) {
                        pageStack.pop();
                        root.selected(selectedItemId);
                    })
                } else if (model.executable) {
                    pageStack.pop();
                    print("selected:", model.id)
                    root.selected(model.id);
                }
            }
        }
    }
}
