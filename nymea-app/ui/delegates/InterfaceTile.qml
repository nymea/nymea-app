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

MainPageTile {
    id: root
    text: iface ? iface.displayName.toUpperCase() : qsTr("uncategorized").toUpperCase()
    iconName: iface ? interfaceToIcon(iface.name) : interfaceToIcon("uncategorized")
    iconColor: app.accentColor
    disconnected: devicesSubProxyConnectables.count > 0
    batteryCritical: devicesSubProxyBattery.count > 0

    property Interface iface: null
    property alias filterTagId: devicesProxy.filterTagId

    backgroundImage: inlineControlLoader.item && inlineControlLoader.item.hasOwnProperty("backgroundImage") ? inlineControlLoader.item.backgroundImage : ""

    onClicked: {
        var page;
        if (!iface) {
            page = "GenericDeviceListPage.qml"
            pageStack.push(Qt.resolvedUrl("../devicelistpages/" + page), {hiddenInterfaces: app.supportedInterfaces, filterTagId: root.filterTagId})
            return;
        }

        switch (iface.name) {
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
        case "garagegate": // Deprecated, might not inherit garagedoor in old versions
        case "garagedoor":
            page = "GarageThingListPage.qml";
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
        print("entering for shown interfaces:", iface.name)
        pageStack.push(Qt.resolvedUrl("../devicelistpages/" + page), {shownInterfaces: [iface.name], filterTagId: root.filterTagId})
    }

    DevicesProxy {
        id: devicesProxy
        engine: _engine
        shownInterfaces: iface ? [iface.name] : []
        hiddenInterfaces: iface ? [] : app.supportedInterfaces
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
            switch (iface.name) {
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
            case "garagedoor":
            case "impulsegaragedoor":
            case "statefulgaragedoor":
            case "extendedstatefulgaragedoor":
            case "garagegate":
            case "blind":
            case "extendedblind":
            case "shutter":
            case "extendedshutter":
            case "awning":
            case "extendedawning":
            case "powersocket":
            case "irrigation":
            case "ventilation":
                return buttonComponent
            case "media":
                return mediaControlComponent
            default:
                console.warn("InterfaceTile, inlineControl: Unhandled interface", iface.name)
            }

        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                switch (iface.name) {
                case "light":
                    var group = engine.deviceManager.createGroup(Interfaces.findByName("colorlight"), devicesProxy);
                    print("opening lights page for group", group)
                    pageStack.push("../devicepages/LightDevicePage.qml", {device: group})
                }

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
                thing: inlineMediaControl.currentDevice
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
                    switch (iface.name) {
                    case "media":
                        return devicesProxy.get(0).name;
                    case "light":
                    case "irrigation":
                    case "ventilation":
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
                    case "garagedoor":
                        var statefulCount = 0;
                        var count = 0;
                        for (var i = 0; i < devicesProxy.count; i++) {
                            var thing = devicesProxy.get(i);
                            if (thing.thingClass.interfaces.indexOf("statefulgaragedoor") >= 0 || thing.thingClass.interfaces.indexOf("extendedstatefulgaragedoor") >= 0 || thing.thingClass.interfaces.indexOf("garagegate") >= 0) {
                                statefulCount++;
                                var stateType = thing.thingClass.stateTypes.findByName("state");
                                if (stateType && thing.states.getState(stateType.id).value !== "closed") {
                                    count++;
                                }
                            }
                        }
                        if (statefulCount > 0) {
                            return count === 0 ? qsTr("All closed") : qsTr("%1 open").arg(count)
                        }
                        return "";
                    case "blind":
                    case "extendedblind":
                    case "awning":
                    case "extendedawning":
                    case "shutter":
                    case "extendedshutter":
                        return ""
                        //                        return qsTr("%1 installed").arg(devicesProxy.count)
                    }
                    console.warn("InterfaceTile, inlineButtonControl: Unhandled interface", model.name)
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
                            switch (iface.name) {
                            case "media":
                            case "light":
                            case "irrigation":
                            case "ventilation":
                                return ""
                            case "garagedoor":
                                var dev = devicesProxy.get(0)
                                if (dev.thingClass.interfaces.indexOf("simplegaragedoor") >= 0
                                        || dev.thingClass.interfaces.indexOf("statefulgaragedoor") >= 0
                                        || dev.thingClass.interfaces.indexOf("extendedstatefulgaragedoor") >= 0
                                        || dev.thingClass.interfaces.indexOf("garagegate") >= 0) {
                                    return "../images/up.svg"
                                }
                                return ""
                            case "blind":
                            case "extendedblind":
                            case "awning":
                            case "extendedawning":
                            case "shutter":
                            case "extendedshutter":
                                return "../images/up.svg"
                            default:
                                console.warn("InterfaceTile", "inlineButtonControl image: Unhandled interface", iface.name)
                            }
                            return ""
                        }
                    }

                    onClicked: {
                        switch (iface.name) {
                        case "light":
                        case "media":
                        case "irrigation":
                        case "ventilation":
                            break;
                        case "garagedoor":
                            for (var i = 0; i < devicesProxy.count; i++) {
                                var thing = devicesProxy.get(i);
                                if (thing.thingClass.interfaces.indexOf("simplegaragedoor") >= 0
                                        || thing.thingClass.interfaces.indexOf("statefulgaragedoor") >= 0
                                        || thing.thingClass.interfaces.indexOf("extendedstatefulgaragedoor") >= 0
                                        || thing.thingClass.interfaces.indexOf("garagegate") >= 0) {

                                    var actionType = thing.thingClass.actionTypes.findByName("open");
                                    engine.deviceManager.executeAction(thing.id, actionType.id)
                                }
                            }
                            break;
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
                            console.warn("InterfaceTile:", "inlineButtonControl clicked: Unhandled interface", iface.name)
                        }
                    }
                }

                ItemDelegate {
                    Layout.preferredHeight: app.iconSize
                    Layout.preferredWidth: height
                    enabled: centerIcon.name.length > 0
                    ColorIcon {
                        id: centerIcon
                        width: app.iconSize
                        height: width
                        color: app.accentColor

                        name: {
                            switch (iface.name) {
                            case "media":
                            case "light":
                            case "irrigation":
                            case "ventilation":
                                return ""
                            case "garagedoor":
                                var dev = devicesProxy.get(0)
                                if (dev.thingClass.interfaces.indexOf("simplegaragedoor") >= 0
                                        || dev.thingClass.interfaces.indexOf("statefulgaragedoor") >= 0
                                        || dev.thingClass.interfaces.indexOf("extendedstatefulgaragedoor") >= 0
                                        || dev.thingClass.interfaces.indexOf("garagegate") >= 0) {
                                    return "../images/media-playback-stop.svg"
                                }
                                return ""
                            case "blind":
                            case "awning":
                            case "shutter":
                            case "extendedblind":
                            case "extendedawning":
                            case "extendedshutter":
                                return "../images/media-playback-stop.svg"
                            default:
                                console.warn("InterfaceTile, inlineButtonControl image: Unhandled interface", iface.name)
                            }
                            return "";
                        }
                    }

                    onClicked: {
                        switch (iface.name) {
                        case "light":
                        case "media":
                        case "irrigation":
                        case "ventilation":
                            break;
                        case "garagedoor":
                            for (var i = 0; i < devicesProxy.count; i++) {
                                var thing = devicesProxy.get(i);
                                if (thing.thingClass.interfaces.indexOf("simplegaragedoor") >= 0
                                        || thing.thingClass.interfaces.indexOf("statefulgaragedoor") >= 0
                                        || thing.thingClass.interfaces.indexOf("extendedstatefulgaragedoor") >= 0
                                        || thing.thingClass.interfaces.indexOf("garagegate") >= 0) {

                                    var actionType = thing.thingClass.actionTypes.findByName("stop");
                                    engine.thingManager.executeAction(thing.id, actionType.id)
                                }
                            }
                            break;
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
                            break;
                        default:
                            console.warn("InterfaceTile, inlineButtonControl clicked: Unhandled interface", iface.name)
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
                            switch (iface.name) {
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
                            case "irrigation":
                            case "ventilation":
                                return "../images/system-shutdown.svg"
                            case "garagedoor":
                                var dev = devicesProxy.get(0)
                                if (dev.thingClass.interfaces.indexOf("simplegaragedoor") >= 0
                                        || dev.thingClass.interfaces.indexOf("statefulgaragedoor") >= 0
                                        || dev.thingClass.interfaces.indexOf("extendedstatefulgaragedoor") >= 0
                                        || dev.thingClass.interfaces.indexOf("garagegate") >= 0) {
                                    return "../images/down.svg"
                                }
                                if (dev.thingClass.interfaces.indexOf("impulsegaragedoor") >= 0) {
                                    return "../images/closable-move.svg"
                                }
                                return ""
                            case "blind":
                            case "extendedblind":
                            case "awning":
                            case "extendedawning":
                            case "shutter":
                            case "extendedshutter":
                                return "../images/down.svg"
                            default:
                                console.warn("InterfaceTile, inlineButtonControl image: Unhandled interface", iface.name)
                            }
                        }
                    }

                    onClicked: {
                        switch (iface.name) {
                        case "light":
                        case "powersocket":
                        case "irrigation":
                        case "ventilation":
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
                        case "garagedoor":
                            for (var i = 0; i < devicesProxy.count; i++) {
                                var thing = devicesProxy.get(i);
                                if (thing.thingClass.interfaces.indexOf("simplegaragedoor") >= 0
                                        || thing.thingClass.interfaces.indexOf("statefulgaragedoor") >= 0
                                        || thing.thingClass.interfaces.indexOf("extendedstatefulgaragedoor") >= 0
                                        || thing.thingClass.interfaces.indexOf("garagegate") >= 0) {

                                    var actionType = thing.thingClass.actionTypes.findByName("close");
                                    engine.deviceManager.executeAction(thing.id, actionType.id)
                                }
                                if (thing.thingClass.interfaces.indexOf("impulsegaragedoor") >= 0) {
                                    var actionType = thing.thingClass.actionTypes.findByName("triggerImpulse");
                                    engine.deviceManager.executeAction(thing.id, actionType.id)
                                }
                            }
                            break;
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
                            console.warn("InterfaceTile, inlineButtonControl clicked: Unhandled interface", iface.name)
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
            property DeviceClass deviceClass: device ? device.deviceClass : null

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
                              ? (Math.round(Types.toUiValue(sensorsRoot.device.states.getState(sensorsRoot.shownStateType.id).value, sensorsRoot.shownStateType.unit) * 100) / 100) + " " + Types.toUiUnit(sensorsRoot.shownStateType.unit)
                              : ""
    //                    font.pixelSize: app.smallFont
                        Layout.fillWidth: true
                        visible: sensorsRoot.shownStateType && sensorsRoot.shownStateType.type.toLowerCase() !== "bool"
                        elide: Text.ElideRight
                    }
                    Led {
                        Layout.preferredHeight: app.iconSize * .5
                        Layout.preferredWidth: height
                        state: visible && sensorsRoot.device.states.getState(sensorsRoot.shownStateType.id).value === true ? "on" : "off"
                        visible: sensorsRoot.shownStateType && sensorsRoot.shownStateType.type.toLowerCase() === "bool"
                    }
                }
            }
        }

    }
}
