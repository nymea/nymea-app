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
    header: NymeaHeader {
        text: qsTr("Zigbee")
        backButtonVisible: true
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/add.svg"
            text: qsTr("Add Zigbee network")
            onClicked: pageStack.push(Qt.resolvedUrl("ZigbeeAddNetworkPage.qml"), {zigbeeManager: zigbeeManager})
        }
    }

    ZigbeeManager {
        id: zigbeeManager
        engine: _engine
    }

    SettingsPageSectionHeader {
        text: qsTr("General")
    }

    NymeaListItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Zigbee enabled")
        subText: qsTr("Enable or disable Zigbee altogether")
        prominentSubText: false
        progressive: false
        additionalItem: Switch {
            anchors.centerIn: parent
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Zigbee networks")
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
        wrapMode: Text.WordWrap
        text: qsTr("There are no Zigbee networks set up yet. In order to use Zigbee, create a Zigbee network.")
        visible: zigbeeManager.networks.count == 0
    }

    Repeater {
        model: zigbeeManager.networks
        delegate: NymeaListItemDelegate {
            Layout.fillWidth: true
            property var network: zigbeeManager.networks.get(index)
            iconName: "../images/zigbee.svg"
            text: model.macAddress
            subText: model.serialPort  + " - " + model.firmwareVersion
            onClicked: pageStack.push(Qt.resolvedUrl("ZigbeeNetworkPage.qml"), { zigbeeManager: zigbeeManager, network: network })
        }
    }

    Button {
        Layout.fillWidth: true
        Layout.margins: app.margins
        text: qsTr("Add a Zigbee network")
        onClicked: pageStack.push(Qt.resolvedUrl("ZigbeeAddNetworkPage.qml"), {zigbeeManager: zigbeeManager})
    }


//    SettingsPageSectionHeader {
//        text: qsTr("Available Zigbee adapters")
//    }

//    Repeater {
//        id: recognizedAdaptersRepeater
//        model: ZigbeeAdaptersProxy {
//            id: recognizedAdaptersProxy
//            manager: zigbeeManager
//            onlyUnused: true
////            hardwareFilter: ZigbeeAdaptersProxy.HardwareFilterRecognized
//        }

//        delegate: NymeaListItemDelegate {
//            Layout.fillWidth: true
//            property ZigbeeAdapter adapter: recognizedAdaptersProxy.get(index)
//            iconName: "../images/stock_usb.svg"
//            progressive: false
//            text: model.description + " - " + model.serialPort
//            subText: adapter.serialPort + " - " + adapter.baudRate + " - " + adapter.backendType + " - " + adapter.serialNumber
//            onClicked: {
//                zigbeeManager.addNetwork(adapter.serialPort, adapter.baudRate, adapter.backendType)
////                pageStack.pop()
//            }
//        }
//    }


//    // List networks
//    SettingsPageSectionHeader {
//        text: qsTr("Zigbee networks")
//    }

//    Repeater {
//        model: zigbeeManager.networks
//        delegate: NymeaListItemDelegate {
//            Layout.fillWidth: true
//            property var network: zigbeeManager.networks.get(index)
//            iconName: "../images/zigbee.svg"
//            text: model.macAddress
//            subText: model.serialPort  + " - " + model.firmwareVersion
//            onClicked: pageStack.push(Qt.resolvedUrl("ZigbeeNetworkPage.qml"), { network: network })
//        }
//    }

//    NymeaListItemDelegate {
//        Layout.fillWidth: true
//        text: qsTr("Add Zigbee network")
//        subText: qsTr("Set up a new Zigbee network")
//        prominentSubText: false
//        onClicked: {
//            pageStack.push(Qt.resolvedUrl("../system/ZigbeeNetworkAddPage.qml"), {zigbeeManager: zigbeeManager})
//        }
//    }

}

