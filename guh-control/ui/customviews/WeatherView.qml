import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1

CustomViewBase {
    id: root
    height: grid.implicitHeight + app.margins * 2

    readonly property var weatherIconStateType: deviceClass.stateTypes ? deviceClass.stateTypes.findByName("weatherIcon") : null
    readonly property var weatherIconState: weatherIconStateType && device.states ? device.states.getState(weatherIconStateType.id) : null

    readonly property var temperatureStateType: deviceClass.stateTypes ? deviceClass.stateTypes.findByName("temperature") : null
    readonly property var temperatureState: temperatureStateType && device.states ? device.states.getState(temperatureStateType.id) : null

    readonly property var minTemperatureStateType: deviceClass.stateTypes ? deviceClass.stateTypes.findByName("temperature minimum") : null
    readonly property var minTemperatureState: minTemperatureStateType && device.states ? device.states.getState(minTemperatureStateType.id) : null

    readonly property var maxTemperatureStateType: deviceClass.stateTypes ? deviceClass.stateTypes.findByName("temperature maximum") : null
    readonly property var maxTemperatureState: maxTemperatureStateType && device.states ? device.states.getState(maxTemperatureStateType.id) : null

    ColumnLayout {
        id: grid
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: app.margins }

        RowLayout {
            Layout.fillWidth: true

            Label {
                text: (temperatureState ? temperatureState.value : "N/A") + " °"
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width
                font.pixelSize: app.largeFont
                horizontalAlignment: Text.AlignHCenter
            }

            Image {
                // h : w = ss.h : ss.w
                Layout.preferredWidth: height * implicitWidth / implicitHeight
                Layout.preferredHeight: app.largeFont * 4
                source: weatherIconState ? "../images/weathericons/weather-" + weatherIconState.value + "-symbolic.svg" : ""
                sourceSize.height: height
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width
                Label {
                    Layout.fillWidth: true
                    text: maxTemperatureState ? (maxTemperatureState.value + "°") : ""
                    horizontalAlignment: Text.AlignHCenter
                }
                Label {
                    Layout.fillWidth: true
                    text: minTemperatureState ? (minTemperatureState.value + "°") : ""
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

    }
}
