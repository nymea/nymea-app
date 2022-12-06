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

ThingsListPageBase {
    id: root

    header: NymeaHeader {
        text: root.shownInterfaces.indexOf("heating") >= 0 ? qsTr("Heating") : qsTr("Sensors")
        onBackPressed: pageStack.pop()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentGrid.implicitHeight
        topMargin: app.margins / 2
        clip: true

        GridLayout {
            id: contentGrid
            width: parent.width - app.margins
            anchors.horizontalCenter: parent.horizontalCenter
            columns: Math.ceil(width / 600)
            rowSpacing: 0
            columnSpacing: 0

            Repeater {
                model: root.thingsProxy

                delegate: BigThingTile {
                    id: itemDelegate
                    Layout.preferredWidth: contentGrid.width / contentGrid.columns
                    thing: root.thingsProxy.getThing(model.id)

                    onClicked: {
                        // we show all "sensors" in shownInterfaces in here so the "sensors" view would be the best match, but for sensors
                        // that should show the input trigger view instead, we need to override that
                        if (thing.thingClass.interfaces.indexOf("vibrationsensor") >= 0) {
                            enterPage(index, "inputtrigger")
                        } else {
                            enterPage(index)
                        }
                    }

                    contentItem: GridLayout {
                        id: dataGrid
                        columns: Math.floor(contentItem.width / 120)

                        Repeater {
                            model: ListModel {
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

                            delegate: RowLayout {
                                id: sensorValueDelegate
                                visible: itemDelegate.thing.thingClass.interfaces.indexOf(model.interfaceName) >= 0
                                Layout.preferredWidth: contentItem.width / dataGrid.columns

                                property StateType stateType: itemDelegate.thing.thingClass.stateTypes.findByName(model.stateName)
                                property State stateValue: stateType ? itemDelegate.thing.states.getState(stateType.id) : null

                                property EventType eventType: itemDelegate.thing.thingClass.eventTypes.findByName(model.eventName)
                                LogsModel {
                                    id: eventLogsModel
                                    engine: sensorValueDelegate.eventType != null ?  _engine : null
                                    thingId: itemDelegate.thing.id
                                    typeIds: sensorValueDelegate.eventType != null ? [sensorValueDelegate.eventType.id] : []
                                    live: true
                                    fetchBlockSize: 1
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
                                            return sensorValueDelegate.stateValue && sensorValueDelegate.stateValue.value === true ? Qt.resolvedUrl("../images/lock-closed.svg") : Qt.resolvedUrl("../images/lock-open.svg");
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
            }
        }
    }
}
