import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Nymea 1.0
import "../components"

Item {
    id: root
    Pane {
        anchors.fill: parent
        anchors.margins: app.margins / 2
        Material.elevation: 1

        Column {
            width: parent.width
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -app.iconSize
            spacing: app.margins
            ColorIcon {
                height: app.iconSize * 2
                width: height
                color: app.guhAccent
                anchors.horizontalCenter: parent.horizontalCenter
                name: interfaceToIcon(model.name)
            }

            Label {
                text: interfaceToString(model.name).toUpperCase()
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var page;
                switch (model.name) {
                case "light":
                    page = "LightsDeviceListPage.qml"
                    break;
                default:
                    page = "GenericDeviceListPage.qml"
                }
                if (model.name === "uncategorized") {
                    pageStack.push(Qt.resolvedUrl("../devicelistpages/" + page), {hiddenInterfaces: app.supportedInterfaces})
                } else {
                    pageStack.push(Qt.resolvedUrl("../devicelistpages/" + page), {shownInterfaces: [model.name]})
                }
            }
        }

        DevicesProxy {
            id: devicesProxy
            devices: Engine.deviceManager.devices
            shownInterfaces: [model.name]
        }
    }

    Item {
        id: inlineControlPane
        anchors { left: parent.left; bottom: parent.bottom; right: parent.right; margins: app.margins / 2 }
        height: app.iconSize + app.margins * 2
        Rectangle {
            anchors.fill: parent
            //                color: app.guhAccent
            color: "black"
            opacity: .05
        }

        Loader {
            id: inlineControlLoader
            anchors {
                fill: parent
                leftMargin: app.margins
                rightMargin: app.margins
                topMargin: app.margins / 2
                bottomMargin: app.margins / 2
            }
            sourceComponent: {
                switch (model.name) {
                case "sensor":
                case "weather":
                    return labelComponent;

                case "light":
                case "media":
                case "garagegate":
                case "blind":
                case "extendedblind":
                case "shutter":
                case "extendedshutter":
                case "awning":
                case "extendedawning":
                    return buttonComponent
                default:
                    console.warn("DevicesPageDelegate, inlineControl: Unhandled interface", model.name)
                }
            }
        }
    }

    Component {
        id: buttonComponent
        MouseArea {
            onClicked: {
                switch (model.name) {
                case "light":
                    if (devicesProxy.count == 1) {
                        var device = devicesProxy.get(0);
                        var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                        var stateType = deviceClass.stateTypes.findByName("power")
                        var actionType = deviceClass.actionTypes.findByName("power")
                        var params = [];
                        var param1 = {};
                        param1["paramTypeId"] = actionType.paramTypes.get(0).id;
                        param1["value"] = !device.states.getState(stateType.id).value;
                        params.push(param1)
                        Engine.deviceManager.executeAction(device.id, actionType.id, params)
                    } else {
                        for (var i = 0; i < devicesProxy.count; i++) {
                            var device = devicesProxy.get(i);
                            var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                            var actionType = deviceClass.actionTypes.findByName("power");

                            var params = [];
                            var param1 = {};
                            param1["paramTypeId"] = actionType.paramTypes.get(0).id;
                            param1["value"] = false;
                            params.push(param1)
                            Engine.deviceManager.executeAction(device.id, actionType.id, params)
                        }
                    }
                    break;
                case "media":
                    var device = devicesProxy.get(0)
                    var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                    var stateType = deviceClass.stateTypes.findByName("playbackStatus");
                    var state = device.states.getState(stateType.id)

                    var actionName
                    switch (state.value) {
                    case "PLAYING":
                        actionName = "pause";
                        break;
                    case "PAUSED":
                        actionName = "play";
                        break;
                    }
                    var actionTypeId = deviceClass.actionTypes.findByName(actionName).id;

                    print("executing", device, device.id, actionTypeId, actionName, deviceClass.actionTypes)

                    Engine.deviceManager.executeAction(device.id, actionTypeId)
                case "garagegate":
                case "shutter":
                case "extendedshutter":
                case "blind":
                case "extendedblind":
                case "awning":
                case "extendedawning":
                case "simpleclosable":
                    for (var i = 0; i < devicesProxy.count; i++) {
                        var device = devicesProxy.get(i);
                        var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                        var actionType = deviceClass.actionTypes.findByName("close");
                        Engine.deviceManager.executeAction(device.id, actionType.id)
                    }

                default:
                    console.warn("DevicesPageDelegate, inlineButtonControl clicked: Unhandled interface", model.name)
                }
            }

            ColumnLayout {
                anchors.fill: parent

                Label {
                    id: label
                    Layout.fillWidth: true
                    text: {
                        switch (model.name) {
                        case "media":
                            return devicesProxy.get(0).name;
                        case "light":
                            var count = 0;
                            for (var i = 0; i < devicesProxy.count; i++) {
                                var device = devicesProxy.get(i);
                                var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                                var stateType = deviceClass.stateTypes.findByName("power")
                                if (device.states.getState(stateType.id).value === true) {
                                    count++;
                                }
                            }
                            return count === 0 ? qsTr("All off") : qsTr("%1 on").arg(count)
                        case "garagegate":
                            var count = 0;
                            for (var i = 0; i < devicesProxy.count; i++) {
                                var device = devicesProxy.get(i);
                                var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                                var stateType = deviceClass.stateTypes.findByName("state");
                                if (device.states.getState(stateType.id).value !== "closed") {
                                    count++;
                                }
                            }
                            return count === 0 ? qsTr("All closed") : qsTr("%1 open").arg(count)
                        case "blind":
                        case "extendedblind":
                        case "awning":
                        case "extendedawning":
                        case "shutter":
                        case "extendedshutter":
                            return qsTr("%1 installed").arg(devicesProxy.count)
                        }
                        console.warn("DevicesPageDelegate, inlineButtonControl: Unhandled interface", model.name)
                    }
                    font.pixelSize: app.smallFont
                    elide: Text.ElideRight
                }
                ColorIcon {
                    id: icon
                    width: app.largeFont
                    height: width
                    color: app.guhAccent
                    Layout.alignment: Qt.AlignRight
                    name: {
                        switch (model.name) {
                        case "media":
                            var device = devicesProxy.get(0)
                            var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                            var stateType = deviceClass.stateTypes.findByName("playbackStatus");
                            var state = device.states.getState(stateType.id)
                            return state.value === "PLAYING" ? "../images/media-playback-pause.svg" :
                                                               state.value === "PAUSED" ? "../images/media-playback-start.svg" :
                                                                                          ""
                        case "light":
                            return "../images/system-shutdown.svg"
                        case "garagegate":
                        case "blind":
                        case "extendedblind":
                        case "awning":
                        case "extendedawning":
                        case "shutter":
                        case "extendedshutter":
                            return "../images/down.svg"
                        default:
                            console.warn("DevicesPageDelegate, inlineButtonControl image: Unhandled interface", model.name)
                        }
                    }
                }
            }
        }
    }

    Component {
        id: labelComponent
        ColumnLayout {
            property var device: devicesProxy.get(0)
            property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
            property var state: deviceClass ? device.states.getState(deviceClass.stateTypes.findByName("temperature").id) : null

            Label {
                text: parent.device.name
                font.pixelSize: app.smallFont
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Label {
                font.pixelSize: app.largeFont
                color: app.guhAccent
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: {
                    if (devicesProxy.count > 0) {
                        var stateName;
                        //                                switch (model.name) {
                        //                                case "sensor":
                        //                                }
                        return  parent.state.value + "°C";
                    }
                }
            }
        }
    }
}
