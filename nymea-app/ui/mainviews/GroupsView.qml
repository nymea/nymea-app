import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import QtQuick.Controls.Material 2.2
import "../components"

MouseArea {
    id: root
    preventStealing: true
    onWheel: wheel.accepted = true

    readonly property int count: groupsGridView.count

    GridView {
        id: groupsGridView
        anchors.fill: parent
        anchors.margins: app.margins / 2


        readonly property int minTileWidth: 180
        readonly property int minTileHeight: 180
        readonly property int tilesPerRow: root.width / minTileWidth

        model: TagListModel {
            tagsProxy: TagsProxyModel {
                tags: engine.tagsManager.tags
                filterTagId: "group-.*"
            }
        }
        cellWidth: width / tilesPerRow
        cellHeight: cellWidth

        delegate: Item {
            id: groupDelegate
            width: groupsGridView.cellWidth
            height: groupsGridView.cellHeight

            Pane {
                anchors.fill: parent
                anchors.margins: app.margins / 2
                Material.elevation: 2
                padding: 0

                DevicesProxy {
                    id: devicesInGroup
                    engine: _engine
                    filterTagId: model.tagId
                    filterTagValue: model.value
                }

                InterfacesProxy {
                    id: controlsInGroup
                    shownInterfaces: ["light", "simpleclosable", "mediacontroller"]
                    devicesProxyFilter: devicesInGroup
                    showStates: true
                    showActions: true
                }
                InterfacesProxy {
                    id: sensorsInGroup
                    shownInterfaces: ["temperaturesensor", "lightsensor", "presencesensor"]
                    devicesProxyFilter: devicesInGroup
                    showStates: true
                }

                contentItem: ItemDelegate {
                    leftPadding: 0
                    topPadding: 0
                    rightPadding: 0
                    bottomPadding: 0

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("../grouping/GroupPage.qml"), {groupTag: model.tagId})
                    }

                    contentItem: ColumnLayout {
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            color: Qt.rgba(app.foregroundColor.r, app.foregroundColor.g, app.foregroundColor.b, .05)
                            Label {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                anchors { leftMargin: app.margins; rightMargin: app.margins }
                                text: model.tagId.substring(6)
                                elide: Text.ElideRight
                            }
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            ColorIcon {
                                anchors.centerIn: parent
                                height: app.iconSize * 2
                                width: height
                                visible: controlsInGroup.count == 0
                                color: app.accentColor
                                name: "../images/view-grid-symbolic.svg"
                            }

                            ColumnLayout {
                                anchors.fill: parent

                                Repeater {
                                    model: Math.min(controlsInGroup.count, parent.height / 50)
                                    delegate: Loader {
                                        id: controlLoader
                                        Layout.fillWidth: true
                                        Layout.leftMargin: app.margins / 2
                                        Layout.rightMargin: app.margins / 2
                                        property string interfaceName: controlsInGroup.get(index).name
                                        sourceComponent: {
                                            switch (interfaceName) {
                                            case "simpleclosable":
                                                return closableDelegate
                                            case "light":
                                                return lightDelegate
                                            case "mediacontroller":
                                                return mediaControllerDelegate
                                            }
                                        }
                                        Binding {
                                            target: controlLoader.item
                                            property: "devices"
                                            value: devicesInGroup
                                        }
                                    }
                                }
                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                }
                            }

                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: app.iconSize * 1.2
                            color: Qt.rgba(app.foregroundColor.r, app.foregroundColor.g, app.foregroundColor.b, 0.05)

                            RowLayout {
                                anchors.fill: parent

                                Repeater {
                                    model: sensorsInGroup
                                    delegate: Row {
                                        height: parent.height

                                        ColorIcon {
                                            height: app.iconSize * .8
                                            width: height
                                            name: app.interfaceToIcon(model.name)
                                            color: app.interfaceToColor(model.name)
                                        }
                                        DevicesProxy {
                                            id: innerProxy
                                            engine: _engine
                                            parentProxy: devicesInGroup
                                            shownInterfaces: [model.name]
                                        }

                                        Led {
                                            visible: ["presencesensor"].indexOf(model.name) >= 0
                                            state: {
                                                var stateName = null
                                                switch (model.name) {
                                                case "presencesensor":
                                                    stateName = "isPresent"
                                                    break;
                                                }
                                                if (!stateName) {
                                                    return "off";
                                                }
                                                var ret = false;
                                                for (var i = 0; i < innerProxy.count; i++) {
                                                    ret |= innerProxy.get(i).states.getState(innerProxy.get(i).deviceClass.stateTypes.findByName(stateName).id).value
                                                }
                                                return ret ? "on" : "off";
                                            }
                                        }

                                        Label {
                                            height: parent.height
                                            verticalAlignment: Text.AlignVCenter
                                            text: {
                                                var stateName = null;
                                                switch (model.name) {
                                                case "temperaturesensor":
                                                    stateName = "temperature";
                                                    break;
                                                case "lightsensor":
                                                    stateName = "lightIntensity"
                                                    break;
                                                }
                                                if (!stateName) {
                                                    return "";
                                                }

                                                var ret = 0
                                                for (var i = 0; i < innerProxy.count; i++) {
                                                    ret += innerProxy.get(i).states.getState(innerProxy.get(i).deviceClass.stateTypes.findByName(stateName).id).value
                                                }
                                                return (ret / innerProxy.count).toFixed(1)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: lightDelegate
        RowLayout {
            property var devices

            DevicesProxy {
                id: lights
                engine: _engine
                parentProxy: devices
                shownInterfaces: ["light"]
            }

            DevicesProxy {
                id: dimmableLights
                engine: _engine
                parentProxy: devices
                shownInterfaces: ["dimmablelight"]
            }

            Label {
                text: qsTr("Lighting")
                Layout.fillWidth: true
                Layout.preferredHeight: slider.height
                verticalAlignment: Text.AlignVCenter
                visible: dimmableLights.count == 0
            }

            Slider {
                id: slider
                from: 0
                to: 100
                visible: dimmableLights.count > 0
                value: {
                    var median = 0
                    var count = 0;
                    for (var i = 0; i < dimmableLights.count; i++) {
                        var device = dimmableLights.get(i);
                        var brightnessId = device.deviceClass.stateTypes.findByName("brightness").id
                        median += device.states.getState(brightnessId).value
                        count++
                    }
                    return median / count;
                }

                Layout.fillWidth: true
                onPressedChanged: {
                    for (var i = 0; i < dimmableLights.count; i++) {
                        var device = dimmableLights.get(i);
                        var brightnessId = device.deviceClass.actionTypes.findByName("brightness").id
                        engine.deviceManager.executeAction(device.id, brightnessId, [{paramTypeId: brightnessId, value: value}]);
                    }
                }
            }
            ColorIcon {
                Layout.preferredHeight: app.iconSize
                Layout.preferredWidth: app.iconSize
                name: isOn ? "../images/light-on.svg" : "../images/light-off.svg"
                color: isOn ? app.accentColor : keyColor

                property bool isOn: {
                    for (var i = 0; i < lights.count; i++) {
                        var device = lights.get(i)
                        var powerId = device.deviceClass.stateTypes.findByName("power").id
                        if (device.states.getState(powerId).value === true) {
                            return true
                        }
                    }
                    return false;
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        for (var i = 0; i < lights.count; i++) {
                            var device = lights.get(i)
                            var powerId = device.deviceClass.stateTypes.findByName("power").id
                            engine.deviceManager.executeAction(device.id, powerId, [{paramTypeId: powerId, value: !parent.isOn}])
                        }
                    }
                }
            }
        }
    }

    Component {
        id: closableDelegate

        RowLayout {

            property var devices: null
            DevicesProxy {
                id: simpleClosables
                engine: _engine
                parentProxy: devices
                shownInterfaces: ["simpleclosable"]
            }
            DevicesProxy {
                id: closables
                engine: _engine
                parentProxy: devices
                shownInterfaces: ["closable"]
            }

            ItemDelegate {
                Layout.fillWidth: true
                Layout.preferredHeight: app.iconSize

                ColorIcon {
                    height: parent.height
                    width: height
                    anchors.centerIn: parent
                    name: Qt.resolvedUrl("../images/up.svg")
                }
                onClicked: {
                    for (var i = 0; i < simpleClosables.count; i++) {
                        var device = simpleClosables.get(i)
                        var openId = device.deviceClass.actionTypes.findByName("open").id
                        engine.deviceManager.executeAction(device.id, openId)
                    }
                }
            }
            ItemDelegate {
                Layout.fillWidth: true
                Layout.preferredHeight: app.iconSize
                visible: closables.count > 0

                ColorIcon {
                    height: parent.height
                    width: height
                    anchors.centerIn: parent
                    name: Qt.resolvedUrl("../images/media-playback-stop.svg")
                }
                onClicked: {
                    for (var i = 0; i < closables.count; i++) {
                        var device = closables.get(i)
                        var openId = device.deviceClass.actionTypes.findByName("stop").id
                        engine.deviceManager.executeAction(device.id, openId)
                    }
                }
            }
            ItemDelegate {
                Layout.fillWidth: true
                Layout.preferredHeight: app.iconSize

                ColorIcon {
                    height: parent.height
                    width: height
                    anchors.centerIn: parent
                    name: Qt.resolvedUrl("../images/down.svg")
                }
                onClicked: {
                    for (var i = 0; i < simpleClosables.count; i++) {
                        var device = simpleClosables.get(i)
                        var closeId = device.deviceClass.actionTypes.findByName("close").id
                        engine.deviceManager.executeAction(device.id, closeId)
                    }
                }
            }
        }
    }

    Component {
        id: mediaControllerDelegate
        MediaControls {
            property var devices: null
            DevicesProxy {
                id: mediaControllers
                engine: _engine
                parentProxy: devices
                shownInterfaces: ["mediacontroller"]
            }

            device: mediaControllers.parentProxy ? mediaControllers.get(0) : null
        }
    }
}
