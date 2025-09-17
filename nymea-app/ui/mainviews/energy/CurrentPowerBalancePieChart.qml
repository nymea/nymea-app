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

    property string gridIcon
    property string pvIcon
    property string homeIcon

    readonly property double fromGrid: Math.max(0, energyManager.currentPowerAcquisition)
    readonly property double fromStorage: -Math.min(0, energyManager.currentPowerStorage)
    readonly property double toStorage: -Math.min(0, -energyManager.currentPowerStorage)
    readonly property double fromProduction: energyManager.currentPowerConsumption - fromGrid - fromStorage
    readonly property double toGrid: Math.max(0, - energyManager.currentPowerAcquisition)


    Label {
        id: titleLabel
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: Style.smallMargins }
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("My energy mix")
        MouseArea {
            anchors.fill: parent
            onClicked: {
                pageStack.push(Qt.resolvedUrl("CurrentPowerBalancePage.qml"), {energyManager: root.energyManager})
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

        property double progress: 0
        onProgressChanged: canvas.requestPaint()

        property int chartSize: width / 2.5

        property bool acquisitionVisible: true
        property bool productionVisible: producers.count > 0 || energyManager.currentPowerAcquisition < 0
        property bool storageVisible: batteries.count > 0
        property bool consumptionVisible: true

        property point acquisitionPos: Qt.point(chartSize/2 + Style.margins, chartSize/2 + Style.margins)
        property point productionPos: Qt.point(contentContainer.width - (chartSize/2 + Style.margins), chartSize/2 + Style.margins)
        property point storagePos: Qt.point(chartSize/2 + Style.margins, contentContainer.height - (chartSize/2 + Style.margins))
        property point consumptionPos: storageVisible || !productionVisible
                                       ? Qt.point(contentContainer.width - (chartSize/2 + Style.margins), contentContainer.height - (chartSize/2 + Style.margins))
                                       : Qt.point(contentContainer.width / 2, contentContainer.height - (chartSize/2 + Style.margins))
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
                            Math.abs(energyManager.currentPowerStorage)
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

                if (energyManager.currentPowerAcquisition > 0) {
                    size = Math.abs(energyManager.currentPowerAcquisition) / biggest
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
                    text: energyManager.currentPowerConsumption < 0 ? "?" : d.formatValue(energyManager.currentPowerConsumption)
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
                        color: Style.powerAcquisitionColor
                        borderColor: color
                        borderWidth: 0
                        value: root.fromGrid
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
    }
}
