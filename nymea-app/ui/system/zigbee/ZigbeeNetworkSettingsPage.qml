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

import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "qrc:/ui/components"
import Nymea 1.0

SettingsPageBase {
    id: root

    property ZigbeeManager zigbeeManager: null
    property ZigbeeNetwork network: null

    signal exit()

    Connections {
        target: zigbeeManager
        onFactoryResetNetworkReply: {
            busy = false;
//            if (error != ZigbeeManager.ZigbeeErrorNoError) {
//            }
        }
    }

    header: NymeaHeader {
        text: qsTr("ZigBee network settings")
        backButtonVisible: true
        onBackPressed: pageStack.pop()

    }

    SettingsPageSectionHeader {
        text: qsTr("Network information")
    }

    NymeaSwipeDelegate {
        Layout.fillWidth: true
        text: qsTr("Network state")
        subText: {
            switch (root.network.networkState) {
            case ZigbeeNetwork.ZigbeeNetworkStateOnline:
                return qsTr("The network is online")
            case ZigbeeNetwork.ZigbeeNetworkStateOffline:
                return qsTr("The network is offline")
            case ZigbeeNetwork.ZigbeeNetworkStateStarting:
                return qsTr("The network is starting...")
            case ZigbeeNetwork.ZigbeeNetworkStateUpdating:
                return qsTr("The controller is currently installing an update")
            case ZigbeeNetwork.ZigbeeNetworkStateError:
                return qsTr("The network is in an error state.")
            }
        }

        progressive: false
    }

    NymeaSwipeDelegate {
        Layout.fillWidth: true
        text: qsTr("Channel")
        subText: root.network ? root.network.channel : ""
        progressive: false
    }

    NymeaSwipeDelegate {
        Layout.fillWidth: true
        text: qsTr("Network PAN ID")
        subText: root.network ? root.network.panId : ""
        progressive: false
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Network map")
        visible: engine.jsonRpcClient.ensureServerVersion("6.2")
        onClicked: {
            pageStack.push(Qt.resolvedUrl("ZigbeeNetworkTopologyPage.qml"), {zigbeeManager: root.zigbeeManager, network: root.network})
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Hardware information")
    }

    NymeaSwipeDelegate {
        Layout.fillWidth: true
        text: qsTr("MAC address:")
        subText: root.network ? root.network.macAddress : ""
        progressive: false
        prominentSubText: false
    }

    NymeaSwipeDelegate {
        Layout.fillWidth: true
        text: qsTr("Serial port")
        subText: root.network ? root.network.serialPort : ""
        progressive: false
        prominentSubText: false
    }

    NymeaSwipeDelegate {
        Layout.fillWidth: true
        text: qsTr("Baud rate")
        subText: root.network ? root.network.baudRate : ""
        progressive: false
        prominentSubText: false
    }

    NymeaSwipeDelegate {
        Layout.fillWidth: true
        text: qsTr("Controller backend")
        subText: root.network ? root.network.backend : ""
        progressive: false
        prominentSubText: false
    }

    NymeaSwipeDelegate {
        Layout.fillWidth: true
        text: qsTr("Controller firmware version")
        subText: root.network ? root.network.firmwareVersion : ""
        progressive: false
        prominentSubText: false
    }

    SettingsPageSectionHeader {
        text: qsTr("Manage network")
    }

    ColumnLayout {

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            text: qsTr("Remove network")
            onClicked: {
                var dialog = Qt.createComponent(Qt.resolvedUrl("/ui/components/NymeaDialog.qml"));
                var text = qsTr("Are you sure you want to remove the network and all associated devices from the system?")
                var popup = dialog.createObject(app,
                                                {
                                                    headerIcon: "qrc:/icons/dialog-warning-symbolic.svg",
                                                    title: qsTr("Remove network"),
                                                    text: text,
                                                    standardButtons: Dialog.Ok | Dialog.Cancel
                                                });
                popup.open();
                popup.accepted.connect(function() {
                    popup.destroy();
                    root.exit()
                    root.zigbeeManager.removeNetwork(root.network.networkUuid)
                })
            }
        }

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            text: qsTr("Factory reset controller")
            onClicked: {
                var dialog = Qt.createComponent(Qt.resolvedUrl("/ui/components/NymeaDialog.qml"));
                var text = qsTr("Are you sure you want to factory reset the controller? This will recreate the network and remove all associated devices from the system.")
                var popup = dialog.createObject(app,
                                                {
                                                    headerIcon: "qrc:/icons/dialog-warning-symbolic.svg",
                                                    title: qsTr("Reset controller"),
                                                    text: text,
                                                    standardButtons: Dialog.Ok | Dialog.Cancel
                                                });
                popup.open();
                popup.accepted.connect(function() {
                    root.zigbeeManager.factoryResetNetwork(root.network.networkUuid)
                    root.busy = true;
                })
            }
        }
    }
}
