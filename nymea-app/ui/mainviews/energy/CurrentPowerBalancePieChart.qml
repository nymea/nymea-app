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

    implicitHeight: titleLabel.implicitHeight + d.preferredContentHeight + Style.smallMargins * 2

    property bool animationsEnabled: false
    property bool pauseParticleEmittersOnWindowFocusChanged: false
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
    readonly property double homeIn: Math.max(0, householdConsumption)
    readonly property double householdConsumption: Math.max(0, energyManager.currentPowerConsumption - (showEvChargers ? evChargerPowerRepeater.currentPower : 0))
    readonly property double visiblePowerThreshold: 0.05
    readonly property bool flowAnimationsEnabled: animationsEnabled && (!pauseParticleEmittersOnWindowFocusChanged || Qt.application.active)

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
            slice.color = NymeaUtils.generateColor(Style.powerReturnColor, i)
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

        var colorMap = {}
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
            colorMap[consumer] = slice.color
            currentPowerState.valueChanged.connect(function() {
                slice.value = Math.max(0, currentPowerState.value)
                root.updateConsumerUnknownSlice()
            })
            consumersSummation += Math.max(0, currentPowerState.value)
        }

        d.consumersSummation = consumersSummation
        d.consumersColorMap = colorMap

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
        property var consumersColorMap: ({})
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
        property bool acquisitionVisible: root.rootMeterConfigured
        property bool productionVisible: root.rootMeterConfigured && producers.count > 0
        property bool storageVisible: root.rootMeterConfigured && batteries.count > 0
        property bool evChargerVisible: root.rootMeterConfigured && root.showEvChargers && evChargers.count > 0
        property bool consumptionVisible: true

        property real layoutWidthFactor: 3.2
        property real layoutHeightFactor: evChargerVisible ? 4 : 2.9
        property int chartSize: contentContainer.width / layoutWidthFactor
        property real preferredContentHeight: chartSize * layoutHeightFactor

        property color gridImportFlowColor: Style.powerAcquisitionColor
        property color gridExportFlowColor: Style.powerReturnColor
        property color productionFlowColor: Style.powerReturnColor
        property color storageChargingFlowColor: Style.powerBatteryChargingColor
        property color storageDischargingFlowColor: Style.powerBatteryDischargingColor
        property color evChargerFlowColor: app.interfaceToColor("electricvehicle")
        property color householdFlowColor: Style.powerSelfProductionConsumptionColor
        property double minimumFlowPower: 100
        property double maximumFlowPower: 5000
        property double minimumFlowWidth: Math.max(5, chartSize * 0.04)
        property double maximumFlowWidth: Math.max(minimumFlowWidth * 2, chartSize * 0.08)
        property double flowBackgroundExtraWidth: Math.max(3, chartSize * 0.035)
        property double flowDashMargin: Math.max(0.5, chartSize * 0.004)
        property int minimumDashDuration: 800
        property int maximumDashDuration: 10000
        property int dashLength: 32
        property int dashGap: 16
        property int directionChangePauseDuration: 120

        property point consumptionPos: Qt.point(contentContainer.width / 2, chartSize * 1.9)
        property point acquisitionPos: Qt.point(contentContainer.width / 2, chartSize / 2)
        property point productionPos: Qt.point(contentContainer.width - chartSize / 2, chartSize)
        property point storagePos: Qt.point(chartSize / 2, chartSize)
        property point evChargerPos: Qt.point(consumptionPos.x, consumptionPos.y + chartSize * 1.5)
        property point consumptionLeftPos: Qt.point(consumptionPos.x, consumptionPos.y)
        property point consumptionRightPos: Qt.point(consumptionPos.x, consumptionPos.y)

        function flowEnabled(power) {
            return power > root.visiblePowerThreshold
        }

        function flowPowerRatio(power) {
            var clampedPower = Math.max(minimumFlowPower, Math.min(maximumFlowPower, power))
            return (clampedPower - minimumFlowPower) / (maximumFlowPower - minimumFlowPower)
        }

        function flowWidth(power) {
            return minimumFlowWidth + (maximumFlowWidth - minimumFlowWidth) * Math.sqrt(flowPowerRatio(power))
        }

        function flowBackgroundWidth(power) {
            return flowWidth(power) + flowBackgroundExtraWidth
        }

        function flowDuration(power) {
            var ratio = flowPowerRatio(power)
            return maximumDashDuration - (maximumDashDuration - minimumDashDuration) * Math.sqrt(ratio)
        }

        function signedFlowWidth(power) {
            return flowWidth(Math.abs(power))
        }

        function signedFlowBackgroundWidth(power) {
            return flowBackgroundWidth(Math.abs(power))
        }

        function signedFlowDuration(power) {
            return flowDuration(Math.abs(power))
        }
    }

    ThingsProxy {
        id: batteries
        engine: _engine
        shownInterfaces: ["energystorage"]
    }
    ThingsProxy {
        id: producers
        engine: _engine
        shownInterfaces: ["solarinverter"]
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

    Item {
        id: contentContainer
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; top: titleLabel.bottom}

        FlowCurve {
            id: gridFlowCurve
            anchors.fill: parent
            routeVisible: d.acquisitionVisible
            flowVisible: d.acquisitionVisible && d.flowEnabled(Math.abs(root.energyManager.currentPowerAcquisition))
            animationsEnabled: root.flowAnimationsEnabled
            startPoint: d.acquisitionPos
            endPoint: d.consumptionRightPos
            reverse: root.energyManager.currentPowerAcquisition < 0
            flowColor: reverse ? d.gridExportFlowColor : d.gridImportFlowColor
            backgroundColor: Qt.rgba(flowColor.r, flowColor.g, flowColor.b, 0.12)
            lineWidth: d.signedFlowWidth(root.energyManager.currentPowerAcquisition)
            backgroundLineWidth: d.signedFlowBackgroundWidth(root.energyManager.currentPowerAcquisition)
            dashMargin: d.flowDashMargin
            bendRatio: 0
            dashLength: d.dashLength
            dashGap: d.dashGap
            animationDuration: d.signedFlowDuration(root.energyManager.currentPowerAcquisition)
            directionChangePauseDuration: d.directionChangePauseDuration
        }

        FlowCurve {
            id: pvProductionFlowCurve
            anchors.fill: parent
            routeVisible: d.productionVisible
            flowVisible: d.productionVisible && d.flowEnabled(root.productionOut)
            animationsEnabled: root.flowAnimationsEnabled
            startPoint: d.productionPos
            endPoint: d.consumptionRightPos
            flowColor: d.productionFlowColor
            backgroundColor: Qt.rgba(flowColor.r, flowColor.g, flowColor.b, 0.12)
            lineWidth: d.flowWidth(root.productionOut)
            backgroundLineWidth: d.flowBackgroundWidth(root.productionOut)
            dashMargin: d.flowDashMargin
            bendRatio: -0.12
            dashLength: d.dashLength
            dashGap: d.dashGap
            animationDuration: d.flowDuration(root.productionOut)
        }

        FlowCurve {
            id: batteryFlowCurve
            anchors.fill: parent
            routeVisible: d.storageVisible
            flowVisible: d.storageVisible && d.flowEnabled(Math.abs(root.energyManager.currentPowerStorage))
            animationsEnabled: root.flowAnimationsEnabled
            startPoint: d.consumptionLeftPos
            endPoint: d.storagePos
            reverse: root.energyManager.currentPowerStorage < 0
            flowColor: reverse ? d.storageDischargingFlowColor : d.storageChargingFlowColor
            backgroundColor: Qt.rgba(flowColor.r, flowColor.g, flowColor.b, 0.12)
            lineWidth: d.signedFlowWidth(root.energyManager.currentPowerStorage)
            backgroundLineWidth: d.signedFlowBackgroundWidth(root.energyManager.currentPowerStorage)
            dashMargin: d.flowDashMargin
            bendRatio: -0.12
            dashLength: d.dashLength
            dashGap: d.dashGap
            animationDuration: d.signedFlowDuration(root.energyManager.currentPowerStorage)
            directionChangePauseDuration: d.directionChangePauseDuration
        }

        FlowCurve {
            id: evChargerFlowCurve
            anchors.fill: parent
            routeVisible: d.evChargerVisible
            flowVisible: d.evChargerVisible && d.flowEnabled(Math.abs(evChargerPowerRepeater.currentPower))
            animationsEnabled: root.flowAnimationsEnabled
            startPoint: d.consumptionPos
            endPoint: d.evChargerPos
            reverse: evChargerPowerRepeater.currentPower < 0
            flowColor: d.evChargerFlowColor
            backgroundColor: Qt.rgba(flowColor.r, flowColor.g, flowColor.b, 0.12)
            lineWidth: d.signedFlowWidth(evChargerPowerRepeater.currentPower)
            backgroundLineWidth: d.signedFlowBackgroundWidth(evChargerPowerRepeater.currentPower)
            dashMargin: d.flowDashMargin
            bendRatio: 0
            dashLength: d.dashLength
            dashGap: d.dashGap
            animationDuration: d.signedFlowDuration(evChargerPowerRepeater.currentPower)
            directionChangePauseDuration: d.directionChangePauseDuration
        }

        Connections {
            target: root.energyManager
            enabled: root.energyManager !== null
            function onPowerBalanceChanged() {
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
                visible: root.rootMeterConfigured
                ColorIcon {
                    Layout.alignment: Qt.AlignHCenter
                    size: Style.bigIconSize
                    //            color: Style.blue
                    name: root.homeIcon === "" ? "qrc:/icons/home.svg": root.homeIcon

                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: root.rootMeterConfigured ? d.formatValue(root.householdConsumption) : d.formatValue(d.consumersSummation)
        //            color: energyManager.currentPowerAcquisition >= 0 ? Style.red : Style.green
                }
            }

            Flickable {
                id: noRootConsumersLayout
                anchors.centerIn: parent
                width: consumptionChart.plotArea.width * 0.7
                height: Math.min(noRootConsumersColumn.implicitHeight, width)
                contentHeight: noRootConsumersColumn.implicitHeight
                clip: true
                visible: !root.rootMeterConfigured

                ColumnLayout {
                    id: noRootConsumersColumn
                    width: parent.width
                    spacing: Style.smallMargins

                    Repeater {
                        model: ThingsProxy {
                            engine: _engine
                            parentProxy: root.consumers
                            sortStateName: "currentPower"
                            sortOrder: Qt.DescendingOrder
                        }

                        delegate: ColumnLayout {
                            width: parent ? parent.width : 0
                            spacing: 0
                            property Thing consumer: root.consumers ? root.consumers.getThing(model.id) : null
                            property State currentPowerState: consumer ? consumer.stateByName("currentPower") : null
                            property double value: currentPowerState ? Math.max(0, currentPowerState.value) : 0
                            visible: value > 0

                            Label {
                                text: model.name
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                font: Style.extraSmallFont
                            }
                            Label {
                                color: d.consumersColorMap.hasOwnProperty(parent.consumer) ? d.consumersColorMap[parent.consumer] : "transparent"
                                text: "%1 %2"
                                .arg((parent.value / (parent.value > 1000 ? 1000 : 1)).toFixed(1))
                                .arg(parent.value > 1000 ? "kW" : "W")
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                font: Style.smallFont
                            }
                        }
                    }
                }
            }

            ChartView {
                id: consumptionChart
                anchors.fill: parent
                margins { left: 0; top: 0; right: 0; bottom: 0 }
                legend.visible: false
                backgroundColor: "transparent"
                animationOptions: root.animationsEnabled ? NymeaUtils.chartsAnimationOptions : ChartView.NoAnimation
                rotation: root.rootMeterConfigured ? (!d.productionVisible || d.storageVisible ? -50 : 0) : 0

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
