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

import QtQuick 2.4
import QtQuick.Controls 2.1
import "../components"
import Nymea 1.0

Page {
    id: root
    property alias text: header.text

    // a ruleAction object needs to be set and prefilled with either thingId or interfaceName
    property RuleAction ruleAction: null

    // optionally, a rule which will be used when determining params for the actions
    property Rule rule: null

    readonly property Thing thing: ruleAction && ruleAction.thingId ? engine.thingManager.things.getThing(ruleAction.thingId) : null

    signal backPressed();
    signal done();

    onRuleActionChanged: buildInterface()
    Component.onCompleted: buildInterface()

    header: NymeaHeader {
        id: header
        onBackPressed: root.backPressed();

        property bool interfacesMode: root.ruleAction.interfaceName !== ""
        onInterfacesModeChanged: root.buildInterface()

        HeaderButton {
            imageSource: header.interfacesMode ? "qrc:/icons/view-expand.svg" : "qrc:/icons/view-collapse.svg"
            visible: root.ruleAction.interfaceName === ""
            onClicked: header.interfacesMode = !header.interfacesMode
        }
    }

    ListModel {
        id: generatedModel
        dynamicRoles: true
    }

    function buildInterface() {
        print("building iface", root.ruleAction, root.ruleAction.interfaceName, header.interfacesMode, root.ruleAction.interfaceName === "")
        if (header.interfacesMode) {
            if (root.thing) {
                generatedModel.clear();
                for (var i = 0; i < Interfaces.count; i++) {
                    var iface = Interfaces.get(i);
                    if (root.thing.thingClass.interfaces.indexOf(iface.name) >= 0) {
                        for (var j = 0; j < iface.actionTypes.count; j++) {
                            var ifaceAt = iface.actionTypes.get(j);
                            var dcAt = root.thing.thingClass.actionTypes.findByName(ifaceAt.name)
                            generatedModel.append({displayName: ifaceAt.displayName, actionTypeId: dcAt.id})
                        }
                    }
                }
                listView.model = generatedModel
            } else if (root.ruleAction.interfaceName !== "") {
                print("showing actions for interface", root.ruleAction.interfaceName)
                listView.model = Interfaces.findByName(root.ruleAction.interfaceName).actionTypes
            } else {
                console.warn("You need to set thing or interfaceName");
            }
        } else {
            if (root.thing) {
                generatedModel.clear();
                for (var i = 0; i < root.thing.thingClass.actionTypes.count; i++) {
                    var actionType = root.thing.thingClass.actionTypes.get(i);
                    generatedModel.append({displayName: actionType.displayName, actionTypeId: actionType.id})
                }

                // Append an item for browse mode
                if (root.thing.thingClass.browsable) {
                    generatedModel.append({displayName: qsTr("Open an item on this thing..."), actionTypeId: "browse"})
                }

                listView.model = generatedModel;

//                listView.model = root.thing.thingClass.actionTypes
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        ScrollBar.vertical: ScrollBar {}

        delegate: NymeaSwipeDelegate {
            id: delegate
            text: model.displayName
            width: parent.width
            iconName: model.actionTypeId === "browse" ? "qrc:/icons/browser/BrowserIconFolder.svg" : "qrc:/icons/action.svg"
            property ActionType actionType: root.thing.thingClass.actionTypes.getActionType(model.actionTypeId)
            progressive: model.actionTypeId === "browse" || actionType.paramTypes.count > 0

            onClicked: {
                if (header.interfacesMode) {
                    if (root.thing) {
                        root.ruleAction.actionTypeId = model.actionTypeId;
                        root.ruleAction.browserItemId = "";
                        root.ruleAction.interfaceAction = "";
                        var actionType = root.thing.thingClass.actionTypes.getActionType(model.actionTypeId)
                        if (actionType.paramTypes.count > 0) {
                            var paramsPage = pageStack.push(Qt.resolvedUrl("SelectRuleActionParamsPage.qml"), {ruleAction: root.ruleAction, rule: root.rule})
                            paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                            paramsPage.onCompleted.connect(function() {
                                pageStack.pop();
                                root.done();
                            })
                        } else {
                            root.done();
                        }
                    } else if (root.ruleAction.interfaceName !== "") {
                        root.ruleAction.interfaceAction = model.name;
                        root.ruleAction.browserItemId = "";
                        root.ruleAction.actionTypeId = "";
                        if (listView.model.get(index).paramTypes.count > 0) {
                            var paramsPage = pageStack.push(Qt.resolvedUrl("SelectRuleActionParamsPage.qml"), {ruleAction: root.ruleAction, rule: root.rule})
                            paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                            paramsPage.onCompleted.connect(function() {
                                pageStack.pop();
                                root.done();
                            })
                        } else {
                            root.done();
                        }
                    } else {
                        console.warn("Neither thingId not interfaceName set. Cannot continue...");
                    }
                } else {
                    if (root.thing) {
                        if (model.actionTypeId === "browse") {
                            var page = pageStack.push(Qt.resolvedUrl("SelectBrowserItemActionPage.qml"), {thing: root.thing});
                            page.selected.connect(function(selectedItemId) {
                                print("selected is", selectedItemId)
                                root.ruleAction.browserItemId = selectedItemId;
                                root.ruleAction.actionTypeId = "";
                                root.ruleAction.interfaceAction = "";
                                pageStack.pop();
                                root.done();
                            })
                        } else {
                            var actionType = root.thing.thingClass.actionTypes.getActionType(model.actionTypeId);
                            console.log("ActionType", actionType.id, "selected. Has", actionType.paramTypes.count, "params");
                            if (root.ruleAction.actionTypeId !== actionType.id) {
                                root.ruleAction.actionTypeId = actionType.id;
                                root.ruleAction.ruleActionParams.clear();
                            }
                            root.ruleAction.browserItemId = "";
                            root.ruleAction.interfaceAction = "";
                            if (actionType.paramTypes.count > 0) {
                                var paramsPage = pageStack.push(Qt.resolvedUrl("SelectRuleActionParamsPage.qml"), {ruleAction: root.ruleAction, rule: root.rule})
                                paramsPage.onBackPressed.connect(function() { pageStack.pop(); });
                                paramsPage.onCompleted.connect(function() {
                                    pageStack.pop();
                                    root.done();
                                })
                            } else {
                                root.done();
                            }
                        }
                    }
                }
            }
        }
    }
}
