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
import QtQuick.Controls.Material
import QtQuick.Layouts
import Nymea

Dialog {
    id: root
    title: qsTr("Server configuration")
    width: parent.width * .8
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    property WebServerConfiguration serverConfiguration: null
    standardButtons: Dialog.Ok | Dialog.Cancel

    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right }
        RowLayout {
            Label {
                text: qsTr("Interface")
                Layout.fillWidth: true
            }
            ComboBox {
                id: interfaceCombobox
                model: [qsTr("Any"), qsTr("Localhost"), qsTr("Custom")]
                Layout.fillWidth: true
                currentIndex: !root.serverConfiguration
                              ? 0 : root.serverConfiguration.address === "0.0.0.0"
                                ? 0
                                : root.serverConfiguration.address === "127.0.0.1"
                                  ? 1 : 2
                onActivated: {
                    switch (index) {
                    case 0:
                        root.serverConfiguration.address = "0.0.0.0";
                        break;
                    case 1:
                        root.serverConfiguration.address = "127.0.0.1";
                        break;
                    }
                }
            }
        }
        RowLayout {
            visible: interfaceCombobox.currentIndex === 2
            Label {
                text: qsTr("Address:")
                Layout.fillWidth: true
            }
            TextField {
                id: addressTextField
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhPreferNumbers
                inputMask: "000.000.000.000"
                text: root.serverConfiguration ? root.serverConfiguration.address : ""
                onEditingFinished: root.serverConfiguration.address = text
            }
        }

        RowLayout {
            Label {
                text: qsTr("Port:")
                Layout.fillWidth: true
            }
            TextField {
                inputMethodHints: Qt.ImhDigitsOnly
                text: root.serverConfiguration ? root.serverConfiguration.port : 0
                validator: IntValidator { bottom: 0; top: 65535 }
                onEditingFinished: root.serverConfiguration.port = text
            }
        }

        RowLayout {
            Label {
                Layout.fillWidth: true
                text: qsTr("SSL enabled")
            }
            CheckBox {
                checkState: root.serverConfiguration && root.serverConfiguration.sslEnabled ? Qt.Checked : Qt.Unchecked
                onClicked: root.serverConfiguration.sslEnabled = checked
            }
        }
        RowLayout {
            Label {
                Layout.fillWidth: true
                text: qsTr("Login required")
            }
            CheckBox {
                checkState: root.serverConfiguration && root.serverConfiguration.authenticationEnabled ? Qt.Checked : Qt.Unchecked
                onClicked: root.serverConfiguration.authenticationEnabled = checked
            }
        }
        RowLayout {
            Label {
                Layout.fillWidth: true
                text: qsTr("Public folder")
            }
            TextField {
                text: root.serverConfiguration ? root.serverConfiguration.publicFolder : ""
                onEditingFinished: root.serverConfiguration.publicFolder = text
            }
        }
    }
}
