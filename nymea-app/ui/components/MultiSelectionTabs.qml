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

import QtQuick 2.12
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import Nymea 1.0

Rectangle {
    id: root
    implicitHeight: layout.implicitHeight
    radius: Style.smallCornerRadius

    property alias backgroundColor: root.color
    property color selectionColor: Style.tileOverlayColor
    property alias model: repeater.model
    property var selectedItems: []

    Rectangle {
        id: clipMask
        anchors.fill: parent
        radius: Style.smallCornerRadius
        color: "red"
        visible: false
    }

    RowLayout {
        id: layout
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
        spacing: 0

        Repeater {
            id: repeater

            delegate: Item {
                Layout.fillWidth: true
                height: label.implicitHeight + Style.smallMargins
                Rectangle {
                    anchors.fill: parent
                    color: root.selectionColor
                    visible: root.selectedItems.indexOf(index) >= 0
                }

                Label {
                    id: label
                    anchors.centerIn: parent
                    text: modelData
                    font: Style.font
                }
            }
        }
    }

    OpacityMask {
        anchors.fill: parent
        maskSource: clipMask
        source: ShaderEffectSource {
            sourceItem: layout
            hideSource: true
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            var index = Math.floor(mouseX / (width / root.model.length))
            var tmp = [...root.selectedItems]
            var idx = tmp.indexOf(index)
            if (idx >= 0) {
                tmp.splice(idx, 1)
            } else {
                tmp.push(index)
            }

            root.selectedItems = tmp
        }
    }
}


