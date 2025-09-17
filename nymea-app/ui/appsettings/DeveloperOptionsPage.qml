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
    title: qsTr("Developer options")

    SettingsPageSectionHeader {
        text: qsTr("Logging")
    }

    SwitchDelegate {
        text: qsTr("Application logs enabled")
        checked: AppLogController.enabled
        onCheckedChanged: AppLogController.enabled = checked
        Layout.fillWidth: true
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("View live log")
        onClicked: pageStack.push(Qt.resolvedUrl("../appsettings/AppLogPage.qml"))
        visible: AppLogController.enabled
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Configure logging categories")
        onClicked: pageStack.push(Qt.resolvedUrl("../appsettings/LoggingCategories.qml"))
    }
}
