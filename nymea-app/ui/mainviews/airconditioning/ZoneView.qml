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
import QtQuick.Layouts
import Nymea
import NymeaApp.Utils
import Nymea.AirConditioning

import "qrc:/ui/components"
import "qrc:/ui/customviews"
import "qrc:/ui/delegates"

Item {
    id: root
    property AirConditioningManager acManager: null
    property ZoneInfoWrapper zoneWrapper: null
    readonly property ZoneInfo zone: zoneWrapper.zone

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: contentLayout.childrenRect.height + Style.margins
        clip: true

        GridLayout {
            id: contentLayout
            width: parent.width
            columns: app.landscape ? 2 : 1

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: flickable.height / 2
                implicitWidth: thermostat.implicitWidth
                visible: zoneWrapper.thermostats.count > 0

                CircleBackground {
                    id: thermostat
                    anchors { fill: parent; leftMargin: Style.hugeMargins; rightMargin: Style.hugeMargins; topMargin: Style.margins; bottomMargin: Style.margins }

                    Dial {
                        id: thermostatDial
                        anchors.fill: parent
                        minValue: 10
                        maxValue: 30
                        precision: 0.5
                        value:  root.zone.currentSetpoint
                        color: pendingValue < activeValue ? Style.blue : Style.red
                        activeValue: zone.temperature

                        onMoved: {
                            acManager.setZoneSetpointOverride(root.zone.id, value, ZoneInfo.SetpointOverrideModeEventual, 0)
                        }
                        onClicked: {
                            var comp = Qt.createComponent(Qt.resolvedUrl("TimeOverrideDialog.qml"))
                            var dialog = comp.createObject(root, {acManager: root.acManager, zone: root.zone})
                            dialog.open()
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -Style.smallMargins
                        width: parent.contentItem.width * 0.6

                        Label {
                            Layout.fillWidth: true
                            text: Types.toUiUnit(Types.UnitDegreeCelsius)
                            font.pixelSize: Math.min(Style.smallFont.pixelSize, thermostat.contentItem.height / 16)
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Label {
                            Layout.fillWidth: true
                            text: Types.toUiValue(zone.currentSetpoint, Types.UnitDegreeCelsius).toFixed(1)
                            font.pixelSize: Math.min(Style.hugeFont.pixelSize, thermostat.contentItem.height / 8)
                            horizontalAlignment: Text.AlignHCenter
                            color:  zone.currentSetpoint > zone.temperature
                                     ? Style.red
                                     : zone.currentSetpoint < zone.temperature
                                       ? Style.blue
                                       : Style.foregroundColor
                        }
                        Label {
                            Layout.fillWidth: true
                            text: Types.toUiValue(zone.temperature, Types.UnitDegreeCelsius).toFixed(1)
                            font.pixelSize: Math.min(Style.largeFont.pixelSize, thermostat.contentItem.height / 12)
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                        ColorIcon {
                            Layout.alignment: Qt.AlignHCenter
                            size: Style.smallIconSize
                            name: {
                                switch (root.zone.setpointOverrideMode) {
                                case ZoneInfo.SetpointOverrideModeUnlimited:
                                    return "infinity"
                                case ZoneInfo.SetpointOverrideModeTimed:
                                    return "alarm-clock"
                                case ZoneInfo.SetpointOverrideModeEventual:
                                    return "event"
                                }
                                return ""
                            }
                        }
                    }

                    ColorIcon {
                        anchors.horizontalCenter: thermostatDial.horizontalCenter
                        y: parent.contentItem.y + parent.contentItem.height - height - Style.smallMargins
                        size: Math.min(Style.bigIconSize, thermostatDial.height / 5)
                        name: zoneWrapper.heatingThermostats.count > 0
                              ? "qrc:/icons/thermostat/heating.svg"
                              : zoneWrapper.coolingThermostats.count > 0
                                ? "qrc:/icons/thermostat/cooling.svg"
                                : ""
                        color: zoneWrapper.heatingThermostats.count > 0
                              ? app.interfaceToColor("heating")
                              : zoneWrapper.coolingThermostats.count > 0
                                ? app.interfaceToColor("cooling")
                                : Style.iconColor
                    }
                }
            }


            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: zoneWrapper.thermostats.count > 0 ? flickable.height / 2 : flickable.height
                implicitWidth: 800
                implicitHeight: statusIcons.implicitHeight
                Layout.minimumHeight: statusIcons.implicitHeight

                BigZoneStatusIcons {
                    id: statusIcons
                    acManager: root.acManager
                    zoneWrapper: root.zoneWrapper
                    iconSize: Style.bigIconSize
                    width: parent.width - Style.margins * 2
                    anchors.centerIn: parent
                }

                ColorIcon {
                    anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: Style.margins }
                    name: "down"
                    opacity: zoneWrapper.indoorSensors.count > 0 && flickable.contentY - flickable.originY <= 0 && !app.landscape ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: Style.animationDuration } }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: Math.ceil(width / 600)
                Layout.columnSpan: contentLayout.columns
                rowSpacing: 0
                columnSpacing: 0

                Repeater {
                    model: zoneWrapper.thermostats
                    delegate: SensorListDelegate {
                        Layout.fillWidth: true
                        thing: zoneWrapper.thermostats.get(index)
                        onClicked: {
                            var page = NymeaUtils.interfaceListToDevicePage(thing.thingClass.interfaces);
                            pageStack.push(Qt.resolvedUrl("/ui/devicepages/" + page), {thing: thing})
                        }
                    }
                }
                Repeater {
                    model: zoneWrapper.indoorSensors
                    delegate: SensorListDelegate {
                        Layout.fillWidth: true
                        thing: zoneWrapper.indoorSensors.get(index)
                        onClicked: {
                            var page = NymeaUtils.interfaceListToDevicePage(thing.thingClass.interfaces);
                            pageStack.push(Qt.resolvedUrl("/ui/devicepages/" + page), {thing: thing})
                        }
                    }
                }
                Repeater {
                    model: zoneWrapper.windowSensors
                    delegate: SensorListDelegate {
                        Layout.fillWidth: true
                        thing: zoneWrapper.windowSensors.get(index)
                        onClicked: {
                            var page = NymeaUtils.interfaceListToDevicePage(thing.thingClass.interfaces);
                            pageStack.push(Qt.resolvedUrl("/ui/devicepages/" + page), {thing: thing})
                        }
                    }
                }
            }
        }
    }

    EmptyViewPlaceholder {
        visible: zoneWrapper.thermostats.count == 0 && zoneWrapper.windowSensors.count == 0 && zoneWrapper.indoorSensors.count == 0
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        title: qsTr("No things in this zone.")
        text: qsTr("In order for this zone zo be useful, assign some things to it.")
        imageSource: "qrc:/icons/sensors.svg"
        buttonText: qsTr("Add things")
        onButtonClicked: {
            pageStack.push(Qt.resolvedUrl("EditZoneThingsPage.qml"), {acManager: acManager, zone: zone})
        }
    }

}
