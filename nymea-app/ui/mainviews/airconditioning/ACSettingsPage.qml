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

import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import Nymea 1.0
import Nymea.AirConditioning 1.0
import "qrc:/ui/components"
import "qrc:/ui/delegates"

SettingsPageBase {
    id: root
    title: qsTr("Configure zones")

    property AirConditioningManager acManager: null

    header: NymeaHeader {
        text: root.title
        backButtonVisible: true
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "add"
            onClicked: {
                createZone();
            }

        }
    }

    function createZone() {
        pendingAddCall = acManager.addZone(qsTr("Zone %1").arg(acManager.zoneInfos.count + 1), [], [], [], [])
    }
    property int pendingAddCall: -1
    Connections {
        target: acManager

        onAddZoneReply: {
            if (commandId == pendingAddCall) {
                print("zone added", zoneId)
                var zone = acManager.zoneInfos.getZoneInfo(zoneId)
                pageStack.push(Qt.resolvedUrl("EditZonePage.qml"), {acManager: acManager, zone: zone, createNew: true})
            }
        }
    }


    Item {
        width: parent.width
        height: root.height - root.header.height
        visible: acManager.zoneInfos.count == 0

        EmptyViewPlaceholder {
            anchors.centerIn: parent
            width: parent.width - app.margins * 2
            title: qsTr("No zones configured.")
            text: qsTr("Start with configuring your zones.")
            imageSource: "qrc:/icons/sensors.svg"
            buttonText: qsTr("Add zone")
            onButtonClicked: createZone()
        }
    }


    Repeater {
        model: acManager.zoneInfos

        delegate: NymeaItemDelegate {
            property ZoneInfo zone: acManager.zoneInfos.get(index)
            Layout.fillWidth: true
            text: model.name
            onClicked: pageStack.push(Qt.resolvedUrl("EditZonePage.qml"), {acManager: root.acManager, zone: zone})
        }
    }
}
