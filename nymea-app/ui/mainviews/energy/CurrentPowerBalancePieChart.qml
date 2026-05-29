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
    property bool showEvChargers: true

    property string gridIcon
    property string pvIcon
    property string homeIcon
    readonly property bool rootMeterConfigured: energyManager && energyManager.rootMeterId.toString() !== "{00000000-0000-0000-0000-000000000000}"

    onConsumersChanged: {
        Qt.callLater(evChargerChart.updateSliceValues)
        Qt.callLater(updateConsumerSlices)
    }

    readonly property double gridIn: Math.max(0, energyManager.currentPowerAcquisition)
    readonly property double gridOut: Math.max(0, -energyManager.currentPowerAcquisition)
    readonly property double productionOut: Math.max(0, -energyManager.currentPowerProduction)
    readonly property double storageIn: Math.max(0, energyManager.currentPowerStorage)
    readonly property double storageOut: Math.max(0, -energyManager.currentPowerStorage)
    readonly property double evIn: showEvChargers ? Math.max(0, evChargerPowerRepeater.currentPower) : 0
    readonly property double evOut: showEvChargers ? Math.max(0, -evChargerPowerRepeater.currentPower) : 0
    readonly property double homeIn: showEvChargers ? Math.max(0, energyManager.currentPowerConsumption - evIn) : energyManager.currentPowerConsumption
    readonly property double consumptionToCar: showEvChargers ? Math.max(0, evChargerPowerRepeater.currentPower) : 0
    readonly property double householdConsumption: Math.max(0, energyManager.currentPowerConsumption - consumptionToCar)
    readonly property double visiblePowerThreshold: 0.05

    function updateConsumerUnknownSlice() {
        var consumersSummation = 0
        if (root.consumers) {
            for (var i = 0; i < root.consumers.count; i++) {
                let consumer = root.consumers.get(i)
                let currentPowerState = consumer ? consumer.stateByName("currentPower") : null
                if (currentPowerState) {
                    consumersSummation += Math.max(0, currentPowerState.value)
                }
            }
        }

        d.consumersSummation = consumersSummation

        if (d.unknownConsumerSlice) {
            d.unknownConsumerSlice.value = Math.max(0, root.householdConsumption - consumersSummation)
        }
    }

    function updateProductionSlices() {
        if (!productionSeries) {
            return
        }

        productionChart.animationOptions = ChartView.NoAnimation
        productionSeries.clear()

        var slices = []
        for (var i = 0; i < producers.count; i++) {
            let producer = producers.get(i)
            let currentPowerState = producer ? producer.stateByName("currentPower") : null
            var value = currentPowerState ? Math.abs(currentPowerState.value) : 0.00001
            let slice = productionSeries.append(producer ? producer.name : "", Math.max(0.00001, value))
            slice.color = NymeaUtils.generateColor(Style.generationBaseColor, i)
            slice.borderColor = slice.color
            slice.borderWidth = 0
            if (currentPowerState) {
                currentPowerState.valueChanged.connect(function() {
                    slice.value = Math.max(0.00001, Math.abs(currentPowerState.value))
                })
            }
            slices.push(slice)
        }

        if (slices.length === 0) {
            var idleSlice = productionSeries.append("", 1)
            idleSlice.color = Style.tooltipBackgroundColor
            idleSlice.borderColor = idleSlice.color
            idleSlice.borderWidth = 0
        }

        productionChart.animationOptions = Qt.binding(function() {
            return root.animationsEnabled ? NymeaUtils.chartsAnimationOptions : ChartView.NoAnimation
        })
    }

    function updateConsumerSlices() {
        if (!consumptionSeries || !root.consumers) {
            return
        }

        consumptionChart.animationOptions = ChartView.NoAnimation
        consumptionSeries.clear()
        d.unknownConsumerSlice = null
        d.idleConsumerSlice = null

        var consumersSummation = 0
        for (var i = 0; i < root.consumers.count; i++) {
            let consumer = root.consumers.get(i)
            let currentPowerState = consumer ? consumer.stateByName("currentPower") : null
            if (!consumer || !currentPowerState) {
                continue
            }

            let slice = consumptionSeries.append(consumer.name, Math.max(0, currentPowerState.value))
            slice.color = NymeaUtils.generateColor(Style.generationBaseColor, i)
            slice.borderColor = slice.color
            slice.borderWidth = 0
            currentPowerState.valueChanged.connect(function() {
                slice.value = Math.max(0, currentPowerState.value)
                root.updateConsumerUnknownSlice()
            })
            consumersSummation += Math.max(0, currentPowerState.value)
        }

        d.consumersSummation = consumersSummation

        if (root.rootMeterConfigured) {
            d.unknownConsumerSlice = consumptionSeries.append(qsTr("Unknown"), Math.max(0, root.householdConsumption - consumersSummation))
            d.unknownConsumerSlice.color = Style.gray
            d.unknownConsumerSlice.borderColor = Style.gray
            d.unknownConsumerSlice.borderWidth = 0
        } else {
            d.idleConsumerSlice = consumptionSeries.append("", 0.00001)
            d.idleConsumerSlice.color = Style.tooltipBackgroundColor
            d.idleConsumerSlice.borderColor = d.idleConsumerSlice.color
            d.idleConsumerSlice.borderWidth = 0
        }

        consumptionChart.animationOptions = Qt.binding(function() {
            return root.animationsEnabled ? NymeaUtils.chartsAnimationOptions : ChartView.NoAnimation
        })
    }


    // Rectangle {
    //     anchors.fill: parent
    //     color: "steelblue"
    //     opacity: 0.5
    // }

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
        property PieSlice unknownConsumerSlice: null
        property PieSlice idleConsumerSlice: null
        property double consumersSummation: 0

        function formatValue(value) {
            var ret
            if (Math.abs(value) >= 1000) {
                ret = (value / 1000).toFixed(1) + "kW"
            } else {
                ret = value.toFixed(1) +  "W"
            }
            return ret
        }
        property double progress: 0
        onProgressChanged: canvas.requestPaint()

        property int chartSize: Math.min(contentContainer.width / 2.7, contentContainer.height / 3)

        property bool acquisitionVisible: root.rootMeterConfigured
        property bool productionVisible: producers.count > 0
        property bool storageVisible: batteries.count > 0
        property bool evChargerVisible: root.showEvChargers && evChargers.count > 0
        property bool consumptionVisible: true
        property color gridImportFlowColor: Style.powerAcquisitionColor
        property color gridExportFlowColor: Style.powerReturnColor
        property color productionFlowColor: Style.powerReturnColor
        property color storageChargingFlowColor: Style.powerBatteryChargingColor
        property color storageDischargingFlowColor: Style.powerBatteryDischargingColor
        property color evChargerFlowColor: app.interfaceToColor("electricvehicle")
        property color householdFlowColor: Style.powerSelfProductionConsumptionColor

        property point circleCenter: Qt.point(contentContainer.width / 2, contentContainer.height / 2)
        property double circleRadius: Math.max(0, Math.min(contentContainer.width / 2 - chartSize / 2 - Style.margins,
                                                          contentContainer.height / 2 - chartSize / 2 - Style.margins))

        function circlePos(index, count) {
            var angle = -90 + index * 360 / count
            return Qt.point(circleCenter.x + circleRadius * Math.cos(angle * Math.PI / 180),
                            circleCenter.y + circleRadius * Math.sin(angle * Math.PI / 180))
        }

        property int circleCount: (acquisitionVisible ? 1 : 0) + (productionVisible ? 1 : 0) + (consumptionVisible ? 1 : 0)
                                  + (evChargerVisible ? 1 : 0) + (storageVisible ? 1 : 0)

        function visibleIndex(node) {
            var index = 0
            if (node === "acquisition")
                return index
            if (acquisitionVisible)
                index++
            if (node === "production")
                return index
            if (productionVisible)
                index++
            if (node === "consumption")
                return index
            if (consumptionVisible)
                index++
            if (node === "evCharger")
                return index
            if (evChargerVisible)
                index++
            return index
        }

        property point acquisitionPos: circlePos(visibleIndex("acquisition"), circleCount)
        property point productionPos: circlePos(visibleIndex("production"), circleCount)
        property point evChargerPos: circlePos(visibleIndex("evCharger"), circleCount)
        property point consumptionPos: circlePos(visibleIndex("consumption"), circleCount)
        property point storagePos: circlePos(visibleIndex("storage"), circleCount)
    }

    ThingsProxy {
        id: batteries
        engine: _engine
        shownInterfaces: ["energystorage"]
    }
    ThingsProxy {
        id: producers
        engine: _engine
        shownInterfaces: ["smartmeterproducer", "solarinverter"]
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
                var storagePos = Qt.point(d.storagePos.x - width / 2, d.storagePos.y - height / 2)
                var consumptionPos = Qt.point(d.consumptionPos.x - width / 2, d.consumptionPos.y - height / 2)
                var gridPos = Qt.point(d.acquisitionPos.x - width / 2, d.acquisitionPos.y - height / 2)
                var evChargerPos = Qt.point(d.evChargerPos.x - width / 2, d.evChargerPos.y - height / 2)

                ctx.save();
                ctx.reset()
                ctx.clearRect(0, 0, width, height)

                ctx.translate(width / 2, height / 2);

                ctx.strokeStyle = Style.foregroundColor
                ctx.fillStyle = Style.foregroundColor
                ctx.lineWidth = 2

                var biggest = Math.max(d.acquisitionVisible ? root.gridIn : 0,
                                       d.acquisitionVisible ? root.gridOut : 0,
                                       d.productionVisible ? root.productionOut : 0,
                                       d.storageVisible ? root.storageIn : 0,
                                       d.storageVisible ? root.storageOut : 0,
                                       d.evChargerVisible ? root.evIn : 0,
                                       d.evChargerVisible ? root.evOut : 0,
                                       Math.max(0, root.homeIn))
                var size


                var busPos = Qt.point(0, 0)

                if (biggest <= 0) {
                    ctx.restore();
                    return;
                }

                if (d.acquisitionVisible && root.gridIn > root.visiblePowerThreshold) {
                    size = root.gridIn / biggest
                    drawDottedCurve(ctx, gridPos, busPos, size, d.gridImportFlowColor)
                }

                if (d.acquisitionVisible && root.gridOut > root.visiblePowerThreshold) {
                    size = root.gridOut / biggest
                    drawDottedCurve(ctx, busPos, gridPos, size, d.gridExportFlowColor)
                }

                if (d.productionVisible && root.productionOut > root.visiblePowerThreshold) {
                    size = root.productionOut / biggest
                    drawDottedCurve(ctx, solarPos, busPos, size, d.productionFlowColor)
                }

                if (d.storageVisible && root.storageIn > root.visiblePowerThreshold) {
                    size = root.storageIn / biggest
                    drawDottedCurve(ctx, busPos, storagePos, size, d.storageChargingFlowColor)
                }

                if (d.storageVisible && root.storageOut > root.visiblePowerThreshold) {
                    size = root.storageOut / biggest
                    drawDottedCurve(ctx, storagePos, busPos, size, d.storageDischargingFlowColor)
                }

                if (d.evChargerVisible) {
                    if (root.evIn > root.visiblePowerThreshold) {
                        size = root.evIn / biggest
                        drawDottedCurve(ctx, busPos, evChargerPos, size, d.evChargerFlowColor)
                    } else if (root.evOut > root.visiblePowerThreshold) {
                        size = root.evOut / biggest
                        drawDottedCurve(ctx, evChargerPos, busPos, size, d.evChargerFlowColor)
                    }
                }

                if (root.homeIn > root.visiblePowerThreshold) {
                    size = root.homeIn / biggest
                    drawDottedCurve(ctx, busPos, consumptionPos, size, d.householdFlowColor)
                }

                ctx.restore();
            }

        Connections {
            target: root.energyManager
            enabled: root.energyManager !== null
            function onPowerBalanceChanged() {
                canvas.requestPaint()
                root.updateConsumerUnknownSlice()
            }
        }

        Connections {
            target: root.consumers
            enabled: root.consumers !== null
            function onCountChanged() {
                root.updateConsumerSlices()
            }
            function onRowsInserted() {
                root.updateConsumerSlices()
            }
            function onRowsRemoved() {
                root.updateConsumerSlices()
            }
            function onModelReset() {
                root.updateConsumerSlices()
            }
        }

        Connections {
            target: producers
            function onCountChanged() {
                root.updateProductionSlices()
            }
            function onRowsInserted() {
                root.updateProductionSlices()
            }
            function onRowsRemoved() {
                root.updateProductionSlices()
            }
            function onModelReset() {
                root.updateProductionSlices()
            }
        }

            Connections {
                target: evChargerPowerRepeater
                function onCurrentPowerChanged() {
                    canvas.requestPaint()
                }
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
            visible: d.acquisitionVisible

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
                        value: root.gridIn
                    }
                    PieSlice {
                        color: Style.powerReturnColor
                        borderColor: color
                        borderWidth: 0
                        value: root.gridOut
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
                    id: productionSeries
                    size: 1
                    holeSize: 0.8
                    Component.onCompleted: root.updateProductionSlices()
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
                    id: consumptionSeries
                    size: 1
                    holeSize: 0.8
                    Component.onCompleted: root.updateConsumerSlices()
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
                               : root.storageIn > 0
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
                        var slice = evChargerSeries.append(item && item.thing ? item.thing.name : "", Math.max(0.00001, Math.abs(item ? item.currentPower : 0)))
                        slice.color = NymeaUtils.generateColor(Style.generationBaseColor, i)
                        slice.borderColor = slice.color
                        slice.borderWidth = 0
                        slices.push(slice)
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

                    if (chargerSlices.length !== Math.max(1, evChargerPowerRepeater.count)) {
                        rebuildSlices()
                        return
                    }

                    for (var i = 0; i < evChargerPowerRepeater.count; i++) {
                        var item = evChargerPowerRepeater.itemAt(i)
                        chargerSlices[i].value = Math.max(0.00001, Math.abs(item ? item.currentPower : 0))
                        chargerSlices[i].color = NymeaUtils.generateColor(Style.generationBaseColor, i)
                        chargerSlices[i].borderColor = chargerSlices[i].color
                    }
                }

                Connections {
                    target: evChargerPowerRepeater
                    function onCountChanged() {
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
