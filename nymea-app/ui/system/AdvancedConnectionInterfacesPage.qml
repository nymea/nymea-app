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
    title: qsTr("Connection interfaces")

    SettingsPageSectionHeader {
        text: qsTr("TCP server interfaces")
    }

    Repeater {
        model: engine.nymeaConfiguration.tcpServerConfigurations
        delegate: ConnectionInterfaceDelegate {
            Layout.fillWidth: true
            iconColor: inUse ? Style.accentColor : Style.iconColor
            readonly property bool inUse: (engine.jsonRpcClient.currentConnection.hostAddress === model.address || model.address === "0.0.0.0")
                                 && engine.jsonRpcClient.currentConnection.port === model.port
            canDelete: !inUse
            onClicked: {
                var component = Qt.createComponent(Qt.resolvedUrl("ServerConfigurationDialog.qml"));
                var popup = component.createObject(root, { serverConfiguration: engine.nymeaConfiguration.tcpServerConfigurations.get(index).clone() });
                popup.accepted.connect(function() {
                    engine.nymeaConfiguration.setTcpServerConfiguration(popup.serverConfiguration)
                    popup.serverConfiguration.destroy();
                })
                popup.rejected.connect(function() {
                    popup.serverConfiguration.destroy();
                })
                popup.open()
            }
            onDeleteClicked: {
                engine.nymeaConfiguration.deleteTcpServerConfiguration(model.id)
            }
        }
    }
    Button {
        Layout.fillWidth: true
        Layout.margins: app.margins
        text: qsTr("Add")
        onClicked: {
            var config = engine.nymeaConfiguration.createServerConfiguration("0.0.0.0", 2222 + engine.nymeaConfiguration.tcpServerConfigurations.count, false, false);
            var component = Qt.createComponent(Qt.resolvedUrl("ServerConfigurationDialog.qml"));
            var popup = component.createObject(root, { serverConfiguration: config });
            popup.accepted.connect(function() {
                engine.nymeaConfiguration.setTcpServerConfiguration(popup.serverConfiguration)
                popup.serverConfiguration.destroy();
            })
            popup.rejected.connect(function() {
                popup.serverConfiguration.destroy();
            })
            popup.open()
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("WebSocket server interfaces")
    }

    Repeater {
        model: engine.nymeaConfiguration.webSocketServerConfigurations
        delegate: ConnectionInterfaceDelegate {
            Layout.fillWidth: true
            iconColor: inUse ? Style.accentColor : Style.iconColor
            readonly property bool inUse: (engine.jsonRpcClient.currentConnection.hostAddress === model.address || model.address === "0.0.0.0")
                                 && engine.jsonRpcClient.currentConnection.port === model.port
            canDelete: !inUse
            onClicked: {
                var component = Qt.createComponent(Qt.resolvedUrl("ServerConfigurationDialog.qml"));
                var popup = component.createObject(root, { serverConfiguration: engine.nymeaConfiguration.webSocketServerConfigurations.get(index).clone() });
                popup.accepted.connect(function() {
                    print("configuring:", popup.serverConfiguration.port)
                    engine.nymeaConfiguration.setWebSocketServerConfiguration(popup.serverConfiguration)
                    popup.serverConfiguration.destroy();
                })
                popup.rejected.connect(function() {
                    popup.serverConfiguration.destroy();
                })
                popup.open()
            }
            onDeleteClicked: {
                print("should delete", model.id)
                engine.nymeaConfiguration.deleteWebSocketServerConfiguration(model.id)
            }
        }
    }
    Button {
        Layout.fillWidth: true
        Layout.margins: app.margins
        text: qsTr("Add")
        onClicked: {
            var config = engine.nymeaConfiguration.createServerConfiguration("0.0.0.0", 4444 + engine.nymeaConfiguration.webSocketServerConfigurations.count, false, false);
            var component = Qt.createComponent(Qt.resolvedUrl("ServerConfigurationDialog.qml"));
            var popup = component.createObject(root, { serverConfiguration: config });
            popup.accepted.connect(function() {
                engine.nymeaConfiguration.setWebSocketServerConfiguration(popup.serverConfiguration)
                popup.serverConfiguration.destroy();
            })
            popup.rejected.connect(function() {
                popup.serverConfiguration.destroy();
            })
            popup.open()
        }
    }
    SettingsPageSectionHeader {
        text: qsTr("Remote connection server interfaces")
        visible: engine.jsonRpcClient.ensureServerVersion("6.0")
    }

    Repeater {
        model: engine.nymeaConfiguration.tunnelProxyServerConfigurations
        delegate: ConnectionInterfaceDelegate {
            Layout.fillWidth: true
            text: qsTr("Server: %1").arg(model.address)
            iconColor: inUse ? Style.accentColor : Style.iconColor
            readonly property bool inUse: (engine.jsonRpcClient.currentConnection.hostAddress === model.address || model.address === "0.0.0.0")
                                 && engine.jsonRpcClient.currentConnection.port === model.port
            canDelete: !inUse
            onClicked: {
                var component = Qt.createComponent(Qt.resolvedUrl("TunnelProxyServerConfigurationDialog.qml"));
                var popup = component.createObject(root, { serverConfiguration: engine.nymeaConfiguration.tunnelProxyServerConfigurations.get(index).clone() });
                popup.accepted.connect(function() {
                    print("configuring:", popup.serverConfiguration.port)
                    engine.nymeaConfiguration.setTunnelProxyServerConfiguration(popup.serverConfiguration)
                    popup.serverConfiguration.destroy();
                })
                popup.rejected.connect(function() {
                    popup.serverConfiguration.destroy();
                })
                popup.open()
            }
            onDeleteClicked: {
                engine.nymeaConfiguration.deleteTunnelProxyServerConfiguration(model.id)
            }
        }
    }
    Button {
        Layout.fillWidth: true
        Layout.margins: app.margins
        text: qsTr("Add")
        visible: engine.jsonRpcClient.ensureServerVersion("6.0")
        onClicked: {
            var config = engine.nymeaConfiguration.createTunnelProxyServerConfiguration(Configuration.tunnelProxyUrl, Configuration.tunnelProxyPort, true, true, false);
            var component = Qt.createComponent(Qt.resolvedUrl("TunnelProxyServerConfigurationDialog.qml"));
            var popup = component.createObject(root, { serverConfiguration: config });
            popup.accepted.connect(function() {
                engine.nymeaConfiguration.setTunnelProxyServerConfiguration(popup.serverConfiguration)
                popup.serverConfiguration.destroy();
            })
            popup.rejected.connect(function() {
                popup.serverConfiguration.destroy();
            })
            popup.open()
        }
    }
}
