/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2022, nymea GmbH
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
