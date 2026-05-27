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
import Qt5Compat.GraphicalEffects
import QtCharts
import Nymea
import NymeaApp.Utils

import "qrc:/ui/components"

Item {
    id: root

    property bool animationsEnabled: false
    property EnergyManager energyManager: null
    property ThingsProxy consumers: null
    property bool showEvChargers: false

    property string gridIcon
    property string pvIcon
    property string homeIcon

    onConsumersChanged: Qt.callLater(evChargerChart.updateSliceValues)

    readonly property double fromGrid: Math.max(0, energyManager.currentPowerAcquisition)
    readonly property double fromStorage: -Math.min(0, energyManager.currentPowerStorage)
    readonly property double toStorage: -Math.min(0, -energyManager.currentPowerStorage)
    readonly property double fromCar: showEvChargers ? -Math.min(0, evChargerPowerRepeater.currentPower) : 0
    readonly property double toCar: showEvChargers ? Math.max(0, evChargerPowerRepeater.currentPower) : 0
    readonly property double householdConsumption: Math.max(0, energyManager.currentPowerConsumption - toCar)
    readonly property double fromGridToConsumption: Math.min(fromGrid, Math.max(0, householdConsumption - fromStorage - fromCar))
    readonly property double fromProduction: Math.max(0, householdConsumption - fromGridToConsumption - fromStorage - fromCar)
    readonly property double toGrid: Math.max(0, - energyManager.currentPowerAcquisition)


    Label {
        id: titleLabel
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: Style.smallMargins }
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("My energy mix")
        MouseArea {
            anchors.fill: parent
            onClicked: {
                pageStack.push(Qt.resolvedUrl("CurrentPowerBalancePage.qml"), {energyManager: root.energyManager, consumers: root.consumers, showEvChargers: root.showEvChargers})
            }
        }
    }

    QtObject {
        id: d
        function formatValue(value) {
            var ret
            if (Math.abs(value) >= 1000) {
                ret = (value / 1000).toFixed(1) + "kW"
            } else {
                ret = value.toFixed(1) +  "W"
            }
            return ret
        }
        function thingColor(thing, fallbackIndex) {
            if (root.consumers && thing) {
                for (var i = 0; i < root.consumers.count; i++) {
                    var consumer = root.consumers.get(i)
                    if (consumer && consumer.id.toString() === thing.id.toString()) {
                        return NymeaUtils.generateColor(Style.generationBaseColor, i)
                    }
                }
            }
            return NymeaUtils.generateColor(Style.generationBaseColor, fallbackIndex)
        }

        property double progress: 0
        onProgressChanged: canvas.requestPaint()

        property int chartSize: evChargerVisible ? Math.min(contentContainer.width / 2.7, contentContainer.height / 3) : width / 2.5

        property bool acquisitionVisible: true
        property bool productionVisible: producers.count > 0 || energyManager.currentPowerAcquisition < 0
        property bool storageVisible: batteries.count > 0
        property bool evChargerVisible: root.showEvChargers && evChargerPowerRepeater.currentPowerCount > 0
        property bool consumptionVisible: true

        property point circleCenter: Qt.point(contentContainer.width / 2, contentContainer.height / 2)
        property double circleRadius: Math.max(0, Math.min(contentContainer.width / 2 - chartSize / 2 - Style.margins,
                                                          contentContainer.height / 2 - chartSize / 2 - Style.margins))

        function circlePos(index, count) {
            var angle = -90 + index * 360 / count
            return Qt.point(circleCenter.x + circleRadius * Math.cos(angle * Math.PI / 180),
                            circleCenter.y + circleRadius * Math.sin(angle * Math.PI / 180))
        }

        property int circleCount: 3 + (storageVisible ? 1 : 0) + (productionVisible ? 1 : 0)
        property point acquisitionPos: evChargerVisible
                                       ? circlePos(0, circleCount)
                                       : Qt.point(chartSize/2 + Style.margins, chartSize/2 + Style.margins)
        property point productionPos: evChargerVisible
                                      ? circlePos(1, circleCount)
                                      : Qt.point(contentContainer.width - (chartSize/2 + Style.margins), chartSize/2 + Style.margins)
        property point evChargerPos: evChargerVisible
                                     ? circlePos(productionVisible ? 2 : 1, circleCount)
                                     : storageVisible ? Qt.point(contentContainer.width / 2, contentContainer.height - (chartSize/2 + Style.margins))
                                                      : Qt.point(chartSize/2 + Style.margins, contentContainer.height - (chartSize/2 + Style.margins))
        property point consumptionPos: evChargerVisible
                                       ? circlePos((productionVisible ? 3 : 2), circleCount)
                                       : storageVisible || evChargerVisible || !productionVisible
                                       ? Qt.point(contentContainer.width - (chartSize/2 + Style.margins), contentContainer.height - (chartSize/2 + Style.margins))
                                       : Qt.point(contentContainer.width / 2, contentContainer.height - (chartSize/2 + Style.margins))
        property point storagePos: evChargerVisible
                                   ? circlePos((productionVisible ? 4 : 3), circleCount)
                                   : Qt.point(chartSize/2 + Style.margins, contentContainer.height - (chartSize/2 + Style.margins))
    }

    ThingsProxy {
        id: batteries
        engine: _engine
        shownInterfaces: ["energystorage"]
    }
    ThingsProxy {
        id: producers
        engine: _engine
        shownInterfaces: ["smartmeterproducer"]
    }
    ThingsProxy {
        id: evChargers
        engine: _engine
        shownInterfaces: ["evcharger"]
    }
    ThingsProxy {
        id: electricVehicles
        engine: _engine
        shownInterfaces: ["electricvehicle"]
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
        property int connectedVehicleCount: {
            var count = 0
            for (var i = 0; i < evChargerPowerRepeater.count; i++) {
                var item = evChargerPowerRepeater.itemAt(i)
                if (item && item.hasCurrentPower && item.connectedVehicle) {
                    count++
                }
            }
            return count
        }
        property int singleBatteryLevel: {
            if (connectedVehicleCount !== 1) {
                return -1
            }

            for (var i = 0; i < evChargerPowerRepeater.count; i++) {
                var item = evChargerPowerRepeater.itemAt(i)
                if (item && item.hasCurrentPower && item.connectedVehicle) {
                    return item.batteryLevelState ? item.batteryLevelState.value : -1
                }
            }
            return -1
        }

        delegate: Item {
            property Thing thing: evChargers.get(index)
            property State currentPowerState: thing ? thing.stateByName("currentPower") : null
            property bool hasCurrentPower: currentPowerState !== null
            property double currentPower: currentPowerState ? currentPowerState.value : 0
            property State connectedVehicleThingIdState: thing ? thing.stateByName("connectedVehicleThingId") : null
            property Thing connectedVehicle: {
                if (connectedVehicleThingIdState && connectedVehicleThingIdState.value !== "") {
                    return _engine.thingManager.things.getThing(connectedVehicleThingIdState.value)
                }

                for (var i = 0; i < electricVehicles.count; i++) {
                    var vehicle = electricVehicles.get(i)
                    var connectedChargerThingIdState = vehicle ? vehicle.stateByName("connectedChargerThingId") : null
                    if (connectedChargerThingIdState && connectedChargerThingIdState.value == thing.id) {
                        return vehicle
                    }
                }
                return null
            }
            property State batteryLevelState: connectedVehicle ? connectedVehicle.stateByName("batteryLevel") : null
        }
    }

    NumberAnimation {
        id: progressAnimation
        target: d
        property: "progress"
        from: 0
        to: 1
        running: root.animationsEnabled
        loops: Animation.Infinite
        duration: 5000
    }

    Item {
        id: contentContainer
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; top: titleLabel.bottom}

        Canvas {
            id: canvas
            anchors.fill: parent

            // Breaks scaling on iOS
            // renderTarget: Canvas.FramebufferObject
            renderStrategy: Canvas.Cooperative

            onPaint: {
                var ctx = getContext("2d");

                var solarPos = Qt.point(d.productionPos.x - width / 2, d.productionPos.y - height / 2)
                var storagePos = Qt.point(d.storagePos.x - width / 2, d.storagePos.y - width / 2)
                var consumptionPos = Qt.point(d.consumptionPos.x - width / 2, d.consumptionPos.y - height / 2)
                var gridPos = Qt.point(d.acquisitionPos.x - width / 2, d.acquisitionPos.y - height / 2)
                var evChargerPos = Qt.point(d.evChargerPos.x - width / 2, d.evChargerPos.y - height / 2)

                ctx.save();
                ctx.reset()

                ctx.translate(width / 2, height / 2);

                ctx.strokeStyle = Style.foregroundColor
                ctx.fillStyle = Style.foregroundColor
                ctx.lineWidth = 2

                var biggest = Math.max(
                            Math.abs(energyManager.currentPowerAcquisition),
                            Math.abs(energyManager.currentPowerConsumption),
                            Math.abs(energyManager.currentPowerProduction),
                            Math.abs(energyManager.currentPowerStorage),
                            Math.abs(evChargerPowerRepeater.currentPower)
                            )
                var size


                if (root.toGrid > 0) {
                    size = root.toGrid / biggest
                    drawDottedCurve(ctx, solarPos, gridPos, size, Style.powerReturnColor)
                }

                if (energyManager.currentPowerProduction < 0 && root.fromProduction) {
                    size = root.fromProduction / biggest
                    drawDottedCurve(ctx, solarPos, consumptionPos, size, Style.powerSelfProductionConsumptionColor)
                }

                if (batteries.count > 0) {
                    if (energyManager.currentPowerStorage > 0) {
                        if (energyManager.currentPowerProduction < 0) {
                            size = Math.abs(energyManager.currentPowerStorage) / biggest
                            drawDottedCurve(ctx, solarPos, storagePos, size, Style.powerBatteryChargingColor)
                        } else {
                            size = Math.abs(energyManager.currentPowerStorage) / biggest
                            drawDottedCurve(ctx, gridPos, storagePos, size, Style.powerBatteryChargingColor)
                        }
                    }

                    if (energyManager.currentPowerStorage < 0) {
                        size = Math.abs(energyManager.currentPowerStorage) / biggest
                        drawDottedCurve(ctx, storagePos, consumptionPos, size, Style.powerBatteryDischargingColor)
                    }
                }

                if (d.evChargerVisible) {
                    if (evChargerPowerRepeater.currentPower > 0) {
                        size = Math.abs(evChargerPowerRepeater.currentPower) / biggest
                        if (energyManager.currentPowerProduction < 0) {
                            drawDottedCurve(ctx, solarPos, evChargerPos, size, app.interfaceToColor("electricvehicle"))
                        } else {
                            drawDottedCurve(ctx, gridPos, evChargerPos, size, app.interfaceToColor("electricvehicle"))
                        }
                    } else if (evChargerPowerRepeater.currentPower < 0) {
                        size = Math.abs(evChargerPowerRepeater.currentPower) / biggest
                        drawDottedCurve(ctx, evChargerPos, consumptionPos, size, app.interfaceToColor("electricvehicle"))
                    }
                }

                if (root.fromGridToConsumption > 0) {
                    size = root.fromGridToConsumption / biggest
                    drawDottedCurve(ctx, gridPos, consumptionPos, size, Style.powerAcquisitionColor)
                }

                ctx.restore();
            }

            function bezierCurvePoint(p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y, t) {
                var x = Math.pow(1-t, 3)*p0x + 3*Math.pow(1-t, 2)*t*p1x + 3*(1-t)*Math.pow(t, 2)*p2x + Math.pow(t, 3)*p3x;
                var y = Math.pow(1-t, 3)*p0y + 3*Math.pow(1-t, 2)*t*p1y + 3*(1-t)*Math.pow(t, 2)*p2y + Math.pow(t, 3)*p3y;
                return Qt.point(x, y)
            }

            function circlePoint(center, radius, angle) {
                var x = center.x + radius * Math.cos(angle * 2 * Math.PI / 360)
                var y = center.y + radius * Math.sin(angle * 2 * Math.PI / 360)
                return Qt.point(x, y)
            }

            function drawDottedCurve(ctx, start, end, size, color) {
                var c1 = getControlPoint(start)
                var c2 = getControlPoint(end)
                ctx.fillStyle = color
                ctx.strokeStyle = color
                var count = 10;
                for (var i = 1; i <= count; i++) {
                    var offset = 1 / count;
                    var progress = d.progress + i * offset
                    if (progress > 1)
                        progress -= 1
                    var point = bezierCurvePoint(start.x, start.y, c1.x, c1.y, c2.x, c2.y, end.x, end.y, progress)
    //                print("painting", d.progress, point.x, point.y)
                    ctx.beginPath();
                    ctx.arc(point.x, point.y, Math.max(1, size * 5), 0, 2 *Math.PI)
                    ctx.stroke();
                    ctx.fill();
                    ctx.closePath();

                }

            }

            function getControlPoint(point) {
                return Qt.point(point.x * .1, point.y * .1)
            }

        }

        Item {
            id: acquisitionItem
            x: d.acquisitionPos.x - width / 2
            y: d.acquisitionPos.y - height / 2
            width: d.chartSize
            height: d.chartSize

            Rectangle {
                anchors.centerIn: parent
                width: acquisitionChart.plotArea.width
                height: acquisitionChart.plotArea.height
                color: Style.backgroundColor
                radius: width / 2
            }

            ColumnLayout {
                anchors.centerIn: parent
                width: acquisitionChart.plotArea.width * 0.8
                ColorIcon {
                    Layout.alignment: Qt.AlignHCenter
                    size: Style.bigIconSize
        //            color: Style.red
                    name: root.gridIcon === "" ? "qrc:/icons/power-grid.svg" : root.gridIcon
                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: d.formatValue(Math.abs(energyManager.currentPowerAcquisition))
    //                color: energyManager.currentPowerAcquisition >= 0 ? Style.red : Style.yellow
                }
            }


            ChartView {
                id: acquisitionChart
                anchors.fill: parent
                legend.visible: false
                margins { left: 0; top: 0; right: 0; bottom: 0 }
                backgroundColor: "transparent"
                animationOptions: root.animationsEnabled ? NymeaUtils.chartsAnimationOptions : ChartView.NoAnimation
                rotation: 130

                PieSeries {
                    size: 1
                    holeSize: 0.8

                    PieSlice {
                        color: Style.powerAcquisitionColor
                        borderColor: color
                        borderWidth: 0
                        value: root.fromGrid
                    }
                    PieSlice {
                        color: Style.powerReturnColor
                        borderColor: color
                        borderWidth: 0
                        value: root.toGrid
                    }
                    PieSlice {
                        color: Style.tooltipBackgroundColor
                        borderColor: color
                        borderWidth: 0
                        value: energyManager.currentPowerAcquisition == 0 ? 1 : 0
                    }
                }
            }
        }


        Item {
            id: productionItem
            x: d.productionPos.x - width / 2
            y: d.productionPos.y - height / 2
            width: d.chartSize
            height: d.chartSize
            visible: d.productionVisible

            Rectangle {
                anchors.centerIn: parent
                width: productionChart.plotArea.width
                height: productionChart.plotArea.height
                color: Style.backgroundColor
                radius: width / 2
            }

            ColumnLayout {
                anchors.centerIn: parent
                width: productionChart.plotArea.width * 0.8
                ColorIcon {
                    Layout.alignment: Qt.AlignHCenter
                    size: Style.bigIconSize
                    //            color: Style.yellow
                    name: root.pvIcon === "" ? "qrc:/icons/weathericons/weather-clear-day.svg" : root.pvIcon

                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: producers.count == 0 ? "?" : d.formatValue(Math.abs(energyManager.currentPowerProduction))
                    //            color: energyManager.currentPowerAcquisition >= 0 ? Style.red : Style.green
                }
            }


            ChartView {
                id: productionChart
                anchors.fill: parent
                legend.visible: false
                backgroundColor: "transparent"
                margins { left: 0; top: 0; right: 0; bottom: 0 }
                animationOptions: root.animationsEnabled ? NymeaUtils.chartsAnimationOptions : ChartView.NoAnimation
                rotation: -130

                PieSeries {
                    size: 1
                    holeSize: 0.8

                    PieSlice {
                        color: Style.powerReturnColor
                        borderColor: color
                        borderWidth: 0
                        value: root.toGrid
                    }
                    PieSlice {
                        color: Style.powerBatteryChargingColor
                        borderColor: color
                        borderWidth: 0
                        value: root.toStorage
                    }
                    PieSlice {
                        color: app.interfaceToColor("electricvehicle")
                        borderColor: color
                        borderWidth: 0
                        value: root.toCar
                    }
                    PieSlice {
                        color: Style.powerSelfProductionConsumptionColor
                        borderColor: color
                        borderWidth: 0
                        value: root.fromProduction
                    }
                    PieSlice {
                        color: Style.tooltipBackgroundColor
                        borderColor: color
                        borderWidth: 0
                        value: energyManager.currentPowerProduction == 0 ? 1 : 0
                    }
                }
            }
        }

        Item {
            id: consumptionItem
            x: d.consumptionPos.x - width / 2
            y: d.consumptionPos.y - height / 2
            width: d.chartSize
            height: d.chartSize

            Rectangle {
                anchors.centerIn: parent
                width: consumptionChart.plotArea.width
                height: consumptionChart.plotArea.height
                color: Style.backgroundColor
                radius: width / 2
            }

            ColumnLayout {
                anchors.centerIn: parent
                width: consumptionChart.plotArea.width * 0.8
                ColorIcon {
                    Layout.alignment: Qt.AlignHCenter
                    size: Style.bigIconSize
                    //            color: Style.blue
                    name: root.homeIcon === "" ? "qrc:/icons/powersocket.svg": root.homeIcon

                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: energyManager.currentPowerConsumption < 0 ? "?" : d.formatValue(root.householdConsumption)
        //            color: energyManager.currentPowerAcquisition >= 0 ? Style.red : Style.green
                }
            }

            ChartView {
                id: consumptionChart
                anchors.fill: parent
                margins { left: 0; top: 0; right: 0; bottom: 0 }
                legend.visible: false
                backgroundColor: "transparent"
                animationOptions: root.animationsEnabled ? NymeaUtils.chartsAnimationOptions : ChartView.NoAnimation
                rotation: !d.productionVisible || d.storageVisible ? -50 : 0

                PieSeries {
                    size: 1
                    holeSize: 0.8

                    PieSlice {
                        color: Style.powerSelfProductionConsumptionColor
                        borderColor: color
                        borderWidth: 0
                        value: root.fromProduction
                    }
                    PieSlice {
                        color: Style.powerBatteryDischargingColor
                        borderColor: color
                        borderWidth: 0
                        value: root.fromStorage
                    }
                    PieSlice {
                        color: app.interfaceToColor("electricvehicle")
                        borderColor: color
                        borderWidth: 0
                        value: root.fromCar
                    }
                    PieSlice {
                        color: Style.powerAcquisitionColor
                        borderColor: color
                        borderWidth: 0
                        value: root.fromGridToConsumption
                    }
                }
            }
        }


        Item {
            id: batteryItem
            x: d.storagePos.x - width / 2
            y: d.storagePos.y - height / 2
            width: d.chartSize
            height: d.chartSize
            visible: d.storageVisible

            Rectangle {
                anchors.centerIn: parent
                width: batteryChart.plotArea.width
                height: batteryChart.plotArea.height
                color: Style.backgroundColor
                radius: width / 2
            }

            ColumnLayout {
                anchors.centerIn: parent
                width: productionChart.plotArea.width * 0.8
                ColorIcon {
                    Layout.alignment: Qt.AlignHCenter
                    size: Style.bigIconSize
                    //            color: Style.purple
                    name: "qrc:/icons/battery/battery-" + NymeaUtils.pad(Math.round(batteryChart.averageLevel / 10) * 10, 3) + ".svg"
                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: d.formatValue(Math.abs(energyManager.currentPowerStorage))
        //            color: energyManager.currentPowerStorage >= 0 ? Style.green : Style.red
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                y: batteryChart.y + batteryChart.plotArea.height * .2
                horizontalAlignment: Text.AlignHCenter
                font: Style.smallFont
                text: batteryChart.averageLevel + "%"
    //            color: energyManager.currentPowerStorage >= 0 ? Style.green : Style.red
            }

            ChartView {
                id: batteryChart
                anchors.fill: parent
                margins { left: 0; top: 0; right: 0; bottom: 0 }
                legend.visible: false
                backgroundColor: "transparent"
                animationOptions: root.animationsEnabled ? NymeaUtils.chartsAnimationOptions : ChartView.NoAnimation
                rotation: 45

                property double totalCapacity: {
                    var totalCapacity = 0;
                    for (var i = 0; i < batteriesRepeater.count; i++) {
                        totalCapacity += batteriesRepeater.itemAt(i).capacityState.value
                    }
                    return totalCapacity;
                }
                property double averageLevel: {
                    if (batteriesRepeater.count == 0) {
                        return 0;
                    }

                    var averageLevel = 0;
                    for (var i = 0; i < batteriesRepeater.count; i++) {
                        averageLevel += batteriesRepeater.itemAt(i).batteryLevelState.value
                    }
                    averageLevel /= batteriesRepeater.count
                    return averageLevel;
                }

                Repeater {
                    id: batteriesRepeater
                    model: batteries
                    delegate: Item {
                        property Thing thing: batteries.get(index)
                        property State batteryLevelState: thing.stateByName("batteryLevel")
                        property State capacityState: thing.stateByName("capacity")
                    }
                }

                PieSeries {
                    id: batterySeries
                    size: 1
                    holeSize: 0.8

                    PieSlice {
                        color: energyManager.currentPowerStorage == 0
                               ? Style.powerBatteryIdleColor
                               : root.toStorage > 0
                                 ? Style.powerBatteryChargingColor
                                 : Style.powerBatteryDischargingColor
                        borderColor: color
                        borderWidth: 0
                        value: batteryChart.averageLevel
                    }
                    PieSlice {
                        color: Style.tooltipBackgroundColor
                        borderColor: color
                        borderWidth: 0
                        value: 100 - batteryChart.averageLevel
                    }
                }
            }
        }

        Item {
            id: evChargerItem
            x: d.evChargerPos.x - width / 2
            y: d.evChargerPos.y - height / 2
            width: d.chartSize
            height: d.chartSize
            visible: d.evChargerVisible

            Rectangle {
                anchors.centerIn: parent
                width: evChargerChart.plotArea.width
                height: evChargerChart.plotArea.height
                color: Style.backgroundColor
                radius: width / 2
            }

            ColumnLayout {
                anchors.centerIn: parent
                width: evChargerChart.plotArea.width * 0.8
                ColorIcon {
                    Layout.alignment: Qt.AlignHCenter
                    size: Style.bigIconSize
                    name: "qrc:/icons/car.svg"
                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: d.formatValue(Math.abs(evChargerPowerRepeater.currentPower))
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                y: evChargerChart.y + evChargerChart.plotArea.height * .2
                horizontalAlignment: Text.AlignHCenter
                font: Style.smallFont
                visible: evChargerPowerRepeater.singleBatteryLevel >= 0
                text: evChargerPowerRepeater.singleBatteryLevel + "%"
            }

            ChartView {
                id: evChargerChart
                anchors.fill: parent
                margins { left: 0; top: 0; right: 0; bottom: 0 }
                legend.visible: false
                backgroundColor: "transparent"
                animationOptions: ChartView.NoAnimation
                rotation: 45

                property var chargerSlices: []

                Component.onCompleted: rebuildSlices()

                function rebuildSlices() {
                    if (!evChargerSeries) {
                        return
                    }

                    evChargerSeries.clear()

                    var slices = []
                    for (var i = 0; i < evChargerPowerRepeater.count; i++) {
                        var item = evChargerPowerRepeater.itemAt(i)
                        if (item && item.hasCurrentPower) {
                            var slice = evChargerSeries.append(item.thing ? item.thing.name : "", Math.max(0.00001, Math.abs(item.currentPower)))
                            slice.color = d.thingColor(item.thing, i)
                            slice.borderColor = slice.color
                            slice.borderWidth = 0
                            slices.push(slice)
                        }
                    }

                    if (slices.length === 0) {
                        slice = evChargerSeries.append("", 1)
                        slice.color = Style.powerBatteryIdleColor
                        slice.borderColor = slice.color
                        slice.borderWidth = 0
                        slices.push(slice)
                    }

                    chargerSlices = slices
                }

                function updateSliceValues() {
                    if (!evChargerSeries) {
                        return
                    }

                    if (chargerSlices.length !== Math.max(1, evChargerPowerRepeater.currentPowerCount)) {
                        rebuildSlices()
                        return
                    }

                    var sliceIndex = 0
                    for (var i = 0; i < evChargerPowerRepeater.count; i++) {
                        var item = evChargerPowerRepeater.itemAt(i)
                        if (item && item.hasCurrentPower) {
                            chargerSlices[sliceIndex].value = Math.max(0.00001, Math.abs(item.currentPower))
                            chargerSlices[sliceIndex].color = d.thingColor(item.thing, i)
                            chargerSlices[sliceIndex].borderColor = chargerSlices[sliceIndex].color
                            sliceIndex++
                        }
                    }
                }

                Connections {
                    target: evChargerPowerRepeater
                    function onCountChanged() {
                        evChargerChart.rebuildSlices()
                    }
                    function onCurrentPowerCountChanged() {
                        evChargerChart.rebuildSlices()
                    }
                    function onCurrentPowerChanged() {
                        evChargerChart.updateSliceValues()
                    }
                }

                Connections {
                    target: root.consumers
                    enabled: root.consumers !== null
                    function onCountChanged() {
                        evChargerChart.rebuildSlices()
                    }
                    function onRowsInserted() {
                        evChargerChart.rebuildSlices()
                    }
                    function onRowsRemoved() {
                        evChargerChart.rebuildSlices()
                    }
                    function onModelReset() {
                        evChargerChart.rebuildSlices()
                    }
                }

                PieSeries {
                    id: evChargerSeries
                    size: 1
                    holeSize: 0.8
                }
            }
        }
    }
}
