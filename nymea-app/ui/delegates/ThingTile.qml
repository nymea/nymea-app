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
    text: device.name.toUpperCase()
    iconName: app.interfacesToIcon(deviceClass.interfaces)
    iconColor: app.accentColor
    isWireless: deviceClass.interfaces.indexOf("wirelessconnectable") >= 0
    batteryCritical: batteryCriticalState && batteryCriticalState.value === true
    disconnected: connectedState && connectedState.value === false
    signalStrength: signalStrengthState ? signalStrengthState.value : -1
    setupStatus: device.setupStatus

    backgroundImage: artworkState && artworkState.value.length > 0 ? artworkState.value : ""

    property Device device: null
    readonly property DeviceClass deviceClass: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
    readonly property State connectedState: deviceClass.interfaces.indexOf("connectable") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("connected").id) : null
    readonly property State signalStrengthState: device.stateByName("signalStrength")
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
                Layout.preferredWidth: app.iconSize
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

        ShutterControls {

        }
    }

    Component {
        id: mediaComponent

        MediaControls {
            property Device device: null
            thing: device
        }
    }
}
