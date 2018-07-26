import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Nymea 1.0
import "../components"

MainPageTile {
    id: root
    text: interfaceToString(model.name).toUpperCase()
    iconName: interfaceToIcon(model.name)
    iconColor: app.guhAccent
    disconnected: devicesSubProxyConnectables.count > 0
    batteryCritical: devicesSubProxyBattery.count > 0

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

    DevicesProxy {
        id: devicesProxy
        devices: Engine.deviceManager.devices
        shownInterfaces: [model.name]
    }

    DevicesProxy {
        id: devicesSubProxyConnectables
        devices: devicesProxy
        filterDisconnected: true
    }
    DevicesProxy {
        id: devicesSubProxyBattery
        devices: devicesProxy
        filterBatteryCritical: true
    }

    contentItem: Loader {
        id: inlineControlLoader
        anchors {
            fill: parent
            leftMargin: app.margins / 2
            rightMargin: app.margins / 2
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

    Component {
        id: buttonComponent
        ColumnLayout {
            spacing: 0

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
            ItemDelegate {
                Layout.preferredHeight: app.iconSize
                Layout.preferredWidth: height
                Layout.alignment: Qt.AlignRight

                ColorIcon {
                    id: icon
                    width: app.iconSize
                    height: width
                    color: app.guhAccent

                    name: {
                        switch (model.name) {
                        case "media":
                            var device = devicesProxy.get(0)
                            var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                            var stateType = deviceClass.stateTypes.findByName("playbackStatus");
                            var state = device.states.getState(stateType.id)
                            return state.value === "Playing" ? "../images/media-playback-pause.svg" :
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
                        case "Playing":
                            actionName = "pause";
                            break;
                        case "Paused":
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

            }

        }
    }

    Component {
        id: labelComponent
        ColumnLayout {
            spacing: 0

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
