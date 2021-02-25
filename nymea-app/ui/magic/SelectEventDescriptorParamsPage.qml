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
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "../components"
import "../delegates"
import Nymea 1.0

Page {
    id: root
    // Needs to be set and filled in with deviceId and eventTypeId
    property var eventDescriptor: null

    readonly property var device: eventDescriptor && eventDescriptor.deviceId ? engine.deviceManager.devices.getDevice(eventDescriptor.deviceId) : null
    readonly property var iface: eventDescriptor && eventDescriptor.interfaceName ? Interfaces.findByName(eventDescriptor.interfaceName) : null
    readonly property var eventType: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId).eventTypes.getEventType(eventDescriptor.eventTypeId)
                                            : iface ? iface.eventTypes.findByName(eventDescriptor.interfaceEvent) : null

    signal backPressed();
    signal completed();

    header: NymeaHeader {
        text: "Options"
        onBackPressed: root.backPressed();
    }

    ColumnLayout {
        anchors.fill: parent
        Repeater {
            id: delegateRepeater
            model: root.eventType.paramTypes
            delegate: ColumnLayout {
                Layout.fillWidth: true
                property alias paramType: paramDescriptorDelegate.paramType
                property alias value: paramDescriptorDelegate.value
                property alias considerParam: paramCheckBox.checked
                property alias operatorType: paramDescriptorDelegate.operatorType
                CheckBox {
                    id: paramCheckBox
                    text: qsTr("Only consider event if")
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                }

                ParamDescriptorDelegate {
                    id: paramDescriptorDelegate
                    enabled: paramCheckBox.checked
                    Layout.fillWidth: true
                    paramType: root.eventType.paramTypes.get(index)
                    value: paramType.defaultValue
                }
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
        Button {
            text: "OK"
            Layout.fillWidth: true
            Layout.margins: app.margins
            onClicked: {
                root.eventDescriptor.paramDescriptors.clear();
                for (var i = 0; i < delegateRepeater.count; i++) {
                    var paramDelegate = delegateRepeater.itemAt(i);
                    if (paramDelegate.considerParam) {
                        print("adding param descriptor")
                        if (root.device) {
                            root.eventDescriptor.paramDescriptors.setParamDescriptor(paramDelegate.paramType.id, paramDelegate.value, paramDelegate.operatorType)
                        } else if (root.iface) {
                            print("setting param descriptors by name", root.eventType.paramTypes.get(i), root.eventType.paramTypes.get(i).name)
                            root.eventDescriptor.paramDescriptors.setParamDescriptorByName(root.eventType.paramTypes.get(i).name, paramDelegate.value, paramDelegate.operatorType)
                        }
                    }
                }
                root.completed()
            }
        }
    }
}
