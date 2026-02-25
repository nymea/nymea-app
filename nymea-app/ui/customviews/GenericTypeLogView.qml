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

import "../components"

Item {
    id: root

    signal addRuleClicked(int index)

    property var logsModel: null

    property alias delegate: listView.delegate

    ListView {
        id: listView
        anchors.fill: parent
        model: logsModel
        clip: true

        ScrollBar.vertical: ScrollBar {}

        SwipeDelegateGroup {}

        delegate: NymeaSwipeDelegate {
            id: logEntryDelegate
            width: parent.width
            implicitHeight: app.delegateHeight
            property Thing thing: engine.thingManager.things.getThing(model.thingId)
            property ThingClass thingClass: engine.thingManager.thingClasses.getThingClass(thing.thingClassId)
            iconName: "qrc:/icons/event.svg"
            text: Qt.formatDateTime(model.timestamp,"dd.MM.yy - hh:mm:ss")
            subText: thingClass.eventTypes.getEventType(model.typeId).displayName + (model.value.length > 0 ? (": " + model.value.trim()) : "")
            prominentSubText: true
            progressive: false
            contextOptions: [
                {
                    text: qsTr("Magic"),
                    icon: "qrc:/icons/magic.svg",
                    callback: function() { root.addRuleClicked(index) }
                }
            ]
            onClicked: {
                if (swipe.complete) {
                    swipe.close()
                } else {
                    swipe.open(SwipeDelegate.Right)
                }
            }
        }

        BusyIndicator {
            anchors.centerIn: parent
            visible: root.logsModel.busy
            running: visible
        }
    }
}
