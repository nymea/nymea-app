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
    objectName: "manualConnectPage"
    header: NymeaHeader {
        text: qsTr("Manual connection")
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: app.margins
        spacing: app.margins

        GridLayout {
            columns: 2

            Label {
                text: qsTr("Protocol")
            }

            ComboBox {
                id: connectionTypeComboBox
                Layout.fillWidth: true
                model: [ qsTr("TCP"), qsTr("Websocket") ]
            }

            Label { text: qsTr("Address:") }
            TextField {
                id: addressTextInput
                objectName: "addressTextInput"
                Layout.fillWidth: true
                placeholderText: "127.0.0.1"
            }

            Label { text: qsTr("Port:") }
            TextField {
                id: portTextInput
                Layout.fillWidth: true
                placeholderText: connectionTypeComboBox.currentIndex === 0 ?
                                     secureCheckBox.checked ? "2223" : "2222"
                                   : secureCheckBox.checked ? "4445" : "4444"
                validator: IntValidator{bottom: 1; top: 65535;}
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Encrypted connection:")
            }
            CheckBox {
                id: secureCheckBox
                checked: true
            }
        }


        Button {
            text: qsTr("Connect")
            objectName: "connectButton"
            Layout.fillWidth: true
            onClicked: {
                var rpcUrl
                var hostAddress
                var port

                // Set default to placeholder
                if (addressTextInput.text === "") {
                    hostAddress = addressTextInput.placeholderText
                } else {
                    hostAddress = addressTextInput.text
                }

                if (portTextInput.text === "") {
                    port = portTextInput.placeholderText
                } else {
                    port = portTextInput.text
                }

                if (connectionTypeComboBox.currentIndex == 0) {
                    if (secureCheckBox.checked) {
                        rpcUrl = "nymeas://" + hostAddress + ":" + port
                    } else {
                        rpcUrl = "nymea://" + hostAddress + ":" + port
                    }
                } else if (connectionTypeComboBox.currentIndex == 1) {
                    if (secureCheckBox.checked) {
                        rpcUrl = "wss://" + hostAddress + ":" + port
                    } else {
                        rpcUrl = "ws://" + hostAddress + ":" + port
                    }
                }

                print("Try to connect ", rpcUrl)
                var host = discovery.nymeaHosts.createLanHost("Manual connection", rpcUrl);
                engine.connection.connect(host)
            }
        }
    }
}
