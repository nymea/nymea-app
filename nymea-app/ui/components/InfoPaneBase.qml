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

Item {
    id: root
    implicitHeight: d.shownHeight
    visible: d.shownHeight > 0

    property alias color: background.color
    property bool shown: false

    property alias contentItem: content.data

    function show() {
        shown = true;
    }
    function hide() {
        shown = false;
    }

    signal clicked();

    QtObject {
        id: d
        property int shownHeight: shown ? content.implicitHeight : 0
        Behavior on shownHeight { NumberAnimation { easing.type: Easing.InOutQuad; duration: 150 } }
    }

    Pane {
        anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
//        Material.elevation: 2
        leftPadding: 0
        rightPadding: 0
        bottomPadding: 0
        topPadding: 0
        height: content.implicitHeight

        MouseArea {
            anchors.fill: parent
            onClicked: root.clicked()
        }

        Rectangle {
            id: background
            color: Style.accentColor
            anchors.fill: parent
        }

        Item {
            id: content
            anchors { left: parent.left; top: parent.top; right: parent.right; leftMargin: app.margins; rightMargin: app.margins; topMargin: app.margins / 2 }
            implicitHeight: childrenRect.height + app.margins
        }
    }
}


