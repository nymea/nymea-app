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

    Component.onCompleted: {
        print("d:", root.device, root.targetTemperatureStateType, root.percentageStateType)
    }

    GridLayout {
        anchors.fill: parent
        anchors.margins: app.margins
        columns: app.landscape ? 2 : 1

        Dial {
            id: dial
            Layout.fillWidth: true
            Layout.fillHeight: true
//            visible: root.targetTemperatureStateType || root.percentageStateType

            device: root.device
            stateType: root.targetTemperatureStateType ? root.targetTemperatureStateType : root.percentageStateType

        }

        Rectangle {
            Layout.preferredWidth: app.landscape ? parent.width / 2 : parent.width
            Layout.preferredHeight: 50
            visible: root.boostStateType
            border.color: boostMouseArea.pressed || root.boostStateType && root.boostState.value === true ? Style.accentColor : Style.foregroundColor
            border.width: 1
            radius: height / 2
            color: root.boostStateType && root.boostState.value === true ? Style.accentColor : "transparent"

            Row {
                anchors.centerIn: parent
                spacing: app.margins / 2
                ColorIcon {
                    height: app.iconSize
                    width: app.iconSize
                    name: "../images/sensors/temperature.svg"
                    color: root.boostStateType && root.boostState.value === true ? "red" : Style.iconColor
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
