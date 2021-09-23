/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import Nymea 1.0
import "../components"
import "../customviews"

ThingPageBase {
    id: root

    readonly property bool isEnergyMeter: root.thing && root.thing.thingClass.interfaces.indexOf("energymeter") >= 0
    readonly property bool isConsumer: root.thing && root.thing.thingClass.interfaces.indexOf("smartmeterconsumer") >= 0
    readonly property bool isProducer: root.thing && root.thingClass.interfaces.indexOf("smartmeterproducer") >= 0
    readonly property bool isBattery: root.thing && root.thingClass.interfaces.indexOf("energystorage") >= 0


    readonly property State currentPowerState: root.thing.stateByName("currentPower")

    // meters, producers, consumers
    readonly property State totalEnergyConsumedState: isEnergyMeter || isConsumer ? root.thing.stateByName("totalEnergyConsumed") : null
    readonly property StateType totalEnergyConsumedStateType: isEnergyMeter || isConsumer ? root.thing.thingClass.stateTypes.findByName("totalEnergyConsumed") : null
    readonly property State totalEnergyProducedState: isEnergyMeter || isProducer ? root.thing.stateByName("totalEnergyProduced") : null
    readonly property StateType totalEnergyProducedStateType: isEnergyMeter || isProducer ? root.thing.thingClass.stateTypes.findByName("totalEnergyProduced") : null

    // Battery related states
    readonly property State batteryLevelState: isBattery ? root.thing.stateByName("batteryLevel") : null
    readonly property State batteryCriticalState: isBattery ? root.thing.stateByName("batteryCritical") : null
    readonly property State chargingState: isBattery ? root.thing.stateByName("chargingState") : null
    readonly property State capacityState: isBattery ? root.thing.stateByName("capacity") : null



    readonly property real currentPower: currentPowerState ? currentPowerState.value : 0

    readonly property date now: d.now
    readonly property date startTime: new Date(now.getTime() - 24 * 60 * 60 * 1000)

    QtObject {
        id: d
        property date now: new Date()
    }
    Timer {
        interval: 60000
        repeat: true
        running: true
        onTriggered: d.now = new Date()
    }

    GridLayout {
        id: contentGrid
        anchors.fill: parent
        columns: app.landscape ? 2 : 1

        CircleBackground {
            id: background
            Layout.fillWidth: true
            Layout.preferredHeight: width
            Layout.leftMargin: app.landscape ? Style.margins : Style.hugeMargins
            Layout.rightMargin: Style.hugeMargins
            Layout.topMargin: Style.hugeMargins
            Layout.bottomMargin: app.landscape ? Style.hugeMargins : Style.margins
            iconSource: ""
            onColor: batteryLevelState
                     ? currentPower < 0 ? "crimson" : "limegreen"
            : currentPower < 0 ? "limegreen" : "crimson"

            Rectangle {
                id: mask
                anchors.centerIn: parent
                width: background.contentItem.width
                height: background.contentItem.height
                radius: width / 2
                visible: false
            }

            Item {
                id: juice
                anchors.fill: parent

                Rectangle {
                    anchors.centerIn: parent
                    width: background.contentItem.width
                    height: background.contentItem.height
                    property real progress: root.batteryLevelState ? root.batteryLevelState.value  / 100 : 0
                    anchors.verticalCenterOffset: height * (1 - progress)
                    color: batteryCriticalState && batteryCriticalState.value ? "crimson" : "limegreen"
                    visible: root.batteryLevelState
                }

                RadialGradient {
                    id: gradient
                    anchors.centerIn: parent
                    width: background.contentItem.width
                    height: background.contentItem.height
                    property real progress: Math.abs(root.currentPower) / 10000
                    visible: currentPower != 0

                    Behavior on gradientRatio { NumberAnimation { duration: Style.sleepyAnimationDuration; easing.type: Easing.InOutQuad } }
                    property real gradientRatio: (1 - progress) * 0.1
                    gradient: Gradient{
                        GradientStop { position: .399 + gradient.gradientRatio; color: "transparent" }
                        GradientStop { position: .5; color: background.onColor }
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent

                    Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        font: Style.hugeFont
                        property bool toKilos: currentPower >= 1000
                        property double value: Math.abs(currentPower / (toKilos ? 1000 : 1))
                        text: "%1 %2".arg(value.toFixed(toKilos ? 2 : 1)).arg(toKilos ? "kW" : "W")
                    }
                    Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: {
                            if (root.chargingState) {
                                switch (root.chargingState.value) {
                                case "idle":
                                    return qsTr("Idle")
                                case "charging":
                                    return qsTr("Charging")
                                case "discharging":
                                    return qsTr("Discharging")
                                }
                            }
                            if (root.isProducer) {
                                return qsTr("Production")
                            }
                            return root.currentPower < 0 ? qsTr("Return") : qsTr("Consumption")
                        }
                        font: Style.smallFont
                    }

                    Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        font: Style.hugeFont
                        visible: batteryLevelState
                        text: "%1 %".arg(batteryLevelState ? batteryLevelState.value : "")
                    }
                }

            }

            OpacityMask {
                anchors.fill: background
                source: ShaderEffectSource {
                    sourceItem: juice
                    hideSource: true
                }
                maskSource: mask
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: Style.bigMargins

            ColumnLayout {
                id: textLayout
                anchors.fill: parent
                spacing: Style.margins

                Label {
                    Layout.fillWidth: true
                    visible: isBattery
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    textFormat: Text.RichText
                    property bool isCharging: root.chargingState && root.chargingState.value === "charging"
                    property bool isDischarging: root.chargingState && root.chargingState.value === "discharging"
                    property double availableWh: isBattery ? root.capacityState.value * 1000 * root.batteryLevelState.value / 100 : 0
                    property double remainingWh: isCharging ? root.capacityState.value - availableWh : availableWh
                    property double remainingHours: isBattery ? remainingWh / Math.abs(root.currentPower) : 0
                    property date endTime: isBattery ? new Date(new Date().getTime() + remainingHours * 60 * 60 * 1000) : new Date()
                    property int n: Math.round(remainingHours)

                    text: isCharging ? qsTr("At the current rate, the battery will be fully charged at %1.").arg('<span style="font-size:' + Style.bigFont.pixelSize + 'px">' + endTime.toLocaleTimeString(Locale.ShortFormat) + "</span>")
                                     : isDischarging ? qsTr("At the current rate, the battery will last until %1.").arg('<span style="font-size:' + Style.bigFont.pixelSize + 'px">' + endTime.toLocaleTimeString(Locale.ShortFormat) + "</span>")
                                                     : qsTr("The battery is fully charged")
                }

                BlurredLabel {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    visible: isEnergyMeter || isConsumer
                    blurred: periodConsumptionModel.busy
                    text: isConsumer ?
                              qsTr("A total of %1 kWh has been <b>consumed</b> in the last 24 hours.").arg('<span style="font-size:' + Style.bigFont.pixelSize + 'px">' + (totalPeriodConsumption).toFixed(1) + '</span>')
                            : qsTr("A total of %1 kWh has been <b>obtained</b> in the last 24 hours.").arg('<span style="font-size:' + Style.bigFont.pixelSize + 'px">' + (totalPeriodConsumption).toFixed(1) + '</span>')
                    textFormat: Text.RichText

                    LogsModel {
                        id: periodConsumptionModel
                        objectName: "Root meter model"
                        engine: root.isEnergyMeter ? _engine : null
                        thingId: root.thing.id
                        typeIds: isEnergyMeter ? [root.totalEnergyConsumedStateType.id] : []
                        viewStartTime: root.startTime
                        live: true
                    }
                    property LogEntry logEntryAtStart: periodConsumptionModel.busy ? null : periodConsumptionModel.findClosest(periodConsumptionModel.viewStartTime)
                    property double totalPeriodConsumption: logEntryAtStart && totalEnergyConsumedState ? totalEnergyConsumedState.value - logEntryAtStart.value : 0
                }

                BlurredLabel {
                    visible: isEnergyMeter || isProducer
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    blurred: periodProductionModel.busy
                    text: isProducer ?
                              qsTr("A total of %1 kWh has been <b>produced</b> in the last 24 hours.").arg('<span style="font-size:' + Style.bigFont.pixelSize + 'px">' + (totalPeriodProduction).toFixed(1) + '</span>')
                            : qsTr("A total of %1 kWh has been <b>returned</b> in the last 24 hours.").arg('<span style="font-size:' + Style.bigFont.pixelSize + 'px">' + (totalPeriodProduction).toFixed(1) + '</span>')
                    textFormat: Text.RichText

                    LogsModel {
                        id: periodProductionModel
                        engine: root.isEnergyMeter ? _engine : null
                        thingId: root.thing.id
                        typeIds: isEnergyMeter ? [root.totalEnergyProducedStateType.id] : []
                        viewStartTime: root.startTime
                        live: true
                    }
                    property LogEntry logEntryAtStart: periodProductionModel.busy ? null : periodProductionModel.findClosest(periodProductionModel.viewStartTime)
                    property double totalPeriodProduction: logEntryAtStart && totalEnergyProducedState ? totalEnergyProducedState.value - logEntryAtStart.value : 0
                }
            }
        }
    }
}

