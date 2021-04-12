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
import "../components"
import Nymea 1.0

Page {
    id: root

    property Thing thing: null

    header: NymeaHeader {
        text: qsTr("Magic involving %1").arg(root.thing.name)
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/add.svg"
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
            if (ruleError == "RuleErrorNoError") {
                pageStack.pop(root);
            } else {
                var errorDialog = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"));
                var popup = errorDialog.createObject(root, {errorCode: ruleError })
                popup.open();
            }
            d.editRulePage.busy = false;
        }

        onEditRuleReply: {
            if (ruleError == "RuleErrorNoError") {
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
            iconName: "../images/magic.svg"
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
                name: "../images/magic.svg"
            }

            onClicked: addRule()
        }
    }
}
