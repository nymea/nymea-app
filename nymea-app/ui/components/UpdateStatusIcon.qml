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
import Nymea

ColorIcon {
    id: root

    property Thing thing: null

    readonly property State updateStatusState: thing.stateByName("updateStatus")
    readonly property bool updateAvailable: updateStatusState && updateStatusState.value === "available"
    readonly property bool updateRunning: updateStatusState && updateStatusState.value === "updating"

    name: "qrc:/icons/system-update.svg"
    color: Style.accentColor

    RotationAnimation on rotation {
        from: 0; to: 360
        duration: 2000
        running: root.updateRunning
        loops: Animation.Infinite
    }
}
