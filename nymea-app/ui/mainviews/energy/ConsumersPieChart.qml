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

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
import QtCharts 2.2
import Nymea 1.0
import NymeaApp.Utils 1.0
import "qrc:/ui/components"

Item {
    id: root

    property EnergyManager energyManager: null
    property ThingsProxy consumers: null
    property bool animationsEnabled: true
    property bool titleVisible: true

    readonly property Thing rootMeter: engine.thingManager.fetchingData ? null : engine.thingManager.things.getThing(energyManager.rootMeterId)
    onRootMeterChanged: updateConsumers()

    Connections {
        target: engine.thingManager
        onFetchingDataChanged: {
            if (!engine.thingManager.fetchingData) {
                updateConsumers()
            }
        }
    }

    Connections {
        target: root.consumers
        onCountChanged: {
            if (!engine.thingManager.fetchingData) {
                updateConsumers()
            }
        }
    }

    Connections {
        target: energyManager
        onPowerBalanceChanged: {
            var consumersSummation = 0
            for (var i = 0; i < consumers.count; i++) {
                consumersSummation += consumers.get(i).stateByName("currentPower").value
            }
            d.consumersSummation = consumersSummation;
            if (d.unknownSlice) {
                d.unknownSlice.value = Math.max(0, energyManager.currentPowerConsumption - consumersSummation)
            }
        }
    }

    Component.onCompleted: updateConsumers()

    QtObject {
        id: d
        property var thingsColorMap: ({})
        property PieSlice unknownSlice: null
        property PieSlice idleSlice: null

        property double consumersSummation: 0
    }

    function updateConsumers() {
        chart.animationOptions = ChartView.NoAnimation
        consumersBalanceSeries.clear();
        d.unknownSlice = null
        d.idleSlice = null
        print("cleared consumers pie chart")

        if (engine.thingManager.fetchingData) {
            return;
        }


        var colorMap = {}
        var consumersSummation = 0;
        for (var i = 0; i < consumers.count; i++) {
            var consumer = consumers.get(i)
            let currentPowerState = consumer.stateByName("currentPower")
            let slice = consumersBalanceSeries.append(consumer.name, currentPowerState.value)
            slice.color = NymeaUtils.generateColor(Style.generationBaseColor, i)
            slice.borderWidth = 0
            slice.borderColor = slice.color
            colorMap[consumer] = slice.color
            currentPowerState.valueChanged.connect(function() {
                slice.value = currentPowerState.value
            })
            consumersSummation += currentPowerState.value
        }
        d.consumersSummation = consumersSummation

        if (root.rootMeter) {
            var unknownConsumption = Math.max(0, energyManager.currentPowerConsumption - consumersSummation)
            d.unknownSlice = consumersBalanceSeries.append(qsTr("Unknown"), unknownConsumption)
            d.unknownSlice.color = Style.gray
            d.unknownSlice.borderColor = Style.gray
            d.unknownSlice.borderWidth = 0
        } else {
            d.idleSlice = consumersBalanceSeries.append(qsTr(""), 0.00001)
            d.idleSlice.color = Style.tooltipBackgroundColor
            d.idleSlice.borderColor = d.idleSlice.color
            d.idleSlice.borderWidth = 0
        }

        d.thingsColorMap = colorMap

        chart.animationOptions = Qt.binding(function() {
            return root.animationsEnabled ? NymeaUtils.chartsAnimationOptions : ChartView.NoAnimation
        })
    }

    Label {
        id: titleLabel
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: Style.smallMargins }
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("Consumers balance")
        visible: root.titleVisible
        MouseArea {
            anchors.fill: parent
            onClicked: {
                pageStack.push(Qt.resolvedUrl("ConsumersPieChartPage.qml"), {energyManager: root.energyManager, consumers: root.consumers})
            }
        }
    }


    ChartView {
        id: chart

        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; top: titleLabel.bottom}

        backgroundColor: "transparent"
        animationOptions: animationsEnabled ? NymeaUtils.chartsAnimationOptions : ChartView.NoAnimation
        titleColor: Style.foregroundColor
        legend.visible: false

        margins.left: 0
        margins.right: 0
        margins.bottom: 0
        margins.top: 0


        PieSeries {
            id: consumersBalanceSeries
            size: 0.88
            holeSize: 0.7
        }

        Flickable {
            id: centerLayout
            x: chart.plotArea.x + (chart.plotArea.width - width) / 2
            y: chart.plotArea.y + (chart.plotArea.height - height) / 2
            width: Math.min(chart.plotArea.width, chart.plotArea.width) *  0.65
            height: Math.min(contentColumn.height + topMargin + bottomMargin, width)
            topMargin: Style.smallIconSize
            bottomMargin: Style.smallIconSize
            opacity: 0
    //        property int maximumHeight: chart.plotArea.height * 0.65

            contentHeight: contentColumn.implicitHeight

            ColumnLayout {
                id: contentColumn
                width: parent.width
                spacing: Style.smallMargins

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    visible: root.rootMeter
                    Label {
                        text: qsTr("Total")
                        font: Style.smallFont
                        Layout.topMargin: Style.smallMargins
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Label {
                        // We're using the maximum value of the energy managers consumption, the sum of all consumers because:
                        // * in a standard setup, the energy manager would know everything and the consumption will always be greater than the sum of all individual consumers
                        // * if there is a producer which is unknown to nymea though, it will decrease the consumption on the root meter so it may be smaller than the
                        //   summation of all consumers. In this particular chart that would be nonsense so in the end we'll only lose the "unknown" power consumption in such a setup
                        property double finalTotal: Math.max(energyManager.currentPowerConsumption, d.consumersSummation)
                        text: "%1 %2"
                        .arg((finalTotal / (finalTotal > 1000 ? 1000 : 1)).toFixed(1))
                        .arg(finalTotal > 1000 ? "kW" : "W")
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        font: Style.bigFont
                    }
                }

                Repeater {
                    model: ThingsProxy {
                        id: sortedConsumers
                        engine: _engine
                        parentProxy: root.consumers
                        sortStateName: "currentPower"
                        sortOrder: Qt.DescendingOrder
                    }

                    delegate: ColumnLayout {
                        id: consumerDelegate
                        width: parent ? parent.width : 0
                        spacing: 0
                        property Thing consumer: consumers.getThing(model.id)
                        property State currentPowerState: consumer ? consumer.stateByName("currentPower") : null
                        property double value: currentPowerState ? currentPowerState.value : 0

                        Label {
                            text: model.name
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            font: Style.extraSmallFont
                        }
                        Label {
                            color: d.thingsColorMap.hasOwnProperty(consumer) ? d.thingsColorMap[consumer] : "transparent"
                            text: "%1 %2"
                            .arg((consumerDelegate.value / (consumerDelegate.value > 1000 ? 1000 : 1)).toFixed(1))
                            .arg(consumerDelegate.value > 1000 ? "kW" : "W")
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            font: Style.smallFont
                        }
                    }
                }
            }

        }

        Rectangle {
            id: innerMask
            anchors.fill: centerLayout
            radius: width / 2
            visible: false
            gradient: Gradient {
                GradientStop { position: 0; color: "transparent" }
                GradientStop { position: 1-(centerLayout.height - downArrow.height * 1.5) / centerLayout.height; color: "red" }
                GradientStop { position: (centerLayout.height - downArrow.height * 1.5) / centerLayout.height; color: "red" }
                GradientStop { position: 1; color: "transparent" }
            }
        }

        OpacityMask {
            anchors.fill: centerLayout
            source: centerLayout
            maskSource: innerMask
        }

        ColorIcon {
            id: upArrow
            anchors { top: centerLayout.top; horizontalCenter: centerLayout.horizontalCenter }
            size: Style.smallIconSize
            name: "up"
            visible: !centerLayout.atYBeginning
        }
        ColorIcon {
            id: downArrow
            anchors { bottom: centerLayout.bottom; horizontalCenter: centerLayout.horizontalCenter }
            size: Style.smallIconSize
            name: "down"
            visible: !centerLayout.atYEnd
        }
    }
}

