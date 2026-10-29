// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2024 - 2026, chargebyte austria GmbH
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

import "qrc:/ui/components"

Page {
    id: root

    title: qsTr("Network settings options")

    // The Settings object of the network settings page, so changes apply immediately
    property var networkSettings: null
    property bool interfaceListAvailable: false
    property bool networkManagerControlsAvailable: false

    header: Item {

        height: 28 + 2 * Style.margins

        RowLayout {
            anchors.fill: parent
            spacing: app.margins

            HeaderButton {
                id: backButton
                objectName: "backButton"
                imageSource: "qrc:/icons/back.svg"
                onClicked: pageStack.pop();
            }

            Label {
                Layout.fillWidth: true
                id: titleLabel
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: root.title
                font.pixelSize: app.largeFont
            }
        }
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: app.margins

        NymeaItemDelegate {
            Layout.fillWidth: true
            text: qsTr("Show all network interfaces")
            subText: qsTr("Loopback, bridge and unknown network interfaces are hidden otherwise")
            prominentSubText: false
            progressive: false
            visible: root.interfaceListAvailable
            additionalItem: Switch {
                anchors.verticalCenter: parent.verticalCenter
                checked: root.networkSettings ? root.networkSettings.showAllInterfaces : false
                onToggled: root.networkSettings.showAllInterfaces = checked
            }
        }

        NymeaItemDelegate {
            Layout.fillWidth: true
            text: qsTr("Show dangerous options")
            subText: qsTr("Show options to disable networking or WiFi and to disconnect network interfaces")
            prominentSubText: false
            progressive: false
            visible: root.networkManagerControlsAvailable
            additionalItem: Switch {
                anchors.verticalCenter: parent.verticalCenter
                checked: root.networkSettings ? root.networkSettings.showDangerousOptions : false
                onToggled: root.networkSettings.showDangerousOptions = checked
            }
        }
    }
}
