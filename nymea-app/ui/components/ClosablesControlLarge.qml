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
import QtQuick.Controls.Material
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Nymea

import "../customviews"

Item {
    id: root

    property Thing thing: null
    readonly property ThingClass thingClass: thing.thingClass

    readonly property string type: "shutter"
    readonly property bool isExtended: thing.thingClass.interfaces.indexOf("extendedclosable") >= 0

    readonly property State movingState: isExtended ? thing.states.getState(thingClass.stateTypes.findByName("moving").id) : 0
    readonly property State percentageState: isExtended ? thing.states.getState(thingClass.stateTypes.findByName("percentage").id) : 0

    readonly property bool moving: movingState ? movingState.value : false
    readonly property int percentage: percentageState ? percentageState.value : 50

    onMovingChanged: {
        if (!moving) {
            movable.visible = false;
        }
    }

    Item {
        id: content
        height: Math.min(root.width, root.height)
        width: height

        readonly property int minY: height * 0.09
        readonly property int maxY: height * 0.91

        ColorIcon {
            anchors.fill: parent
            name: "qrc:/icons/" + root.type + "/" + root.type + "-000.svg"
        }


        Item {
            id: inlay
            anchors.fill: parent
            visible: false

            ColorIcon {
                width: parent.width
                height: parent.height
                name: "qrc:/icons/" + root.type + "/" + root.type + "-inlay.svg"
                property int movingHeight: content.maxY - content.minY
                y: -height + (height - movingHeight) + (root.percentage / 100 * movingHeight)
            }
        }

        Item {
            id: movableSource
            anchors.fill: parent
            visible: false

            ColorIcon {
                id: movableContent
                width: parent.width
                height: parent.height
                name: "qrc:/icons/" + root.type + "/" + root.type + "-inlay.svg"
                color: Style.foregroundColor
            }
        }
        OpacityMask {
            id: movable
            anchors.fill: parent
            source: movableSource
            maskSource: mask
            opacity: .1
            visible: false
        }

        Item {
            id: mask
            anchors.fill: parent
            visible: false

            Rectangle {
                anchors.fill: parent
                color: "blue"
                anchors.margins: parent.height * .09
            }
        }

        OpacityMask {
            anchors.fill: parent
            source: inlay
            maskSource: mask
        }


        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: parent.width / 6
            height: 2
            color: Style.accentColor
            y: Math.max(parent.minY, Math.min(parent.maxY, dragArea.mouseY))
            visible: root.isExtended && dragArea.containsMouse
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            hoverEnabled: true
            readonly property int percentage: Math.max(0, Math.min(100, 100 * (mouseY - parent.minY) / (parent.maxY - parent.minY)))

            onPressed: movable.visible = root.isExtended
            onMouseYChanged: if (pressed) movableContent.y = Math.min(content.maxY, Math.max(0, dragArea.mouseY)) - height + content.minY
            onReleased: {
                print("released on", percentage)

                if (root.isExtended) {
                    var actionType = root.thingClass.actionTypes.findByName("percentage");
                    var params = [];
                    var percentageParam = {}
                    percentageParam["paramTypeId"] = actionType.paramTypes.findByName("percentage").id;
                    percentageParam["value"] = percentage
                    params.push(percentageParam);
                    print("executing", percentage)
                    engine.thingManager.executeAction(root.thing.id, actionType.id, params);

                }
            }
        }
    }
}
