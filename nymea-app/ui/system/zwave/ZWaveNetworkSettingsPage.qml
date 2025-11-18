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

    property ZWaveManager zwaveManager: null
    property ZWaveNetwork network: null

    signal exit()

    busy: d.pendingCommandId != -1

    header: NymeaHeader {
        text: qsTr("Z-Wave network settings")
        backButtonVisible: true
        onBackPressed: pageStack.pop()

    }

    QtObject {
        id: d
        property int pendingCommandId: -1
    }

    Connections {
        target: root.zwaveManager
        onRemoveNetworkReply: {
            if (commandId === d.pendingCommandId) {
                d.pendingCommandId = -1;
                if (!processError(error)) {
                    root.exit();
                }
            }
        }

        onFactoryResetNetworkReply: {
            if (commandId === d.pendingCommandId) {
                d.pendingCommandId = -1;
                if (!processError(error)) {
                    root.exit();
                }
            }
        }
        onSoftResetControllerReply: {
            if (commandId === d.pendingCommandId) {
                d.pendingCommandId = -1;
                processError(error)
            }
        }

        function processError(error) {
            var props = {};
            switch (error) {
            case ZWaveManager.ZWaveErrorNoError:
                return false;
            case ZWaveManager.ZWaveErrorBackendError:
                props.text = qsTr("An error happened in the ZWave backend.");
                break;
            default:
                props.errorCode = error;
            }
            var comp = Qt.createComponent("../components/ErrorDialog.qml")
            var popup = comp.createObject(app, props)
            popup.open();
            return true
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Network information")
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Network state")
        subText: {
            switch (root.network.networkState) {
            case ZWaveNetwork.ZWaveNetworkStateOnline:
                return qsTr("The network is online")
            case ZWaveNetwork.ZWaveNetworkStateOffline:
                return qsTr("The network is offline")
            case ZWaveNetwork.ZWaveNetworkStateStarting:
                return qsTr("The network is starting...")
            case ZWaveNetwork.ZWaveNetworkStateError:
                return qsTr("The network is in an error state.")
            }
        }

        progressive: false
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Home ID:")
        subText: root.network ? "0x" + network.homeId.toString(16).toUpperCase() : ""
        progressive: false
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Controller type")
        subText: network.isPrimaryController ? qsTr("Primary") : qsTr("Secondary")
                                               + (network.isStaticUpdateController ? ", " + qsTr("Static") : "")
                                               + (network.isBridgeController ? ", " + qsTr("Bridge") : "")
        progressive: false
    }

    SettingsPageSectionHeader {
        text: qsTr("Hardware information")
    }

    NymeaSwipeDelegate {
        Layout.fillWidth: true
        text: qsTr("Serial port")
        subText: root.network ? root.network.serialPort : ""
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
                    d.pendingCommandId = root.zwaveManager.removeNetwork(root.network.networkUuid)
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
                    d.pendingCommandId = root.zwaveManager.factoryResetNetwork(root.network.networkUuid)
                })
            }
        }
    }
}
