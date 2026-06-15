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

ChartView {
    id: consumptionPieChart
    backgroundColor: "transparent"
    animationOptions: animationsEnabled ? NymeaUtils.chartsAnimationOptions : ChartView.NoAnimation
    title: qsTr("My energy consumption")
    titleColor: Style.foregroundColor
    legend.visible: false

    margins.left: 0
    margins.right: 0
    margins.bottom: 0
    margins.top: 0

    property bool animationsEnabled: true
    property EnergyManager energyManager: null
    property bool showEvChargers: false

    ThingsProxy {
        id: batteries
        engine: _engine
        shownInterfaces: ["energystorage"]
    }
    ThingsProxy {
        id: evChargers
        engine: _engine
        shownInterfaces: ["evcharger"]
    }

    Repeater {
        id: evChargerPowerRepeater
        model: evChargers

        property int currentPowerCount: {
            var count = 0
            for (var i = 0; i < evChargerPowerRepeater.count; i++) {
                var item = evChargerPowerRepeater.itemAt(i)
                if (item && item.hasCurrentPower) {
                    count++
                }
            }
            return count
        }
        property double currentPower: {
            var power = 0
            for (var i = 0; i < evChargerPowerRepeater.count; i++) {
                var item = evChargerPowerRepeater.itemAt(i)
                if (item && item.hasCurrentPower) {
                    power += item.currentPower
                }
            }
            return power
        }

        delegate: Item {
            property Thing thing: evChargers.get(index)
            property State currentPowerState: thing ? thing.stateByName("currentPower") : null
            property bool hasCurrentPower: currentPowerState !== null
            property double currentPower: currentPowerState ? currentPowerState.value : 0
        }
    }

    PieSeries {
        id: consumptionBalanceSeries
        size: 0.88
        holeSize: 0.7

        property double fromGrid: Math.max(0, energyManager.currentPowerAcquisition)
        property double fromStorage: -Math.min(0, energyManager.currentPowerStorage)
        property double fromCar: consumptionPieChart.showEvChargers ? -Math.min(0, evChargerPowerRepeater.currentPower) : 0
        property double toCar: consumptionPieChart.showEvChargers ? Math.max(0, evChargerPowerRepeater.currentPower) : 0
        property double householdConsumption: Math.max(0, energyManager.currentPowerConsumption - toCar)
        property double fromGridToConsumption: Math.min(fromGrid, Math.max(0, householdConsumption - fromStorage - fromCar))
        property double fromProduction: Math.max(0, householdConsumption - fromGridToConsumption - fromStorage - fromCar)

        PieSlice {
            color: Style.red
            borderColor: color
            borderWidth: 0
            value: consumptionBalanceSeries.fromGridToConsumption
        }
        PieSlice {
            color: Style.green
            borderColor: color
            borderWidth: 0
            value: consumptionBalanceSeries.fromProduction
        }
        PieSlice {
            color: Style.orange
            borderColor: color
            borderWidth: 0
            value: consumptionBalanceSeries.fromStorage
        }
        PieSlice {
            color: app.interfaceToColor("electricvehicle")
            borderColor: color
            borderWidth: 0
            value: consumptionBalanceSeries.fromCar
        }
        PieSlice {
            color: Style.tooltipBackgroundColor
            borderColor: color
            borderWidth: 0
            value: consumptionBalanceSeries.fromGrid == 0 && consumptionBalanceSeries.fromProduction == 0 && consumptionBalanceSeries.fromStorage == 0 && consumptionBalanceSeries.fromCar == 0 ? 1 : 0
        }
    }


    Column {
        id: centerLayout
        x: consumptionPieChart.plotArea.x + (consumptionPieChart.plotArea.width - width) / 2
        y: consumptionPieChart.plotArea.y + (consumptionPieChart.plotArea.height - height) / 2
        width: consumptionPieChart.plotArea.width * 0.65
//                    height: consumptionPieChart.plotArea.height * 0.65
        height: childrenRect.height
        spacing: Style.smallMargins

        ColumnLayout {
            width: parent.width
            spacing: 0
            Label {
                text: qsTr("Total")
                font: Style.smallFont
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                text: "%1 %2"
                .arg((consumptionBalanceSeries.householdConsumption / (consumptionBalanceSeries.householdConsumption > 1000 ? 1000 : 1)).toFixed(1))
                .arg(consumptionBalanceSeries.householdConsumption > 1000 ? "kW" : "W")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.bigFont

            }
        }


        ColumnLayout {
            width: parent.width
            spacing: 0
            Label {
                text: qsTr("From grid")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.extraSmallFont
            }
            Label {
                property double absValue: consumptionBalanceSeries.fromGridToConsumption
                color: Style.red
                text: "%1 %2"
                .arg((absValue / (absValue > 1000 ? 1000 : 1)).toFixed(1))
                .arg(absValue > 1000 ? "kW" : "W")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.smallFont
            }
        }


        ColumnLayout {
            width: parent.width
            spacing: 0
            Label {
                text: qsTr("From self production")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.extraSmallFont
            }
            Label {
                color: Style.green
                property double absValue: consumptionBalanceSeries.fromProduction
                text: "%1 %2".arg((absValue / (absValue > 1000 ? 1000 : 1)).toFixed(1))
                .arg(absValue > 1000 ? "kW" : "W")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.smallFont
            }
        }
        ColumnLayout {
            width: parent.width
            spacing: 0
            visible: batteries.count > 0
            Label {
                text: qsTr("From battery")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.extraSmallFont
            }
            Label {
                color: Style.orange
                property double absValue: consumptionBalanceSeries.fromStorage
                text: "%1 %2".arg((absValue / (absValue > 1000 ? 1000 : 1)).toFixed(1))
                .arg(absValue > 1000 ? "kW" : "W")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.smallFont
            }
        }
        ColumnLayout {
            width: parent.width
            spacing: 0
            visible: consumptionPieChart.showEvChargers && evChargerPowerRepeater.currentPowerCount > 0
            Label {
                text: qsTr("From car")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.extraSmallFont
            }
            Label {
                color: app.interfaceToColor("electricvehicle")
                property double absValue: consumptionBalanceSeries.fromCar
                text: "%1 %2".arg((absValue / (absValue > 1000 ? 1000 : 1)).toFixed(1))
                .arg(absValue > 1000 ? "kW" : "W")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.smallFont
            }
        }
    }
}
