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

pragma Singleton
import QtQuick

ConfigurationBase {
    systemName: "nymea"
    appName: "nymea:app"
    appId: "io.guh.nymeaapp"
    company: "chargebyte GmbH"

    connectionWizard: "/ui/connection/ConnectionWizard.qml"

    magicEnabled: true
    networkSettingsEnabled: true
    apiSettingsEnabled: true
    mqttSettingsEnabled: true
    webServerSettingsEnabled: true
    zigbeeSettingsEnabled: true
    zwaveSettingsEnabled: true
    modbusSettingsEnabled: true
    pluginSettingsEnabled: true

    tunnelProxyUrl: "tunnelproxy.nymea.io"
    privacyPolicyUrl: "https://nymea.io/privacy-statement/en/nymea_privacy.html"

    mainMenuLinks: [
        {
            text: qsTr("Help"),
            iconName: "qrc:/icons/help.svg",
            url: "https://nymea.io/documentation/users/usage/first-steps"
        },
        {
            text: qsTr("Telegram"),
            iconName: "qrc:/icons/telegram.svg",
            url: "https://t.me/nymeacommunity"
        }
    ]
}
