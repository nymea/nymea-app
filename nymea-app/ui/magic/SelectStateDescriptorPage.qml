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
import Nymea

import "../components"

Page {
    id: root
    property alias text: header.text

    // a ruleAction object needs to be set and prefilled with either thingId or interfaceName
    property var stateDescriptor: null

    readonly property Thing thing: stateDescriptor && stateDescriptor.thingId ? engine.thingManager.things.getThing(stateDescriptor.thingId) : null

    signal backPressed();
    signal done();

    onStateDescriptorChanged: buildInterface()
    Component.onCompleted: buildInterface()

    header: NymeaHeader {
        id: header
        onBackPressed: root.backPressed();

        property bool interfacesMode: root.stateDescriptor && root.stateDescriptor.interfaceName && root.stateDescriptor.interfaceName.length > 0
        onInterfacesModeChanged: root.buildInterface()

        HeaderButton {
            imageSource: header.interfacesMode ? "qrc:/icons/view-expand.svg" : "qrc:/icons/view-collapse.svg"
            visible: root.stateDescriptor && root.stateDescriptor.interfaceName.length === 0
            onClicked: header.interfacesMode = !header.interfacesMode
        }
    }

    ListModel {
        id: generatedModel
        ListElement { displayName: ""; stateTypeId: "" }
    }

    function buildInterface() {
        print("building interface:", header.interfacesMode, root.stateDescriptor, root.stateDescriptor.interfaceName)
        if (header.interfacesMode) {
            if (root.thing) {
                generatedModel.clear();
                for (var i = 0; i < Interfaces.count; i++) {
                    var iface = Interfaces.get(i);
                    if (root.thing.thingClass.interfaces.indexOf(iface.name) >= 0) {
                        print("root has thing class:", iface.name, iface.stateTypes.count)
                        for (var j = 0; j < iface.stateTypes.count; j++) {
                            var ifaceSt = iface.stateTypes.get(j);
                            print("ifaceSt:", ifaceSt, j, iface.stateTypes.count)
                            var dcSt = root.thing.thingClass.stateTypes.findByName(ifaceSt.name)
                            print("adding:", ifaceSt.displayName, dcSt.id)
                            generatedModel.append({displayName: ifaceSt.displayName, stateTypeId: dcSt.id})
                        }
                    }
                }
                listView.model = generatedModel
            } else if (root.stateDescriptor.interfaceName !== "") {
                listView.model = Interfaces.findByName(root.stateDescriptor.interfaceName).stateTypes
            } else {
                console.warn("You need to set thing or interfaceName");
            }
        } else {
            if (root.thing) {
                listView.model = root.thing.thingClass.stateTypes;
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent

        delegate: ItemDelegate {
            text: model.displayName
            width: parent.width
            onClicked: {
                if (header.interfacesMode) {
                    if (root.thing) {
                        print("selected:", model.stateTypeId)
                        root.stateDescriptor.stateTypeId = model.stateTypeId;
                        var stateType = root.thing.thingClass.stateTypes.getStateType(model.stateTypeId)
                        var paramsPage = pageStack.push(Qt.resolvedUrl("SelectStateDescriptorParamsPage.qml"), {stateDescriptor: root.stateDescriptor})
                        paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                        paramsPage.onCompleted.connect(function() {
                            pageStack.pop();
                            root.done();
                        })
                    } else if (root.stateDescriptor.interfaceName !== "") {
                        root.stateDescriptor.interfaceState = model.name;
                        var paramsPage = pageStack.push(Qt.resolvedUrl("SelectStateDescriptorParamsPage.qml"), {stateDescriptor: root.stateDescriptor})
                        paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                        paramsPage.onCompleted.connect(function() {
                            pageStack.pop();
                            root.done();
                        })
                    } else {
                        console.warn("Neither thingId not interfaceName set. Cannot continue...");
                    }
                } else {
                    if (root.thing) {
                        var stateType = root.thing.thingClass.stateTypes.getStateType(model.id);
                        root.stateDescriptor.stateTypeId = model.id;
                        var paramsPage = pageStack.push(Qt.resolvedUrl("SelectStateDescriptorParamsPage.qml"), {stateDescriptor: root.stateDescriptor})
                        paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                        paramsPage.onCompleted.connect(function() {
                            pageStack.pop();
                            root.done();
                        })

                        print("have type", stateType.id)
                    } else {
                        console.warn("FIXME: not implemented yet");
                    }
                }
            }
        }
    }
}
