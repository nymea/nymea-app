// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Nymea
import NymeaApp.Utils

import "../components"

MainPageTile {
    id: root
    text: iface ? iface.displayName.toUpperCase() : qsTr("uncategorized").toUpperCase()
    iconName: iface ? interfaceToIcon(iface.name) : interfaceToIcon("uncategorized")
    iconColor: Style.accentColor
    disconnected: devicesSubProxyConnectables.count > 0
    isWireless: devicesSubProxyConnectables.count > 0 && devicesSubProxyConnectables.get(0).thingClass.interfaces.indexOf("wirelessconnectable") >= 0
    batteryCritical: devicesSubProxyBattery.count > 0
    setupStatus: thingsSubProxySetupFailure.count > 0 ? Thing.ThingSetupStatusFailed : Thing.ThingSetupStatusComplete
    updateStatus: thingsSubProxyUpdates.count > 0

    property Interface iface: null
    property alias filterTagId: thingsProxy.filterTagId

    backgroundImage: inlineControlLoader.item && inlineControlLoader.item.hasOwnProperty("backgroundImage") ? inlineControlLoader.item.backgroundImage : ""

    onClicked: {
        var page;
        // Only one item? Go streight to the thing page
        if (thingsProxy.count === 1) {
            if (!iface) {
                page = "GenericThingPage.qml";
            } else {
                page = NymeaUtils.interfaceListToDevicePage([iface.name]);
            }
            pageStack.push(Qt.resolvedUrl("../devicepages/" + page), {thing: thingsProxy.get(0)})
            return;
        }

        // No (supported by app) interfaces at all? Open generic list
        if (!iface) {
            page = "GenericThingsListPage.qml"
            pageStack.push(Qt.resolvedUrl("../devicelistpages/" + page), {hiddenInterfaces: app.supportedInterfaces, filterTagId: root.filterTagId})
            return;
        }

        // Open interface specific things list
        switch (iface.name) {
        case "heating":
        case "cooling":
        case "thermostat":
        case "sensor":
            page = "SensorsDeviceListPage.qml"
            break;
        case "weather":
            page = "WeatherDeviceListPage.qml"
            break;
        case "light":
            page = "LightThingsListPage.qml"
            break;
        case "smartmeter":
            page ="SmartMeterDeviceListPage.qml";
            break;
        case "garagegate": // Deprecated, might not inherit garagedoor in old versions
        case "garagedoor":
            page = "GarageThingsListPage.qml";
            break;
        case "awning":
        case "extendedAwning":
            page = "AwningThingsListPage.qml";
            break;
        case "blind":
        case "extendedBlind":
            page = "BlindThingsListPage.qml";
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
            page = "GenericThingsListPage.qml"
        }
        print("entering for shown interfaces:", iface.name)
        pageStack.push(Qt.resolvedUrl("../devicelistpages/" + page), {shownInterfaces: [iface.name], filterTagId: root.filterTagId})
    }

    ThingsProxy {
        id: thingsProxy
        engine: _engine
        shownInterfaces: iface ? [iface.name] : []
        hiddenInterfaces: iface ? [] : app.supportedInterfaces
    }
    readonly property ThingsProxy _thingsProxy: thingsProxy

    ThingsProxy {
        id: devicesSubProxyConnectables
        engine: _engine
        parentProxy: thingsProxy
        shownInterfaces: ["connectable"]
        filterDisconnected: true
    }
    ThingsProxy {
        id: devicesSubProxyBattery
        engine: _engine
        parentProxy: thingsProxy
        filterBatteryCritical: true
    }
    ThingsProxy {
        id: thingsSubProxySetupFailure
        engine: _engine
        parentProxy: thingsProxy
        filterSetupFailed: true
    }
    ThingsProxy {
        id: thingsSubProxyUpdates
        engine: _engine
        parentProxy: thingsProxy
        filterUpdates: true
    }

    property int currentDeviceIndex: 0
    readonly property Thing currentDevice: thingsProxy.get(currentDeviceIndex)

    contentItem: Loader {
        id: inlineControlLoader
        anchors {
            fill: parent
            leftMargin: Style.margins / 2
            rightMargin: Style.margins / 2
        }
        sourceComponent: {
            if (!root.iface) {
                return labelComponent
            }

            switch (iface.name) {
            case "sensor":
            case "weather":
            case "smartmeter":
            case "smartmeterconsumer":
            case "smartmeterproducer":
            case "extendedsmartmeterconsumer":
            case "extendedsmartmeterproducer":
            case "heating":
            case "cooling":
            case "thermostat":
                return sensorComponent;

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
            case "cleaningrobot":
            case "evcharger":
                return buttonComponent
            case "media":
                return mediaControlComponent
            default:
                return labelComponent
            }

        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                switch (iface.name) {
                case "light":
                    var group = engine.thingManager.createGroup(Interfaces.findByName("colorlight"), thingsProxy);
                    print("opening lights page for group", group)
                    pageStack.push("../devicepages/LightThingPage.qml", {thing: group})
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
            readonly property Thing currentDevice: thingsProxy.get(currentDeviceIndex)
            readonly property StateType playbackStateType: currentDevice.thingClass.stateTypes.findByName("playbackStatus")
            readonly property State playbackState: currentDevice.states.getState(playbackStateType.id)
            readonly property StateType artworkStateType: currentDevice.thingClass.stateTypes.findByName("artwork")
            readonly property State artworkState: artworkStateType ? currentDevice.states.getState(artworkStateType.id) : null

            Component.onCompleted: {
                for (var i = 0; i < thingsProxy.count; i++) {
                    var d = thingsProxy.get(i);
                    var st = d.thingClass.stateTypes.findByName("playbackStatus")
                    var s = d.states.getState(st.id)
                    s.valueChanged.connect(function() {
                        if (inlineMediaControl) {
                            inlineMediaControl.updateTile()
                        }
                    })
                }
                updateTile();
            }

            function updateTile() {
                var playingIndex = -1;
                var pausedIndex = -1;
                for (var i = 0; i < thingsProxy.count; i++) {
                    var d = thingsProxy.get(i);
                    var st = d.thingClass.stateTypes.findByName("playbackStatus");
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
                thing: inlineMediaControl.currentDevice
                iconColor: Style.tileOverlayIconColor
            }
        }
    }

    Component {
        id: buttonComponent

        ButtonControls {
            thingsProxy: _thingsProxy
            iface: root.iface.name
        }
    }

    Component {
        id: labelComponent
        ColumnLayout {
            spacing: 0

            Label {
                text: qsTr("%n things", "", thingsProxy.count)
                font: Style.smallFont
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

            property Thing thing: thingsProxy.get(currentDevice)

            property var shownSensors: findSensors(thing.thingClass)
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
                ListElement { ifaceName: "vibfrationsensor"; stateName: "" }
                ListElement { ifaceName: "closablesensor"; stateName: "closed" }
                ListElement { ifaceName: "lightsensor"; stateName: "lightIntensity" }
                ListElement { ifaceName: "watersensor"; stateName: "waterDetected" }
                ListElement { ifaceName: "waterlevelsensor"; stateName: "waterLevel" }
                ListElement { ifaceName: "firesensor"; stateName: "fireDetected" }
                ListElement { ifaceName: "cosensor"; stateName: "co" }
                ListElement { ifaceName: "co2sensor"; stateName: "co2" }
                ListElement { ifaceName: "gassensor"; stateName: "gasLevel" }
                ListElement { ifaceName: "conductivity"; stateName: "conductivity" }
                ListElement { ifaceName: "noisesensor"; stateName: "noise" }
                ListElement { ifaceName: "smartmeterconsumer"; stateName: "currentPower" }
                ListElement { ifaceName: "smartmeterproducer"; stateName: "currentPower" }
                ListElement { ifaceName: "energymeter"; stateName: "currentPower" }
                ListElement { ifaceName: "thermostat"; stateName: "targetTemperature" }
                ListElement { ifaceName: "heating"; stateName: "power" }
                ListElement { ifaceName: "extendedHeating"; stateName: "percentage" }
                ListElement { ifaceName: "o2sensor"; stateName: "o2saturation" }
                ListElement { ifaceName: "orpsensor"; stateName: "orp" }
                ListElement { ifaceName: "phsensor"; stateName: "ph" }
            }
            function findSensors(thingClass) {
                var ret = []
                for (var i = 0; i < supportedSensors.count; i++) {
                    if (thingClass.interfaces.indexOf(supportedSensors.get(i).ifaceName) >= 0) {
                        ret.push({ifaceName: supportedSensors.get(i).ifaceName, stateName: supportedSensors.get(i).stateName})
                    }
                }
                return ret;
            }

            property StateType shownStateType: shownSensors.length > currentSensor && currentSensor >= 0
                                               ? thing.thingClass.stateTypes.findByName(shownSensors[currentSensor].stateName)
                                               : null

            function nextSensor() {
                var newSensorIndex = sensorsRoot.currentSensor + 1;
                if (newSensorIndex > sensorsRoot.shownSensors.length - 1) {
                    var newDeviceIndex = (sensorsRoot.currentDevice + 1) % thingsProxy.count;
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
                running: sensorsRoot.shownSensors.length > 1 || thingsProxy.count > 1
                onTriggered: nextSensorAnimation.start()
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: Style.margins / 2
                spacing: Style.margins / 2

                ColorIcon {
                    Layout.preferredHeight: Style.iconSize
                    Layout.preferredWidth: Style.iconSize
                    name: sensorsRoot.currentSensor >= 0 && sensorsRoot.shownSensors.length > sensorsRoot.currentSensor ? app.interfaceToIcon(sensorsRoot.shownSensors[sensorsRoot.currentSensor].ifaceName) : ""
                    color: sensorsRoot.currentSensor >= 0 && sensorsRoot.shownSensors.length > sensorsRoot.currentSensor ? app.interfaceToColor(sensorsRoot.shownSensors[sensorsRoot.currentSensor].ifaceName) : Style.iconColor
                }

                ColumnLayout {
                    Label {
                        text: sensorsRoot.thing.name
                        font: Style.smallFont
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Label {
                        text: sensorsRoot.shownStateType
                              ? (Math.round(Types.toUiValue(sensorsRoot.thing.states.getState(sensorsRoot.shownStateType.id).value, sensorsRoot.shownStateType.unit) * 100) / 100) + " " + Types.toUiUnit(sensorsRoot.shownStateType.unit)
                              : ""
                        font: Style.smallFont
                        Layout.fillWidth: true
                        visible: sensorsRoot.shownStateType && sensorsRoot.shownStateType.type.toLowerCase() !== "bool"
                        elide: Text.ElideRight
                    }
                    Led {
                        Layout.preferredHeight: Style.iconSize * .5
                        Layout.preferredWidth: height
                        state: visible && sensorsRoot.thing.states.getState(sensorsRoot.shownStateType.id).value === true ? "on" : "off"
                        visible: sensorsRoot.shownStateType && sensorsRoot.shownStateType.type.toLowerCase() === "bool"
                    }
                }
            }
        }
    }
}
