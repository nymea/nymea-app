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

import "../components"
import "../delegates"

Page {
    id: root

    property bool selectInterface: false
    property alias showEvents: interfacesProxy.showEvents
    property alias showActions: interfacesProxy.showActions
    property alias showStates: interfacesProxy.showStates
    property alias shownInterfaces: thingsProxy.shownInterfaces
    property bool allowSelectAny: false
    property bool multipleSelection: false
    property alias requiredEventName: thingsProxy.requiredEventName
    property alias requiredStateName: thingsProxy.requiredStateName
    property alias requiredActionName: thingsProxy.requiredActionName

    signal backPressed();
    signal thingSelected(var thing);
    signal thingsSelected(var thing);
    signal interfaceSelected(string interfaceName);
    signal anySelected();

    header: NymeaHeader {
        text: root.selectInterface ?
                  qsTr("Select kind of things") :
                  root.shownInterfaces.length > 0 ? qsTr("Select %1").arg(app.interfaceToDisplayName(root.shownInterfaces[0])) : qsTr("Select thing")
        onBackPressed: root.backPressed()

        HeaderButton {
            imageSource: "qrc:/icons/find.svg"
            color: filterInput.shown ? Style.accentColor : Style.iconColor
            onClicked: filterInput.shown = !filterInput.shown
        }
    }

    InterfacesProxy {
        id: interfacesProxy
        thingsFilter: engine.thingManager.things
    }

    ThingsProxy {
        id: thingsProxy
        engine: _engine
        groupByInterface: true
        nameFilter: filterInput.shown ? filterInput.text : ""
        Component.onCompleted: {
            print("showing things for interfaces", thingsProxy.shownInterfaces)
        }
    }

    ColumnLayout {
        anchors.fill: parent

        ListFilterInput {
            id: filterInput
            Layout.fillWidth: true
        }

        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: qsTr("Any %1").arg(app.interfaceToDisplayName(root.shownInterfaces[0]))
            visible: root.allowSelectAny
            onClicked: {
                root.anySelected();
            }
        }
        ThinDivider { visible: root.allowSelectAny }

        GroupedListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.selectInterface ? interfacesProxy : thingsProxy
            clip: true
            property var checkBoxCache: ({})
            function toggleCheckBoxCache(thingId) {
                var newCache = listView.checkBoxCache;
                if (!newCache.hasOwnProperty(thingId) || !newCache[thingId]) {
                    newCache[thingId] = true
                } else {
                    newCache[thingId] = false
                }
                listView.checkBoxCache = newCache;
                print("new checked state;", newCache[thingId])
            }

            delegate: NymeaItemDelegate {
                width: parent.width
                text: root.selectInterface ? model.displayName : model.name
                iconName: root.selectInterface ? app.interfaceToIcon(model.name) : app.interfacesToIcon(model.interfaces)
                onClicked: {
                    if (root.selectInterface) {
                        root.interfaceSelected(interfacesProxy.get(index).name)
                    } else if (!root.multipleSelection) {
                        root.thingSelected(thingsProxy.get(index))
                    } else {
                        listView.toggleCheckBoxCache(model.id)
                    }
                }
                progressive: !root.multipleSelection

                additionalItem: root.multipleSelection ? entryCheckBox : null
                CheckBox {
                    id: entryCheckBox
                    height: parent.height
                    visible: root.multipleSelection
                    checked: listView.checkBoxCache.hasOwnProperty(model.id) && listView.checkBoxCache[model.id]
                    onClicked: listView.toggleCheckBoxCache(model.id)
                }
            }
        }

        Button {
            Layout.fillWidth: true
            Layout.margins: app.margins
            text: qsTr("OK")
            visible: root.multipleSelection
            onClicked: {
                var things = []
                for (var i = 0; i < thingsProxy.count; i++) {
                    var thing = thingsProxy.get(i);
                    if (listView.checkBoxCache.hasOwnProperty(thing.id) && listView.checkBoxCache[thing.id]) {
                        things.push(thing)
                    }
                }
                root.thingsSelected(things)
            }
        }
    }
}
