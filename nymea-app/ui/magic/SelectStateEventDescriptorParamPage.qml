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
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "../components"
import "../delegates"
import Nymea 1.0

Page {
    id: root
    // Needs to be set and filled in with thingId and eventTypeId
    property var eventDescriptor: null

    readonly property Thing thing: eventDescriptor && eventDescriptor.thingId ? engine.thingManager.things.getThing(eventDescriptor.thingId) : null
    readonly property var iface: eventDescriptor && eventDescriptor.interfaceName ? Interfaces.findByName(eventDescriptor.interfaceName) : null
    readonly property var stateType: thing ? thing.thingClass.stateTypes.getStateType(eventDescriptor.eventTypeId)
                                            : iface ? iface.eventTypes.findByName(eventDescriptor.interfaceEvent) : null

    signal backPressed();
    signal completed();

    header: NymeaHeader {
        text: "Options"
        onBackPressed: root.backPressed();
    }

    ColumnLayout {
        anchors.fill: parent
        ColumnLayout {
            Layout.fillWidth: true
            property alias paramType: paramDescriptorDelegate.paramType
            property alias value: paramDescriptorDelegate.value
            property alias considerParam: paramCheckBox.checked
            property alias operatorType: paramDescriptorDelegate.operatorType
            CheckBox {
                id: paramCheckBox
                text: qsTr("Only consider state change if")
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
            }

            ParamDescriptorDelegate {
                id: paramDescriptorDelegate
                enabled: paramCheckBox.checked
                Layout.fillWidth: true
                stateType: root.stateType
                value: stateType.defaultValue
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
                if (paramDelegate.considerParam) {
                    if (root.thing) {
                        root.eventDescriptor.paramDescriptors.setParamDescriptor(root.stateType.id, paramDescriptorDelegate.value, paramDescriptorDelegate.operatorType)
                    } else if (root.iface) {
                        root.eventDescriptor.paramDescriptors.setParamDescriptorByName(root.stateType.name, paramDescriptorDelegate.value, paramDescriptorDelegate.operatorType)
                    }
                }
                root.completed()
            }
        }
    }
}
