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
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"
import "../utils"

ThingPageBase {
    id: root

    readonly property bool landscape: width > height
    readonly property bool isExtended: thing.thingClass.interfaces.indexOf("extendedawning") >= 0
    readonly property State percentageState: thing.stateByName("percentage")
    readonly property State movingState: thing.stateByName("moving")

    GridLayout {
        anchors.fill: parent
        columns: root.landscape ? 2 : 1

        CircleBackground {
            id: background
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: Style.hugeMargins
            onColor: Style.yellow
            on: true
            iconSource: "weathericons/weather-clear-day"

            ActionQueue {
                id: actionQueue
                thing: root.thing
                stateName: "percentage"
            }

            Item {
                id: awning
                anchors.fill: parent


                Rectangle {
                    anchors.centerIn: parent
                    width: background.contentItem.width
                    height: background.contentItem.height
                    property real progress: root.percentageState ?
                                                dragArea.pressed ? dragArea.draggedProgress : root.percentageState.value  / 100
                                              : .5
                    anchors.verticalCenterOffset: -height * (1 - progress)
                    color: Style.tileOverlayColor
                }
            }

            OpacityMask {
                anchors.fill: background
                source: ShaderEffectSource {
                    sourceItem: awning
                    hideSource: true
                }
                maskSource: background
            }

            MouseArea {
                id: dragArea
                anchors.centerIn: parent
                width: background.contentItem.width
                height: background.contentItem.height
                property real draggedProgress: mouseY / height
                onMouseYChanged: print("mouseY", mouseY, draggedProgress)
                onReleased: {
                    actionQueue.sendValue(draggedProgress * 100)
                }
            }
        }


        ShutterControls {
            id: shutterControls
            Layout.fillWidth: true
            Layout.minimumWidth: implicitWidth
            Layout.preferredHeight: implicitHeight

            thing: root.thing
            size: Style.bigIconSize
            backgroundEnabled: true
            invert: true
        }
    }
}
