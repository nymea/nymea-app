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

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.1
import Nymea 1.0
import "../components"

ThingPageBase {
    id: root

    readonly property var powerStateType: thing.thingClass.stateTypes.findByName("power")
    readonly property var powerState: thing.states.getState(powerStateType.id)
    readonly property var powerActionType: thing.thingClass.actionTypes.findByName("power");

    readonly property bool isOn: powerState && powerState.value === true

    QtObject {
        id: d
        property var pendingRuleCreationId: -1
        property var now: new Date()
    }
    Timer {
        running: true
        repeat: true
        interval: 5000
        onTriggered: {
            d.now = new Date()
        }
    }

    Component.onCompleted: {
        cleanupRules();
    }

    function waterFor(minutes) {
        var rule = engine.ruleManager.createNewRule();
        var now = new Date();
        var offDate = new Date(now.getTime() + (minutes * 60000));

        rule.name = qsTr("Turn %1 off at %2").arg(root.thing.name).arg(Qt.formatDateTime(offDate))

        var timeEvent = rule.timeDescriptor.timeEventItems.createNewTimeEventItem();
        timeEvent.dateTime = offDate;
        timeEvent.repeatingOption.repeatingMode = RepeatingOption.RepeatingModeNone;
        rule.timeDescriptor.timeEventItems.addTimeEventItem(timeEvent);

        var ruleAction = rule.actions.createNewRuleAction();
        ruleAction.thingId = root.thing.id;
        ruleAction.interfaceName = "power";
        ruleAction.interfaceAction = "power"
        ruleAction.ruleActionParams.setRuleActionParamByName("power", false);
        rule.actions.addRuleAction(ruleAction)

        d.pendingRuleCreationId = engine.ruleManager.addRule(rule);
    }

    function cleanupRules() {
        print("cleaning up stale oneshot watering rules")
        for (var i = 0; i < engine.tagsManager.tags.count; i++) {
            var tag = engine.tagsManager.tags.get(i);
            if (tag.tagId === "oneshot-watering") {
                print("have a oneshot-watering tag")
                // Delete it if the timer expired already
                var rule = engine.ruleManager.rules.getRule(tag.ruleId)
                if (rule.timeDescriptor.timeEventItems.get(0).dateTime < new Date()) {
                    print("need to cleanup rule:", tag.ruleId, rule.timeDescriptor.timeEventItems.get(0).dateTime)
                    engine.ruleManager.removeRule(tag.ruleId)
                } else {
                    print("Rule still pending:", tag.ruleId)
                }
                // Also delete it if the irrigation is off already
                if (root.powerState.value === false) {
                    engine.ruleManager.removeRule(tag.ruleId);
                }
            }
        }
    }

    Connections {
        target: engine.ruleManager
        onAddRuleReply: {
            if (commandId == d.pendingRuleCreationId) {
                d.pendingRuleCreationId = -1
                if (ruleError != "RuleErrorNoError") {
                    var comp = Qt.createComponent("../components/ErrorDialog.qml")
                    var popup = comp.createObject(app, {errorCode: ruleError})
                    popup.open();
                    return;
                }
                // Tag the rule so we can clean identify it
                engine.tagsManager.tagRule(ruleId, "oneshot-watering", root.thing.id)

                // Off rule has been added. Turning on now
                if (root.powerState.value === false) {
                    engine.thingManager.executeAction(root.thing.id, root.powerActionType.id, [{paramTypeId: root.powerActionType.id, value: true}])
                }
            }
        }
    }

    Connections {
        target: root.powerState
        onValueChanged: cleanupRules()
    }

    LogsModelNg {
        id: history
        engine: _engine
        thingId: root.thing.id
        typeIds: [root.powerStateType.id]
        property var lastWatering: count > 0 ? get(0).timestamp : null
        live: true
    }

    TagsProxyModel {
        id: tagsProxy
        tags: engine.tagsManager.tags
        filterTagId: "oneshot-watering"
        filterValue: root.thing.id
    }

    GridLayout {
        id: mainGrid
        anchors.fill: parent
        anchors.margins: app.margins
        columns: app.landscape ? 2 : 1

        Item {
            Layout.preferredWidth: app.landscape ? parent.width * .4 : parent.width
            Layout.preferredHeight: app.landscape ? parent.height : parent.height *.4

            AbstractButton {
                height: Math.min(Math.min(parent.height, parent.width), Style.iconSize * 5)
                width: height
                anchors.centerIn: parent
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: root.powerState.value === true ? Style.accentColor : Style.iconColoor
                    border.width: 4
                    radius: width / 2
                }

                ColorIcon {
                    id: irrigationIcon
                    anchors.fill: parent
                    anchors.margins: app.margins * 1.5
                    name: "../images/irrigation.svg"
                    color: root.powerState.value === true ? Style.accentColor : Style.iconColor
                }
                onClicked: {
                    var params = []
                    var param = {}
                    param["paramTypeId"] = root.powerActionType.paramTypes.get(0).id;
                    param["value"] = !root.powerState.value;
                    params.push(param)
                    engine.thingManager.executeAction(root.thing.id, root.powerStateType.id, params);
                    PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                }
            }
        }

        ColumnLayout {
            Layout.preferredWidth: app.landscape ? parent.width * .6 : parent.width
            Layout.preferredHeight: app.landscape ? parent.height : parent.height * .6
            Item { Layout.fillWidth: true; Layout.fillHeight: true }
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                horizontalAlignment: Text.AlignHCenter
                text: root.isOn ? qsTr("Watering since")
                                : history.lastWatering ? qsTr("Last watering")
                                           : qsTr("This irrigation has not been used yet")
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                horizontalAlignment: Text.AlignHCenter
                text: history.lastWatering ? Qt.formatDateTime(history.lastWatering) : ""
                font.pixelSize: app.largeFont
                color: Style.accentColor
            }
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.bottomMargin: app.margins
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: app.smallFont
                text: {
                    if (!history.lastWatering) {
                        return ""
                    }

                    var n = Math.floor((d.now - history.lastWatering) / 60 / 1000)

                    n = Math.max(0, n)

                    if (root.isOn) {
                        if (n < 60) {
                            return qsTr("%n minute(s)", "", n);
                        }
                        n /= 60;
                        if (n < 24) {
                            return qsTr("%n hour(s)", "", n);
                        }
                        n /= 24;
                        return qsTr("%n day(s)", "", n);

                    }

                    if (n < 60) {
                        return qsTr("%n minute(s) ago", "", n);
                    }
                    n /= 60;
                    if (n < 24) {
                        return qsTr("%n hour(s) ago", "", n);
                    }
                    n /= 24;
                    return qsTr("%n day(s) ago", "", n);
                }
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
                horizontalAlignment: Text.AlignHCenter
                text: tagsProxy.count > 0 ?
                          //: Irrigation will be turned of at, e.g. 09:00
                          qsTr("Watering until")
                          //: Turn on irrigation for, e.g. 5 minutes
                        : root.isOn ? qsTr("Turn off in") : qsTr("Water for")
            }

            GridLayout {
                columns: 3
                visible: tagsProxy.count == 0

                Button {
                    Layout.fillWidth: true
                    text: qsTr("1 minute")
                    onClicked: root.waterFor(1)
                }
                Button {
                    Layout.fillWidth: true
                    text: qsTr("2 minutes")
                    onClicked: root.waterFor(2)
                }
                Button {
                    Layout.fillWidth: true
                    text: qsTr("5 minutes")
                    onClicked: root.waterFor(5)
                }
                Button {
                    Layout.fillWidth: true
                    text: qsTr("15 minutes")
                    onClicked: root.waterFor(15)
                }
                Button {
                    Layout.fillWidth: true
                    text: qsTr("30 minutes")
                    onClicked: root.waterFor(30)
                }
                Button {
                    Layout.fillWidth: true
                    text: qsTr("1 hour")
                    onClicked: root.waterFor(60)
                }
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                horizontalAlignment: Text.AlignHCenter
                visible: tagsProxy.count > 0
                font.pixelSize: app.largeFont
                color: Style.accentColor
                text: tagsProxy.count == 0 ? "" : Qt.formatDateTime(engine.ruleManager.rules.getRule(tagsProxy.get(0).ruleId).timeDescriptor.timeEventItems.get(0).dateTime)
            }
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.bottomMargin: app.margins
                horizontalAlignment: Text.AlignHCenter
                visible: tagsProxy.count > 0
                font.pixelSize: app.smallFont
                text: {
                    if (tagsProxy.count == 0) {
                        return ""
                    }

                    var end = engine.ruleManager.rules.getRule(tagsProxy.get(0).ruleId).timeDescriptor.timeEventItems.get(0).dateTime
                    var n = Math.floor((end - d.now) / 60 / 1000)

                    n = Math.max(0, n);

                    if (n < 60) {
                        return qsTr("%n minute(s) left", "", n);
                    }
                    n /= 60;
                    if (n < 24) {
                        return qsTr("%n hour(s) left", "", n);
                    }
                    n /= 24;
                    return qsTr("%n day(s) left", "", n);
                }
            }

            Item { Layout.fillWidth: true; Layout.fillHeight: true }
        }
    }
}
