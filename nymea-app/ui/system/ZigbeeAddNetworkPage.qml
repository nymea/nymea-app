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
    title: qsTr("Add a new Zigbee network")
    busy: d.pendingCommandId != -1

    property ZigbeeManager zigbeeManager: null


    QtObject {
        id: d
        property int pendingCommandId: -1

        function addNetwork(serialPort, baudRate, backendType) {
            d.pendingCommandId = root.zigbeeManager.addNetwork(serialPort, baudRate, backendType)
        }
    }


    Connections {
        target: root.zigbeeManager
        onAddNetworkReply: {
            if (commandId == d.pendingCommandId) {
                d.pendingCommandId = -1
                var props = {};
                switch (error) {
                case "ZigbeeErrorNoError":
                    pageStack.pop();
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
        text: qsTr("Hardware not available")
        visible: root.zigbeeManager.adapters.count == 0
    }

    RowLayout {
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        visible: root.zigbeeManager.adapters.count == 0
        spacing: app.margins
        ColorIcon {
            Layout.preferredHeight: app.iconSize
            Layout.preferredWidth: app.iconSize
            name: "../images/connections/network-wifi-offline.svg"
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: qsTr("No Zigbee adapters or serial ports are available on this system. Connect a Zigbee adapter via USB or UART serial port.")
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Available Zigbee adapters")
        visible: recognizedAdapters.count > 0
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
        text: qsTr("Please select the Zigbee adapter on which the new network will be created.")
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

        delegate: NymeaListItemDelegate {
            Layout.fillWidth: true
            iconName: "../images/zigbee.svg"
            text: model.name + " - " + model.description + " - " + model.serialPort
            onClicked: d.addNetwork(model.serialPort, model.baudRate, model.backendType)
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Available serial ports")
        visible: serialPorts.count > 0
    }

    Label {
        Layout.fillWidth: true; Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
        wrapMode: Text.WordWrap
        font.pixelSize: app.smallFont
        text: qsTr("Please verify that the Zigbee adapter is properly connected to a serial port and select the appropriate port.")
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

        delegate: NymeaListItemDelegate {
            Layout.fillWidth: true
            property ZigbeeAdapter adapter: root.zigbeeManager.adapters.get(index)
            iconName: "../images/stock_usb.svg"
            text: model.description + " - " + model.serialPort
            onClicked: {
                var dialog = serialPortOptionsDialogComponent.createObject(app, {serialPort: model.serialPort, baudRate: model.baudRate})
                dialog.open()
            }
        }
    }


    Component {
        id: serialPortOptionsDialogComponent
        MeaDialog {
            id: serialPortOptionsDialog
            property string serialPort
            property int baudRate

            headerIcon: "../images/stock_usb.svg"
            title: qsTr("Serial port options")
            text: qsTr("Please select the serial port options for using the Zigbee adapter")
            standardButtons: Dialog.Ok | Dialog.Cancel

            RowLayout {
                Label {
                    text: qsTr("Adapter")
                    Layout.fillWidth: true
                }
                ComboBox {
                    id: backendComboBox
                    model: ListModel {
                        id: backendModel
                        ListElement { displayName: "deConz"; backendValue: ZigbeeAdapter.ZigbeeBackendTypeDeconz }
                        ListElement { displayName: "NXP"; backendValue: ZigbeeAdapter.ZigbeeBackendTypeNxp }
                    }
                    textRole: "displayName"
                }
            }

            RowLayout {
                Label {
                    text: qsTr("Baud rate")
                    Layout.fillWidth: true
                }
                ComboBox {
                    id: baudRateComboBox
                    model: [300, 600, 1200, 2400, 4800, 9600, 14400, 19200, 38400, 57600]
                    Component.onCompleted: {
                        currentIndex = indexOfValue(serialPortOptionsDialog.baudRate)
                    }
                }
            }

            onAccepted: {
                d.addNetwork(serialPortOptionsDialog.serialPort, baudRateComboBox.currentValue, backendModel.get(backendComboBox.currentIndex).backendValue)
            }
        }
    }
}
