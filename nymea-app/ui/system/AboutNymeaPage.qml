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

SettingsPageBase {
    id: root
    title: qsTr("About %1").arg(Configuration.systemName)

    Imprint {
        id: imprint
        Layout.fillWidth: true
        title: Configuration.systemName
        showOpensourceLicenses: false
        githubLink: "https://github.com/nymea/nymea"

        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: qsTr("Connection:")
            subText: engine.jsonRpcClient.currentConnection.url
            progressive: false
            prominentSubText: false
        }

        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: qsTr("Server UUID:")
            subText: engine.jsonRpcClient.serverUuid
            progressive: false
            prominentSubText: false
            onClicked: {
                PlatformHelper.toClipBoard(engine.jsonRpcClient.serverUuid)
                ToolTip.show(qsTr("ID copied to clipboard"), 500);
            }
        }

        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: qsTr("Server version:")
            subText: engine.jsonRpcClient.serverVersion
            progressive: false
            prominentSubText: false
        }

        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: qsTr("JSON-RPC version:")
            subText: engine.jsonRpcClient.jsonRpcVersion
            progressive: false
            prominentSubText: false
        }

        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: qsTr("Qt version:")
            visible: engine.jsonRpcClient.ensureServerVersion("4.1")
            subText: engine.jsonRpcClient.serverQtVersion + (engine.jsonRpcClient.serverQtVersion !== engine.jsonRpcClient.serverQtBuildVersion ? " (" + qsTr("Built with %1").arg(engine.jsonRpcClient.serverQtBuildVersion) + ")" : "")
            progressive: false
            prominentSubText: false
        }

        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: qsTr("Device serial number")
            subText: engine.systemController.deviceSerialNumber
            visible: engine.systemController.deviceSerialNumber.length > 0
            progressive: false
            prominentSubText: false
            onClicked: {
                PlatformHelper.toClipBoard(engine.systemController.deviceSerialNumber)
                ToolTip.show(qsTr("Serial copied to clipboard"), 500);
            }
        }
    }
}

