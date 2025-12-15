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
import QtQuick.Layouts
import Nymea

import "../../components"

SettingsPageBase {
    id: root
    title: qsTr("Add a new Z-Wave network")
    busy: d.pendingCallId != -1

    property ZWaveManager zwaveManager: null

    signal done();

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {
        target: root.zwaveManager
        onAddNetworkReply: {
            if (commandId == d.pendingCallId) {
                d.pendingCallId = -1
                var props = {};
                switch (error) {
                case ZWaveManager.ZWaveErrorNoError:
                    root.done();
                    break;
                case ZWaveManager.ZWaveErrorInUse:
                    props.text = qsTr("The selected adapter is already in use.");
                    break;
                case ZWaveManager.ZWaveErrorBackendError:
                    props.text = qsTr("An error happened in the ZWave backend.");
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
        text: qsTr("Available serial ports")
        visible: root.zwaveManager.serialPorts.count > 0
    }

    Label {
        Layout.fillWidth: true; Layout.leftMargin: Style.margins; Layout.rightMargin: Style.margins
        wrapMode: Text.WordWrap
        font.pixelSize: app.smallFont
        text: qsTr("Please verify that the Z-Wave adapter is properly connected to a serial port and select the appropriate port.")
        visible: root.zwaveManager.serialPorts.count > 0
    }

    Repeater {
        id: unrecognizedRepeater
        model: root.zwaveManager.serialPorts

        delegate: NymeaSwipeDelegate {
            Layout.fillWidth: true
//            property ZigbeeAdapter adapter: root.zwaveManager.serialPorts.get(index)
            iconName: "qrc:/icons/stock_usb.svg"
            text: model.description + " - " + model.systemLocation
            onClicked: {
                d.pendingCallId = root.zwaveManager.addNetwork(model.systemLocation)
            }
        }
    }
}
