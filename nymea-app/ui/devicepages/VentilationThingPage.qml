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
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../utils"

ThingPageBase {
    id: root

    readonly property State powerState: thing.stateByName("power")
    readonly property State autoState: thing.stateByName("auto")
    readonly property State flowRateState: thing.stateByName("flowRate")
    readonly property StateType flowRateStateType: thing.thingClass.stateTypes.findByName("flowRate")

    ActionQueue {
        id: actionQueue
        thing: root.thing
        stateName: "power"
    }

    GridLayout {
        anchors.fill: parent
        anchors.margins: Style.margins
        columns: app.landscape ? 2 : 1

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Style.bigMargins
            implicitWidth: 400
            implicitHeight: 400

            CircleBackground {
                id: background
                anchors.fill: parent
                iconSource: "ventilation"
                onColor: app.interfaceToColor("ventilation")
                showOnGradient: root.flowRateState == null
                on: (actionQueue.pendingValue || powerState.value) === true
                PropertyAnimation on rotation {
                    running: root.powerState.value === true
                    duration: 2000
                    from: 0
                    to: 360
                    loops: Animation.Infinite
                    onDurationChanged: {
                        running = false;
                        running = true;
                    }
                }
            }

            Dial {
                anchors.centerIn: background
                height: background.contentItem.height
                width: background.contentItem.width
                visible: root.flowRateState
                on: (actionQueue.pendingValue || powerState.value) === true
                value: valueActionQueue.pendingValue || flowRateState.value
                onMoved: valueActionQueue.sendValue(value)
                color: app.interfaceToColor("ventilation")
                minValue: root.flowRateState.minValue
                maxValue: root.flowRateState.maxValue

                onClicked: {
                    PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                    actionQueue.sendValue(!root.powerState.value)
                }

                ActionQueue {
                    id: valueActionQueue
                    thing: root.thing
                    stateName: "flowRate"

                }
            }


//            StateDial {
//                anchors.centerIn: background
//                height: background.contentItem.height
//                width: background.contentItem.width
//                visible: root.flowRateState
//                on: (actionQueue.pendingValue || powerState.value) === true

//                thing: root.thing
//                stateName: "flowRate"
//                color: app.interfaceToColor("ventilation")
//            }
        }

        ProgressButton {
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: Style.bigMargins
            size: Style.largeIconSize
            imageSource: ""
            color: Style.white
            backgroundColor: Style.accentColor
            visible: root.autoState
            busy: autoActionQueue.pendingValue ? autoActionQueue.pendingValue : (root.autoState && root.autoState.value === true)
            onClicked: autoActionQueue.sendValue(!root.autoState.value)

            Label {
                anchors.centerIn: parent
                text: "A"
                font.pixelSize: parent.height / 2
            }

            ActionQueue {
                id: autoActionQueue
                thing: root.thing
                stateName: "auto"
            }
        }
    }




}
