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

import QtQuick 2.9
import QtQuick.Controls 2.9
import QtQuick.Layouts 1.2
import Qt.labs.settings 1.1

import "qrc:/ui/components"
import Nymea 1.0

Page {
    id: root

    title: qsTr("WiFi list options")

    property WirelessAccessPointsProxy wirelessAccessPointsProxy: null

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

    Settings {
        id: settings
        property bool wirelessShowDuplicates: false
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: app.margins


        NymeaItemDelegate {
            Layout.fillWidth: true
            text: qsTr("Show all networks")
            subText: qsTr("Multiple networks with the same name get filterd out")
            prominentSubText: false
            progressive: false
            additionalItem: Switch {
                anchors.verticalCenter: parent.verticalCenter
                checked: settings.wirelessShowDuplicates
                onCheckedChanged:  {
                    settings.wirelessShowDuplicates = checked
                    wirelessAccessPointsProxy.showDuplicates = checked
                }
            }
        }
    }
}
