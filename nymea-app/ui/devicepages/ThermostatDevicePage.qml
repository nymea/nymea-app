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
    readonly property StateType powerStateType: thing.thingClass.stateTypes.findByName("power")
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
        anchors.margins: Style.margins
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
            color: Style.white
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
