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

import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import "qrc:/ui/components"
import "qrc:/ui/customviews"
import Nymea 1.0
import Nymea.AirConditioning 1.0

Page {
    id: root
    property AirConditioningManager acManager: null
    property ZoneInfo zoneInfo: null

    readonly property Thing thermostat: engine.thingManager.things.getThing(root.zoneInfo.thermostatId)    

    header: NymeaHeader {
        text: root.thermostat.name

        onBackPressed: {
            pageStack.pop()
        }

        HeaderButton {
            imageSource: "tick"
            onClicked: {
                var sensorIds = []
                acManager.setZoneThings(root.zoneInfo.id, d.checkedThings)
            }
        }
    }

    QtObject {
        id: d
        property var checkedThings: root.zoneInfo.thingIds

    }

    Component.onCompleted: print("***** sensors", root.zoneInfo.thingIds, d.checkedThings)

    GroupedListView {
        id: sensorsListView
        anchors.fill: parent

        section.property: "mainInterface"
        model: ThingsProxy {
            id: sensorsProxy
            engine: _engine
            shownInterfaces: ["thermostat", "closablesensor", "temperaturesensor", "humiditysensor", "vocsensor", "pm25sensor"]
//            hiddenInterfaces: ["thermostat"]
            groupByInterface: true
        }
        delegate: CheckDelegate {
            readonly property Thing thing: sensorsProxy.get(index)
            width: parent.width
            text: model.name
            checked: {
                for (var i = 0; i < d.checkedThings.length; i++) {
                    if (d.checkedThings[i] == model.id) { // Intentionally
                        return true;
                    }
                }
                return false;
            }
            onClicked: {
                if (checked) {
                    d.checkedThings.push(model.id)
                } else {
                    d.checkedThings.splice(d.checkedThings.indexOf(model.id.toString()), 1)
                }
            }
        }
    }
}
