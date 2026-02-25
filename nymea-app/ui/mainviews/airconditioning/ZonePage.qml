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
import Nymea.AirConditioning

import "qrc:/ui/components"
import "qrc:/ui/customviews"

Page {
    id: root
    property AirConditioningManager acManager: null
    property ZoneInfo zone: null

    ZoneInfoWrapper {
        id: zoneWrapper
        zone: root.zone
    }


    header: NymeaHeader {
        text: root.zone.name

        onBackPressed: {
            pageStack.pop()
        }

        HeaderButton {
            imageSource: "chart"
            onClicked: pageStack.push(Qt.resolvedUrl("ACChartsPage.qml"), {acManager: root.acManager, zoneWrapper: zoneWrapper})
        }
    }

    ZoneView {
        anchors.fill: parent
        acManager: root.acManager
        zoneWrapper: zoneWrapper
    }
}
