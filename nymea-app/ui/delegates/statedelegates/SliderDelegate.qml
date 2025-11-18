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

import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../../components"

RowLayout {
    id: root
    width: 150
    signal changed(var value)

    property var value
    property var unit: Types.UnitNone
    property alias from: slider.from
    property alias to: slider.to

    property StateType stateType

    readonly property int decimals: root.stateType.type.toLowerCase() === "int" ? 0 : 1

    Slider {
        id: slider
        Layout.fillWidth: true
        value: root.value
        stepSize: {
            var ret = 1
            for (var i = 0; i < root.decimals; i++) {
                ret /= 10;
            }
            return ret;
        }
        property var lastVibration: new Date()
        property var lastChange: root.value
        onMoved: {
            // Emits moved more often than stepsize, we only want to act when we actually emitted value change
            if (value === lastChange) {
                return;
            }
            lastChange = value;

            if (value === from || value === to) {
                PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackImpact)
            } else {
                if (lastVibration.getTime() + 35 < new Date()) {
                    PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                }
                lastVibration = new Date()
            }


            root.changed(value)
        }
    }
    Label {
        text: Types.toUiValue(slider.value, root.unit).toFixed(root.decimals)
    }
}
