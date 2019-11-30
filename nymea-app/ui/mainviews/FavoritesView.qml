import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Nymea 1.0
import "../components"
import "../delegates"

MouseArea {
    id: root

    property bool editMode: false
    readonly property int count: tagsProxy.count

    // Prevent scroll events to swipe left/right in case they fall through the grid
    preventStealing: true
    onWheel: wheel.accepted = true

    TagsProxyModel {
        id: tagsProxy
        tags: engine.tagsManager.tags
        filterTagId: "favorites"
    }

    GridView {
        id: gridView
        anchors.fill: parent
        anchors.margins: app.margins / 2
        readonly property int minTileWidth: 180
        readonly property int minTileHeight: 240
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
}
