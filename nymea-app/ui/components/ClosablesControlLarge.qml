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
import QtGraphicalEffects 1.0
import Nymea 1.0
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
