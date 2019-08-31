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
    iconColor: app.accentColor
    disconnected: devicesSubProxyConnectables.count > 0
    batteryCritical: devicesSubProxyBattery.count > 0

    backgroundImage: inlineControlLoader.item && inlineControlLoader.item.hasOwnProperty("backgroundImage") ? inlineControlLoader.item.backgroundImage : ""

    onClicked: {
        var page;
        switch (model.name) {
        case "heating":
        case "sensor":
            page = "SensorsDeviceListPage.qml"
            break;
        case "weather":
            page = "WeatherDeviceListPage.qml"
            break;
        case "light":
            page = "LightsDeviceListPage.qml"
            break;
        case "smartmeter":
            page ="SmartMeterDeviceListPage.qml";
            break;
        case "garagegate":
            page = "GarageDeviceListPage.qml";
            break;
        case "awning":
        case "extendedAwning":
            page = "AwningDeviceListPage.qml";
            break;
        case "blind":
        case "extendedBlind":
            page = "ShutterDeviceListPage.qml";
            break;
        case "shutter":
        case "extendedShutter":
            page = "ShutterDeviceListPage.qml";
            break;
        case "powersocket":
            page = "PowerSocketsDeviceListPage.qml";
            break;
        case "media":
            page = "MediaDeviceListPage.qml";
            break;
        default:
            page = "GenericDeviceListPage.qml"
        }
        if (model.name === "uncategorized") {
            pageStack.push(Qt.resolvedUrl("../devicelistpages/" + page), {hiddenInterfaces: app.supportedInterfaces})
        } else {
            print("<entering for shown interfaces:", model.name)
            pageStack.push(Qt.resolvedUrl("../devicelistpages/" + page), {shownInterfaces: [model.name]})
        }
    }

    DevicesProxy {
        id: devicesProxy
        engine: _engine
        shownInterfaces: [model.name]
    }

    DevicesProxy {
        id: devicesSubProxyConnectables
        engine: _engine
        parentProxy: devicesProxy
        filterDisconnected: true
    }
    DevicesProxy {
        id: devicesSubProxyBattery
        engine: _engine
        parentProxy: devicesProxy
        filterBatteryCritical: true
    }

    property int currentDeviceIndex: 0
    readonly property Device currentDevice: devicesProxy.get(currentDeviceIndex)

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
            case "smartmeter":
            case "smartmeterconsumer":
            case "smartmeterproducer":
            case "extendedsmartmeterconsumer":
            case "extendedsmartmeterproducer":
            case "heating":
                return sensorComponent;
