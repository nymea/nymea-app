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

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

BigThingTile {
    id: itemDelegate

    contentItem: GridLayout {
        id: dataGrid
        columns: Math.floor(contentItem.width / 120)

        Connections {
            target: itemDelegate
            onThingChanged: stateModel.update()
        }

        ListModel {
            id: interfacesModel
            ListElement { interfaceName: "temperaturesensor"; stateName: "temperature" }
            ListElement { interfaceName: "humiditysensor"; stateName: "humidity" }
            ListElement { interfaceName: "moisturesensor"; stateName: "moisture" }
            ListElement { interfaceName: "pressuresensor"; stateName: "pressure" }
            ListElement { interfaceName: "lightsensor"; stateName: "lightIntensity" }
            ListElement { interfaceName: "conductivitysensor"; stateName: "conductivity" }
            ListElement { interfaceName: "noisesensor"; stateName: "noise" }
            ListElement { interfaceName: "cosensor"; stateName: "co" }
            ListElement { interfaceName: "co2sensor"; stateName: "co2" }
            ListElement { interfaceName: "gassensor"; stateName: "gasLevel" }
            ListElement { interfaceName: "daylightsensor"; stateName: "daylight" }
            ListElement { interfaceName: "presencesensor"; stateName: "isPresent" }
            ListElement { interfaceName: "vibrationsensor"; stateName: ""; eventName: "vibrationDetected" }
            ListElement { interfaceName: "closablesensor"; stateName: "closed" }
            ListElement { interfaceName: "heating"; stateName: "power" }
            ListElement { interfaceName: "thermostat"; stateName: "targetTemperature" }
            ListElement { interfaceName: "watersensor"; stateName: "waterDetected" }
            ListElement { interfaceName: "waterlevelsensor"; stateName: "waterLevel" }
            ListElement { interfaceName: "firesensor"; stateName: "fireDetected" }
            ListElement { interfaceName: "o2sensor"; stateName: "o2saturation" }
            ListElement { interfaceName: "phsensor"; stateName: "ph" }
            ListElement { interfaceName: "orpsensor"; stateName: "orp" }
            ListElement { interfaceName: "vocsensor"; stateName: "voc" }
            ListElement { interfaceName: "pm10sensor"; stateName: "pm10" }
            ListElement { interfaceName: "pm25sensor"; stateName: "pm25" }
            ListElement { interfaceName: "no2sensor"; stateName: "no2" }
            ListElement { interfaceName: "o3sensor"; stateName: "o3" }
        }
        Repeater {
            model: ListModel {
                id: stateModel
                dynamicRoles: true
                Component.onCompleted: {
                    update()
                }

                function update() {
                    for (var i = 0; i < interfacesModel.count; i++) {
                        if (itemDelegate.thing.thingClass.interfaces.indexOf(interfacesModel.get(i).interfaceName) >= 0) {
                            append(interfacesModel.get(i))
                        }
                    }
                }
            }

            delegate: RowLayout {
                id: sensorValueDelegate
                visible: itemDelegate.thing.thingClass.interfaces.indexOf(model.interfaceName) >= 0
                Layout.preferredWidth: contentItem.width / dataGrid.columns

                property StateType stateType: itemDelegate.thing.thingClass.stateTypes.findByName(model.stateName)
                property State stateValue: stateType ? itemDelegate.thing.states.getState(stateType.id) : null

                property EventType eventType: itemDelegate.thing.thingClass.eventTypes.findByName(model.eventName)

                property QtObject eventLogsModel: {
                    if (model.eventName) {
                        if (engine.jsonRpcClient.ensureServerVersion("8.0")) {
                            return eventLogsModelComponent.createObject(sensorValueDelegate)
                        }
                        return legacyEventLogsModelComponent.createObject(sensorValueDelegate)
                    }
                    return null
                }

                Component {
                    id: legacyEventLogsModelComponent
                    LogsModel {
                        objectName: itemDelegate.thing.name + "-" + model.eventName
                        engine: sensorValueDelegate.eventType != null ?  _engine : null
                        thingId: itemDelegate.thing.id
                        typeIds: sensorValueDelegate.eventType != null ? [sensorValueDelegate.eventType.id] : []
                        live: true
                        fetchBlockSize: 1
                    }
                }
                Component {
                    id: eventLogsModelComponent
                    NewLogsModel {
                        engine: _engine
                        source: "event-" + itemDelegate.thing.id + "-" + model.eventName
                        live: true
                        fetchBlockSize: 1
                        Component.onCompleted: fetchLogs()
                    }
                }


                ColorIcon {
                    Layout.preferredHeight: Style.iconSize
                    Layout.preferredWidth: height
                    Layout.alignment: Qt.AlignVCenter
                    color: {
                        switch (model.interfaceName) {
                        case "closablesensor":
                            return sensorValueDelegate.stateValue && sensorValueDelegate.stateValue.value === true ? Style.green : Style.red;
                        case "firesensor":
                            return sensorValueDelegate.stateValue && sensorValueDelegate.stateValue.value === true ? Style.red : Style.iconColor;
                        default:
                            return app.interfaceToColor(model.interfaceName)
                        }
                    }
                    name: {
                        switch (model.interfaceName) {
                        case "closablesensor":
                            return sensorValueDelegate.stateValue && sensorValueDelegate.stateValue.value === true ? Qt.resolvedUrl("qrc:/ui/images/sensors/window-closed.svg") : Qt.resolvedUrl("qrc:/ui/images/sensors/window-open.svg");
                        default:
                            return app.interfacesToIcon([model.interfaceName, "sensor"])
                        }
                    }
                }

                Label {
                    Layout.fillWidth: true
                    property var unit: sensorValueDelegate.stateType ? sensorValueDelegate.stateType.unit : Types.UnitNone
                    text: {
                        switch (model.interfaceName) {
                        case "closablesensor":
                            return sensorValueDelegate.stateValue && sensorValueDelegate.stateValue.value === true ? qsTr("Closed") : qsTr("Open");
                        case "presencesensor":
                            return sensorValueDelegate.stateValue && sensorValueDelegate.stateValue.value === true ? qsTr("Presence") : qsTr("Vacant");
                        case "daylightsensor":
                            return sensorValueDelegate.stateValue && sensorValueDelegate.stateValue.value === true ? qsTr("Daytime") : qsTr("Nighttime");
                        case "watersensor":
                            return sensorValueDelegate.stateValue && sensorValueDelegate.stateValue.value === true ? qsTr("Wet") : qsTr("Dry");
                        case "firesensor":
                            return sensorValueDelegate.stateValue && sensorValueDelegate.stateValue.value === true ? qsTr("Fire") : qsTr("No fire");
                        case "heating":
                            return sensorValueDelegate.stateValue && sensorValueDelegate.stateValue.value === true ? qsTr("On") : qsTr("Off");
                        case "vibrationsensor": {
                            if (eventLogsModel.count > 0) {
                                return qsTr("Last vibration: %1").arg(eventLogsModel.get(0).timestamp.toLocaleString(Qt.locale(), Locale.ShortFormat))
                            } else {
                                return qsTr("Not moved yet")
                            }
                        }
                        default:
                            return sensorValueDelegate.stateType && sensorValueDelegate.stateType.type.toLowerCase() === "bool"
                                    ? sensorValueDelegate.stateType.displayName
                                    : sensorValueDelegate.stateValue
                                      ? "%1 %2".arg(Math.round(Types.toUiValue(sensorValueDelegate.stateValue.value, unit) * 100) / 100).arg(Types.toUiUnit(unit))
                                      : ""
                        }
                    }
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: app.smallFont
                }
                Led {
                    id: led
                    visible: sensorValueDelegate.stateType && sensorValueDelegate.stateType.type.toLowerCase() === "bool" && ["presencesensor", "daylightsensor", "heating", "closablesensor", "watersensor", "firesensor"].indexOf(model.interfaceName) < 0
                    state: visible && sensorValueDelegate.stateValue.value === true ? "on" : "off"
                }
                Item {
                    Layout.preferredWidth: led.width
                    visible: led.visible
                }

            }
        }
    }
}
