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

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"

Item {
    id: root

    property string title: ""

    property bool isCurrentItem: false

    property int topMargin: 40
    property int bottomMargin: 64
    property int contentY: 0 // Relative to topMargin

    property var headerButtons: []

    // Override this to receive events (e.g. from push notification bubbles)
    function handleEvent(data) {
        print("handleEvent not implemented in", title)
    }

    // Prevent scroll events to swipe left/right in case they fall through the grid
    MouseArea {
        anchors.fill: parent
        preventStealing: true
        onWheel: wheel.accepted = true
    }
}
