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
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0

Dialog {
    id: root
    title: qsTr("Proxy server configuration")
    width: parent.width * .8
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    property ServerConfiguration serverConfiguration: null
    standardButtons: Dialog.Ok | Dialog.Cancel

    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right }
        RowLayout {
            Label {
                text: qsTr("Proxy server address:")
                Layout.fillWidth: true
            }
            TextField {
                id: addressTextField
                Layout.fillWidth: true
                text: root.serverConfiguration ? root.serverConfiguration.address : ""
                onEditingFinished: root.serverConfiguration.address = text
            }
        }

        RowLayout {
            Label {
                text: qsTr("Port:")
                Layout.fillWidth: true
            }
            TextField {
                inputMethodHints: Qt.ImhDigitsOnly
                text: root.serverConfiguration ? root.serverConfiguration.port : 0
                validator: IntValidator { bottom: 0; top: 65535 }
                onEditingFinished: root.serverConfiguration.port = text
            }
        }

        RowLayout {
            Label {
                Layout.fillWidth: true
                text: qsTr("Require login")
            }
            CheckBox {
                checkState: root.serverConfiguration && root.serverConfiguration.authenticationEnabled ? Qt.Checked : Qt.Unchecked
                onClicked: root.serverConfiguration.authenticationEnabled = checked
            }
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: qsTr("Not requiring a login for the remote connection will allow anyone on the internet to connect to your %1 system.").arg(Configuration.systemName)
            color: Style.red
            visible: root.serverConfiguration && !root.serverConfiguration.authenticationEnabled
        }

        RowLayout {
            Label {
                Layout.fillWidth: true
                text: qsTr("SSL enabled")
            }
            CheckBox {
                checkState: root.serverConfiguration && root.serverConfiguration.sslEnabled ? Qt.Checked : Qt.Unchecked
                onClicked: root.serverConfiguration.sslEnabled = checked
            }
        }
        RowLayout {
            Label {
                Layout.fillWidth: true
                text: qsTr("Ignore SSL errors")
            }
            CheckBox {
                checkState: root.serverConfiguration && root.serverConfiguration.ignoreSslErrors ? Qt.Checked : Qt.Unchecked
                onClicked: root.serverConfiguration.ignoreSslErrors = checked
            }
        }
    }
}
