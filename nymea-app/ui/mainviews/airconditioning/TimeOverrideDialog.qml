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

NymeaDialog {
    id: root
    standardButtons: Dialog.NoButton

    title: qsTr("Manual mode")
    text: qsTr("Select how long the manual temperature setpoint should be kept.")

    property AirConditioningManager acManager: null
    property ZoneInfo zone: null

    RadioButton {
        id: eventualButton
        Layout.fillWidth: true
        text: qsTr("Eventual")
        checked: root.zone.setpointOverrideMode == ZoneInfo.SetpointOverrideModeEventual
        contentItem: ColumnLayout {
            width: root.width
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: eventualButton.indicator.width + eventualButton.spacing
                text: eventualButton.text
            }
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: eventualButton.indicator.width + eventualButton.spacing
                wrapMode: Text.WordWrap
                text: qsTr("Until the temperature is changed by some other event.")
                font: Style.smallFont
            }
        }
    }

    RadioButton {
        id: foreverButton
        Layout.fillWidth: true
        text: qsTr("Forever")
        checked: root.zone.setpointOverrideMode == ZoneInfo.SetpointOverrideModeUnlimited
        contentItem: ColumnLayout {
            width: root.width
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: foreverButton.indicator.width + foreverButton.spacing
                text: foreverButton.text
            }
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: foreverButton.indicator.width + foreverButton.spacing
                wrapMode: Text.WordWrap
                text: qsTr("Until manually removed or changed.")
                font: Style.smallFont
            }
        }
    }
    RadioButton {
        id: timeButton
        text: qsTr("Time")
        checked: root.zone.setpointOverrideMode == ZoneInfo.SetpointOverrideModeTimed
        contentItem: ColumnLayout {
            width: root.width
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: timeButton.indicator.width + timeButton.spacing
                text: timeButton.text
            }
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: timeButton.indicator.width + timeButton.spacing
                wrapMode: Text.WordWrap
                text: qsTr("For a specified amount of time.")
                font: Style.smallFont
            }
        }
    }

    RowLayout {
        Layout.leftMargin: timeButton.indicator.width + timeButton.spacing
        enabled: timeButton.checked
        SpinBox {
            from: 30
            to: 30 * 2 * 12
            stepSize: 30
            value: 120
            textFromValue: function(value) {
                return Math.floor(value / 60) + ":" + NymeaUtils.pad(value % 60, 2)
            }
        }
    }


    RowLayout {
        Layout.fillWidth: true
        Button {
            text: qsTr("Remove")
            onClicked: {
                acManager.setZoneSetpointOverride(root.zone.id, root.zone.setpointOverride, ZoneInfo.SetpointOverrideModeNone, 0)
                root.close();
            }
        }
        Item {
            Layout.fillWidth: true
        }

        Button {
            text: qsTr("OK")
            onClicked: {
                var mode = ZoneInfo.SetpointOverrideModeEventual
                if (foreverButton.checked) {
                    mode = ZoneInfo.SetpointOverrideModeUnlimited
                } else if (timeButton.checked) {
                    mode = ZoneInfo.SetpointOverrideModeTimed
                }
                acManager.setZoneSetpointOverride(root.zone.id, root.zone.setpointOverride, mode, 120)

                root.close();
            }
        }
    }

}

