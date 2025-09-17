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
import Qt5Compat.GraphicalEffects
import QtCharts
import Nymea
import Nymea.AirConditioning

import "qrc:/ui/components"
import "qrc:/ui/delegates"

Item {
    id: root

    property ZoneInfo zone: null

    readonly property ThingsProxy thermostats: ThingsProxy {
        engine: zone.thermostats.length > 0 ? _engine : null
        shownThingIds: zone.thermostats
    }
    readonly property ThingsProxy heatingThermostats: ThingsProxy {
        engine: _engine
        parentProxy: thermostats
        stateFilter: { "heatingOn": true }
    }
    readonly property ThingsProxy coolingThermostats: ThingsProxy {
        engine: _engine
        parentProxy: thermostats
        stateFilter: { "coolingOn": true }
    }

    readonly property ThingsProxy windowSensors: ThingsProxy {
        engine: zone.windowSensors.length > 0 ? _engine : null
        shownThingIds: zone.windowSensors
    }
    readonly property ThingsProxy openWindows: ThingsProxy {
        engine: _engine
        parentProxy: windowSensors
        stateFilter: { "closed": false }
    }

    readonly property ThingsProxy indoorSensors: ThingsProxy {
        engine: root.zone.indoorSensors.length > 0 ? _engine : null
        shownThingIds: root.zone.indoorSensors
    }
    readonly property ThingsProxy indoorTempSensors: ThingsProxy {
        engine: _engine
        parentProxy: indoorSensors
        shownInterfaces: ["temperaturesensor"]
    }
    readonly property ThingsProxy indoorHumiditySensors: ThingsProxy {
        engine: _engine
        parentProxy: indoorSensors
        shownInterfaces: ["humiditysensor"]
    }
    readonly property ThingsProxy indoorVocSensors: ThingsProxy {
        engine: _engine
        parentProxy: indoorSensors
        shownInterfaces: ["vocsensor"]
    }
    readonly property ThingsProxy indoorPm25Sensors: ThingsProxy {
        engine: _engine
        parentProxy: indoorSensors
        shownInterfaces: ["pm25sensor"]
    }

    readonly property ThingsProxy outdoorSensors: ThingsProxy {
        engine: root.zone.outdoorSensors.length > 0 ? _engine : null
        shownThingIds: root.zone.outdoorSensors
    }
    readonly property ThingsProxy outdoorTempSensors: ThingsProxy {
        engine: _engine
        parentProxy: outdoorSensors
        shownInterfaces: ["temperaturesensor"]
    }
    readonly property ThingsProxy outoorHumiditySensors: ThingsProxy {
        engine: _engine
        parentProxy: outdoorSensors
        shownInterfaces: ["humiditysensor"]
    }
    readonly property ThingsProxy outdoorPm25Sensors: ThingsProxy {
        engine: _engine
        parentProxy: outdoorSensors
        shownInterfaces: ["pm25sensor"]
    }

    readonly property ThingsProxy notifications: ThingsProxy {
        engine: root.zone.notifications.length > 0 ? _engine : null
        shownThingIds: root.zone.notifications
    }
}
