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
import QtQuick.Controls.Material 2.2
import Nymea 1.0
import "../components"
import "../delegates"

MainViewBase {
    id: root

    property bool editMode: false

    TagsProxyModel {
        id: tagsProxy
        tags: engine.tagsManager.tags
        filterTagId: "favorites"
    }

    GridView {
        id: gridView
        anchors.fill: parent
        anchors.margins: app.margins / 2
        readonly property int minTileWidth: 172
        readonly property int tilesPerRow: root.width / minTileWidth

        cellWidth: gridView.width / tilesPerRow
        cellHeight: cellWidth

        model: tagsProxy
        delegate: ThingTile {
            id: delegateRoot
            width: gridView.cellWidth
            height: gridView.cellHeight
            device: engine.deviceManager.devices.getDevice(deviceId)

            onClicked: pageStack.push(Qt.resolvedUrl("../devicepages/" + app.interfaceListToDevicePage(deviceClass.interfaces)), {device: device})

            onPressAndHold: root.editMode = true

            SequentialAnimation {
                loops: Animation.Infinite
                running: root.editMode
                alwaysRunToEnd: true
                NumberAnimation { from: 0; to: 3; target: delegateRoot; duration: 75; property: "rotation" }
                NumberAnimation { from: 3; to: -3; target: delegateRoot; duration: 150; property: "rotation" }
                NumberAnimation { from: -3; to: 0; target: delegateRoot; duration: 75; property: "rotation" }
            }
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            enabled: root.editMode
            propagateComposedEvents: true
            property var dragOffset: ({})
            property var draggedItem: null

            onPressed: {
                var item = gridView.itemAt(mouseX, mouseY)
                draggedItem = item;
                dragOffset = mapToItem(item, mouseX, mouseY)
                fakeDragItem.x = mouseX - dragOffset.x;
                fakeDragItem.y = mouseY - dragOffset.y;
                fakeDragItem.text = item.text
                fakeDragItem.iconName = item.iconName
                fakeDragItem.iconColor = item.iconColor;
                fakeDragItem.deviceId = item.device.id
                fakeDragItem.batteryCritical = item.batteryCritical
                fakeDragItem.disconnected = item.disconnected
                drag.target = fakeDragItem
            }
            onReleased: {
                drag.target = null
                draggedItem = null
            }

            onClicked: {
                root.editMode = false
            }
        }

        MainPageTile {
            id: fakeDragItem
            width: gridView.cellWidth
            height: gridView.cellHeight
            Drag.active: dragArea.drag.active
            visible: Drag.active
            property var deviceId
        }

        DropArea {
            id: dropArea
            anchors.fill: gridView

            property int from: -1
            property int to: -1

            onEntered: {
                var index = gridView.indexAt(drag.x + dragArea.dragOffset.x, drag.y + dragArea.dragOffset.y);
                from = index;
                to = index;
            }

            onPositionChanged: {
                var index = gridView.indexAt(drag.x + dragArea.dragOffset.x, drag.y + dragArea.dragOffset.y);
                if (to !== index && from !== index && index >= 0 && index <= tagsProxy.count) {
                    to = index;
                    print("should move", from, "to", to)
                    for (var i = 0; i < tagsProxy.count; i++) {
                        if (i < Math.min(from, to) || i > Math.max(from, to)) {
                            // outside the range... don't touch
                            continue;
                        }
                        var newIdx;
                        if (i == from) {
                            newIdx = to;
                        } else {
                            if (from < to) {
                                // item is moved down the list
                                newIdx = i - 1;
                            } else {
                                newIdx = i + 1;
                            }
                        }

                        var tag = tagsProxy.get(i);
                        engine.tagsManager.tagDevice(tag.deviceId, tag.tagId, newIdx);
                    }
                    from = index;
                }
            }
        }
    }

    EmptyViewPlaceholder {
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        anchors.verticalCenter: parent.verticalCenter
        visible: gridView.count === 0 && !engine.deviceManager.fetchingData
        title: qsTr("There are no favorite things yet.")
        text: engine.deviceManager.devices.count === 0 ?
                  qsTr("It appears there are no things set up either yet. In order to use favorites you need to add some things first.") :
                  qsTr("Favorites allow you to keep track of your most important things when you have lots of them. Watch out for the star when interacting with things and use it to mark them as your favorites.")
        imageSource: "../images/starred.svg"
        buttonVisible: engine.deviceManager.devices.count === 0
        buttonText: qsTr("Add a thing")
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../thingconfiguration/NewThingPage.qml"))
    }

}
