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
import QtQuick.Layouts
import Nymea

Page {
    id: root
    header: NymeaHeader {
        text: root.title
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    default property alias content: contentColumn.data
    property alias busy: busyOverlay.shown
    property alias busyText: busyOverlay.text

    BackgroundFocusHandler { anchors.fill: parent }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: contentColumn.height + Style.margins
        interactive: contentHeight > height
        clip: true

        ScrollBar.vertical: ScrollBar {}

        ColumnLayout {
            id: contentColumn
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(500, flickable.width)
        }
    }

    BusyOverlay {
        id: busyOverlay
    }
}
