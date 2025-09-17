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

import "../components"
import "../delegates"

Item {
    id: root
    opacity: shown ? 1 : 0
    implicitWidth: searchColumn.implicitWidth
    implicitHeight: shown ? searchColumn.implicitHeight : 0
    Behavior on implicitHeight {NumberAnimation { duration: 130; easing.type: Easing.InOutQuad }}

    property bool shown: false
    property alias text: searchTextField.displayText

    ColumnLayout {
        id: searchColumn
        anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
        RowLayout {
            Layout.margins: app.margins
            spacing: app.margins
            TextField {
                id: searchTextField
                Layout.fillWidth: true
            }

            HeaderButton {
                imageSource: "qrc:/icons/erase.svg"
                onClicked: searchTextField.text = ""
                enabled: searchTextField.displayText.length > 0
                color: enabled ? Style.accentColor : Style.iconColor
            }
        }
        ThinDivider {}
    }
}
