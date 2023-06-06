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

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtCharts 2.2
import Nymea 1.0
import "../../components"
import "../../delegates"

MainViewBase {
    id: root

    property var model: null
    property bool editMode: false
    property bool dashboardVisible: false

    property int contentY: flickable.contentY - flickable.originY

    function addItem(index) {
        if (index === undefined) {
            index = root.model.count
        }
        var addComponent = Qt.createComponent(Qt.resolvedUrl("DashboardAddWizard.qml"))
        if (addComponent.status === Component.Error) {
            console.warn(addComponent.errorString())
        }
        var popup = addComponent.createObject(root, {dashboardModel: root.model, index: index})
        popup.open()
    }

    readonly property var componentMap: {
        "thing": "DashboardThingDelegate.qml",
        "folder": "DashboardFolderDelegate.qml",
        "graph": "DashboardGraphDelegate.qml",
        "scene": "DashboardSceneDelegate.qml",
        "webview": "DashboardWebViewDelegate.qml"
    }

    onEditModeChanged: {
        if (!editMode) {
            root.model.save()
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: Style.smallMargins
        contentHeight: Math.max(layout.implicitHeight, height)
        contentWidth: width
        bottomMargin: root.bottomMargin

        // Disabling this as it causes collisions when items in the dashboard use longpresses
//        MouseArea {
//            width: flickable.contentWidth
//            height: flickable.contentHeight
//            onPressAndHold: root.editMode = true
//        }

        GridLayout {
            id: layout
            width: Math.min(root.model.count * cellWidth, flickable.width)
            readonly property int minTileWidth: 172
            readonly property int tilesPerRow: root.width / minTileWidth
            columns: tilesPerRow
            columnSpacing: 0
            rowSpacing: 0

            property int cellWidth: flickable.width / tilesPerRow
            property int cellHeight: cellWidth

            Repeater {
                id: repeater
                model: root.model

                Loader {
                    id: loader
                    Layout.preferredWidth: layout.cellWidth * columnSpan
                    Layout.preferredHeight: layout.cellHeight * rowSpan
                    property int columnSpan: model.columnSpan
                    property int rowSpan: model.rowSpan

                    Layout.columnSpan: columnSpan
                    Layout.rowSpan: rowSpan
                    property string type: model.type
                    property DashboardItem dashboardItem: root.model.get(index)
                    opacity: dragArea.fromIndex == index ? .3 : 1

                    Component.onCompleted: {
                        setSource(Qt.resolvedUrl(componentMap[model.type]), {item: loader.dashboardItem})
                    }

                    Binding {
                        target: loader.item
                        property: "enabled"
                        value: !root.editMode// dragArea.editIndex === index
                    }
                    Binding {
                        target: loader.item
                        property: "editMode"
                        value: root.editMode
                    }
                    Binding {
                        target: loader.item
                        property: "dashboardVisible"
                        value: root.dashboardVisible
                    }
                    Binding {
                        target: loader.item
                        property: "bottomClip"
                        value: loader.bottomClip
                    }
                    Binding {
                        target: loader.item
                        property: "topClip"
                        value: loader.topClip
                    }
                    Connections {
                        target: loader.item
                        onOpenDialog: {
                            dialogComponent.createObject(root).open()
                        }
                    }

                    property int topClip: Math.min(height, Math.max(0, -y + (flickable.contentY - flickable.originY) - Style.margins))
                    property int bottomClip: Math.max(0, y + height - flickable.height - Style.margins - (flickable.contentY - flickable.originY))

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: Style.smallMargins
                        color: "transparent"
                        border.color: Style.accentColor
                        border.width: 4
                        radius: Style.cornerRadius
                        visible: dragArea.fromIndex == index
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
                            opacity: dragArea.fromIndex == -1
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
                                    root.model.removeItem(index)
                                }
                            }
                        }
                        Rectangle {
                            anchors {
                                right: parent.right
                                top: parent.top
                                margins: Style.smallMargins
                            }
                            height: Style.largeIconSize
                            width: Style.largeIconSize
                            color: Style.tileOverlayColor
                            radius: Style.cornerRadius
                            visible: opacity > 0
                            opacity: dragArea.fromIndex == -1 && loader.item.configurable
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            Rectangle {
                                anchors.fill: parent
                                radius: Style.cornerRadius
                                color: Style.foregroundColor
                                opacity: configureMouseArea.pressed || configureMouseArea.containsMouse ? .08 : 0
                                Behavior on opacity {
                                    NumberAnimation { duration: 200 }
                                }

                            }
                            ColorIcon {
                                name: "/ui/images/configure.svg"
                                size: Style.iconSize
                                anchors.centerIn: parent
//                                color: Style.white
                            }
                            MouseArea {
                                id: configureMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    loader.item.configure()
                                }
                            }
                        }
                    }
                }
            }

            MouseArea {
                id: addTile
                Layout.preferredWidth: layout.cellWidth
                Layout.preferredHeight: layout.cellHeight
                hoverEnabled: true
                opacity: root.editMode ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                onClicked: {
                    print("add clicked")
                    root.addItem()
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: Style.smallMargins
                    border.width: 4
                    border.color: Style.tileOverlayColor
                    color: Qt.rgba( Style.tileBackgroundColor.r,  Style.tileBackgroundColor.g,  Style.tileBackgroundColor.b,  addTile.containsMouse ? 1 : 0)
                    Behavior on color { ColorAnimation { duration: 200 } }
                    radius: Style.cornerRadius

                    ColorIcon {
                        name: "/ui/images/add.svg"
                        size: Style.bigIconSize
                        anchors.centerIn: parent
                        color: Style.tileOverlayColor
                    }
                }
            }

        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            enabled: root.editMode
            propagateComposedEvents: true
            preventStealing: fakeDragItem != null
            property var fakeDragItem: null
            property int fromIndex: -1
            property int editIndex: -1
            property int fakeDragOffsetX: 0
            property int fakeDragOffsetY: 0

            Timer {
                id: scrollTimer
                interval: 10
                repeat: true
                running: dragArea.fakeDragItem !== null

                property int scrollOffset: 0
                onTriggered: {
                    var mappedPos = dragArea.mapToItem(flickable, dragArea.mouseX, dragArea.mouseY)
                    var scrollPixels = 0
                    if (mappedPos.y + scrollOffset < 60) {
                        scrollPixels = Math.max(-2, -flickable.contentY)
                    } else if (mappedPos.y + scrollOffset > flickable.height - 60) {
                        scrollPixels = Math.min(2, flickable.contentHeight - flickable.height - flickable.contentY)
                    }
                    flickable.contentY += scrollPixels
                    scrollOffset += scrollPixels
                    dragArea.fakeDragItem.y += scrollPixels
                }
            }

            onClicked: {
                var ret = itemUnderMouse()
                if (ret.item) {
                    dragArea.editIndex = ret.index
                    // Let the click pass through
                    mouse.accepted = false
                } else if (itemContainsMouse(addTile)) {
                    mouse.accepted = false
                } else {
                    root.editMode = false
                }
            }

            onPressAndHold: {
                print("position", mouseX, mouseY)


                var draggedItem = null
                for (var i = 0; i < repeater.count; i++) {
                    var item = repeater.itemAt(i);
                    print("item coords:", item.x, item.y, item.width, item.height)
                    if (itemContainsMouse(item)) {
                        print("Yes!, Item at:", i)
                        fromIndex = i;
                        draggedItem = item;
                        break;
                    }
                }
                if (!draggedItem) {
                    return
                }

                var mappedCursor = dragArea.mapToItem(item, mouseX, mouseY)
                fakeDragOffsetX = mappedCursor.x
                fakeDragOffsetY = mappedCursor.y

                dragArea.fakeDragItem = dragItemComponent.createObject(dragArea,
                                                                  {
                                                                      x: mouseX - fakeDragOffsetX,
                                                                      y: mouseY - fakeDragOffsetY,
                                                                      draggedItem: draggedItem
                                                                  })
            }


            function itemUnderMouse() {
                var ret = {}
                for (var i = 0; i < repeater.count; i++) {
                    var item = repeater.itemAt(i);
                    if (itemContainsMouse(item)) {
                        ret.item = item;
                        ret.index = i
                        break;
                    }
                }
                return ret
            }

            function itemContainsMouse(item) {
                var mapped = dragArea.mapToItem(item, mouseX, mouseY)
                return mapped.x > 0 && mapped.x < item.width && mapped.y > 0 && mapped.y < item.height
            }

            onPositionChanged: {
                if (!fakeDragItem) {
                    return
                }
                scrollTimer.scrollOffset = 0;

                fakeDragItem.x = mouseX - fakeDragOffsetX
                fakeDragItem.y = mouseY - fakeDragOffsetY
                var itemUnderCursor = null
                var itemIndex = -1
                for (var i = 0; i < repeater.count; i++) {
                    var item = repeater.itemAt(i);
                    if (itemContainsMouse(item)) {
                        print("Yes!, Item at:", i)
                        itemUnderCursor = item;
                        itemIndex = i
                        break;
                    }
                }
                if (!itemUnderCursor) {
                    return
                }
                if (fromIndex === itemIndex) {
                    return
                }

                print("over item:", itemIndex)

                root.model.move(fromIndex, itemIndex)
                fromIndex = itemIndex

            }
            onReleased: {
                if (dragArea.fakeDragItem) {
                    dragArea.fakeDragItem.destroy();
                    dragArea.fakeDragItem = null
                    dragArea.fromIndex = -1
                }
            }
        }
    }

    EmptyViewPlaceholder {
        anchors { left: parent.left; right: parent.right; margins: Style.margins }
        anchors.verticalCenter: parent.verticalCenter
        visible: !engine.thingManager.fetchingData && root.model.count === 0 && !root.editMode
        title: qsTr("Dashboard is empty")
        text: qsTr("Start with adding a new item to this dashboard.")
        buttonText: qsTr("Add item")
        imageSource: "/ui/images/dashboard.svg"
        onButtonClicked: {
            root.addItem()
        }
    }

    Component {
        id: dragItemComponent
        Item {
            property Item draggedItem: null

            layer.enabled: true
            layer.effect: ShaderEffectSource {
                sourceItem: draggedItem
                live: true
            }

            height: draggedItem.height
            width: draggedItem.width
        }
    }

    Component {
        id: editDialogComponent

        NymeaDialog {
            id: editDialog
            standardButtons: Dialog.NoButton

            property DashboardItem dashboardItem: null
            property int index: -1


            ColumnLayout {
                Button {
                    text: qsTr("Remove")
                    Layout.fillWidth: true
                    onClicked: {
                        root.model.removeItem(editDialog.index)
                        editDialog.close()
                    }
                }
            }
        }
    }
}


