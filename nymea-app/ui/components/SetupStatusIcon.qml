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

    readonly property int setupStatus: thing.setupStatus
    readonly property bool setupInProgress: setupStatus == Thing.ThingSetupStatusInProgress
    readonly property bool setupFailed: setupStatus == Thing.ThingSetupStatusFailed

    name: setupFailed ? "qrc:/icons/dialog-warning-symbolic.svg"
                      : setupInProgress ?  "qrc:/icons/settings.svg" : "qrc:/icons/tick.svg"
    color: setupFailed ? "red" : Style.iconColor

    RotationAnimation on rotation {
        from: 0; to: 360
        duration: 2000
        running: root.setupInProgress
        loops: Animation.Infinite
    }
}
