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
    text: thing ? thing.name.toUpperCase() : ""
    iconName: thing ? app.interfacesToIcon(thing.thingClass.interfaces) : ""
    iconColor: Style.accentColor
    isWireless: thing && thing.thingClass.interfaces.indexOf("wirelessconnectable") >= 0
    batteryCritical: batteryCriticalState && batteryCriticalState.value === true
    disconnected: connectedState && connectedState.value === false
    signalStrength: signalStrengthState ? signalStrengthState.value : -1
    setupStatus: thing ? thing.setupStatus : Thing.ThingSetupStatusNone
    updateStatus: updateStatusState && updateStatusState.value !== "idle"

    backgroundImage: artworkState && artworkState.value.length > 0 ? artworkState.value : ""

    property Thing thing: null
    property alias device: root.thing
    readonly property State connectedState: thing ? thing.stateByName("connected") : null
    readonly property State signalStrengthState: thing ? thing.stateByName("signalStrength") : null
    readonly property State batteryCriticalState: thing ? thing.stateByName("batteryCritical") : null
    readonly property State artworkState: thing ? thing.stateByName("artwork") : null
    readonly property State updateStatusState: thing ? thing.stateByName("updateStatus") : null

    contentItem: Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: {
            if (!root.thing) {
                return null
            }

            for (var i = 0; i < root.thing.thingClass.interfaces.length; i++) {
                switch (root.thing.thingClass.interfaces[i]) {
                case "closable":
                    return closableComponent;
                case "mediacontroller":
                    return mediaComponent;
                case "power":
                    return lightsComponent;
                case "sensor":
                    return sensorsComponent;
                case "weather":
                    return sensorsComponent;
                case "smartmeter":
                    return sensorsComponent;
                case "cleaningrobot":
                    return buttonComponent;
                case "ventilation":
                    return ventilationComponent;
                }
            }
        }
        Binding { target: loader.item ? loader.item : null; property: "thing"; value: root.thing }
    }

    Component {
        id: lightsComponent
        RowLayout {
            property Thing thing: null
            readonly property State powerState: thing.stateByName("power")
            readonly property State brightnessState: thing.stateByName("brightness")

            ThrottledSlider {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins / 2
                Layout.alignment: Qt.AlignVCenter
                opacity: thing.thingClass.interfaces.indexOf("dimmablelight") >= 0 ? 1 : 0
                enabled: opacity > 0
                from: 0
                to: 100
                value: brightnessState ? brightnessState.value : 0
                onMoved: {
                    var actionType = thing.thingClass.actionTypes.findByName("brightness");
                    var params = [];
                    var powerParam = {}
                    powerParam["paramTypeId"] = actionType.paramTypes.get(0).id;
                    powerParam["value"] = value;
                    params.push(powerParam)
                    engine.thingManager.executeAction(thing.id, actionType.id, params);
                }
            }

            ItemDelegate {
                Layout.preferredWidth: Style.iconSize
                Layout.preferredHeight: width
                Layout.rightMargin: app.margins / 2
                Layout.alignment: Qt.AlignVCenter
                padding: 0; topPadding: 0; bottomPadding: 0

                contentItem: ColorIcon {
                    name: thing.thingClass.interfaces.indexOf("light") >= 0
                          ? (powerState.value === true ? "../images/light-on.svg" : "../images/light-off.svg")
                          : app.interfacesToIcon(thing.thingClass.interfaces)
                    color: powerState.value === true ? Style.accentColor : Style.iconColor
                }
                onClicked: {
                    var actionType = thing.thingClass.actionTypes.findByName("power");
                    var params = [];
                    var powerParam = {}
                    powerParam["paramTypeId"] = actionType.paramTypes.get(0).id;
                    powerParam["value"] = !powerState.value;
                    params.push(powerParam)
                    engine.thingManager.executeAction(thing.id, actionType.id, params);
                }
            }
        }
    }

    Component {
        id: ventilationComponent
        RowLayout {
            property Thing thing: null
            readonly property State powerState: thing.stateByName("power")
            readonly property State flowRateState: thing.stateByName("flowRate")

            ThrottledSlider {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins / 2
                Layout.alignment: Qt.AlignVCenter
                opacity: flowRateState ? 1 : 0
                enabled: opacity > 0
                from: 0
                to: 100
                value: flowRateState ? flowRateState.value : 0
                onMoved: {
                    var actionType = thing.thingClass.actionTypes.findByName("flowRate");
                    var params = [];
                    var powerParam = {}
                    powerParam["paramTypeId"] = actionType.paramTypes.get(0).id;
                    powerParam["value"] = value;
                    params.push(powerParam)
                    engine.thingManager.executeAction(thing.id, actionType.id, params);
                }
            }

            ItemDelegate {
                Layout.preferredWidth: Style.iconSize
                Layout.preferredHeight: width
                Layout.rightMargin: app.margins / 2
                Layout.alignment: Qt.AlignVCenter
                padding: 0; topPadding: 0; bottomPadding: 0

                contentItem: ColorIcon {
                    name: "../images/ventilation.svg"
                    color: powerState.value === true ? Style.accentColor : Style.iconColor
                }
                onClicked: {
                    var actionType = thing.thingClass.actionTypes.findByName("power");
                    var params = [];
                    var powerParam = {}
                    powerParam["paramTypeId"] = actionType.paramTypes.get(0).id;
                    powerParam["value"] = !powerState.value;
                    params.push(powerParam)
                    engine.thingManager.executeAction(thing.id, actionType.id, params);
                }
            }
        }
    }

    Component {
        id: sensorsComponent
        RowLayout {
            id: sensorsRoot
            property Thing thing: null
            spacing: 0

            property var shownInterfaces: []
            property int currentStateIndex: -1
            property StateType currentStateType: thing ? thing.thingClass.stateTypes.findByName(shownInterfaces[currentStateIndex].state) : null
            property State currentState: currentStateType ? thing.states.getState(currentStateType.id) : null

            onThingChanged:  {
                if (thing == null) {
                    return;
                }

                var tmp = []
                if (thing.thingClass.interfaces.indexOf("temperaturesensor") >= 0) {
                    tmp.push({iface: "temperaturesensor", state: "temperature"});
                }
                if (thing.thingClass.interfaces.indexOf("humiditysensor") >= 0) {
                    tmp.push({iface: "humiditysensor", state: "humidity"});
                }
                if (thing.thingClass.interfaces.indexOf("moisturesensor") >= 0) {
                    tmp.push({iface: "moisturesensor", state: "moisture"});
                }
                if (thing.thingClass.interfaces.indexOf("pressuresensor") >= 0) {
                    tmp.push({iface: "pressuresensor", state: "pressure"});
                }
                if (thing.thingClass.interfaces.indexOf("lightsensor") >= 0) {
                    tmp.push({iface: "lightsensor", state: "lightIntensity"});
                }
                if (thing.thingClass.interfaces.indexOf("conductivitysensor") >= 0) {
                    tmp.push({iface: "conductivitysensor", state: "conductivity"});
                }
                if (thing.thingClass.interfaces.indexOf("noisesensor") >= 0) {
                    tmp.push({iface: "noisesensor", state: "noise"});
                }
                if (thing.thingClass.interfaces.indexOf("cosensor") >= 0) {
                    tmp.push({iface: "cosensor", state: "co"});
                }
                if (thing.thingClass.interfaces.indexOf("co2sensor") >= 0) {
                    tmp.push({iface: "co2sensor", state: "co2"});
                }
                if (thing.thingClass.interfaces.indexOf("gassensor") >= 0) {
                    tmp.push({iface: "gassensor", state: "gasLevel"});
                }
                if (thing.thingClass.interfaces.indexOf("smartmeterconsumer") >= 0) {
                    tmp.push({iface: "smartmeterconsumer", state: "currentPower"});
                }
                if (thing.thingClass.interfaces.indexOf("smartmeterproducer") >= 0) {
                    tmp.push({iface: "smartmeterproducer", state: "currentPower"});
                }
                if (thing.thingClass.interfaces.indexOf("energymeter") >= 0) {
                    tmp.push({iface: "energymeter", state: "currentPower"});
                }
                if (thing.thingClass.interfaces.indexOf("daylightsensor") >= 0) {
                    tmp.push({iface: "daylightsensor", state: "daylight"});
                }
                if (thing.thingClass.interfaces.indexOf("presencesensor") >= 0) {
                    tmp.push({iface: "presencesensor", state: "isPresent"});
                }
                if (thing.thingClass.interfaces.indexOf("phsensor") >= 0) {
                    tmp.push({iface: "phsensor", state: "ph"})
                }
                if (thing.thingClass.interfaces.indexOf("orpsensor") >= 0) {
                    tmp.push({iface: "orpsensor", state: "orp"})
                }
                if (thing.thingClass.interfaces.indexOf("o2sensor") >= 0) {
                    tmp.push({iface: "o2sensor", state: "o2saturation"})
                }
                if (thing.thingClass.interfaces.indexOf("closablesensor") >= 0) {
                    tmp.push({iface: "closablesensor", state: "closed"})
                }
                if (thing.thingClass.interfaces.indexOf("watersensor") >= 0) {
                    tmp.push({iface: "watersensor", state: "waterDetected"})
                }
                if (thing.thingClass.interfaces.indexOf("waterlevelsensor") >= 0) {
                    tmp.push({iface: "waterlevelsensor", state: "waterLevel"})
                }
                if (thing.thingClass.interfaces.indexOf("firesensor") >= 0) {
                    tmp.push({iface: "firesensor", state: "fireDetected"})
                }

                if (thing.thingClass.interfaces.indexOf("weather") >= 0) {
                    tmp.push({iface: "temperaturesensor", state: "temperature"});
                    tmp.push({iface: "humiditysensor", state: "humidity"});
                    tmp.push({iface: "pressuresensor", state: "pressure"});
                }

                shownInterfaces = tmp
                currentStateIndex = 0
            }

            Item { Layout.fillHeight: true; Layout.fillWidth: true }
            ProgressButton {
                visible: sensorsRoot.shownInterfaces.length > 1
                longpressEnabled: false
                imageSource: "../images/back.svg"
                onClicked: {
                    var newIndex = sensorsRoot.currentStateIndex - 1;
                    if (newIndex < 0) newIndex = sensorsRoot.shownInterfaces.length - 1
                    sensorsRoot.currentStateIndex = newIndex;
                }
            }

            Item { Layout.fillHeight: true; Layout.fillWidth: true }
            ColorIcon {
                Layout.preferredWidth: Style.iconSize
                Layout.preferredHeight: width
                Layout.alignment: Qt.AlignVCenter
                color: app.interfaceToColor(sensorsRoot.shownInterfaces[sensorsRoot.currentStateIndex].iface)
                name: app.interfaceToIcon(sensorsRoot.shownInterfaces[sensorsRoot.currentStateIndex].iface)
            }

            Item { Layout.fillHeight: true; Layout.fillWidth: true }
            ColumnLayout {
                Layout.fillWidth: false
                spacing: 0
                visible: sensorsRoot.currentStateType.type.toLowerCase() !== "bool"

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                    text: Types.toUiUnit(sensorsRoot.currentStateType.unit)
                    font.pixelSize: app.smallFont
                    visible: text !== ""
                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(Types.toUiValue(sensorsRoot.currentState.value, sensorsRoot.currentStateType.unit) * 100) / 100
                    elide: Text.ElideRight
                }
            }
            Led {
                state: sensorsRoot.currentState.value === true ? "on" : "off"
                visible: sensorsRoot.currentStateType.type.toLowerCase() === "bool"
            }

            Item { Layout.fillHeight: true; Layout.fillWidth: true }

            ProgressButton {
                visible: sensorsRoot.shownInterfaces.length > 1
                longpressEnabled: false
                imageSource: "../images/next.svg"
                onClicked: {
                    var newIndex = sensorsRoot.currentStateIndex + 1;
                    if (newIndex >= sensorsRoot.shownInterfaces.length) newIndex = 0;
                    sensorsRoot.currentStateIndex = newIndex;
                }
            }
            Item { Layout.fillHeight: true; Layout.fillWidth: true }
        }
    }

    Component {
        id: closableComponent
        ShutterControls {}
    }

    Component {
        id: mediaComponent
        MediaControls {}
    }

    Component {
        id: buttonComponent
        ButtonControls {
            iface: root.thing.thingClass.interfaces[0]
        }
    }
}
