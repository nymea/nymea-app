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
import "../components"
import Nymea 1.0

SettingsPageBase {
    id: root

    property ModbusRtuManager modbusRtuManager
    property ModbusRtuMaster modbusRtuMaster

    property ListModel serialPortBaudrateModel
    property ListModel serialPortParityModel
    property ListModel serialPortDataBitsModel
    property ListModel serialPortStopBitsModel

    header: NymeaHeader {
        text: qsTr("Reconfigure Modbus RTU master")
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
            onClicked: pageStack.push(reconfigureNewModbusRtuMasterPage, {
                                          modbusRtuManager: modbusRtuManager,
                                          serialPort: modbusRtuManager.serialPorts.get(index),
                                          modbusRtuMaster: modbusRtuMaster })
        }
    }

    Component {
        id: reconfigureNewModbusRtuMasterPage

        SettingsPageBase {
            id: root

            property ModbusRtuManager modbusRtuManager
            property SerialPort serialPort
            property ModbusRtuMaster modbusRtuMaster

            busy: d.pendingCommandId != -1

            header: NymeaHeader {
                text: qsTr("Reconfigure Modbus RTU master")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            QtObject {
                id: d
                property int pendingCommandId: -1

                function reconfigureModbusRtuMaster(modbusUuid, serialPort, baudRate, parity, dataBits, stopBits, numberOfRetries, timeout) {
                    d.pendingCommandId = root.modbusRtuManager.reconfigureModbusRtuMaster(modbusUuid, serialPort, baudRate, parity, dataBits, stopBits, numberOfRetries, timeout)
                }
            }

            Connections {
                target: root.modbusRtuManager
                onReconfigureModbusRtuMasterReply: {
                    if (commandId === d.pendingCommandId) {
                        d.pendingCommandId = -1
                        if (modbusRtuManager.handleModbusError(error)) {
                            pageStack.pop();
                            pageStack.pop();
                        }
                    }
                }
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("UUID")
                subText: modbusRtuMaster.modbusUuid
                progressive: false
                prominentSubText: false
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
                subText: serialPort.description.length > 0 ? serialPort.description : qsTr("Unknown")
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
                    enabled: !root.busy
                    textRole: "value"
                    model: serialPortBaudrateModel
                    onActivated: console.log("Selected baudrate", currentText, model.get(currentIndex).value)
                    Component.onCompleted: {
                        for (var i = 0; i < serialPortBaudrateModel.count; i++) {
                            if (serialPortBaudrateModel.get(i).value === modbusRtuMaster.baudrate) {
                                currentIndex = i
                            }
                        }
                    }
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
                    onActivated: console.log("Selected parity", currentText, model.get(currentIndex).value)
                    model: serialPortParityModel
                    Component.onCompleted: {
                        for (var i = 0; i < serialPortParityModel.count; i++) {
                            if (serialPortParityModel.get(i).value === modbusRtuMaster.parity) {
                                currentIndex = i
                            }
                        }
                    }
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
                    onActivated: console.log("Selected data bits", currentText, model.get(currentIndex).value)
                    model: serialPortDataBitsModel
                    Component.onCompleted: {
                        for (var i = 0; i < serialPortDataBitsModel.count; i++) {
                            if (serialPortDataBitsModel.get(i).value === modbusRtuMaster.dataBits) {
                                currentIndex = i
                            }
                        }
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
                    onActivated: console.log("Selected stop bits", currentText, model.get(currentIndex).value)
                    model: serialPortStopBitsModel
                    Component.onCompleted: {
                        for (var i = 0; i < serialPortStopBitsModel.count; i++) {
                            if (serialPortStopBitsModel.get(i).value === modbusRtuMaster.stopBits) {
                                currentIndex = i
                            }
                        }
                    }
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
                    Component.onCompleted: {
                        numberOfRetriesText.text = modbusRtuMaster.numberOfRetries
                    }
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
                    text: "100"
                    validator: IntValidator { bottom: 10; top: 100000 }
                    Component.onCompleted: {
                        timeoutText.text = modbusRtuMaster.timeout
                    }
                }
            }


            Button {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                text: qsTr("Apply")
                enabled: !root.busy
                onClicked: {
                    var baudrate = serialPortBaudrateModel.get(baudRateComboBox.currentIndex).value
                    var parity = serialPortParityModel.get(parityComboBox.currentIndex).value
                    var dataBits = serialPortDataBitsModel.get(dataBitsComboBox.currentIndex).value
                    var stopBits = serialPortStopBitsModel.get(stopBitsComboBox.currentIndex).value
                    var numberOfRetries = numberOfRetriesText.text
                    var timeout = timeoutText.text

                    console.log("Reconfigure Modbus RTU", modbusRtuMaster.modbusUuid, "with", serialPort.systemLocation, baudrate, parity, dataBits, stopBits, numberOfRetries, timeout)
                    d.reconfigureModbusRtuMaster(modbusRtuMaster.modbusUuid, serialPort.systemLocation, baudrate, parity, dataBits, stopBits, numberOfRetries, timeout)
                }
            }
        }
    }
}