//                return labelComponent;

            case "light":
            case "garagegate":
            case "blind":
            case "extendedblind":
            case "shutter":
            case "extendedshutter":
            case "awning":
            case "extendedawning":
            case "powersocket":
                return buttonComponent
            case "media":
                return mediaControlComponent
            default:
                console.warn("DevicesPageDelegate, inlineControl: Unhandled interface", model.name)
            }
        }
    }

    Component {
        id: mediaControlComponent
        RowLayout {
            id: inlineMediaControl

            property string backgroundImage: artworkState ? artworkState.value : ""

            property int currentDeviceIndex: 0
            readonly property Device currentDevice: devicesProxy.get(currentDeviceIndex)
            readonly property StateType playbackStateType: currentDevice.deviceClass.stateTypes.findByName("playbackStatus")
            readonly property State playbackState: currentDevice.states.getState(playbackStateType.id)
            readonly property StateType artworkStateType: currentDevice.deviceClass.stateTypes.findByName("artwork")
            readonly property State artworkState: artworkStateType ? currentDevice.states.getState(artworkStateType.id) : null

            Component.onCompleted: {
                for (var i = 0; i < devicesProxy.count; i++) {
                    var d = devicesProxy.get(i);
                    var st = d.deviceClass.stateTypes.findByName("playbackStatus")
                    var s = d.states.getState(st.id)
                    s.valueChanged.connect(function() {updateTile()})
                }
                updateTile();
            }

            function updateTile() {
                var playingIndex = -1;
                var pausedIndex = -1;
                for (var i = 0; i < devicesProxy.count; i++) {
                    var d = devicesProxy.get(i);
                    var st = d.deviceClass.stateTypes.findByName("playbackStatus");
                    if (!st) continue;
                    var s = d.states.getState(st.id);
                    if (playingIndex === -1 && s.value === "Playing") {
                        playingIndex = i;
                    } else if (pausedIndex === -1 && s.value === "Paused") {
                        pausedIndex = -i;
                    }
                }
                if (playingIndex !== -1) {
                    currentDeviceIndex = playingIndex;
                } else if (pausedIndex !== -1) {
                    currentDeviceIndex = pausedIndex;
                }
            }

            MediaControls {
                iconSize: app.iconSize * 1.2
                device: inlineMediaControl.currentDevice
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
                visible: text != ""
                text: {
                    switch (model.name) {
                    case "media":
                        return devicesProxy.get(0).name;
                    case "light":
                    case "powersocket":
                        var count = 0;
                        for (var i = 0; i < devicesProxy.count; i++) {
                            var device = devicesProxy.get(i);
                            var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
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
                            var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
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
                        return ""
                        //                        return qsTr("%1 installed").arg(devicesProxy.count)
                    }
                    console.warn("DevicesPageDelegate, inlineButtonControl: Unhandled interface", model.name)
                }
                font.pixelSize: app.smallFont
                elide: Text.ElideRight
            }
            RowLayout {
//                Layout.alignment: Qt.AlignRight
                Layout.fillWidth: true
                spacing: (parent.width - app.iconSize * 3) / 2

                ItemDelegate {
                    Layout.preferredHeight: app.iconSize
                    Layout.preferredWidth: height

                    ColorIcon {
                        id: leftIcon
                        width: app.iconSize
                        height: width
                        color: app.accentColor

                        name: {
                            switch (model.name) {
                            case "media":
                            case "light":
                                return ""
                            case "garagegate":
                            case "blind":
                            case "extendedblind":
                            case "awning":
                            case "extendedawning":
                            case "shutter":
                            case "extendedshutter":
                                return "../images/up.svg"
                            default:
                                console.warn("DevicesPageDelegate, inlineButtonControl image: Unhandled interface", model.name)
                            }
                            return ""
                        }
                    }

                    onClicked: {
                        switch (model.name) {
                        case "light":
                        case "media":
                            break;
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
                                var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                                var actionType = deviceClass.actionTypes.findByName("open");
                                engine.deviceManager.executeAction(device.id, actionType.id)
                            }
                            break;
                        default:
                            console.warn("DevicesPageDelegate, inlineButtonControl clicked: Unhandled interface", model.name)
                        }
                    }
                }

                ItemDelegate {
                    Layout.preferredHeight: app.iconSize
                    Layout.preferredWidth: height
                    ColorIcon {
                        id: centerIcon
                        width: app.iconSize
                        height: width
                        color: app.accentColor

                        name: {
                            switch (model.name) {
                            case "media":
                            case "light":
                                return ""
                            case "garagegate":
                            case "blind":
                            case "extendedblind":
                            case "awning":
                            case "extendedawning":
                            case "shutter":
                            case "extendedshutter":
                                return "../images/media-playback-stop.svg"
                            default:
                                console.warn("DevicesPageDelegate, inlineButtonControl image: Unhandled interface", model.name)
                            }
                            return "";
                        }
                    }

                    onClicked: {
                        switch (model.name) {
                        case "light":
                        case "media":
                            break;
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
                                var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                                var actionType = deviceClass.actionTypes.findByName("stop");
                                engine.deviceManager.executeAction(device.id, actionType.id)
                            }

                        default:
                            console.warn("DevicesPageDelegate, inlineButtonControl clicked: Unhandled interface", model.name)
                        }
                    }
                }

                ItemDelegate {
                    Layout.preferredHeight: app.iconSize
                    Layout.preferredWidth: height

                    ColorIcon {
                        id: icon
                        width: app.iconSize
                        height: width
                        color: app.accentColor

                        name: {
                            switch (model.name) {
                            case "media":
                                var device = devicesProxy.get(0)
                                var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                                var stateType = deviceClass.stateTypes.findByName("playbackStatus");
                                var state = device.states.getState(stateType.id)
                                return state.value === "Playing" ? "../images/media-playback-pause.svg" :
                                                                   state.value === "Paused" ? "../images/media-playback-start.svg" :
                                                                                              ""
                            case "light":
                            case "powersocket":
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
                        case "powersocket":
                            var allOff = true;
                            for (var i = 0; i < devicesProxy.count; i++) {
                                var device = devicesProxy.get(i);
                                if (device.states.getState(device.deviceClass.stateTypes.findByName("power").id).value === true) {
                                    allOff = false;
                                    break;
                                }
                            }

                            for (var i = 0; i < devicesProxy.count; i++) {
                                var device = devicesProxy.get(i);
                                var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                                var actionType = deviceClass.actionTypes.findByName("power");

                                var params = [];
                                var param1 = {};
                                param1["paramTypeId"] = actionType.paramTypes.get(0).id;
                                param1["value"] = allOff ? true : false;
                                params.push(param1)
                                engine.deviceManager.executeAction(device.id, actionType.id, params)
                            }
                            break;
                        case "media":
                            var device = devicesProxy.get(0)
                            var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
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

                            engine.deviceManager.executeAction(device.id, actionTypeId)
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
                                var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                                var actionType = deviceClass.actionTypes.findByName("close");
                                engine.deviceManager.executeAction(device.id, actionType.id)
                            }

                        default:
                            console.warn("DevicesPageDelegate, inlineButtonControl clicked: Unhandled interface", model.name)
                        }
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
            property var deviceClass: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null

            Label {
                text: parent.device.name
                font.pixelSize: app.smallFont
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }
    }

    Component {
        id: sensorComponent
        MouseArea {
            id: sensorsRoot
            property int currentDevice: 0

            property Device device: devicesProxy.get(currentDevice)
            property DeviceClass deviceClass: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null

            property var shownSensors: findSensors(deviceClass)
            property int currentSensor: 0

            ListModel {
                id: supportedSensors
                ListElement { ifaceName: "temperaturesensor"; stateName: "temperature" }
                ListElement { ifaceName: "weather"; stateName: "temperature" }
                ListElement { ifaceName: "humiditysensor"; stateName: "humidity" }
                ListElement { ifaceName: "moisturesensor"; stateName: "moisture" }
                ListElement { ifaceName: "pressuresensor"; stateName: "pressure" }
                ListElement { ifaceName: "daylightsensor"; stateName: "daylight" }
                ListElement { ifaceName: "presencesensor"; stateName: "isPresent" }
                ListElement { ifaceName: "closablesensor"; stateName: "closed" }
                ListElement { ifaceName: "lightsensor"; stateName: "lightIntensity" }
                ListElement { ifaceName: "co2sensor"; stateName: "co2" }
                ListElement { ifaceName: "conductivity"; stateName: "conductivity" }
                ListElement { ifaceName: "noisesensor"; stateName: "noise" }
                ListElement { ifaceName: "smartmeterconsumer"; stateName: "totalEnergyConsumed" }
                ListElement { ifaceName: "smartmeterproducer"; stateName: "totalEnergyProduced" }
                ListElement { ifaceName: "thermostat"; stateName: "targetTemperature" }
                ListElement { ifaceName: "heating"; stateName: "power" }
                ListElement { ifaceName: "extendedHeating"; stateName: "percentage" }
            }
            function findSensors(deviceClass) {
                var ret = []
                for (var i = 0; i < supportedSensors.count; i++) {
                    if (deviceClass.interfaces.indexOf(supportedSensors.get(i).ifaceName) >= 0) {
                        ret.push({ifaceName: supportedSensors.get(i).ifaceName, stateName: supportedSensors.get(i).stateName})
                    }
                }
                return ret;
            }

            property StateType shownStateType: shownSensors.length > currentSensor && currentSensor >= 0
                                               ? deviceClass.stateTypes.findByName(shownSensors[currentSensor].stateName)
                                               : null

            function nextSensor() {
                var newSensorIndex = sensorsRoot.currentSensor + 1;
                if (newSensorIndex > sensorsRoot.shownSensors.length - 1) {
                    var newDeviceIndex = (sensorsRoot.currentDevice + 1) % devicesProxy.count;
                    newSensorIndex = 0;
                    sensorsRoot.currentDevice = newDeviceIndex;
                }
                sensorsRoot.currentSensor = newSensorIndex;
            }

            onClicked: {
                nextSensorAnimation.start()
                timer.restart()
            }

            SequentialAnimation {
                id: nextSensorAnimation
                NumberAnimation { target: sensorsRoot; property: "opacity"; from: 1; to: 0; duration: 500 }
                ScriptAction { script: { nextSensor(); } }
                NumberAnimation { target: sensorsRoot; property: "opacity"; from: 0; to: 1; duration: 500 }
            }
            Timer {
                id: timer
                interval: 10000
                repeat: true
                running: sensorsRoot.shownSensors.length > 1 || devicesProxy.count > 1
                onTriggered: nextSensorAnimation.start()
            }

            RowLayout {
                anchors.fill: parent

                ColorIcon {
                    Layout.preferredHeight: app.iconSize
                    Layout.preferredWidth: app.iconSize
                    name: sensorsRoot.currentSensor >= 0 && sensorsRoot.shownSensors.length > sensorsRoot.currentSensor ? app.interfaceToIcon(sensorsRoot.shownSensors[sensorsRoot.currentSensor].ifaceName) : ""
                    color: sensorsRoot.currentSensor >= 0 && sensorsRoot.shownSensors.length > sensorsRoot.currentSensor ? app.interfaceToColor(sensorsRoot.shownSensors[sensorsRoot.currentSensor].ifaceName) : keyColor
                }

                ColumnLayout {
                    Label {
                        text: sensorsRoot.device.name
                        font.pixelSize: app.smallFont
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Label {
                        text: sensorsRoot.shownStateType
                              ? Math.round(sensorsRoot.device.states.getState(shownStateType.id).value * 100) / 100 + " " + sensorsRoot.shownStateType.unitString
                              : ""
    //                    font.pixelSize: app.smallFont
                        Layout.fillWidth: true
                        visible: sensorsRoot.shownStateType && sensorsRoot.shownStateType.type.toLowerCase() !== "bool"
                        elide: Text.ElideRight
                    }
                    Led {
                        Layout.preferredHeight: app.iconSize * .5
                        Layout.preferredWidth: height
                        state: sensorsRoot.shownStateType && sensorsRoot.device.states.getState(sensorsRoot.shownStateType.id).value === true ? "on" : "off"
                        visible: sensorsRoot.shownStateType && sensorsRoot.shownStateType.type.toLowerCase() === "bool"
                    }
                }
            }
        }

    }
}
