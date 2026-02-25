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

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Nymea

Rectangle {
    id: root
    color: Style.tileBackgroundColor
    property color selectionColor: Style.tileOverlayColor
    radius: Style.smallCornerRadius
    implicitHeight: layout.implicitHeight

    property int currentIndex: 0
    property alias model: repeater.model
    readonly property var currentValue: model.hasOwnProperty("get") ? model.get(currentIndex) : model[currentIndex]

    signal tabSelected(int index)


    Rectangle {
        x: repeater.count > 0 ? repeater.itemAt(root.currentIndex).x + 1 : 0
        anchors.verticalCenter: parent.verticalCenter
        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
        height: layout.height - 2
        width: Math.floor(root.width / repeater.count) - 2
        color: root.selectionColor
        radius: Style.smallCornerRadius
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
                Label {
                    id: label
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    text: modelData
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        print("current index:", index)
                        root.currentIndex = index
                        root.tabSelected(index)
                    }
                }
            }
        }
    }
}
