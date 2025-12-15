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
import Nymea.AirConditioning

import "qrc:/ui/components"
import "qrc:/ui/delegates"

Flickable {
    id: root
    contentHeight: contentGrid.implicitHeight

    property AirConditioningManager acManager: null

    GridLayout {
        id: contentGrid
        width: parent.width - app.margins
        anchors.horizontalCenter: parent.horizontalCenter
        columns: Math.ceil(width / 600)
        rowSpacing: 0
        columnSpacing: 0

        Repeater {
            model: !engine.thingManager.fetchingData ? acManager.zoneInfos : null


            delegate: BigTile {
                id: zoneDelegate
                Layout.preferredWidth: contentGrid.width / contentGrid.columns

                readonly property ZoneInfo zone: acManager.zoneInfos.getZoneInfo(model.id)
                ZoneInfoWrapper {
                    id: zoneWrapper
                    zone: zoneDelegate.zone
                }

                header: RowLayout {
                    id: headerRow
                    width: parent.width
                    Layout.margins: Style.margins / 2
                    Label {
                        Layout.fillWidth: true
                        text: zoneDelegate.zone.name
                        elide: Text.ElideRight
                    }
//                    ThingStatusIcons {
//                        thing: zoneDelegate.thermostat
//                    }
                }

                contentItem: RowLayout {
                    spacing: Style.margins

                    ColumnLayout {

                        RowLayout {
                            ColorIcon {
                                name: app.interfaceToIcon("thermostat")
                                size: Style.smallIconSize
                                color: app.interfaceToColor("thermostat")
                            }
                            Label {
                                text: Types.toUiValue(zoneDelegate.zone.currentSetpoint, Types.UnitDegreeCelsius).toFixed(1) + Types.toUiUnit(Types.UnitDegreeCelsius)
                                font: Style.bigFont
                            }
                        }

                        RowLayout {
                            ColorIcon {
                                name: app.interfaceToIcon("temperaturesensor")
                                size: Style.smallIconSize
                                color: app.interfaceToColor("temperaturesensor")
                            }
                            Label {
                                text: Types.toUiValue(zoneDelegate.zone.temperature, Types.UnitDegreeCelsius).toFixed(1) + Types.toUiUnit(Types.UnitDegreeCelsius)
                            }
                        }

                    }

                    ZoneStatusIcons {
                        zone: zoneDelegate.zone
                        onClicked: zoneDelegate.clicked()

                    }
                }

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ZonePage.qml"), {zone: acManager.zoneInfos.get(index), acManager: acManager})
                }
            }
        }
    }
}
