import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Nymea 1.0
import "../components"

Item {
    id: root

    readonly property int count: tagsProxy.count

    TagsProxyModel {
        id: tagsProxy
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
        delegate: favoritesDelegateComponent
        MouseArea {
            id: dndArea
            anchors.fill: parent
            propagateComposedEvents: true

            property int from: -1
            property int to: -1
            property int index: gridView.indexAt(mouseX, mouseY) // Item underneath cursor
            property var dndDelegate: null

            property int dx
            property int dy

            onPressAndHold: {
                //currentId = icons.get(newIndex = index).gridId
                preventStealing = true;
                from = index;
                print("pressandHold on", index)
                var tag = tagsProxy.get(index);
                var originalDelegate = gridView.itemAt(mouseX, mouseY)
                dndDelegate = favoritesDelegateComponent.createObject(dndArea, {deviceId: tag.deviceId, ruleId: tag.ruleId, x: originalDelegate.x, y: originalDelegate.y})
                dx = mouseX - originalDelegate.x;
                dy = mouseY - originalDelegate.y;
            }
            onReleased: {
                preventStealing = false;
                from = -1;
                dndDelegate.destroy();
            }

            onPositionChanged: {
                if (dndDelegate) {
                    dndDelegate.x = mouseX - dx
                    dndDelegate.y = mouseY - dy
                }

                if (dndArea.from >= 0 && to != index && from != index) {
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
                        Engine.tagsManager.tagDevice(tag.deviceId, tag.tagId, newIdx);
                    }
                    from = index;
                }
                //                tagsProxy.move(newIndex, newIndex = index, 1)
            }
        }


    }

    Component {
        id: favoritesDelegateComponent
        Item {
            id: delegateRoot
            property string deviceId: model.deviceId
            property string ruleId: model.ruleId
            readonly property var device: Engine.deviceManager.devices.getDevice(deviceId)
            readonly property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null

            visible: index !== undefined && index !== dndArea.from
            width: gridView.cellWidth
            height: gridView.cellHeight

            Pane {
                id: pane
                anchors.fill: parent
                anchors.margins: app.margins / 2
                Material.elevation: 1
                ColumnLayout {
                    anchors.centerIn: parent
                    width: parent.width - app.margins * 2
                    spacing: app.margins

                    ColorIcon {
                        Layout.preferredWidth: app.iconSize * 2
                        Layout.preferredHeight: width
                        name: app.interfacesToIcon(delegateRoot.deviceClass.interfaces)
                        color: app.guhAccent
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        Layout.fillWidth: true
                        text: delegateRoot.device.name.toUpperCase()
                        font.pixelSize: app.extraSmallFont
                        font.bold: true
                        font.letterSpacing: 1
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../devicepages/" + app.interfaceListToDevicePage(delegateRoot.deviceClass.interfaces)), {device: delegateRoot.device})
                }
            }
        }
    }
}
