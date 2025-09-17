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

Item {
    id: root

    property Thing thing: null

    // either or
    property string stateName: ""
    property StateType stateType: null

    readonly property var pendingValue: d.queuedValue || d.pendingValue

    Component.onDestruction: {
        if (d.queuedValue != null) {
            d.pendingCommand = -1;
            sendValue(d.queuedValue);
        }
    }

    function sendValue(value) {
        if (d.pendingCommand != -1) {
            // busy, cache value
            d.queuedValue = value;
            return;
        }
        d.pendingValue = value;
//        print("sending action", value)
        var stateName = root.stateType == null ? root.stateName : root.stateType.name
        d.pendingCommand = root.thing.executeAction(stateName,
                                          [{
                                               paramName: stateName,
                                               value: value
                                           }])
    }

    QtObject {
        id: d
        property int pendingCommand: -1
        property var pendingValue: null
        property var queuedValue: null
    }

    Connections {
        target: root.thing
        onExecuteActionReply: {
            if (d.pendingCommand == commandId) {
//                print("command finished")
                d.pendingCommand = -1;
                if (d.queuedValue != null) {
                    root.sendValue(d.queuedValue)
                    d.queuedValue = null
                } else {
                    d.pendingValue = null
                }
            }
        }
    }
}
