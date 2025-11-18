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
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Dialog {
    id: certDialog
    width: Math.min(parent.width * .9, 400)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    standardButtons: Dialog.Ok

    property string serverUuid
    property var issuerInfo

    ColumnLayout {
        id: certLayout
        anchors.fill: parent
        //                spacing: app.margins

        RowLayout {
            Layout.fillWidth: true
            spacing: app.margins
            ColorIcon {
                Layout.preferredHeight: Style.iconSize * 2
                Layout.preferredWidth: height
                name: "qrc:/icons/lock-closed.svg"
                color: Style.accentColor
            }

            Label {
                id: titleLabel
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: qsTr("Certificate information")
                color: Style.accentColor
                font.pixelSize: app.largeFont
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: app.margins
        }

        Label {
            text: qsTr("nymea UUID:")
            Layout.fillWidth: true
        }
        Label {
            text: certDialog.serverUuid
            Layout.fillWidth: true
        }
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: app.margins
        }
        GridLayout {
            columns: 2
            Label {
                text: qsTr("Organisation:")
                Layout.fillWidth: true
            }
            Label {
                text: certDialog.issuerInfo["O"]
                Layout.fillWidth: true
            }
            Label {
                text: qsTr("Common name:")
                Layout.fillWidth: true
            }
            Label {
                text: certDialog.issuerInfo["CN"]
                Layout.fillWidth: true
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: app.margins
        }
        Label {
            text: qsTr("Fingerprint:")
            Layout.fillWidth: true
        }
        Label {
            text: certDialog.issuerInfo["fingerprint"]
            Layout.fillWidth: true
            wrapMode: Text.WrapAnywhere
        }
    }
}
