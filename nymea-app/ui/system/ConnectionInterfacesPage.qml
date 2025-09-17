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
    title: qsTr("Connection settings")

    SettingsPageSectionHeader {
        text: qsTr("Remote connection")
    }
    Label {
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        text: qsTr("Enabling the remote connection will allow connecting to this %1 system from anywhere.").arg(Configuration.systemName)
        wrapMode: Text.WordWrap
    }

    SwitchDelegate {
        Layout.fillWidth: true
        text: checked ? qsTr("Enabled") : qsTr("Disabled")
        checked: engine.nymeaConfiguration.tunnelProxyServerConfigurations.count > 0
        onClicked: {
            if (!checked) {
                for (var i = 0; i < engine.nymeaConfiguration.tunnelProxyServerConfigurations.count; i++) {
                    var config = engine.nymeaConfiguration.tunnelProxyServerConfigurations.get(i);
                    engine.nymeaConfiguration.deleteTunnelProxyServerConfiguration(config.id)
                }
            } else {
                var config = engine.nymeaConfiguration.createTunnelProxyServerConfiguration(Configuration.tunnelProxyUrl, Configuration.tunnelProxyPort, true, true, false);
                engine.nymeaConfiguration.setTunnelProxyServerConfiguration(config)
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Advanced")
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Connection interfaces")
        onClicked: pageStack.push("AdvancedConnectionInterfacesPage.qml")
    }
}
