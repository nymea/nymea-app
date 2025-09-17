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

NymeaSwipeDelegate {
    text: qsTr("Interface: %1").arg(model.address === "0.0.0.0" ? qsTr("Any") : model.address === "127.0.0.1" ? qsTr("localhost") : model.address)
    subText: qsTr("Port: %1").arg(model.port)
    iconName: "qrc:/icons/connections/network-vpn.svg"
    progressive: false
    secondaryIconName: "qrc:/icons/account.svg"
    secondaryIconColor: model.authenticationEnabled ? Style.accentColor : Style.iconColor
    tertiaryIconName: "qrc:/icons/connections/network-secure.svg"
    tertiaryIconColor: model.sslEnabled ? Style.accentColor : Style.iconColor
}
