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
            iconName: "../images/groups.svg"
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
        imageSource: "../images/groups.svg"
        buttonVisible: false
    }
}
