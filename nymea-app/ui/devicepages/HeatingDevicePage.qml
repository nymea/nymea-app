import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

DevicePageBase {
    id: root

    readonly property bool landscape: width > height

    readonly property StateType targetTemperatureStateType: device.deviceClass.stateTypes.findByName("targetTemperature")
    readonly property State targetTemperatureState: targetTemperatureStateType ? device.states.getState(targetTemperatureStateType.id) : null
    readonly property StateType powerStateType: deviceClass.stateTypes.findByName("power")
    readonly property State powerState: powerStateType ? device.states.getState(powerStateType.id) : null
    readonly property StateType temperatureStateType: device.deviceClass.stateTypes.findByName("temperature")
    readonly property State temperatureState: temperatureStateType ? device.states.getState(temperatureStateType.id) : null
    readonly property StateType percentageStateType: device.deviceClass.stateTypes.findByName("percentage")
    readonly property State percentageState: percentageStateType ? device.states.getState(percentageStateType.id) : null
    // TODO: should this be an interface? e.g. extendedthermostat
    readonly property StateType boostStateType: device.deviceClass.stateTypes.findByName("boost")
    readonly property State boostState: boostStateType ? device.states.getState(boostStateType.id) : null


    GridLayout {
        anchors.fill: parent
        anchors.margins: app.margins
        columns: app.landscape ? 2 : 1

        Dial {
            id: dial
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.targetTemperatureStateType || root.percentageStateType

            device: root.device
            stateType: root.targetTemperatureStateType ? root.targetTemperatureStateType : root.percentageStateType
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            visible: root.boostStateType
            border.color: boostMouseArea.pressed || root.boostStateType && root.boostState.value === true ? app.accentColor : app.foregroundColor
            border.width: 1
            radius: height / 2
            color: root.boostStateType && root.boostState.value === true ? app.accentColor : "transparent"

            Row {
                anchors.centerIn: parent
                spacing: app.margins / 2
                ColorIcon {
                    height: app.iconSize
                    width: app.iconSize
                    name: "../images/sensors/temperature.svg"
                    color: root.boostStateType && root.boostState.value === true ? "red" : keyColor
                }

                Label {
                    text: qsTr("Boost")
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            MouseArea {
                id: boostMouseArea
                anchors.fill: parent
                onPressedChanged: PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackImpact)
                onClicked: {
                    var params = []
                    var param = {}
                    param["paramTypeId"] = root.boostStateType.id
                    param["value"] = !root.boostState.value
                    params.push(param)
                    engine.deviceManager.executeAction(root.device.id, root.boostStateType.id, params);
                }
            }
        }
    }
}
