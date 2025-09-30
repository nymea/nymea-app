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

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import Nymea

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
