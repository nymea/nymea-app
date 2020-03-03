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
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import "../components"
import Nymea 1.0

CustomViewBase {
    id: root
    height: grid.implicitHeight + app.margins * 2

    readonly property StateType weatherConditionStateType: deviceClass.stateTypes ? deviceClass.stateTypes.findByName("weatherCondition") : null
    readonly property State weatherConditionState: weatherConditionStateType && device.states ? device.states.getState(weatherConditionStateType.id) : null

    readonly property StateType weatherDescriptionStateType: deviceClass.stateTypes ? deviceClass.stateTypes.findByName("weatherDescription") : null
    readonly property State weatherDescriptionState: weatherDescriptionStateType && device.states ? device.states.getState(weatherDescriptionStateType.id) : null

    readonly property StateType temperatureStateType: deviceClass.stateTypes ? deviceClass.stateTypes.findByName("temperature") : null
    readonly property State temperatureState: temperatureStateType && device.states ? device.states.getState(temperatureStateType.id) : null

    readonly property StateType humidityStateType: deviceClass.stateTypes ? deviceClass.stateTypes.findByName("humidity") : null
    readonly property State humidityState: humidityStateType && device.states ? device.states.getState(humidityStateType.id) : null

    readonly property StateType pressureStateType: deviceClass.stateTypes ? deviceClass.stateTypes.findByName("pressure") : null
    readonly property State pressureState: pressureStateType && device.states ? device.states.getState(pressureStateType.id) : null

    readonly property StateType windDirectionStateType: deviceClass.stateTypes ? deviceClass.stateTypes.findByName("windDirection") : null
    readonly property State windDirectionState: windDirectionStateType && device.states ? device.states.getState(windDirectionStateType.id) : null

    readonly property StateType windSpeedStateType: deviceClass.stateTypes ? deviceClass.stateTypes.findByName("windSpeed") : null
    readonly property State windSpeedState: windSpeedStateType && device.states ? device.states.getState(windSpeedStateType.id) : null

    ColumnLayout {
        id: grid
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: app.margins }
        spacing: app.margins

        RowLayout {
            Layout.fillWidth: true

            Item {
                Layout.fillWidth: true
                Layout.preferredWidth: (parent.width - mainImage.width) / 2

                GridLayout {
                    anchors.centerIn: parent
                    columns: 2
                    ColorIcon {
                        name: "../images/sensors/temperature.svg"
                        Layout.preferredWidth: app.iconSize
                        Layout.preferredHeight: width
                        color: app.interfaceToColor("temperaturesensor")
                    }
                    Label {
                        text: (temperatureState ? Math.round(Types.toUiValue(temperatureState.value, temperatureStateType.unit) * 10) / 10 : "N/A") + " °"
                        Layout.fillWidth: true
                        font.pixelSize: app.largeFont
                        horizontalAlignment: Text.AlignHCenter
                    }
                    ColorIcon {
                        name: "../images/weathericons/humidity.svg"
                        Layout.preferredWidth: app.iconSize
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
                Layout.preferredWidth: app.largeFont * 4
                Layout.preferredHeight: app.largeFont * 4
                name: weatherConditionState ? "../images/weathericons/weather-" + weatherConditionState.value + ".svg" : ""
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredWidth: (parent.width - mainImage.width) / 2
                GridLayout {
                    columns: 2
                    anchors.centerIn: parent
                    ColorIcon {
                        name: "../images/sensors/pressure.svg"
                        width: app.iconSize
                        height: width
                        color: app.interfaceToColor("pressuresensor")
                    }

                    Label {
                        text: (pressureState ? pressureState.value : "N/A") + " %"
                    }
                    ColorIcon {
                        name: "../images/weathericons/wind.svg"
                        width: app.iconSize
                        height: width
                    }

                    Label {
                        text: windSpeedState && windDirectionState ? "%1 km/h %2".arg(windSpeedState.value).arg(angleToOrientation(windDirectionState.value)) : "N/A"
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
