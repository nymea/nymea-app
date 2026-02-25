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

import "../components"

ColumnLayout {

    property string rpcUrl: {
        var rpcUrl
        var hostAddress
        var port

        // Set default to placeholder
        if (addressTextInput.text === "") {
            hostAddress = addressTextInput.placeholderText
        } else {
            hostAddress = addressTextInput.text
        }

        if (portTextInput.text === "") {
            port = portTextInput.placeholderText
        } else {
            port = portTextInput.text
        }

        if (connectionTypeComboBox.currentIndex == 0) {
            if (secureCheckBox.checked) {
                rpcUrl = "nymeas://" + hostAddress + ":" + port
            } else {
                rpcUrl = "nymea://" + hostAddress + ":" + port
            }
        } else if (connectionTypeComboBox.currentIndex == 1) {
            if (secureCheckBox.checked) {
                rpcUrl = "wss://" + hostAddress + ":" + port
            } else {
                rpcUrl = "ws://" + hostAddress + ":" + port
            }
        } else if (connectionTypeComboBox.currentIndex == 2) {
            if (secureCheckBox.checked) {
                rpcUrl = "tunnels://" + hostAddress + ":" + port + "?uuid=" + serverUuidTextInput.text
            } else {
                rpcUrl = "tunnel://" + hostAddress + ":" + port + "?uuid=" + serverUuidTextInput.text
            }
        }

        return rpcUrl;
    }

    property bool sslEnabled: secureCheckBox.checked

    GridLayout {
        columns: 2

        Label {
            text: qsTr("Protocol")
        }

        ComboBox {
            id: connectionTypeComboBox
            Layout.fillWidth: true
            model: [ qsTr("TCP"), qsTr("Websocket"), qsTr("Remote proxy") ]
        }

        Label {
            text: connectionTypeComboBox.currentIndex < 2 ? qsTr("Address:") : qsTr("Proxy address:")
        }
        TextField {
            id: addressTextInput
            objectName: "addressTextInput"
            Layout.fillWidth: true
            placeholderText: connectionTypeComboBox.currentIndex < 2 ? "127.0.0.1" : Configuration.tunnelProxyUrl
        }

        Label {
            text: qsTr("%1 UUID:").arg(Configuration.systemName)
            visible: connectionTypeComboBox.currentIndex == 2
        }
        TextField {
            id: serverUuidTextInput
            Layout.fillWidth: true
            visible: connectionTypeComboBox.currentIndex == 2
        }
        Label { text: qsTr("Port:") }
        TextField {
            id: portTextInput
            Layout.fillWidth: true
            placeholderText: connectionTypeComboBox.currentIndex === 0
                             ? "2222"
                             : connectionTypeComboBox.currentIndex == 1
                               ? "4444"
                               : Configuration.tunnelProxyPort
            validator: IntValidator{bottom: 1; top: 65535;}
        }

        Label {
            Layout.fillWidth: true
            text: qsTr("SSL:")
        }
        CheckBox {
            id: secureCheckBox
            checked: true
        }
    }
}
