import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import "../components"

CustomViewBase {
    id: root
    height: grid.implicitHeight + app.margins * 2

    readonly property var weatherConditionStateType: deviceClass.stateTypes ? deviceClass.stateTypes.findByName("weatherCondition") : null
    readonly property var weatherConditionState: weatherConditionStateType && device.states ? device.states.getState(weatherConditionStateType.id) : null

    readonly property var weatherDescriptionStateType: deviceClass.stateTypes ? deviceClass.stateTypes.findByName("weatherDescription") : null
    readonly property var weatherDescriptionState: weatherDescriptionStateType && device.states ? device.states.getState(weatherDescriptionStateType.id) : null

    readonly property var temperatureStateType: deviceClass.stateTypes ? deviceClass.stateTypes.findByName("temperature") : null
    readonly property var temperatureState: temperatureStateType && device.states ? device.states.getState(temperatureStateType.id) : null

    readonly property var humidityStateType: deviceClass.stateTypes ? deviceClass.stateTypes.findByName("humidity") : null
    readonly property var humidityState: humidityStateType && device.states ? device.states.getState(humidityStateType.id) : null

    readonly property var pressureStateType: deviceClass.stateTypes ? deviceClass.stateTypes.findByName("pressure") : null
    readonly property var pressureState: pressureStateType && device.states ? device.states.getState(pressureStateType.id) : null

    readonly property var windDirectionStateType: deviceClass.stateTypes ? deviceClass.stateTypes.findByName("windDirection") : null
    readonly property var windDirectionState: windDirectionStateType && device.states ? device.states.getState(windDirectionStateType.id) : null

    readonly property var windSpeedStateType: deviceClass.stateTypes ? deviceClass.stateTypes.findByName("windSpeed") : null
    readonly property var windSpeedState: windSpeedStateType && device.states ? device.states.getState(windSpeedStateType.id) : null

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
                        text: (temperatureState ? Math.round(temperatureState.value * 10) / 10 : "N/A") + " °"
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
