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
import QtCharts
import Nymea
import NymeaApp.Utils

import "../../components"
import "../../delegates"
import "../../customviews"

DashboardDelegateBase {
    id: root
    property DashboardSensorItem item: null

    readonly property Thing thing: engine.thingManager.fetchingData ? null : engine.thingManager.things.getThing(root.item.thingId)
    readonly property var interfaces: root.item.interfaces

    contentItem: Loader {
        height: root.height
        width: root.width
        sourceComponent: root.item.interfaces.length === 1 ? singleSensorViewComponent : multiSensorViewComponent
    }

    Component {
        id: singleSensorViewComponent
        ColumnLayout {
            id: delegateRoot
            SensorView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                thing: root.thing
                interfaceName: root.item.interfaces[0]
        //        onPressAndHold: root.longPressed();
            }
            Label {
                text: root.thing.name
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Component {
        id: multiSensorViewComponent
        SensorListDelegate {
            id: delegateRoot
            thing: root.thing
        }
    }
}
