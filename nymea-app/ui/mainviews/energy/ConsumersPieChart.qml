import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
import QtCharts 2.2
import Nymea 1.0

ChartView {
    id: root
    backgroundColor: "transparent"
    animationOptions: Qt.application.active ? ChartView.SeriesAnimations : ChartView.NoAnimation
    title: qsTr("Consumers balance")
    titleColor: Style.foregroundColor
    legend.visible: false

    property EnergyManager energyManager: null
    property ThingsProxy consumers: null
    property var colors: null

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
            var consumption = energyManager.currentPowerConsumption
            for (var i = 0; i < consumers.count; i++) {
                consumption -= consumers.get(i).stateByName("currentPower").value
            }
            d.unknownSlice.value = consumption
        }
    }

    Component.onCompleted: updateConsumers()

    QtObject {
        id: d
        property var thingsColorMap: ({})
        property PieSlice unknownSlice: null
    }

    function updateConsumers() {
        consumersBalanceSeries.clear();

        if (engine.thingManager.fetchingData) {
            return;
        }

        var unknownConsumption = energyManager.currentPowerConsumption

        var colorMap = {}
        for (var i = 0; i < consumers.count; i++) {
            var consumer = consumers.get(i)
            colorMap[consumer] = root.colors[i % root.colors.length]
            let currentPowerState = consumer.stateByName("currentPower")
            let slice = consumersBalanceSeries.append(consumer.name, currentPowerState.value)
            slice.color = root.colors[i % root.colors.length]
            currentPowerState.valueChanged.connect(function() {
                slice.value = currentPowerState.value
            })
            unknownConsumption -= currentPowerState.value
        }

        d.unknownSlice = consumersBalanceSeries.append(qsTr("Unknown"), unknownConsumption)
        d.unknownSlice.color = Style.gray

        d.thingsColorMap = colorMap
    }

    PieSeries {
        id: consumersBalanceSeries
        size: 0.9
        holeSize: 0.7
    }


    ColumnLayout {
        id: centerLayout
        x: root.plotArea.x + (root.plotArea.width - width) / 2
        y: root.plotArea.y + (root.plotArea.height - height) / 2
        width: root.plotArea.width * 0.65
//        height: root.plotArea.height * 0.65
        spacing: Style.smallMargins
        property int maximumHeight: root.plotArea.height * 0.65

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Label {
                text: qsTr("Total")
                font: Style.smallFont
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                text: "%1 %2"
                .arg((energyManager.currentPowerConsumption / (energyManager.currentPowerConsumption > 1000 ? 1000 : 1)).toFixed(1))
                .arg(energyManager.currentPowerConsumption > 1000 ? "kW" : "W")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.bigFont
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: count * (Style.smallMargins + Style.extraSmallFont.pixelSize + Style.smallFont.pixelSize)
            Layout.maximumHeight: centerLayout.maximumHeight - y
            clip: true
            spacing: Style.smallMargins

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

                    color: d.thingsColorMap[consumer]
                    text: "%1 %2"
                    .arg((consumerDelegate.value / (consumerDelegate.value > 1000 ? 1000 : 1)).toFixed(1))
                    .arg(consumerDelegate.value > 1000 ? "kWh" : "W")
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    font: Style.smallFont
                }
            }
        }
    }
}
