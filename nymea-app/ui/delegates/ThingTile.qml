import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Nymea 1.0
import "../components"

MainPageTile {
    id: root
    text: device.name.toUpperCase()
    iconName: app.interfacesToIcon(deviceClass.interfaces)
    iconColor: app.accentColor
    batteryCritical: batteryCriticalState && batteryCriticalState.value === true
    disconnected: connectedState && connectedState.value === false

    backgroundImage: artworkState && artworkState.value.length > 0 ? artworkState.value : ""

    property Device device: null
    readonly property DeviceClass deviceClass: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
    readonly property State connectedState: deviceClass.interfaces.indexOf("connectable") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("connected").id) : null
    readonly property State batteryCriticalState: deviceClass.interfaces.indexOf("battery") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("batteryCritical").id) : null
    readonly property State artworkState: deviceClass.interfaces.indexOf("mediametadataprovider") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("artwork").id) : null

    contentItem: Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: {
            if (root.deviceClass.interfaces.indexOf("closable") >= 0) {
                return closableComponent;
            }
            if (root.deviceClass.interfaces.indexOf("power") >= 0) {
                return lightsComponent;
            }
            if (root.deviceClass.interfaces.indexOf("sensor") >= 0) {
                return sensorsComponent;
            }
            if (root.deviceClass.interfaces.indexOf("weather") >= 0) {
                return sensorsComponent;
            }
            if (root.deviceClass.interfaces.indexOf("smartmeter") >= 0) {
                return sensorsComponent;
            }
            if (root.deviceClass.interfaces.indexOf("mediacontroller") >= 0) {
                return mediaComponent;
            }
        }
        Binding { target: loader.item ? loader.item : null; property: "deviceClass"; value: root.deviceClass }
        Binding { target: loader.item ? loader.item : null; property: "device"; value: root.device }
    }

    Component {
        id: lightsComponent
        RowLayout {
            property var device: null
            property var deviceClass: null

            readonly property var powerStateType: deviceClass.stateTypes.findByName("power");
            readonly property var powerState: device.states.getState(powerStateType.id)

            readonly property var brightnessStateType: deviceClass.stateTypes.findByName("brightness");
            readonly property var brightnessState: brightnessStateType ? device.states.getState(brightnessStateType.id) : null

            ThrottledSlider {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins / 2
                Layout.alignment: Qt.AlignVCenter
                opacity: deviceClass.interfaces.indexOf("dimmablelight") >= 0 ? 1 : 0
                enabled: opacity > 0
                from: 0
                to: 100
                value: brightnessState ? brightnessState.value : 0
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
                    name: deviceClass.interfaces.indexOf("light") >= 0
                          ? (powerState.value === true ? "../images/light-on.svg" : "../images/light-off.svg")
                          : app.interfacesToIcon(deviceClass.interfaces)
                    color: powerState.value === true ? app.accentColor : keyColor
                }
                onClicked: {
                    var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                    var actionType = deviceClass.actionTypes.findByName("power");
                    var params = [];
                    var powerParam = {}
                    powerParam["paramTypeId"] = actionType.paramTypes.get(0).id;
                    powerParam["value"] = !powerState.value;
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
                if (deviceClass.interfaces.indexOf("smartmeterconsumer") >= 0) {
                    tmp.push({iface: "smartmeterconsumer", state: "totalEnergyConsumed"});
                }
                if (deviceClass.interfaces.indexOf("smartmeterproducer") >= 0) {
                    tmp.push({iface: "smartmeterproducer", state: "totalEnergyProduced"});
                }
                if (deviceClass.interfaces.indexOf("daylightsensor") >= 0) {
                    tmp.push({iface: "daylightsensor", state: "daylight"});
                }
                if (deviceClass.interfaces.indexOf("presencesensor") >= 0) {
                    tmp.push({iface: "presencesensor", state: "isPresent"});
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

            Item { Layout.fillHeight: true; Layout.fillWidth: true }
            ColorIcon {
                Layout.preferredWidth: app.iconSize
                Layout.preferredHeight: width
                Layout.alignment: Qt.AlignVCenter
                color: app.interfaceToColor(sensorsRoot.shownInterfaces[sensorsRoot.currentStateIndex].iface)
                name: app.interfaceToIcon(sensorsRoot.shownInterfaces[sensorsRoot.currentStateIndex].iface)
            }

            Item { Layout.fillHeight: true; Layout.fillWidth: true }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                visible: sensorsRoot.currentStateType.type.toLowerCase() !== "bool"

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                    text: sensorsRoot.currentStateType.unitString
                    font.pixelSize: app.smallFont
                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                    text: sensorsRoot.currentState.value// + " " + sensorsRoot.currentStateType.unitString
                    elide: Text.ElideRight
                }
            }
            Led {
                state: sensorsRoot.currentState.value === true ? "on" : "off"
                visible: sensorsRoot.currentStateType.type.toLowerCase() === "bool"
            }

            Item { Layout.fillHeight: true; Layout.fillWidth: true }

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
                readonly property var percentateState: percentageStateType ? device.states.getState(percentageStateType.id) : null
                from: 0
                to: 100
                value: percentateState ? percentateState.value : 0
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

    Component {
        id: mediaComponent
        RowLayout {
            id: mediaRoot

            property Device device: null
            property DeviceClass deviceClass: null

            readonly property State playbackState: device.states.getState(deviceClass.stateTypes.findByName("playbackStatus").id)

            function executeAction(actionName, params) {
                var actionTypeId = deviceClass.actionTypes.findByName(actionName).id;
                engine.deviceManager.executeAction(device.id, actionTypeId, params)
            }
            Item { Layout.fillWidth: true }

            ProgressButton {
                Layout.preferredHeight: app.iconSize * .9
                Layout.preferredWidth: height
                imageSource: "../images/media-skip-backward.svg"
                longpressImageSource: "../images/media-seek-backward.svg"
                repeat: true

                onClicked: {
                    mediaRoot.executeAction("skipBack")
                }
                onLongpressed: {
                    mediaRoot.executeAction("fastRewind")
                }
            }
            Item { Layout.fillWidth: true }

            ProgressButton {
                Layout.preferredHeight: app.iconSize * 1.3
                Layout.preferredWidth: height
                imageSource: mediaRoot.playbackState.value === "Playing" ? "../images/media-playback-pause.svg" : "../images/media-playback-start.svg"
                longpressImageSource: "../images/media-playback-stop.svg"
                longpressEnabled: mediaRoot.playbackState.value !== "Stopped"

                onClicked: {
                    if (mediaRoot.playbackState.value === "Playing") {
                        mediaRoot.executeAction("pause")
                    } else {
                        mediaRoot.executeAction("play")
                    }
                }

                onLongpressed: {
                    mediaRoot.executeAction("stop")
                }
            }

            Item { Layout.fillWidth: true }
            ProgressButton {
                Layout.preferredHeight: app.iconSize * .9
                Layout.preferredWidth: height
                imageSource: "../images/media-skip-forward.svg"
                longpressImageSource: "../images/media-seek-forward.svg"
                repeat: true
                onClicked: {
                    mediaRoot.executeAction("skipNext")
                }
                onLongpressed: {
                    mediaRoot.executeAction("fastForward")
                }
            }
            Item { Layout.fillWidth: true }
        }
    }
}
