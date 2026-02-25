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
import QtQuick.Layouts
import QtQuick.Controls
import Nymea

import "qrc:/ui/components"

Page {
    id: root

    property EnergyManager energyManager: null
    property ThingsProxy consumers: null
    property ThingsProxy producers: null

    header: NymeaHeader {
        text: qsTr("My energy mix")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    GridLayout {
        anchors.fill: parent
        columns: app.landscape ? 2 : 1

        CurrentConsumptionBalancePieChart {
            Layout.fillWidth: true
            Layout.fillHeight: true
            energyManager: root.energyManager
            visible: root.producers ? root.producers.count > 0 : false
            animationsEnabled: Qt.application.active
        }
        CurrentProductionBalancePieChart {
            Layout.fillWidth: true
            Layout.fillHeight: true
            energyManager: root.energyManager
            visible: root.producers ? root.producers.count > 0 : false
            animationsEnabled: Qt.application.active
        }
    }


}
