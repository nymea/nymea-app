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

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "../components"
import Nymea 1.0

Page {
    id: root

    property Thing thing: null

    header: NymeaHeader {
        text: qsTr("Magic involving %1").arg(root.thing.name)
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "qrc:/icons/add.svg"
            visible: rulesListView.count > 0
            onClicked: addRule()
        }
    }

    RuleTemplatesFilterModel {
        id: ruleTemplatesModel
        ruleTemplates: RuleTemplates {}
        filterByThings: ThingsProxy { engine: _engine }
        filterInterfaceNames: root.thing ? root.thing.thingClass.interfaces : []
    }

    // Rule is optional and might be initialized with anything wanted. A new, empty one will be created if null
    // This Page will take ownership of the rule and delete it eventually.
    function addRule(rule) {
        if (rule === null || rule === undefined) {
            print("creating new rule. have", ruleTemplatesModel.count, "templates", root.thing.thingClass.interfaces)
            if (ruleTemplatesModel.count > 0) {
                d.editRulePage = pageStack.push(Qt.resolvedUrl("NewThingMagicPage.qml"), {thing: root.thing});
                d.editRulePage.manualCreation.connect(function() {
                    pageStack.pop();
                    rule = engine.ruleManager.createNewRule();
                    addRule(rule)
                })
                d.editRulePage.done.connect(function() {pageStack.pop(root);});
                return;
            }
            rule = engine.ruleManager.createNewRule();
            d.editRulePage = pageStack.push(Qt.resolvedUrl("EditRulePage.qml"), {rule: rule, initialDeviceToBeAdded: root.thing});
        } else {
            d.editRulePage = pageStack.push(Qt.resolvedUrl("EditRulePage.qml"), {rule: rule});
        }

        d.editRulePage.StackView.onRemoved.connect(function() {
            rule.destroy();
        })
        d.editRulePage.onAccept.connect(function() {
            d.editRulePage.busy = true;
            engine.ruleManager.addRule(d.editRulePage.rule);
        })
        d.editRulePage.onCancel.connect(function() {
            pageStack.pop();
        })

        //        if (rule.eventDescriptors.count === 0) {
        //            var eventDescriptor = rule.eventDescriptors.createNewEventDescriptor();
        //            eventDescriptor.thingId = thing.id;
        //            page.selectEventDescriptorData(eventDescriptor);
        //        }

    }

    QtObject {
        id: d
        property var editRulePage: null
    }

    Connections {
        target: engine.ruleManager
        onAddRuleReply: {
            if (ruleError == RuleManager.RuleErrorNoError) {
                pageStack.pop(root);
            } else {
                var errorDialog = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"));
                var popup = errorDialog.createObject(root, {errorCode: ruleError })
                popup.open();
            }
            d.editRulePage.busy = false;
        }

        onEditRuleReply: {
            if (ruleError == RuleManager.RuleErrorNoError) {
                pageStack.pop(root);
            } else {
                var errorDialog = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"));
                var popup = errorDialog.createObject(root, {errorCode: ruleError })
                popup.open();
            }
            d.editRulePage.busy = false;
        }
    }

    ListView {
        id: rulesListView
        anchors.fill: parent

        model: RulesFilterModel {
            id: rulesFilterModel
            rules: engine.ruleManager.rules
            filterThingId: root.thing.id
        }

        delegate: NymeaSwipeDelegate {
            width: parent.width
            iconName: "qrc:/icons/magic.svg"
            iconColor: !model.enabled ? "red" : (model.active ? Style.accentColor : "grey")
            text: model.name
            canDelete: true

            onDeleteClicked: engine.ruleManager.removeRule(model.id)
            onClicked: {
                print("clicked")
                var newRule = rulesFilterModel.get(index).clone();
                print("rule cloned")
                d.editRulePage = pageStack.push(Qt.resolvedUrl("EditRulePage.qml"), {rule: newRule })
                print("page pushed")
                d.editRulePage.StackView.onRemoved.connect(function() {
                    newRule.destroy();
                })
                d.editRulePage.onAccept.connect(function() {
                    d.editRulePage.busy = true
                    engine.ruleManager.editRule(d.editRulePage.rule);
                })
                d.editRulePage.onCancel.connect(function() {
                    pageStack.pop();
                })
            }

        }
    }

    Column {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        spacing: app.margins * 2
        visible: rulesListView.count == 0

        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("There's no magic involving %1.").arg(root.thing.name)
            font.pixelSize: app.largeFont
            color: Style.accentColor
        }
        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Add some using the wizard stick!")
            font.pixelSize: app.largeFont
        }

        AbstractButton {
            height: Style.iconSize * 4
            width: height
            anchors.horizontalCenter: parent.horizontalCenter

            ColorIcon {
                anchors.fill: parent
                name: "qrc:/icons/magic.svg"
            }

            onClicked: addRule()
        }
    }
}
