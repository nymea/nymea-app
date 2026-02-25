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

ChartView {
    id: root
    backgroundColor: Style.tileBackgroundColor
    backgroundRoundness: Style.cornerRadius
    theme: ChartView.ChartThemeLight
    legend.labelColor: Style.foregroundColor
    legend.font.pixelSize: app.smallFont
    legend.alignment: Qt.AlignRight
    titleColor: Style.foregroundColor

    property Thing rootMeter: null
    property ThingsProxy meters: null
    property int multiplier: 1
    property string stateName: "totalEnergyConsumed"

    readonly property State rootMeterTotalEnergyState: rootMeter ? rootMeter.stateByName(stateName) : null

    Connections {
        target: meters
        onCountChanged: root.refresh()
    }

    Component.onCompleted: {
        root.refresh()
    }

    QtObject {
        id: d
        property var sliceMap: {}
    }

    function refresh() {
        pieSeries.clear();
        d.sliceMap = {}

        var unknownEnergy = rootMeterTotalEnergyState ? rootMeterTotalEnergyState.value : 0

        for (var i = 0; i < meters.count; i++) {
            var thing = meters.get(i);
            var value = 0;
            var energyState = thing.stateByName(root.stateName)
            if (energyState) {
                value += energyState.value
            }
            var slice = pieSeries.append(thing.name, Math.max(0, value))
            var color = Style.accentColor
            for (var j = 0; j <= i; j+=2) {
                if (i % 2 == 0) {
                    color = Qt.lighter(color, 1.2);
                } else {
                    color = Qt.darker(color, 1.2)
                }
            }
            slice.color = color
            d.sliceMap[slice] = thing
            unknownEnergy -= value
        }

        if (unknownEnergy > 0) {
            var slice = pieSeries.append(qsTr("Unknown"), unknownEnergy)
            slice.color = Style.accentColor
            d.sliceMap[slice] = rootMeter
        }
    }

    PieSeries {
        id: pieSeries
        holeSize: 0.6
        size: 0.8

        onClicked: {
            print("clicked slice", slice, d.sliceMap[slice], d.sliceMap[slice].name)
            pageStack.push("../devicepages/SmartMeterDevicePage.qml", {thing: d.sliceMap[slice]})
        }
    }

    ColumnLayout {
        x: root.plotArea.x + (root.plotArea.width * 0.5) - (width / 2)
        y: root.plotArea.y + (root.plotArea.height * 0.5) - (height / 2)
        width: root.width

        Label {
            font.pixelSize: app.largeFont
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: root.rootMeterTotalEnergyState
                  ? root.rootMeterTotalEnergyState.value.toFixed(2)
                  : Math.round(pieSeries.sum * 1000) / 1000
        }

        Label {
            text: "KWh"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }
    }
}

