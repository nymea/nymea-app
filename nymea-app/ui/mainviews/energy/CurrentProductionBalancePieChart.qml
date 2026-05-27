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
    id: productionPieChart
    backgroundColor: "transparent"
    animationOptions: animationsEnabled ? NymeaUtils.chartsAnimationOptions : ChartView.NoAnimation
    title: qsTr("My energy production")
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
        id: productionBalanceSeries
        size: 0.88
        holeSize: 0.7

        property double toGrid: Math.abs(Math.min(0, energyManager.currentPowerAcquisition))
        property double toStorage: Math.max(0, energyManager.currentPowerStorage)
        property double toCar: productionPieChart.showEvChargers ? Math.max(0, evChargerPowerRepeater.currentPower) : 0
        property double toConsumers: -energyManager.currentPowerProduction - toGrid - toStorage - toCar

        PieSlice {
            color: Style.red
            borderColor: color
            borderWidth: 0
            value: productionBalanceSeries.toConsumers
        }
        PieSlice {
            color: Style.green
            borderColor: color
            borderWidth: 0
            value: productionBalanceSeries.toGrid
        }
        PieSlice {
            color: Style.orange
            borderColor: color
            borderWidth: 0
            value: productionBalanceSeries.toStorage
        }
        PieSlice {
            color: app.interfaceToColor("electricvehicle")
            borderColor: color
            borderWidth: 0
            value: productionBalanceSeries.toCar
        }
        PieSlice {
            color: Style.tooltipBackgroundColor
            borderColor: color
            borderWidth: 0
            value: productionBalanceSeries.toConsumers == 0 && productionBalanceSeries.toGrid == 0 && productionBalanceSeries.toStorage == 0 && productionBalanceSeries.toCar == 0 ? 1 : 0
        }
    }


    Column {
        id: productionCenterLayout
        x: productionPieChart.plotArea.x + (productionPieChart.plotArea.width - width) / 2
        y: productionPieChart.plotArea.y + (productionPieChart.plotArea.height - height) / 2
        width: productionPieChart.plotArea.width * 0.65
//                    height: productionPieChart.plotArea.height * 0.65
        height: childrenRect.height
        spacing: Style.smallMargins

        ColumnLayout {
            spacing: 0
            width: parent.width
            Label {
                text: qsTr("Total")
                font: Style.smallFont
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                property double absValue: Math.abs(Math.min(0, energyManager.currentPowerProduction))
                text: "%1 %2"
                .arg((absValue / (absValue > 1000 ? 1000 : 1)).toFixed(1))
                .arg(absValue > 1000 ? "kW" : "W")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.bigFont

            }
        }


        ColumnLayout {
            spacing: 0
            width: parent.width
            Label {
                text: qsTr("Consumed")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.extraSmallFont
            }
            Label {
                property double absValue: productionBalanceSeries.toConsumers
                color: Style.red
                text: "%1 %2"
                .arg((absValue / (absValue > 1000 ? 1000 : 1)).toFixed(1))
                .arg(absValue > 1000 ? "kWh" : "W")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.smallFont
            }
        }


        ColumnLayout {
            spacing: 0
            width: parent.width
            Label {
                text: qsTr("To grid")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.extraSmallFont
            }
            Label {
                color: Style.green
                property double absValue: productionBalanceSeries.toGrid
                text: "%1 %2".arg((absValue / (absValue > 1000 ? 1000 : 1)).toFixed(1))
                .arg(absValue > 1000 ? "kW" : "W")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.smallFont
            }
        }
        ColumnLayout {
            spacing: 0
            width: parent.width
            visible: batteries.count > 0
            Label {
                text: qsTr("To battery")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.extraSmallFont
            }
            Label {
                color: Style.orange
                property double absValue: productionBalanceSeries.toStorage
                text: "%1 %2".arg((absValue / (absValue > 1000 ? 1000 : 1)).toFixed(1))
                .arg(absValue > 1000 ? "kW" : "W")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.smallFont
            }
        }
        ColumnLayout {
            spacing: 0
            width: parent.width
            visible: productionPieChart.showEvChargers && evChargerPowerRepeater.currentPowerCount > 0
            Label {
                text: qsTr("To car")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.extraSmallFont
            }
            Label {
                color: app.interfaceToColor("electricvehicle")
                property double absValue: productionBalanceSeries.toCar
                text: "%1 %2".arg((absValue / (absValue > 1000 ? 1000 : 1)).toFixed(1))
                .arg(absValue > 1000 ? "kW" : "W")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.smallFont
            }
        }
    }
}
