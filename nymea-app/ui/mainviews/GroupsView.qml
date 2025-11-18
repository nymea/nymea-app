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
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import QtQuick.Controls.Material 2.2
import "../components"

MainViewBase {
    id: root
    contentY: groupsGridView.contentY - groupsGridView.originY + topMargin

    GridView {
        id: groupsGridView
        anchors.fill: parent
        anchors.margins: app.margins / 2
        topMargin: root.topMargin
        bottomMargin: root.bottomMargin

        readonly property int minTileWidth: 172
        readonly property int tilesPerRow: root.width / minTileWidth

        model: TagListProxyModel {
            tagListModel: TagListModel {
                tagsProxy: TagsProxyModel {
                    tags: engine.tagsManager.tags
                    filterTagId: "group-.*"
                }
            }
        }
        cellWidth: width / tilesPerRow
        cellHeight: cellWidth

        delegate: MainPageTile {
            width: groupsGridView.cellWidth
            height: groupsGridView.cellHeight
            iconName: "qrc:/icons/groups.svg"
            iconColor: Style.accentColor
            lowerText: model.tagId.substring(6)
            onClicked: {
                pageStack.push(Qt.resolvedUrl("../grouping/GroupInterfacesPage.qml"), {groupTag: model.tagId})
            }
        }
    }

    EmptyViewPlaceholder {
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        anchors.verticalCenter: parent.verticalCenter
        visible: groupsGridView.count == 0 && !engine.thingManager.fetchingData && !engine.tagsManager.busy
        title: qsTr("There are no groups set up yet.")
        text: qsTr("Grouping things can be useful to control multiple devices at once, for example an entire room. Watch out for the group symbol when interacting with things and use it to add them to groups.")
        imageSource: "qrc:/icons/groups.svg"
        buttonVisible: false
    }
}
