// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import Nymea
import NymeaApp.Utils

Item {
    id: palette
    visible: false
    property ThingsProxy consumers: null
    property ThingsProxy chargers: null
    property int revision: 0

    Connections {
        target: palette.consumers
        ignoreUnknownSignals: true
        function onCountChanged() { palette.revision++ }
        function onRowsInserted() { palette.revision++ }
        function onRowsRemoved() { palette.revision++ }
        function onRowsMoved() { palette.revision++ }
        function onModelReset() { palette.revision++ }
    }

    Connections {
        target: palette.chargers
        ignoreUnknownSignals: true
        function onCountChanged() { palette.revision++ }
        function onRowsInserted() { palette.revision++ }
        function onRowsRemoved() { palette.revision++ }
        function onRowsMoved() { palette.revision++ }
        function onModelReset() { palette.revision++ }
    }

    function colorFor(thing, opacity) {
        revision
        var index = consumers && thing ? consumers.indexOf(thing) : -1
        if (index < 0) {
            var chargerIndex = chargers && thing ? chargers.indexOf(thing) : -1
            if (chargerIndex < 0) {
                return Style.gray
            }
            index = (consumers ? consumers.count : 0) + chargerIndex
        }
        return NymeaUtils.generateColor(Style.generationBaseColor, index,
                                        opacity === undefined ? 1 : opacity)
    }
}
