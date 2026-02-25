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
import QtCharts 2.2

Item {
    id: sliceItem
    property PieSeries series: null
    property Thing thing: model.get(index)
    property State currentPowerState: thing ? thing.stateByName("currentPower") : null
    property PieSlice consumerSlice: null
    property PieSlice producerSlice: null
    Component.onCompleted: {
        if (currentPowerState.value >= 0) {
            consumerSlice = consumersSeries.append(thing.name, currentPowerState.value)
            prodcuersSlice = producerSeries.append(thing.name, 0)
        } else {
            consumerSlice = consumersSeries.append(thing.name, 0)
            prodcuersSlice = producerSeries.append(thing.name, Math.abs(currentPowerState.value))
        }
    }
    Connections {
        target: currentPowerState
        onValueChanged: {
            if (currentPowerState.value >= 0) {
                consumerSlice.value = currentPowerState.value
                producerSlice.value = 0
            } else {
                consumerSlice.value = 0
                producerSlice.value = Math.abs(currentPowerState.value)
            }
        }
    }

    Component.onDestruction: {
        consumersSeries.remove(slice)
    }
}
