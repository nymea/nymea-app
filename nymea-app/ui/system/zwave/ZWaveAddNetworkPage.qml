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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0

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
