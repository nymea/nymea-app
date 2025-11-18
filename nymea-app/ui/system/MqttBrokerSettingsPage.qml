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
    title: qsTr("MQTT broker")

    SettingsPageSectionHeader {
        text: qsTr("MQTT Server Interfaces")
    }

    Repeater {
        model: engine.nymeaConfiguration.mqttServerConfigurations

        delegate: ConnectionInterfaceDelegate {
            Layout.fillWidth: true
            canDelete: true
            onClicked: {
                var component = Qt.createComponent(Qt.resolvedUrl("ServerConfigurationDialog.qml"));
                var popup = component.createObject(root, { serverConfiguration: engine.nymeaConfiguration.mqttServerConfigurations.get(index).clone() });
                popup.accepted.connect(function() {
                    engine.nymeaConfiguration.setMqttServerConfiguration(popup.serverConfiguration)
                    popup.serverConfiguration.destroy();
                })
                popup.rejected.connect(function() {
                    popup.serverConfiguration.destroy();
                })
                popup.open()
            }

            onDeleteClicked: {
                engine.nymeaConfiguration.deleteMqttServerConfiguration(model.id)
            }
        }
    }
    Button {
        Layout.fillWidth: true
        Layout.margins: app.margins
        text: qsTr("Add")
        onClicked: {
            var config = engine.nymeaConfiguration.createServerConfiguration("0.0.0.0", 1883 + engine.nymeaConfiguration.mqttServerConfigurations.count, false, false);
            var component = Qt.createComponent(Qt.resolvedUrl("ServerConfigurationDialog.qml"));
            var popup = component.createObject(root, { serverConfiguration: config });
            popup.accepted.connect(function() {
                engine.nymeaConfiguration.setMqttServerConfiguration(popup.serverConfiguration)
                popup.serverConfiguration.destroy();
            })
            popup.rejected.connect(function() {
                popup.serverConfiguration.destroy();
            })
            popup.open()
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("MQTT permissions")
    }

    Repeater {
        model: engine.nymeaConfiguration.mqttPolicies
        delegate: NymeaSwipeDelegate {
            Layout.fillWidth: true
            iconName: "qrc:/icons/account.svg"
            text: qsTr("Client ID: %1").arg(model.clientId)
            subText: qsTr("Username: %1").arg(model.username)
            progressive: false
            canDelete: true
            onClicked: {
                var page = pageStack.push(Qt.resolvedUrl("MqttPolicyPage.qml"), { policy: engine.nymeaConfiguration.mqttPolicies.get(index).clone() });
                page.accepted.connect(function() {
                    if (page.policy.clientId !== model.clientId) {
                        engine.nymeaConfiguration.deleteMqttPolicy(model.clientId);
                    }
                    engine.nymeaConfiguration.updateMqttPolicy(page.policy)
                    page.policy.destroy();
                })
                page.rejected.connect(function() {
                    page.policy.destroy();
                })
            }
            onDeleteClicked: {
                engine.nymeaConfiguration.deleteMqttPolicy(model.clientId)
            }
        }
    }

    Button {
        Layout.fillWidth: true
        Layout.margins: app.margins
        text: qsTr("Add")
        onClicked: {
            var page = pageStack.push(Qt.resolvedUrl("MqttPolicyPage.qml"), { policy: engine.nymeaConfiguration.createMqttPolicy() });
            page.accepted.connect(function() {
                engine.nymeaConfiguration.updateMqttPolicy(page.policy)
                page.policy.destroy();
            })
            page.rejected.connect(function() {
                page.policy.destroy();
            })
        }
    }
}
