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

import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import "qrc:/ui/components"
import "qrc:/ui/customviews"
import Nymea 1.0
import Nymea.AirConditioning 1.0

WizardPageBase {
    id: root
    property AirConditioningManager acManager: null
    title: qsTr("New zone")

    showBackButton: true
    showExtraButton: false


    QtObject {
        id: d
        property var thermostats: []
        property var windowSensors: []
        property var indoorSensors: []
        property var outdoorSensors: []
    }

    onBack: pageStack.pop();

    onNext: {
        acManager.addZone(nameTextField.text, d.thermostats, d.windowSensors, d.indoorSensors, d.outdoorSensors)
        pageStack.pop();
    }

    ThingsProxy {
        id: thermostatsProxy
        engine: _engine
        shownInterfaces: ["thermostat"]
    }
    ThingsProxy {
        id: windowSensorsProxy
        engine: _engine
        shownInterfaces: ["closablesensors"]
    }

    ThingsProxy {
        id: sensorsProxy
        engine: _engine
        shownInterfaces: ["temperaturesensor", "humiditysensor", "vocsensor", "pm25sensor"]
        hiddenInterfaces: ["thermostat"]
    }

    content: Item {
        Layout.fillWidth: true
        Layout.preferredHeight: root.visibleContentHeight

        Flickable {
            id: flickable
            anchors.fill: parent
            contentHeight: contentColumn.height


            ColumnLayout {
                id: contentColumn
                width: flickable.width

                SettingsPageSectionHeader {
                    text: qsTr("Zone name")
                }

                NymeaTextField {
                    id: nameTextField
                    Layout.fillWidth: true
                    Layout.leftMargin: Style.margins
                    Layout.rightMargin: Style.margins
                }


                Label {
                    Layout.fillWidth: true
                    Layout.margins: Style.margins
                    text: qsTr("Select the thermostats that should be part of this zone.")
                    wrapMode: Text.WordWrap
                }

                Repeater {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    model: thermostatsProxy

                    delegate: CheckDelegate {
                        Layout.fillWidth: true
                        text: model.name
                        checked: d.thermostats.indexOf(model.id) >= 0
                        onClicked: {
                            var tmp = d.thermostats
                            if (checked) {
                                tmp.push(model.id)
                            } else {
                                var idx = tmp.indexOf(model.id);
                                tmp.splice(idx, 1)
                            }
                            d.thermostats = tmp;
                        }
                    }
                }

                Label {
                    Layout.fillWidth: true
                    Layout.margins: Style.margins
                    text: qsTr("Select the sensors that should be part of this zone.")
                    wrapMode: Text.WordWrap
                }

                Repeater {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    model: sensorsProxy

                    delegate: CheckDelegate {
                        Layout.fillWidth: true
                        text: model.name
                        checked: d.things.indexOf(model.id) >= 0
                        onClicked: {
                            var tmp = d.sensors
                            if (checked) {
                                tmp.push(model.id)
                            } else {
                                var idx = tmp.indexOf(model.id);
                                tmp.splice(idx, 1)
                            }
                            d.sensors = tmp;
                        }
                    }
                }
            }
        }

    }

}
