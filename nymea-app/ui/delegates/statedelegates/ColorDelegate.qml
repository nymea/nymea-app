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
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Nymea

import "../../components"

Item {
    id: colorComponentItem
    implicitWidth: Style.iconSize * 2
    implicitHeight: Style.iconSize
    property bool writable: false
    property var value
    signal changed(var value)

    Pane {
        anchors.fill: parent
        topPadding: 0
        bottomPadding: 0
        leftPadding: 0
        rightPadding: 0
        Material.elevation: 1
        contentItem: Rectangle {
            color: colorComponentItem.value

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (!colorComponentItem.writable) {
                        return;
                    }

                    var pos = colorComponentItem.mapToItem(root, 0, colorComponentItem.height)
                    print("opening", colorComponentItem.value)
                    var colorPicker = colorPickerComponent.createObject(root, {preferredY: pos.y, colorValue: colorComponentItem.value })
                    colorPicker.open()
                }
            }
        }
    }

    Component {
        id: colorPickerComponent
        Dialog {
            id: colorPickerDialog
            modal: true
            x: (parent.width - width) / 2
            y: Math.min(preferredY, parent.height - height)
            width: parent.width - app.margins * 2
            height: 200
            padding: app.margins
            property var colorValue
            property int preferredY: 0
            contentItem: ColorPickerPre510 {
                color: colorPickerDialog.colorValue
                property var lastSentTime: new Date()
                onColorChanged: {
                    var currentTime = new Date();
                    if (pressed && currentTime - lastSentTime > 200) {
                        colorComponentItem.changed(color);
                    }
                }
            }
        }
    }
}
