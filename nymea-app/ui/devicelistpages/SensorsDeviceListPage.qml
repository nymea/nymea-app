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

import "qrc:/ui/components"
import "qrc:/ui/delegates"

ThingsListPageBase {
    id: root

    header: NymeaHeader {
        text: root.shownInterfaces.indexOf("heating") >= 0
              ? qsTr("Heating")
              : root.shownInterfaces.indexOf("thermostat") >= 0
                ? qsTr("Thermostats")
                : qsTr("Sensors")
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

                delegate: SensorListDelegate {
                    id: itemDelegate
                    Layout.preferredWidth: contentGrid.width / contentGrid.columns
                    thing: root.thingsProxy.getThing(model.id)

                    onClicked: {
                        // we show all "sensors" in shownInterfaces in here so the "sensors" view would be the best match, but for sensors
                        // that should show the input trigger view instead, we need to override that
                        if (thing.thingClass.interfaces.indexOf("vibrationsensor") >= 0) {
                            enterPage(index, "inputtrigger")
                        } else {
                            enterPage(index)
                        }
                    }
                }
            }
        }
    }
}
