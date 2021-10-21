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

SettingsPageBase {
    id: root
    title: qsTr("Add a new ZigBee network")

    property ZigbeeManager zigbeeManager: null

    signal done();

    SettingsPageSectionHeader {
        text: qsTr("Hardware not available")
        visible: root.zigbeeManager.adapters.count == 0
    }

    RowLayout {
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        visible: root.zigbeeManager.adapters.count == 0
        spacing: Style.margins
        ColorIcon {
            Layout.preferredHeight: Style.iconSize
            Layout.preferredWidth: Style.iconSize
            name: "../images/connections/network-wifi-offline.svg"
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: qsTr("No ZigBee adapters or serial ports are available on this system. Connect a ZigBee adapter via USB or UART serial port.")
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Available ZigBee adapters")
        visible: recognizedAdapters.count > 0
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins; Layout.rightMargin: Style.margins
        text: qsTr("Please select the ZigBee adapter on which the new network will be created.")
        font.pixelSize: app.smallFont
        wrapMode: Text.WordWrap
        visible: recognizedAdapters.count > 0
    }


    Repeater {
        id: recognizedRepeater
        model: ZigbeeAdaptersProxy {
            id: recognizedAdapters
            manager: root.zigbeeManager
            hardwareFilter: ZigbeeAdaptersProxy.HardwareFilterRecognized
            onlyUnused: true
        }

        delegate: NymeaSwipeDelegate {
            Layout.fillWidth: true
            iconName: "../images/zigbee.svg"
            text: model.backend + " - " + model.description + " - " + model.serialPort
            onClicked: {
                pageStack.push(addSettingsPageComponent, {serialPort: model.serialPort, baudRate: model.baudRate, backend: model.backend, allowSerialPortSettings: false})
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Available serial ports")
        visible: serialPorts.count > 0
    }

    Label {
        Layout.fillWidth: true; Layout.leftMargin: Style.margins; Layout.rightMargin: Style.margins
        wrapMode: Text.WordWrap
        font.pixelSize: app.smallFont
        text: qsTr("Please verify that the ZigBee adapter is properly connected to a serial port and select the appropriate port.")
        visible: serialPorts.count > 0
    }

    Repeater {
        id: unrecognizedRepeater
        model: ZigbeeAdaptersProxy {
            id: serialPorts
            manager: root.zigbeeManager
            hardwareFilter: ZigbeeAdaptersProxy.HardwareFilterUnrecognized
            onlyUnused: true
        }

        delegate: NymeaSwipeDelegate {
            Layout.fillWidth: true
            property ZigbeeAdapter adapter: root.zigbeeManager.adapters.get(index)
            iconName: "../images/stock_usb.svg"
            text: model.description + " - " + model.serialPort
            onClicked: {
                pageStack.push(addSettingsPageComponent, {serialPort: model.serialPort, baudRate: model.baudRate, backend: model.backend, allowSerialPortSettings: true})
            }
        }
    }


    Component {
        id: addSettingsPageComponent
        SettingsPageBase {
            id: addSettingsPage
            title: qsTr("Add ZigBee network")
            busy: d.pendingCommandId != -1

            property bool allowSerialPortSettings: false
            property string serialPort
            property int baudRate
            property string backend

            QtObject {
                id: d
                property int pendingCommandId: -1
            }

            Connections {
                target: root.zigbeeManager
                onAddNetworkReply: {
                    if (commandId == d.pendingCommandId) {
                        d.pendingCommandId = -1
                        var props = {};
                        switch (error) {
                        case "ZigbeeErrorNoError":
                            root.done()
                            return;
                        case "ZigbeeErrorAdapterNotAvailable":
                            props.text = qsTr("The selected adapter is not available or the selected serial port configration is incorrect.");
                            break;
                        case "ZigbeeErrorAdapterAlreadyInUse":
                            props.text = qsTr("The selected adapter is already in use.");
                            break;
                        default:
                            props.errorCode = error;
                        }
                        var comp = Qt.createComponent("../components/ErrorDialog.qml")
                        var popup = comp.createObject(app, props)
                        popup.open();
                    }
                }
            }

            SettingsPageSectionHeader {
                text: qsTr("Serial port options")
                visible: addSettingsPage.allowSerialPortSettings
            }
            Label {
                visible: addSettingsPage.allowSerialPortSettings
                Layout.fillWidth: true; Layout.leftMargin: Style.margins; Layout.rightMargin: Style.margins
                wrapMode: Text.WordWrap
                text: qsTr("Please select the serial port options for using the ZigBee adapter")
            }

            RowLayout {
                Layout.fillWidth: true; Layout.leftMargin: Style.margins; Layout.rightMargin: Style.margins
                visible: addSettingsPage.allowSerialPortSettings
                Label {
                    text: qsTr("Adapter")
                    Layout.fillWidth: true
                }
                ComboBox {
                    id: backendComboBox
                    model: root.zigbeeManager.availableBackends
                    Component.onCompleted: {
                        currentIndex = backendComboBox.find(addSettingsPage.backend)
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true; Layout.leftMargin: Style.margins; Layout.rightMargin: Style.margins
                visible: addSettingsPage.allowSerialPortSettings
                Label {
                    text: qsTr("Baud rate")
                    Layout.fillWidth: true
                }
                ComboBox {
                    id: baudRateComboBox
                    model: ["9600", "14400", "19200", "38400", "57600", "115200", "128000", "230400", "256000"]
                    Component.onCompleted: {
                        currentIndex = baudRateComboBox.find(addSettingsPage.baudRate)
                    }
                }
            }

            SettingsPageSectionHeader {
                text: qsTr("Zigbee network settings")
            }

            RowLayout {
                Layout.fillWidth: true; Layout.leftMargin: Style.margins; Layout.rightMargin: Style.margins
                Label {
                    text: qsTr("Channel")
                    Layout.fillWidth: true
                }
                ComboBox {
                    id: channelCombobox
                    model: ListModel {
                        id: channelsModel
                        ListElement { modelData: qsTr("Auto"); channel: ZigbeeManager.ZigbeeChannelAll }
                        ListElement { modelData: qsTr("Auto light link"); channel: ZigbeeManager.ZigbeeChannelPrimaryLightLink }
                        ListElement { modelData: "11"; channel: ZigbeeManager.ZigbeeChannel11 }
                        ListElement { modelData: "12"; channel: ZigbeeManager.ZigbeeChannel12 }
                        ListElement { modelData: "13"; channel: ZigbeeManager.ZigbeeChannel13 }
                        ListElement { modelData: "14"; channel: ZigbeeManager.ZigbeeChannel14 }
                        ListElement { modelData: "15"; channel: ZigbeeManager.ZigbeeChannel15 }
                        ListElement { modelData: "16"; channel: ZigbeeManager.ZigbeeChannel16 }
                        ListElement { modelData: "17"; channel: ZigbeeManager.ZigbeeChannel17 }
                        ListElement { modelData: "18"; channel: ZigbeeManager.ZigbeeChannel18 }
                        ListElement { modelData: "19"; channel: ZigbeeManager.ZigbeeChannel19 }
                        ListElement { modelData: "20"; channel: ZigbeeManager.ZigbeeChannel20 }
                        ListElement { modelData: "21"; channel: ZigbeeManager.ZigbeeChannel21 }
                        ListElement { modelData: "22"; channel: ZigbeeManager.ZigbeeChannel22 }
                        ListElement { modelData: "23"; channel: ZigbeeManager.ZigbeeChannel23 }
                        ListElement { modelData: "24"; channel: ZigbeeManager.ZigbeeChannel24 }
                        ListElement { modelData: "25"; channel: ZigbeeManager.ZigbeeChannel25 }
                        ListElement { modelData: "26"; channel: ZigbeeManager.ZigbeeChannel26 }
                    }
                    currentIndex: 0
                }
            }

            Button {
                Layout.fillWidth: true; Layout.leftMargin: Style.margins; Layout.rightMargin: Style.margins
                text: qsTr("OK")
                onClicked: {
                    print("adding ---", channelCombobox.currentIndex, channelsModel.get(channelCombobox.currentIndex).modelData, channelsModel.get(channelCombobox.currentIndex).channel)
                    d.pendingCommandId = root.zigbeeManager.addNetwork(addSettingsPage.serialPort, baudRateComboBox.currentText, backendComboBox.currentText, channelsModel.get(channelCombobox.currentIndex).channel)
                }
            }
        }
    }
}
