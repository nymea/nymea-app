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

    property ZigbeeManager zigbeeManager: null

    property ZigbeeNetwork network: null

    header: NymeaHeader {
        text: qsTr("Network settings")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    SettingsPageSectionHeader {
        text: qsTr("Hardware information")
    }

    NymeaListItemDelegate {
        Layout.fillWidth: true
        text: qsTr("MAC address:")
        subText: root.network.macAddress
        progressive: false
        prominentSubText: false
    }

    NymeaListItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Serial port")
        subText: root.network.serialPort
        progressive: false
        prominentSubText: false
    }

    NymeaListItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Baud rate")
        subText: root.network.baudRate
        progressive: false
        prominentSubText: false
    }

    NymeaListItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Controller backend")
        subText: ZigbeeAdapter.getBackendName(root.network.backendType)
        progressive: false
        prominentSubText: false
    }

    NymeaListItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Controller firmware version")
        subText: root.network.firmwareVersion
        progressive: false
        prominentSubText: false
    }

    SettingsPageSectionHeader {
        text: qsTr("Manage network")
    }

    ColumnLayout {
        anchors { left: parent.left; right: parent.right }

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            text: qsTr("Remove network")
            onClicked: {
                root.zigbeeManager.removeNetwork(root.network.networkUuid)
                pageStack.pop()
                pageStack.pop()
            }
        }

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            text: qsTr("Factory reset controller")
            onClicked: {
                engine.zigbeeManager.factoryResetNetwork(root.network.networkUuid)
                pageStack.pop()
            }
        }
    }


}
