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
            iconColor: inUse ? app.accentColor : iconKeyColor
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
            iconColor: inUse ? app.accentColor : iconKeyColor
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
}
