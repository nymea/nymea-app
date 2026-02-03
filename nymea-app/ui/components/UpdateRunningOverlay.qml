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

Rectangle {
    anchors.fill: parent
    color: Material.background
    visible: engine.systemController.updateRunning

    // Event eater
    MouseArea {
        anchors.fill: parent
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width

        ColorIcon {
            height: Style.iconSize * 3
            width: height
            Layout.alignment: Qt.AlignHCenter
            name: Qt.resolvedUrl("qrc:/icons/system-update.svg")
            color: Style.accentColor
            PropertyAnimation on rotation {
                from: 0; to: 360;
                duration: 2000
                loops: Animation.Infinite
//                onStopped: start(); // No clue why loops won't work
            }
        }

        Label {
            Layout.fillWidth: true
            Layout.margins: app.margins * 2
            text: qsTr("System update in progress...")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: app.largeFont
        }

        ProgressBar {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            visible: engine.systemController.updateProgress >=  0
            value: engine.systemController.updateProgress / 100.0
        }

        Label {
            Layout.fillWidth: true
            Layout.margins: app.margins * 2
            text: qsTr("Please wait")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
        Label {
            Layout.fillWidth: true
            Layout.margins: app.margins * 2
            text: qsTr("The system may restart in order to complete the update. %1:app will reconnect automatically after the update.").arg(Configuration.systemName)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: app.smallFont
        }
    }
}
