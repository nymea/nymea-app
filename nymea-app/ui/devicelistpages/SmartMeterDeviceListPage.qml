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
import Nymea

import "../components"

ThingsListPageBase {
    id: root

    header: NymeaHeader {
        text: qsTr("Smart meters")
        onBackPressed: pageStack.pop()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentGrid.implicitHeight
        topMargin: app.margins / 2
        clip: true

        GridLayout {
            id: contentGrid
            width: parent.width - app.margins
            anchors.horizontalCenter: parent.horizontalCenter
            columns: Math.ceil(width / 600)
            rowSpacing: 0
            columnSpacing: 0

            Repeater {
                model: root.thingsProxy

                delegate: BigThingTile {
                    id: itemDelegate
                    Layout.preferredWidth: contentGrid.width / contentGrid.columns
                    thing: root.thingsProxy.getThing(model.id)

                    onClicked: {
                        enterPage(index, ["energystorage", "smartmeter"])
                    }
                    contentItem: RowLayout {
                        id: dataGrid

                        property State currentPowerState: itemDelegate.thing.stateByName("currentPower")
                        property bool isEnergyMeter: itemDelegate.thing.thingClass.interfaces.indexOf("energymeter") >= 0
                        property bool isBattery: itemDelegate.thing.thingClass.interfaces.indexOf("energystorage") >= 0
                        property bool isEvCharger: itemDelegate.thing.thingClass.interfaces.indexOf("evcharger") >= 0
                        property bool isProducer: itemDelegate.thing.thingClass.interfaces.indexOf("smartmeterproducer") >= 0
                        property bool isConsumer: itemDelegate.thing.thingClass.interfaces.indexOf("smartmeterconsumer") >= 0
                        property bool isProduction: currentPowerState.value < 0
                        property bool isConsumption: currentPowerState.value > 0
                        property bool isIdling: currentPowerState.value === 0
                        property double absValue: Math.abs(currentPowerState.value)
                        property double cleanVale: (absValue / (absValue > 1000 ? 1000 : 1)).toFixed(1)
                        property string unit: absValue > 1000 ? "kW" : "W"

                        ColorIcon {
                            name: app.stateIcon("currentPower")
                            color: app.stateColor("currentPower")
                            size: Style.iconSize
                        }

                        Label {
                            Layout.fillWidth: true
                            text: {
                                if (dataGrid.isEnergyMeter) {
                                    if (dataGrid.isProduction) {
                                        //: e.g. Returning 5kW
                                        return qsTr("Returning %1").arg(dataGrid.cleanVale + " " + dataGrid.unit)
                                    } else {
                                        //: e.g. Obtaining 5kW
                                        return qsTr("Obtaining %1").arg(dataGrid.cleanVale + " " + dataGrid.unit)
                                    }

                                } else if (dataGrid.isBattery || dataGrid.isEvCharger) {
                                    if (dataGrid.isProduction) {
                                        //: e.g. Discharging at 5kW
                                        return qsTr("Discharging at %1").arg(dataGrid.cleanVale + " " + dataGrid.unit)
                                    } else if (dataGrid.isConsumption){
                                        //: e.g. Charging at 5kW
                                        return qsTr("Charging at %1").arg(dataGrid.cleanVale + " "  + dataGrid.unit)
                                    } else {
                                        return qsTr("Idling")
                                    }

                                } else if (dataGrid.isProducer && !dataGrid.isConsumer) {
                                    if (dataGrid.isProduction) {
                                        //: e.g. Producing 5kW
                                        return qsTr("Producing %1").arg(dataGrid.cleanVale + " " + dataGrid.unit)
                                    } else {
                                        //: A producer, not producing anything
                                        return qsTr("Idling")
                                    }

                                } else if (dataGrid.isConsumer && !dataGrid.isProducer) {
                                    if (dataGrid.isProduction) {
                                        //: A consumer, not consuming anything
                                        return qsTr("Idling")
                                    } else {
                                        //: e.g. Consuming 5kW
                                        return qsTr("Consuming %1").arg(dataGrid.cleanVale + " " + dataGrid.unit)
                                    }

                                } else {
                                    if (dataGrid.isProduction) {
                                        return qsTr("Producing %1").arg(dataGrid.cleanVale + " " + dataGrid.unit)
                                    } else {
                                        return qsTr("Consuming %1").arg(dataGrid.cleanVale + " " + dataGrid.unit)
                                    }
                                }
                            }
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: app.smallFont
                        }
                    }
                }
            }
        }
    }
}
