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

import "qrc:/ui/components"

SettingsPageBase {
    id: root
    title: qsTr("Energy settings")

    property EnergyManager energyManager: null

    property ThingsProxy allConsumers: ThingsProxy {
        engine: _engine
        shownInterfaces: ["smartmeterconsumer", "energymeter"]
        hiddenThingIds: [energyManager.rootMeterId]
    }


    SettingsPageSectionHeader {
        text: qsTr("General")
        visible: rootMeterProxy.count > 1
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        wrapMode: Text.WordWrap
        text: qsTr("Multiple energy meters are installed in the system. Please select the one you'd like to use as the root meter. That is, the one measuring the entire household.")
        visible: rootMeterProxy.count > 1
    }

    RowLayout {
        Layout.fillWidth: true
        visible: rootMeterProxy.count > 1
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins

        Label {
            text: qsTr("Root meter")
        }
        ComboBox {
            Layout.fillWidth: true
            model: ThingsProxy {
                id: rootMeterProxy
                engine: _engine
                shownInterfaces: ["energymeter"]
            }

            textRole: "name"
            currentIndex: rootMeterProxy.indexOf(rootMeterProxy.getThing(energyManager.rootMeterId))
            onActivated: (index) => {
                energyManager.setRootMeterId(rootMeterProxy.get(index).id)
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Consumers")
        visible: root.allConsumers.count > 0
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        wrapMode: Text.WordWrap
        text: qsTr("Uncheck individual consumers to hide them from the energy charts.")
        visible: root.allConsumers.count > 0
    }

    Repeater {
        model: root.allConsumers
        delegate: CheckDelegate {
            Layout.fillWidth: true
            text: model.name
            checked: !tagWatcher.tag
            onToggled: {
                if (checked) {
                    engine.tagsManager.untagThing(model.id, "hiddenInEnergyView")
                } else {
                    engine.tagsManager.tagThing(model.id, "hiddenInEnergyView", "1")
                }
            }

            TagWatcher {
                id: tagWatcher
                tags: engine.tagsManager.tags
                thingId: model.id
                tagId: "hiddenInEnergyView"
            }
        }
    }
}
