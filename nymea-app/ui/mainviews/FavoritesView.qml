import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Nymea 1.0
import "../components"

Item {
    id: root

    property bool editMode: false
    readonly property int count: tagsProxy.count

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
        delegate: MainPageTile {
            id: delegateRoot
            width: gridView.cellWidth
            height: gridView.cellHeight
            text: device.name.toUpperCase()
            iconName: app.interfacesToIcon(deviceClass.interfaces)
            iconColor: app.accentColor
            visible: !fakeDragItem.visible || fakeDragItem.deviceId !== device.id
            batteryCritical: batteryCriticalState && batteryCriticalState.value === true
            disconnected: connectedState && connectedState.value === false

            property var modelIndex: index

            property string deviceId: model.deviceId
            property string ruleId: model.ruleId
            readonly property var device: engine.deviceManager.devices.getDevice(deviceId)
            readonly property var deviceClass: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
            readonly property var connectedState: deviceClass.interfaces.indexOf("connectable") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("connected").id) : null
            readonly property var batteryCriticalState: deviceClass.interfaces.indexOf("battery") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("batteryCritical").id) : null

            onClicked: pageStack.push(Qt.resolvedUrl("../devicepages/" + app.interfaceListToDevicePage(deviceClass.interfaces)), {device: device})

            onPressAndHold: root.editMode = true

            contentItem: Loader {
                id: loader
                anchors.fill: parent
                sourceComponent: {
                    if (delegateRoot.deviceClass.interfaces.indexOf("closable") >= 0) {
                        return closableComponent;
                    }
                    if (delegateRoot.deviceClass.interfaces.indexOf("light") >= 0) {
                        return lightsComponent;
                    }
                    if (delegateRoot.deviceClass.interfaces.indexOf("sensor") >= 0) {
                        return sensorsComponent;
                    }
                    if (delegateRoot.deviceClass.interfaces.indexOf("weather") >= 0) {
                        return sensorsComponent;
                    }
                }
                Binding { target: loader.item ? loader.item : null; property: "deviceClass"; value: delegateRoot.deviceClass }
                Binding { target: loader.item ? loader.item : null; property: "device"; value: delegateRoot.device }
            }

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

    Component {
        id: lightsComponent
        RowLayout {
            property var device: null
            property var deviceClass: null

            ItemDelegate {
                Layout.preferredWidth: app.iconSize
                Layout.preferredHeight: app.iconSize
                Layout.leftMargin: app.margins / 2
                Layout.alignment: Qt.AlignVCenter
                padding: 0; topPadding: 0; bottomPadding: 0
                contentItem: ColorIcon {
                    name: "../images/light-off.svg"
                    color: app.accentColor
                }
                onClicked: {
                    var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                    var actionType = deviceClass.actionTypes.findByName("power");
                    var params = [];
                    var powerParam = {}
                    powerParam["paramTypeId"] = actionType.paramTypes.get(0).id;
                    powerParam["value"] = false;
                    params.push(powerParam)
                    engine.deviceManager.executeAction(device.id, actionType.id, params);
                }
            }

            ThrottledSlider {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                visible: deviceClass.interfaces.indexOf("dimmablelight") >= 0
                readonly property var brightnessStateType: deviceClass.stateTypes.findByName("brightness");
                readonly property var brightnessState: device.states.getState(brightnessStateType.id)
                from: 0
                to: 100
                value: brightnessState.value
                onMoved: {
                    var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                    var actionType = deviceClass.actionTypes.findByName("brightness");
                    var params = [];
                    var powerParam = {}
                    powerParam["paramTypeId"] = actionType.paramTypes.get(0).id;
                    powerParam["value"] = value;
                    params.push(powerParam)
                    engine.deviceManager.executeAction(device.id, actionType.id, params);
                }
            }

            ItemDelegate {
                Layout.preferredWidth: app.iconSize
                Layout.preferredHeight: width
                Layout.rightMargin: app.margins / 2
                Layout.alignment: Qt.AlignVCenter
                padding: 0; topPadding: 0; bottomPadding: 0
                contentItem: ColorIcon {
                    name: "../images/light-on.svg"
                    color: app.accentColor
                }
                onClicked: {
                    var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                    var actionType = deviceClass.actionTypes.findByName("power");
                    var params = [];
                    var powerParam = {}
                    powerParam["paramTypeId"] = actionType.paramTypes.get(0).id;
                    powerParam["value"] = true;
                    params.push(powerParam)
                    engine.deviceManager.executeAction(device.id, actionType.id, params);
                }
            }
        }
    }

    Component {
        id: sensorsComponent
        RowLayout {
            id: sensorsRoot
            property var device: null
            property var deviceClass: null
            spacing: 0

            property var shownInterfaces: []
            property int currentStateIndex: -1
            property var currentStateType: deviceClass ? deviceClass.stateTypes.findByName(shownInterfaces[currentStateIndex].state) : null
            property var currentState: currentStateType ? device.states.getState(currentStateType.id) : null

            onDeviceClassChanged:  {
                if (deviceClass == null) {
                    return;
                }

                var tmp = []
                if (deviceClass.interfaces.indexOf("temperaturesensor") >= 0) {
                    tmp.push({iface: "temperaturesensor", state: "temperature"});
                }
                if (deviceClass.interfaces.indexOf("humiditysensor") >= 0) {
                    tmp.push({iface: "humiditysensor", state: "humidity"});
                }
                if (deviceClass.interfaces.indexOf("moisturesensor") >= 0) {
                    tmp.push({iface: "moisturesensor", state: "moisture"});
                }
                if (deviceClass.interfaces.indexOf("pressuresensor") >= 0) {
                    tmp.push({iface: "pressuresensor", state: "pressure"});
                }
                if (deviceClass.interfaces.indexOf("lightsensor") >= 0) {
                    tmp.push({iface: "lightsensor", state: "lightIntensity"});
                }
                if (deviceClass.interfaces.indexOf("conductivitysensor") >= 0) {
                    tmp.push({iface: "conductivitysensor", state: "conductivity"});
                }
                if (deviceClass.interfaces.indexOf("noisesensor") >= 0) {
                    tmp.push({iface: "noisesensor", state: "noise"});
                }
                if (deviceClass.interfaces.indexOf("co2sensor") >= 0) {
                    tmp.push({iface: "co2sensor", state: "co2"});
                }
                if (deviceClass.interfaces.indexOf("weather") >= 0) {
                    tmp.push({iface: "temperaturesensor", state: "temperature"});
                    tmp.push({iface: "humiditysensor", state: "humidity"});
                    tmp.push({iface: "pressuresensor", state: "pressure"});
                }

                shownInterfaces = tmp
                currentStateIndex = 0
            }

            ItemDelegate {
                Layout.preferredWidth: app.iconSize
                Layout.preferredHeight: width
                Layout.leftMargin: app.margins / 2
                Layout.alignment: Qt.AlignVCenter
                padding: 0; topPadding: 0; bottomPadding: 0
                visible: sensorsRoot.shownInterfaces.length > 1
                contentItem: ColorIcon {
                    name: "../images/back.svg"
                }
                onClicked: {
                    var newIndex = sensorsRoot.currentStateIndex - 1;
                    if (newIndex < 0) newIndex = sensorsRoot.shownInterfaces.length - 1
                    sensorsRoot.currentStateIndex = newIndex;
                }
            }

            ColorIcon {
                Layout.preferredWidth: app.iconSize
                Layout.preferredHeight: width
                Layout.alignment: Qt.AlignVCenter
                color: app.interfaceToColor(sensorsRoot.shownInterfaces[sensorsRoot.currentStateIndex].iface)
                name: app.interfaceToIcon(sensorsRoot.shownInterfaces[sensorsRoot.currentStateIndex].iface)
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                    text: sensorsRoot.currentStateType.unitString
                    font.pixelSize: app.smallFont
                    color: app.accentColor
                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                    text: sensorsRoot.currentState.value// + " " + sensorsRoot.currentStateType.unitString
                    color: app.accentColor
                }
            }

            ItemDelegate {
                Layout.preferredWidth: app.iconSize
                Layout.preferredHeight: width
                Layout.rightMargin: app.margins / 2
                Layout.alignment: Qt.AlignVCenter
                padding: 0; topPadding: 0; bottomPadding: 0
                visible: sensorsRoot.shownInterfaces.length > 1
                contentItem: ColorIcon {
                    name: "../images/next.svg"
                }
                onClicked: {
                    var newIndex = sensorsRoot.currentStateIndex + 1;
                    if (newIndex >= sensorsRoot.shownInterfaces.length) newIndex = 0;
                    sensorsRoot.currentStateIndex = newIndex;
                }
            }

        }
    }

    Component {
        id: closableComponent
        RowLayout {
            property var device: null
            property var deviceClass: null

            ItemDelegate {
                Layout.preferredWidth: app.iconSize
                Layout.preferredHeight: width
                Layout.leftMargin: app.margins / 2
                Layout.alignment: Qt.AlignVCenter
                padding: 0; topPadding: 0; bottomPadding: 0
                contentItem: ColorIcon {
                    name: "../images/up.svg"
                    color: app.accentColor
                }
                onClicked: {
                    var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                    var actionType = deviceClass.actionTypes.findByName("open");
                    engine.deviceManager.executeAction(device.id, actionType.id);
                }
            }

            Slider {
                id: closableSlider
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                visible: deviceClass.interfaces.indexOf("extendedclosable") >= 0
                readonly property var percentageStateType: deviceClass.stateTypes.findByName("percentage");
                readonly property var percentateState: device.states.getState(percentageStateType.id)
                from: 0
                to: 100
                value: percentateState.value
            }
            Item {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                visible: !closableSlider.visible
            }

            ItemDelegate {
                Layout.preferredWidth: app.iconSize
                Layout.preferredHeight: width
                Layout.rightMargin: app.margins / 2
                Layout.alignment: Qt.AlignVCenter
                padding: 0; topPadding: 0; bottomPadding: 0
                contentItem: ColorIcon {
                    name: "../images/down.svg"
                    color: app.accentColor
                }
                onClicked: {
                    var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                    var actionType = deviceClass.actionTypes.findByName("close");
                    engine.deviceManager.executeAction(device.id, actionType.id);
                }
            }
        }
    }
}
