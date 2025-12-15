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
import QtQuick.Controls.Material
import QtQuick.Layouts
import Nymea

Dialog {
    id: root
    title: qsTr("Server configuration")
    width: parent.width * .8
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    property ServerConfiguration serverConfiguration: null
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
                onActivated: (index) => {
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
    }
}
