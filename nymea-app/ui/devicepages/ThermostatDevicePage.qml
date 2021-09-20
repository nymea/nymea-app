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
import "../utils"

ThingPageBase {
    id: root

    readonly property bool landscape: width > height

    readonly property StateType targetTemperatureStateType: thing.thingClass.stateTypes.findByName("targetTemperature")
    readonly property State targetTemperatureState: targetTemperatureStateType ? thing.states.getState(targetTemperatureStateType.id) : null
    readonly property StateType powerStateType: thingClass.stateTypes.findByName("power")
    readonly property State powerState: powerStateType ? thing.states.getState(powerStateType.id) : null
    readonly property StateType temperatureStateType: thing.thingClass.stateTypes.findByName("temperature")
    readonly property State temperatureState: temperatureStateType ? thing.states.getState(temperatureStateType.id) : null
    readonly property StateType percentageStateType: thing.thingClass.stateTypes.findByName("percentage")
    readonly property State percentageState: percentageStateType ? thing.states.getState(percentageStateType.id) : null
    // TODO: should this be an interface? e.g. extendedthermostat
    readonly property StateType boostStateType: thing.thingClass.stateTypes.findByName("boost")
    readonly property State boostState: boostStateType ? thing.states.getState(boostStateType.id) : null

    GridLayout {
        anchors.fill: parent
        anchors.margins: app.margins
        columns: app.landscape ? 2 : 1

        CircleBackground {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Style.bigMargins
            ThermostatController {
                anchors.centerIn: parent
                height: Math.min(400, Math.min(parent.height, parent.width))
                width: height
                thing: root.thing
            }
        }

        ProgressButton {
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: Style.bigMargins
            size: Style.largeIconSize
            imageSource: "thermostat/heating"
            backgroundColor: app.interfaceToColor("heating")
            visible: root.boostState
            busy: actionQueue.pendingValue ? actionQueue.pendingValue : (root.boostState && root.boostState.value === true)
            onClicked: actionQueue.sendValue(!root.boostState.value)

            ActionQueue {
                id: actionQueue
                thing: root.thing
                stateName: "boost"
            }
        }
    }
}
