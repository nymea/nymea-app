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

    ColumnLayout {
        id: grid
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: app.margins }
        spacing: app.margins

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: mainImageSize

            property int mainImageSize: app.iconSize * 2

            Item {
                Layout.fillWidth: true
                Layout.preferredWidth: (parent.width - parent.mainImageSize) / 2

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
                Layout.preferredWidth: parent.mainImageSize
                Layout.preferredHeight: width
                name: weatherConditionState ? "../images/weathericons/weather-" + weatherConditionState.value + ".svg" : ""
                color: app.foregroundColor
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredWidth: (parent.width - parent.mainImageSize) / 2
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
                        text: (pressureState ? pressureState.value : "N/A") + " mBar"
                    }
                    ColorIcon {
                        name: "../images/weathericons/wind.svg"
                        width: app.iconSize
                        height: width
                        color: app.interfaceToColor("windspeedsensor")
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
