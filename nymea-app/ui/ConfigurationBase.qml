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

Item {
    property string systemName: ""
    property string appName: ""
    property string appId: ""

    property string company: ""

    property string connectionWizard: ""

    property string tunnelProxyUrl: ""
    property int tunnelProxyPort: 2213

    property string privacyPolicyUrl: ""

    // Enable/disable certain features
    property bool magicEnabled: false
    property bool networkSettingsEnabled: false
    property bool apiSettingsEnabled: false
    property bool mqttSettingsEnabled: false
    property bool webServerSettingsEnabled: false
    property bool zigbeeSettingsEnabled: false
    property bool zwaveSettingsEnabled: false
    property bool modbusSettingsEnabled: false
    property bool pluginSettingsEnabled: false

    property string defaultMainView: "things"

    property string alternativeMainPage: ""

    property var mainMenuLinks: null
    property bool closedSource: false

    property var additionalImrintLinks: null
    property var additionalLicenses: null
}
