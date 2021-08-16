import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtCharts 2.2
import Nymea 1.0
import NymeaApp.Utils 1.0

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

    ThingsProxy {
        id: batteries
        engine: _engine
        shownInterfaces: ["energystorage"]
    }
    PieSeries {
        id: productionBalanceSeries
        size: 0.88
        holeSize: 0.7

        property double toGrid: Math.abs(Math.min(0, energyManager.currentPowerAcquisition))
        property double toStorage: Math.max(0, energyManager.currentPowerStorage)
        property double toConsumers: -energyManager.currentPowerProduction - toGrid - toStorage

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
            color: Style.tooltipBackgroundColor
            borderColor: color
            borderWidth: 0
            value: productionBalanceSeries.toConsumers == 0 && productionBalanceSeries.toGrid == 0 && productionBalanceSeries.toStorage == 0 ? 1 : 0
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
    }
}
