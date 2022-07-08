/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2022, nymea GmbH
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
            text: qsTr("Reboot controller")
            onClicked: {
                d.pendingCommandId = root.zwaveManager.softResetController(root.network.networkUuid)
            }
        }

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            text: qsTr("Remove network")
            onClicked: {
                d.pendingCommandId = root.zwaveManager.removeNetwork(root.network.networkUuid)
            }
        }

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            text: qsTr("Factory reset controller")
            onClicked: {
                d.pendingCommandId = root.zwaveManager.factoryResetNetwork(root.network.networkUuid)
            }
        }
    }
}
