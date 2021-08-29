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
    contentY: gridView.contentY - gridView.originY + topMargin

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
        topMargin: root.topMargin
        readonly property int minTileWidth: 172
        readonly property int tilesPerRow: root.width / minTileWidth

        cellWidth: gridView.width / tilesPerRow
        cellHeight: cellWidth

        moveDisplaced: Transition { NumberAnimation { properties: "x,y"; duration: 150; easing.type: Easing.InOutQuad } }

        model: tagsProxy
        delegate: Item {
            id: delegateRoot
            width: gridView.cellWidth
            height: gridView.cellHeight

            property Thing thing: engine.thingManager.things.getThing(thingId)

            property alias tile: thingTile

            ThingTile {
                id: thingTile
                anchors.fill: parent
                thing: delegateRoot.thing
                enabled: !root.editMode
                onClicked: pageStack.push(Qt.resolvedUrl("../devicepages/" + NymeaUtils.interfaceListToDevicePage(thing.thingClass.interfaces)), {thing: thing})
                onPressAndHold: root.editMode = true
                opacity: dragArea.fakeDragItem !== null && delegateRoot.thing === dragArea.fakeDragItem.thing ? .3 : 1
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: Style.smallMargins
                color: "transparent"
                border.color: Style.accentColor
                border.width: 4
                radius: Style.cornerRadius
                visible: dragArea.fakeDragItem !== null && delegateRoot.thing === dragArea.fakeDragItem.thing
            }

            Rectangle {
                z: 2
                anchors.fill: parent
                anchors.margins: Style.smallMargins
                visible: opacity > 0
                radius: Style.cornerRadius
                color: Qt.rgba(Style.backgroundColor.r, Style.backgroundColor.g, Style.backgroundColor.b, .5)
                opacity: root.editMode ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.editMode = false
                }

                Rectangle {
                    anchors {
                        left: parent.left; top: parent.top;
                        margins: Style.smallMargins
                    }
                    height: Style.largeIconSize
                    width: Style.largeIconSize
                    color: Style.red
                    radius: Style.cornerRadius
                    opacity: dragArea.fakeDragItem == null
                    Rectangle {
                        anchors.fill: parent
                        radius: Style.cornerRadius
                        color: Style.foregroundColor
                        opacity: deleteMouseArea.pressed || deleteMouseArea.containsMouse ? .08 : 0
                        Behavior on opacity {
                            NumberAnimation { duration: 200 }
                        }
                    }
                    ColorIcon {
                        name: "/ui/images/delete.svg"
                        size: Style.iconSize
                        anchors.centerIn: parent
                        color: Style.white
                    }
                    MouseArea {
                        id: deleteMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            print("delete clicked")
                            engine.tagsManager.untagThing(model.thingId, "favorites")
                        }
                    }
                }
            }
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            enabled: root.editMode
            propagateComposedEvents: true
            property var dragOffset: ({})
            property var draggedItem: null
            property var fakeDragItem: null

            onPressAndHold: {
                var gridViewCoords = mapToItem(gridView.contentItem, mouseX, mouseY)
                var item = gridView.itemAt(gridViewCoords.x, gridViewCoords.y);
                draggedItem = item;
                dragOffset = mapToItem(item, mouseX, mouseY)

                dragArea.fakeDragItem = dragItemComponent.createObject(dragArea, {
                                                                           x: mouseX - dragOffset.x,
                                                                           y: mouseY - dragOffset.y,
                                                                           thing: draggedItem.thing
                                                                       })

                drag.target = fakeDragItem
            }
            onReleased: {
                if (drag.target) {
                    drag.target = null
                    dragArea.fakeDragItem.destroy()
                    dragArea.fakeDragItem = null
                    dragArea.draggedItem = null
                }
            }

            onClicked: {
                var gridViewCoords = mapToItem(gridView.contentItem, mouseX, mouseY)
                var itemUnderMouse = gridView.itemAt(gridViewCoords.x, gridViewCoords.y);
                if (itemUnderMouse !== null) {
                    mouse.accepted = false
                } else {
                    root.editMode = false
                }
            }
        }

        Component {
            id: dragItemComponent

            ThingTile {
                id: fakeDragItem
                width: gridView.cellWidth
                height: gridView.cellHeight
                Drag.active: dragArea.drag.active
            }
        }


        DropArea {
            id: dropArea
            anchors.fill: gridView

            property int from: -1
            property int to: -1

            property int pendingCommand: -1
            Connections {
                target: engine.tagsManager
                onAddTagReply: {
                    if (commandId == dropArea.pendingCommand) {
                        dropArea.pendingCommand = -1
                    }
                }
            }

            onEntered: {
                var gridViewCoords = mapToItem(gridView.contentItem, drag.x, drag.y)
                var index = gridView.indexAt(gridViewCoords.x + dragArea.dragOffset.x, gridViewCoords.y + dragArea.dragOffset.y);
                from = index;
                to = index;
            }

            onPositionChanged: {
                if (dropArea.pendingCommand != -1) {
                    // busy
                    return
                }

                var gridViewCoords = mapToItem(gridView.contentItem, drag.x, drag.y)
                var index = gridView.indexAt(gridViewCoords.x + dragArea.dragOffset.x, gridViewCoords.y + dragArea.dragOffset.y);
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
                        dropArea.pendingCommand = engine.tagsManager.tagThing(tag.thingId, tag.tagId, newIdx);
                    }
                    from = index;
                }
            }
        }
    }

    EmptyViewPlaceholder {
        anchors { left: parent.left; right: parent.right; margins: Style.margins }
        anchors.verticalCenter: parent.verticalCenter
        visible: gridView.count === 0 && !engine.thingManager.fetchingData
        title: qsTr("There are no favorite things yet.")
        text: engine.thingManager.things.count === 0 ?
                  qsTr("It appears there are no things set up either yet. In order to use favorites you need to add some things first.") :
                  qsTr("Favorites allow you to keep track of your most important things when you have lots of them. Watch out for the star when interacting with things and use it to mark them as your favorites.")
        imageSource: "../images/starred.svg"
        buttonVisible: engine.thingManager.things.count === 0
        buttonText: qsTr("Add things")
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../thingconfiguration/NewThingPage.qml"))
    }

}
