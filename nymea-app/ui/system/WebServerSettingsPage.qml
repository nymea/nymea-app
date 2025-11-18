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
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

SettingsPageBase {
    id: root
    title: qsTr("Web server")

    SettingsPageSectionHeader {
        text: qsTr("Web server interfaces")
    }

    Repeater {
        model: engine.nymeaConfiguration.webServerConfigurations
        delegate: ConnectionInterfaceDelegate {
            Layout.fillWidth: true
            canDelete: true
            onClicked: {
                var component = Qt.createComponent(Qt.resolvedUrl("WebServerConfigurationDialog.qml"));
                var popup = component.createObject(root, { serverConfiguration: engine.nymeaConfiguration.webServerConfigurations.get(index).clone() });
                popup.accepted.connect(function() {
                    engine.nymeaConfiguration.setWebServerConfiguration(popup.serverConfiguration)
                    popup.serverConfiguration.destroy();
                })
                popup.rejected.connect(function() {
                    popup.serverConfiguration.destroy();
                })
                popup.open()
            }
            onDeleteClicked: {
                print("should delete")
                engine.nymeaConfiguration.deleteWebServerConfiguration(model.id)
            }
        }
    }
    Button {
        Layout.fillWidth: true
        Layout.margins: app.margins
        text: qsTr("Add")
        onClicked: {
            var config = engine.nymeaConfiguration.createWebServerConfiguration("0.0.0.0", 80 + engine.nymeaConfiguration.webServerConfigurations.count, false, false, "/var/www/");
            var component = Qt.createComponent(Qt.resolvedUrl("WebServerConfigurationDialog.qml"));
            var popup = component.createObject(root, { serverConfiguration: config });
            popup.accepted.connect(function() {
                engine.nymeaConfiguration.setWebServerConfiguration(popup.serverConfiguration)
                popup.serverConfiguration.destroy();
            })
            popup.rejected.connect(function() {
                popup.serverConfiguration.destroy();
            })
            popup.open()
        }
    }
}
