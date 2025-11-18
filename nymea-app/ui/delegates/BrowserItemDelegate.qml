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

NymeaSwipeDelegate {
    id: root
    width: parent.width
    text: model.displayName
    progressive: model.browsable
    subText: model.description
    prominentSubText: false
    iconName: "qrc:/icons/browser/" + (model.mediaIcon && model.mediaIcon !== "MediaBrowserIconNone" ? model.mediaIcon : model.icon) + ".svg"
    thumbnail: model.thumbnail
    enabled: !model.disabled
    secondaryIconName: model.actionTypeIds.length > 0 ? "qrc:/icons/navigation-menu.svg" : ""
    secondaryIconClickable: true

    property Thing thing: null
    property alias device: root.thing

    onPressAndHold: openContextMenu()
    onSecondaryIconClicked: openContextMenu()

    signal contextMenuActionTriggered(var actionTypeId, var params)

    function openContextMenu() {
        if (model.actionTypeIds.length === 0) {
            return;
        }

        var actionDialogComponent = Qt.createComponent(Qt.resolvedUrl("../components/BrowserContextMenu.qml"));
        var popup = actionDialogComponent.createObject(app,
                                                       {
                                                           thing: root.thing,
                                                           title: model.displayName,
                                                           itemId: model.id,
                                                           actionTypeIds: model.actionTypeIds
                                                       });
        popup.activated.connect(function(actionTypeId, params) {
            root.contextMenuActionTriggered(actionTypeId, params)
        })
        popup.open()
    }
}
