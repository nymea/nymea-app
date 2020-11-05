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

import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "../components"
import Nymea 1.0

SettingsPageBase {
    id: root

    property ZigbeeNetwork network: null

    header: NymeaHeader {
        text: qsTr("Network") + " " + root.network.macAddress
        backButtonVisible: true
        onBackPressed: pageStack.pop()

        HeaderButton {
            text: qsTr("Settings")
            imageSource: "../images/settings.svg"
            onClicked: pageStack.push(Qt.resolvedUrl("ZigbeeNetworkInfoPage.qml"), { network: root.network })
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Network information")
    }

    NymeaListItemDelegate {
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

    NymeaListItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Channel")
        subText: root.network.channel
        progressive: false
    }

    NymeaListItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Network PAN ID")
        subText: root.network.panId
        progressive: false
    }

    SettingsPageSectionHeader {
        text: qsTr("Adding zigbee devices")
    }

    NymeaListItemDelegate {
        Layout.fillWidth: true
        text: root.network.permitJoiningEnabled ? qsTr("The network is open") : qsTr("The network is closed")
        subText: root.network.permitJoiningEnabled ? qsTr("Devices can join this network") : qsTr("Devices are not allowed to join this network")
        progressive: false
        prominentSubText: false
    }

    ColumnLayout {
        anchors { left: parent.left; right: parent.right }

        ProgressBar {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            visible: root.network.permitJoiningEnabled
            from: root.network.permitJoiningDuration
            to: 0
            value: root.network.permitJoiningRemaining
        }

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            enabled: network.networkState === ZigbeeNetwork.ZigbeeNetworkStateOnline
            text: root.network.permitJoiningEnabled ? qsTr("Extend network open duration") : qsTr("Open network for new Zigbee devices")
            onClicked: engine.zigbeeManager.setPermitJoin(root.network.networkUuid)
        }

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            visible: network.networkState === ZigbeeNetwork.ZigbeeNetworkStateOnline && root.network.permitJoiningEnabled
            text: qsTr("Close network")
            onClicked: engine.zigbeeManager.setPermitJoin(root.network.networkUuid, 0)
        }
    }

}
