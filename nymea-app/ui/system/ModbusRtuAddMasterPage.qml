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

import "../components"

SettingsPageBase {
    id: root

    property ModbusRtuManager modbusRtuManager
    property ListModel serialPortBaudrateModel
    property ListModel serialPortParityModel
    property ListModel serialPortDataBitsModel
    property ListModel serialPortStopBitsModel

    header: NymeaHeader {
        text: qsTr("Add a new Modbus RTU master")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    SettingsPageSectionHeader {
        text: qsTr("Serial ports")
    }

    Label {
        Layout.fillWidth: true
        Layout.topMargin: app.margins
        Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
        wrapMode: Text.WordWrap
        text: modbusRtuManager.serialPorts.count !== 0 ? qsTr("Select a serial port.") : qsTr("There are no serial ports available.") + "\n\n" + qsTr("Please make sure the Modbus RTU interface is connected to the system.")
    }

    Repeater {
        model: modbusRtuManager.serialPorts
        delegate: NymeaSwipeDelegate {
            Layout.fillWidth: true
            iconName: "qrc:/icons/stock_usb.svg"
            text:  model.description + (model.manufacturer === "" ? "" : " - " + model.manufacturer)
            subText: model.systemLocation + (model.serialNumber === "" ? "" : " - " + model.serialNumber)
            onClicked: pageStack.push(configureNewModbusRtuMasterPage, { modbusRtuManager: modbusRtuManager, serialPort: modbusRtuManager.serialPorts.get(index) })
        }
    }

    Component {
        id: configureNewModbusRtuMasterPage

        SettingsPageBase {
            id: root

            property ModbusRtuManager modbusRtuManager
            property SerialPort serialPort
            busy: d.pendingCommandId != -1

            header: NymeaHeader {
                text: qsTr("Configure Modbus RTU master")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            QtObject {
                id: d
                property int pendingCommandId: -1

                function addModbusRtuMaster(serialPort, baudRate, parity, dataBits, stopBits, numberOfRetries, timeout) {
                    d.pendingCommandId = root.modbusRtuManager.addModbusRtuMaster(serialPort, baudRate, parity, dataBits, stopBits, numberOfRetries, timeout)
                }
            }

            Connections {
                target: root.modbusRtuManager
                onAddModbusRtuMasterReply: {
                    if (commandId === d.pendingCommandId) {
                        d.pendingCommandId = -1
                        if (modbusRtuManager.handleModbusError(error)) {
                            pageStack.pop();
                            pageStack.pop();
                        }
                    }
                }
            }


            SettingsPageSectionHeader {
                text: qsTr("Serial port")
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Path")
                subText: serialPort.systemLocation
                progressive: false
                prominentSubText: false
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Description")
                subText: serialPort.description
                progressive: false
                prominentSubText: false
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Manufacturer")
                subText: serialPort.manufacturer
                progressive: false
                prominentSubText: false
                visible: serialPort.manufacturer !== ""
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Serialnumber")
                subText: serialPort.serialNumber
                progressive: false
                prominentSubText: false
                visible: serialPort.serialNumber !== ""
            }

            SettingsPageSectionHeader {
                text: qsTr("Configuration")
            }

            RowLayout {
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                Label {
                    text: qsTr("Baud rate")
                    Layout.fillWidth: true
                }

                ComboBox {
                    id: baudRateComboBox
                    Layout.minimumWidth: 250
                    textRole: "value"
                    enabled: !root.busy
                    onActivated: (index) => console.log("Selected baud rate", currentText, model.get(index).value)
                    model: serialPortBaudrateModel
                }
            }

            RowLayout {
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins

                Label {
                    text: qsTr("Parity")
                    Layout.fillWidth: true
                }

                ComboBox {
                    id: parityComboBox
                    textRole: "text"
                    enabled: !root.busy
                    Layout.minimumWidth: 250
                    onActivated: (index) => console.log("Selected parity", currentText,  model.get(index).value)
                    model: serialPortParityModel
                }
            }

            RowLayout {
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins

                Label {
                    text: qsTr("Data bits")
                    Layout.fillWidth: true
                }

                ComboBox {
                    id: dataBitsComboBox
                    textRole: "text"
                    enabled: !root.busy
                    Layout.minimumWidth: 250
                    onActivated: (index) => console.log("Selected data bits", currentText,  model.get(index).value)
                    model: serialPortDataBitsModel
                    Component.onCompleted: {
                        currentIndex = 3
                    }
                }
            }

            RowLayout {
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins

                Label {
                    text: qsTr("Stop bits")
                    Layout.fillWidth: true
                }

                ComboBox {
                    id: stopBitsComboBox
                    textRole: "text"
                    enabled: !root.busy
                    Layout.minimumWidth: 250
                    onActivated: (index) => console.log("Selected stop bits", currentText,  model.get(index).value)
                    model: serialPortStopBitsModel
                }
            }

            RowLayout {
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins

                Label {
                    text: qsTr("Request retries")
                    Layout.fillWidth: true
                }
                TextField {
                    id: numberOfRetriesText
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: "3"
                    validator: IntValidator { bottom: 0; top: 100 }
                }
            }

            RowLayout {
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins

                Label {
                    text: qsTr("Request timeout [ms]")
                    Layout.fillWidth: true
                }
                TextField {
                    id: timeoutText
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: "500"
                    validator: IntValidator { bottom: 10; top: 100000 }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                text: qsTr("Add")
                enabled: !root.busy
                onClicked: {
                    var baudrate = serialPortBaudrateModel.get(baudRateComboBox.currentIndex).value
                    var parity = serialPortParityModel.get(parityComboBox.currentIndex).value
                    var dataBits = serialPortDataBitsModel.get(dataBitsComboBox.currentIndex).value
                    var stopBits = serialPortStopBitsModel.get(stopBitsComboBox.currentIndex).value
                    var numberOfRetries = numberOfRetriesText.text
                    var timeout = timeoutText.text

                    console.log("Adding Modbus RTU with", serialPort.systemLocation, baudrate, parity, dataBits, stopBits, numberOfRetries, timeout)

                    d.addModbusRtuMaster(serialPort.systemLocation, baudrate, parity, dataBits, stopBits, numberOfRetries, timeout)
                }
            }
        }
    }
}
