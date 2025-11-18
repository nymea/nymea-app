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

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

SettingsPageBase {
    id: root
    title: qsTr("About %1").arg(Configuration.appName)

    Imprint {
        id: imprint
        Layout.fillWidth: true
        title: Configuration.appName
        additionalLicenses: ListModel {
            ListElement { license: "CC-BY-SA-3.0"; component: "Suru icons"; infoText: qsTr("Suru icons by Ubuntu"); platforms: "*" }
            ListElement { license: "CC-BY-SA-3.0"; component: "Ubuntu font"; infoText: qsTr("Ubuntu font by Ubuntu"); platforms: "*" }
            ListElement { license: "LGPL3"; component: "QtZeroConf"; infoText: qsTr("QtZeroConf library by Jonathan Bagg"); platforms: "android,ios,linux,osx" }
            ListElement { license: "OpenSSL"; component: "OpenSSL"; infoText: qsTr("OpenSSL libraries by Eric Young"); platforms: "android,windows" }
            ListElement { license: "OFL"; component: "Oswald font"; infoText: qsTr("Oswald font by The Oswald Project"); platforms: "*" }
        }

        githubLink: "https://github.com/nymea/nymea-app"

        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: qsTr("App version:")
            subText: appVersion
            progressive: false
            prominentSubText: false
        }
        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: qsTr("Qt version:")
            subText: qtVersion + (qtBuildVersion !== qtVersion ? " (" + qsTr("Built with %1").arg(qtBuildVersion) + ")" : "")
            progressive: false
            prominentSubText: false
        }
    }
}
