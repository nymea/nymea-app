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
import QtQuick.Layouts
import QtQuick.Controls
import Nymea
import NymeaApp.Utils
import Nymea.AirConditioning

import "qrc:/ui/components"

Item {
    id: root
    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    property AirConditioningManager acManager: null
    property ZoneInfoWrapper zoneWrapper: null
    readonly property ZoneInfo zone: zoneWrapper ? zoneWrapper.zone : null

    property int iconSize: Style.iconSize

    signal clicked(int flag)

    property var zoneStatusModel: [
        {
            value: ZoneInfo.ZoneStatusFlagSetpointOverrideActive,
            icon: "dial",
            color: Style.iconColor,
            activeColor: Style.accentColor,
            text: qsTr("Automatic mode"),
            activeText: qsTr("Manual mode"),
            visible: zoneWrapper.thermostats.count > 0,
            alertVisible: false,
            onClicked: function() {
                var comp = Qt.createComponent(Qt.resolvedUrl("TimeOverrideDialog.qml"))
                var dialog = comp.createObject(app, {acManager: root.acManager, zone: root.zone})
                dialog.open()
            }
        },
        {
            value: ZoneInfo.ZoneStatusFlagTimeScheduleActive,
            icon: "calendar",
            color: Style.iconColor,
            activeColor: Style.orange,
            text: qsTr("Time schedule not active"),
            activeText: qsTr("Time schedule active"),
            visible: zoneWrapper.thermostats.count > 0,
            alertVisible: false,
            onClicked: function() {
                pageStack.push(Qt.resolvedUrl("TimeSchedulePage.qml"), {acManager: root.acManager, zone: root.zone})
            }
        },
        {
            value: ZoneInfo.ZoneStatusFlagWindowOpen,
            icon: "sensors/window-closed",
            activeIcon: "sensors/window-open",
            color: Style.green,
            activeColor: Style.red,
            text: qsTr("All windows closed"),
            activeText: qsTr("%n window(s) open", "", zoneWrapper.openWindows.count),
            visible: zoneWrapper.windowSensors.count > 0,
            alertVisible: false
        },
        {
            value: ZoneInfo.ZoneStatusFlagNone,
            icon: "sensors/temperature",
            color: Style.iconColor,
            activeColor: Style.accentColor,
            text: Types.toUiValue(zone.temperature.toFixed(1), Types.UnitDegreeCelsius) + Types.toUiUnit(Types.UnitDegreeCelsius),
            visible: zoneWrapper.indoorTempSensors.count > 0 &&  zoneWrapper.thermostats.count == 0,
            alertVisible: false
        },
        {
            value: ZoneInfo.ZoneStatusFlagHighHumidity,
            icon: "sensors/humidity",
            color: app.interfaceToColor("humiditysensor"),
            activeColor: app.interfaceToColor("humiditysensor"),
            text: qsTr("%1% humidity").arg(zone.humidity.toFixed(0)),
            activeText:qsTr("%1% humidity").arg(zone.humidity.toFixed(0)),
            visible: zoneWrapper.indoorHumiditySensors.count > 0,
            alertVisible: (root.zone.zoneStatus & ZoneInfo.ZoneStatusFlagHighHumidity) > 0
        },
        {
            value: ZoneInfo.ZoneStatusFlagBadAir,
            icon: "weathericons/weather-clouds",
            color: AirQualityIndex.currentIndex(AirQualityIndex.iaqVoc, zone.voc).color,
            activeColor: AirQualityIndex.currentIndex(AirQualityIndex.iaqVoc, zone.voc).color,
            text: AirQualityIndex.currentIndex(AirQualityIndex.iaqVoc, zone.voc).text,
            activeText: AirQualityIndex.currentIndex(AirQualityIndex.iaqVoc, zone.voc).text,// qsTr("Air quality alert!"),
            visible: zoneWrapper.indoorVocSensors.count > 0 || zoneWrapper.indoorPm25Sensors.count > 0,
            alertVisible: (root.zone.zoneStatus & ZoneInfo.ZoneStatusFlagBadAir) > 0
        }
    ]

    GridLayout {
        id: layout
        flow: GridLayout.TopToBottom
        rows: {
            var ret = 0;
            for (var i = 0; i < zoneStatusModel.length; i++) {
                var entry = zoneStatusModel[i]
                if (entry.visible) {
                    ret++
                }
            }
            return ret;
        }
        anchors.fill: parent
        columnSpacing: Style.smallMargins
        rowSpacing: Style.smallMargins

        Repeater {
            model: zoneStatusModel
            delegate: Item {
                Layout.fillWidth: false
                implicitHeight: root.iconSize
                implicitWidth: root.width / 3
                visible: entry.visible

                property var entry: zoneStatusModel[index]
                property bool active: (root.zone.zoneStatus & entry.value) > 0
                ColorIcon {
                    name: entry.hasOwnProperty("activeIcon") && active ? entry.activeIcon : entry.icon
                    size: root.iconSize
                    color: active ? entry.activeColor : Style.iconColor
                    anchors.right: parent.right
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: entry.onClicked()
                }
            }
        }
        Repeater {
            model: zoneStatusModel

            delegate: RowLayout {
                Layout.fillWidth: true
                implicitHeight: root.iconSize
                implicitWidth: 100
                visible: entry.visible

                property var entry: zoneStatusModel[index]
                property bool active: (root.zone.zoneStatus & entry.value) > 0

                Label {
//                    Layout.alignment: Qt.AlignVCenter
                    text: active ? entry.activeText : entry.text
                    elide: Text.ElideRight
                }
                ColorIcon {
                    size: Style.iconSize
                    name: "attention"
                    color: Style.yellow
                    visible: entry.alertVisible
                }
                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }
}
