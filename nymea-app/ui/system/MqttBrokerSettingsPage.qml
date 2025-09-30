/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

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
