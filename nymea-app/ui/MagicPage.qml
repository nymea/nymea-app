/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "components"
import Nymea 1.0

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("Magic")
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: Qt.resolvedUrl("images/script.svg")
            visible: engine.jsonRpcClient.ensureServerVersion("4.1")
            onClicked: {
                pageStack.push("magic/ScriptsPage.qml")
            }
        }

        HeaderButton {
            imageSource: Qt.resolvedUrl("images/add.svg")
            onClicked: {
                addRule()
            }
        }
    }

    RuleTemplatesFilterModel {
        id: ruleTemplatesModel
        ruleTemplates: RuleTemplates {}
        readonly property var deviceClass: root.device ? engine.deviceManager.deviceClasses.getDeviceClass(root.device.deviceClassId) : null
        filterByDevices: DevicesProxy { engine: _engine }
        filterInterfaceNames: deviceClass ? deviceClass.interfaces : []
    }

    function addRule() {
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
        onAddRuleReply: {
            if (ruleError == "RuleErrorNoError") {
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

        onEditRuleReply: {
            if (ruleError == "RuleErrorNoError") {
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

        model: RulesFilterModel {
            id: rulesProxy
            rules: engine.ruleManager.rules
        }
        delegate: NymeaSwipeDelegate {
            id: ruleDelegate
            width: parent.width
            iconName: "../images/" + (model.executable ? (iconTag && iconTag.value.length > 0 ? iconTag.value : "slideshow") : "magic") + ".svg"
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
        imageSource: "images/magic.svg"
        buttonText: qsTr("Add some magic")
        onImageClicked: addRule()
        onButtonClicked: addRule()
    }

    Component {
        id: errorDialog
        ErrorDialog {}
    }
}
