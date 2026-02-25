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
import QtQuick.Layouts
import QtQuick.Controls
import Nymea

import "../components"

Item {
    id: root
    implicitHeight: grid.implicitHeight + app.margins * 2

    property Thing thing: null

    readonly property State weatherConditionState: thing.stateByName("weatherCondition")
    readonly property State weatherDescriptionState: thing.stateByName("weatherDescription")
    readonly property State temperatureState: thing.stateByName("temperature")
    readonly property State humidityState: thing.stateByName("humidity")
    readonly property State pressureState: thing.stateByName("pressure")
    readonly property State windDirectionState: thing.stateByName("windDirection")
    readonly property State windSpeedState: thing.stateByName("windSpeed")

    readonly property StateType temperatureStateType: thing.thingClass.stateTypes.findByName("temperature")
    readonly property StateType pressureStateType: thing.thingClass.stateTypes.findByName("pressure")
    readonly property StateType windSpeedStateType: thing.thingClass.stateTypes.findByName("windSpeed")

    ColumnLayout {
        id: grid
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: app.margins }
        spacing: app.margins

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: mainImageSize
            spacing: Style.margins

            property int mainImageSize: Style.iconSize * 2

            Item {
                Layout.fillWidth: true
                Layout.preferredWidth: (parent.width - parent.mainImageSize) / 2 - Style.margins

                GridLayout {
                    anchors.centerIn: parent
                    columns: 2
                    ColorIcon {
                        name: "qrc:/icons/sensors/temperature.svg"
                        Layout.preferredWidth: Style.iconSize
                        Layout.preferredHeight: width
                        color: app.interfaceToColor("temperaturesensor")
                    }
                    Label {
                        text: (temperatureState ? "%1 %2".arg(Math.round(Types.toUiValue(temperatureState.value, temperatureStateType.unit) * 10) / 10).arg(Types.toUiUnit(temperatureStateType.unit)) : "N/A")
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    ColorIcon {
                        name: "qrc:/icons/weathericons/humidity.svg"
                        Layout.preferredWidth: Style.iconSize
                        Layout.preferredHeight: width
                        color: app.interfaceToColor("humiditysensor")
                    }
                    Label {
                        text: (humidityState ? humidityState.value : "N/A") + " %"
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            ColorIcon {
                id: mainImage
                Layout.preferredWidth: parent.mainImageSize
                Layout.preferredHeight: width
                name: weatherConditionState ? "qrc:/icons/weathericons/weather-" + weatherConditionState.value + ".svg" : ""
                color: Style.foregroundColor
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredWidth: (parent.width - parent.mainImageSize) / 2 - Style.margins
                GridLayout {
                    columns: 2
                    anchors.centerIn: parent
                    ColorIcon {
                        name: "qrc:/icons/sensors/pressure.svg"
                        width: Style.iconSize
                        height: width
                        color: app.interfaceToColor("pressuresensor")
                    }

                    Label {
                        text: (pressureState ? "%1 %2".arg(Types.toUiValue(pressureState.value, pressureStateType.unit)).arg(Types.toUiUnit(pressureStateType.unit)) : "N/A")
                    }
                    ColorIcon {
                        name: "qrc:/icons/weathericons/wind.svg"
                        width: Style.iconSize
                        height: width
                        color: app.interfaceToColor("windspeedsensor")
                    }

                    Label {
                        text: windSpeedState && windDirectionState ? "%1 %2 %3".arg(Types.toUiValue(windSpeedState.value, windSpeedStateType.unit)).arg(Types.toUiUnit(windSpeedStateType.unit)).arg(angleToOrientation(windDirectionState.value)) : "N/A"
                        function angleToOrientation(windAngle) {
                            if (windAngle < 23) {
                                return qsTr("N");
                            } else if (windAngle < 68) {
                                return qsTr("NE");
                            } else if (windAngle < 113) {
                                return qsTr("E");
                            } else if (windAngle < 156) {
                                return qsTr("SE");
                            } else if (windAngle < 203) {
                                return qsTr("S");
                            } else if (windAngle < 248) {
                                return qsTr("SW");
                            } else if (windAngle < 293) {
                                return qsTr("W");
                            } else if (windAngle < 338) {
                                return qsTr("NW");
                            }

                            return qsTr("N");
                        }
                    }
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: weatherDescriptionState.value
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
