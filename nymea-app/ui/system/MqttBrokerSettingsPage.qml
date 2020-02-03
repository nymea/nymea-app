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

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("MQTT broker")
        onBackPressed: pageStack.pop();
    }

//    Flickable {
//        anchors.fill: parent
//        contentHeight: connectionsColumn.implicitHeight
//        interactive: contentHeight > height

        ColumnLayout {
            id: connectionsColumn
//            anchors { left: parent.left; top: parent.top; right: parent.right }
            anchors.fill: parent
//            layoutDirection: Qt.
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: app.margins
                text: qsTr("MQTT Server Interfaces")
                wrapMode: Text.WordWrap
                color: app.accentColor
            }

            ListView {
                Layout.fillWidth: true
                Layout.minimumHeight: 0
                Layout.preferredHeight: Math.min(contentHeight, 120)
                model: engine.nymeaConfiguration.mqttServerConfigurations
                clip: true
                ScrollBar.vertical: ScrollBar {}

                delegate: ConnectionInterfaceDelegate {
                    width: parent.width
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
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
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
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.topMargin: app.margins; Layout.rightMargin: app.margins
                text: qsTr("MQTT permissions")
                wrapMode: Text.WordWrap
                color: app.accentColor
            }

            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(contentHeight, parent.height * .4)
                model: engine.nymeaConfiguration.mqttPolicies
                clip: true
                ScrollBar.vertical: ScrollBar {}
                delegate: NymeaListItemDelegate {
                    width: parent.width
                    iconName: "../images/account.svg"
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
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
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
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 0
            }
        }
//    }
}
