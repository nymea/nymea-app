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

pragma Singleton

import QtQuick
import Nymea

Item {
    id: root

    function currentIndex(scale, value) {
        for (var i = 0; i < scale.length; i++) {
            if (value <= scale[i].value) {
                return scale[i];
            }
        }
        log.warn("Value out of scale!")
        return null
    }


    property var caqiPm10: [
        {
            "value": 25,
            "angle": 54,
            "text": qsTr("Very low"),
            "color": Style.blue
        },
        {
            "value": 50,
            "angle": 108,
            "text": qsTr("Low"),
            "color": Style.green
        },
        {
            "value": 90,
            "angle": 162,
            "text": qsTr("Medium"),
            "color": Style.yellow
        },
        {
            "value": 180,
            "angle": 216,
            "text": qsTr("High"),
            "color": Style.orange
        },
        {
            "value": 500,
            "angle": 270,
            "text": qsTr("Very high"),
            "color": Style.red
        }
    ]

    property var caqiPm25: [
        {
            "value": 15,
            "angle": 54,
            "text": qsTr("Very low"),
            "color": Style.blue
        },
        {
            "value": 30,
            "angle": 108,
            "text": qsTr("Low"),
            "color": Style.green
        },
        {
            "value": 55,
            "angle": 162,
            "text": qsTr("Medium"),
            "color": Style.yellow
        },
        {
            "value": 110,
            "angle": 216,
            "text": qsTr("High"),
            "color": Style.orange
        },
        {
            "value": 500,
            "angle": 270,
            "text": qsTr("Very high"),
            "color": Style.red
        }
    ]

    property var caqiO3: [
        {
            "value": 60,
            "angle": 54,
            "text": qsTr("Very low"),
            "color": Style.blue
        },
        {
            "value": 120,
            "angle": 108,
            "text": qsTr("Low"),
            "color": Style.green
        },
        {
            "value": 180,
            "angle": 162,
            "text": qsTr("Medium"),
            "color": Style.yellow
        },
        {
            "value": 240,
            "angle": 216,
            "text": qsTr("High"),
            "color": Style.orange
        },
        {
            "value": 500,
            "angle": 270,
            "text": qsTr("Very high"),
            "color": Style.red
        }
    ]

    property var caqiNo2: [
        {
            "value": 50,
            "angle": 54,
            "text": qsTr("Very low"),
            "color": Style.blue
        },
        {
            "value": 100,
            "angle": 108,
            "text": qsTr("Low"),
            "color": Style.green
        },
        {
            "value": 200,
            "angle": 162,
            "text": qsTr("Medium"),
            "color": Style.yellow
        },
        {
            "value": 400,
            "angle": 216,
            "text": qsTr("High"),
            "color": Style.orange
        },
        {
            "value": 800,
            "angle": 270,
            "text": qsTr("Very high"),
            "color": Style.red
        }
    ]

    property var caqiCo: [
        {
            "value": 5,
            "angle": 54,
            "text": qsTr("Very low"),
            "color": Style.blue
        },
        {
            "value": 7.5,
            "angle": 108,
            "text": qsTr("Low"),
            "color": Style.green
        },
        {
            "value": 10,
            "angle": 162,
            "text": qsTr("Medium"),
            "color": Style.yellow
        },
        {
            "value": 20,
            "angle": 216,
            "text": qsTr("High"),
            "color": Style.orange
        },
        {
            "value": 255,
            "angle": 270,
            "text": qsTr("Very high"),
            "color": Style.red
        }
    ]

    property var iaqVoc: [
        {
            "value": 65,
            "angle": 54,
            "text": qsTr("Excellent"),
            "color": Style.blue
        },
        {
            "value": 220,
            "angle": 108,
            "text": qsTr("Good"),
            "color": Style.green
        },
        {
            "value": 660,
            "angle": 162,
            "text": qsTr("Moderate"),
            "color": Style.yellow
        },
        {
            "value": 2200,
            "angle": 216,
            "text": qsTr("Poor"),
            "color": Style.orange
        },
        {
            "value": 65535,
            "angle": 270,
            "text": qsTr("Unhealthy"),
            "color": Style.red
        }
    ]

    property var epaAqiO3: [
        {
            "value": 54,
            "angle": 54,
            "text": qsTr("Good"),
            "color": Style.blue
        },
        {
            "value": 70,
            "angle": 108,
            "text": qsTr("Moderate"),
            "color": Style.blue
        },
        {
            "value": 85,
            "angle": 162,
            "text": qsTr("Unhealthy for sensitive groups"),
            "color": Style.yellow
        },
        {
            "value": 105,
            "angle": 216,
            "text": qsTr("Unhealthy"),
            "color": Style.orange
        },
        {
            "value": 200,
            "angle": 270,
            "text": qsTr("Very unhealthy"),
            "color": Style.red
        },
        {
            "value": 200,
            "angle": 270,
            "text": qsTr("Hazardeous"),
            "color": Style.purple
        }
    ]
}
