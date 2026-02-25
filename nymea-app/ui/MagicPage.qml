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

import "components"

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("Magic")
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: Qt.resolvedUrl("qrc:/icons/script.svg")
            visible: engine.jsonRpcClient.ensureServerVersion("4.1")
            onClicked: {
                pageStack.push("magic/ScriptsPage.qml")
            }
        }

        HeaderButton {
            imageSource: Qt.resolvedUrl("qrc:/icons/add.svg")
            onClicked: {
                addRule()
            }
        }
    }

    RuleTemplatesFilterModel {
        id: ruleTemplatesModel
        ruleTemplates: RuleTemplates {}
        filterByThings: ThingsProxy {
            id: templatesThingsProxy
            engine: _engine
        }
    }

    function addRule() {
        print("ruletemplates:", ruleTemplatesModel.count, templatesThingsProxy.count)
        if (ruleTemplatesModel.count > 0) {
            d.editRulePage = pageStack.push(Qt.resolvedUrl("magic/NewThingMagicPage.qml"))
            d.editRulePage.done.connect(function() {
                print("add rule done")
                pageStack.pop(root);
            })

            d.editRulePage.manualCreation.connect(function() {
                pageStack.pop(root);
                manualAddRule();
            })
        } else {
            manualAddRule();
        }
    }

    function manualAddRule() {
        var newRule = engine.ruleManager.createNewRule();
        d.editRulePage = pageStack.push(Qt.resolvedUrl("magic/EditRulePage.qml"), {rule: newRule });
        d.editRulePage.StackView.onRemoved.connect(function() {
            newRule.destroy();
        })
        d.editRulePage.onAccept.connect(function() {
            d.editRulePage.busy = true;
            engine.ruleManager.addRule(d.editRulePage.rule);
        })
        d.editRulePage.onCancel.connect(function() {
            pageStack.pop();
        })
    }

    QtObject {
        id: d
        property var editRulePage: null
    }

    Connections {
        target: engine.ruleManager
        onAddRuleReply: (commandId, ruleError, ruleId) => {
            if (ruleError === RuleManager.RuleErrorNoError) {
//                print("should tag rule now:", d.editRulePage.rule.id, d.editRulePage.ruleIcon, d.editRulePage.ruleColor)
//                engine.tagsManager.tagRule(ruleId, "color", d.editRulePage.ruleColor)
//                engine.tagsManager.tagRule(ruleId, "icon", d.editRulePage.ruleIcon)
                pageStack.pop(root);
            } else {
                var popup = errorDialog.createObject(app, {errorCode: ruleError })
                popup.open();
            }
            d.editRulePage.busy = false;
        }

        onEditRuleReply: (commandId, ruleError) => {
            if (ruleError === RuleManager.RuleErrorNoError) {
//                print("should tag rule now:", d.editRulePage.ruleIcon, d.editRulePage.ruleColor)
                engine.tagsManager.tagRule(d.editRulePage.rule.id, "color", d.editRulePage.ruleColor)
                engine.tagsManager.tagRule(d.editRulePage.rule.id, "icon", d.editRulePage.ruleIcon)
                pageStack.pop();
            } else {
                var popup = errorDialog.createObject(app, {errorCode: ruleError })
                popup.open();
            }
            d.editRulePage.busy = false;
        }
    }

    ListView {
        anchors.fill: parent
        clip: true

        model: RulesFilterModel {
            id: rulesProxy
            rules: engine.ruleManager.rules
        }
        delegate: NymeaSwipeDelegate {
            id: ruleDelegate
            width: parent.width
            iconName: "qrc:/icons/" + (model.executable ? (iconTag && iconTag.value.length > 0 ? iconTag.value : "slideshow") : "magic") + ".svg"
            iconColor: model.executable ? (colorTag && colorTag.value.length > 0 ? colorTag.value : Style.accentColor) : !model.enabled ? "red" : (model.active ? Style.accentColor : "grey")
            text: model.name
            canDelete: true

            property var colorTag: model.executable ? engine.tagsManager.tags.findRuleTag(model.id, "color") : null
            property var iconTag: model.executable ? engine.tagsManager.tags.findRuleTag(model.id, "icon") : null
            Connections {
                target: engine.tagsManager.tags
                onCountChanged: {
                    colorTag = engine.tagsManager.tags.findRuleTag(model.id, "color")
                    iconTag = engine.tagsManager.tags.findRuleTag(model.id, "icon")
                }
            }

            onDeleteClicked: engine.ruleManager.removeRule(model.id)

            onClicked: {
                var newRule = rulesProxy.get(index).clone();
                d.editRulePage = pageStack.push(Qt.resolvedUrl("magic/EditRulePage.qml"), {rule: newRule})
                d.editRulePage.StackView.onRemoved.connect(function() {
                    newRule.destroy();
                })
                d.editRulePage.onAccept.connect(function() {
                    d.editRulePage.busy = true;
                    engine.ruleManager.editRule(d.editRulePage.rule);
                })
                d.editRulePage.onCancel.connect(function() {
                    pageStack.pop();
                })
            }
        }
    }

    EmptyViewPlaceholder {
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        anchors.verticalCenter: parent.verticalCenter
        visible: engine.ruleManager.rules.count === 0
        title: qsTr("There is no magic set up yet.")
        text: qsTr("Use magic to make your things smart! In a few easy steps you'll have your things wired up and work for you.")
        imageSource: "qrc:/icons/magic.svg"
        buttonText: qsTr("Add some magic")
        onImageClicked: addRule()
        onButtonClicked: addRule()
    }

    Component {
        id: errorDialog
        ErrorDialog {}
    }
}
