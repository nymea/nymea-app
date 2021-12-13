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
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
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
                                    } else {
                                        //: e.g. Charging at 5kW
                                        return qsTr("Charging at %1").arg(dataGrid.cleanVale + " "  + dataGrid.unit)
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
