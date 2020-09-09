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
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import "../components"
import Nymea 1.0

Page {
    id: root

    property Rule rule: null
    property Device initialDeviceToBeAdded: null

    property bool busy: false

    readonly property bool isEventBased: rule.eventDescriptors.count > 0 || rule.timeDescriptor.timeEventItems.count > 0
    readonly property bool isStateBased: (rule.stateEvaluator !== null || rule.timeDescriptor.calendarItems.count > 0)
    readonly property bool actionsVisible: true
    readonly property bool exitActionsVisible: engine.jsonRpcClient.ensureServerVersion("1.7") && isStateBased
    readonly property bool hasActions: rule.actions.count > 0
    readonly property bool hasExitActions: rule.exitActions.count > 0
    readonly property bool isEmpty: !isEventBased && !isStateBased && !hasActions

    property string ruleIcon: engine.tagsManager.tags.findRuleTag(rule.id, "icon").value
    property string ruleColor: engine.tagsManager.tags.findRuleTag(rule.id, "color").value

    signal accept();
    signal cancel();

    Component.onCompleted: print("+++ created editrulepage")
    Component.onDestruction: {
        print("--- destroying editrulepage")
        d.backupRule.destroy();
    }

    onRuleChanged: d.createRuleBackup();
    QtObject {
        id: d
        property Rule backupRule: null

        function createRuleBackup() {
            if (backupRule !== null) {
                backupRule.destroy();
            }
            backupRule = root.rule.clone();
        }
    }

    function addEventDescriptor(interfaceMode) {
        if (interfaceMode === undefined) {
            interfaceMode = false;
        }

        var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {selectInterface: interfaceMode, showEvents: true});
        page.onBackPressed.connect(function() {
            pageStack.pop();
        });
        page.onThingSelected.connect(function(device) {
            var eventDescriptor = root.rule.eventDescriptors.createNewEventDescriptor();
            eventDescriptor.deviceId = device.id;
            selectEventDescriptorData(eventDescriptor);
        })
        page.onInterfaceSelected.connect(function(interfaceName) {
            var eventDescriptor = root.rule.eventDescriptors.createNewEventDescriptor();
            eventDescriptor.interfaceName = interfaceName;
            selectEventDescriptorData(eventDescriptor);
        })
    }

    function addInterfaceEventDescriptor() {
        addEventDescriptor(true);
    }

    function selectEventDescriptorData(eventDescriptor) {
        var eventPage = pageStack.push(Qt.resolvedUrl("SelectEventDescriptorPage.qml"), {text: "Select event", eventDescriptor: eventDescriptor});
        eventPage.onBackPressed.connect(function() {
            eventPage.StackView.onRemoved.connect(function() {
                eventDescriptor.destroy();
            });
            pageStack.pop();
        })
        eventPage.onDone.connect(function() {
            root.rule.eventDescriptors.addEventDescriptor(eventPage.eventDescriptor);
            pageStack.pop(root)
        })
    }

    function addTimeEventItem() {
        var timeEventItem = root.rule.timeDescriptor.timeEventItems.createNewTimeEventItem();
        var page = pageStack.push(Qt.resolvedUrl("EditTimeEventItemPage.qml"), {timeEventItem: timeEventItem});
        page.onBackPressed.connect(function() {
            page.StackView.onRemoved.connect(function() {
                timeEventItem.destroy();
            });
            pageStack.pop()
        })
        page.onDone.connect(function() {
            root.rule.timeDescriptor.timeEventItems.addTimeEventItem(timeEventItem);
            pageStack.pop(root);
        })
    }

    function addCalendarItem() {
        var calendarItem = root.rule.timeDescriptor.calendarItems.createNewCalendarItem();
        var page = pageStack.push(Qt.resolvedUrl("EditCalendarItemPage.qml"), {calendarItem: calendarItem});
        page.onBackPressed.connect(function() {
            page.StackView.onRemoved.connect(function() {
                calendarItem.destroy();
            });
            pageStack.pop();
        })
        page.onDone.connect(function() {
            root.rule.timeDescriptor.calendarItems.addCalendarItem(calendarItem);
            pageStack.pop(root);
        })
    }

    function createStateEvaluator(interfaceMode) {
        if (interfaceMode === undefined) {
            interfaceMode = false;
        }

        var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {selectInterface: interfaceMode, showStates: true});
        page.backPressed.connect(function() {
            pageStack.pop();
        });
        page.interfaceSelected.connect(function(interfaceName) {
            var stateEvaluator = root.rule.createStateEvaluator();
            stateEvaluator.stateDescriptor.interfaceName = interfaceName;
            selectStateDescriptorData(stateEvaluator)
        });
        page.thingSelected.connect(function(device) {
            var stateEvaluator = root.rule.createStateEvaluator();
            stateEvaluator.stateDescriptor.deviceId = device.id
            selectStateDescriptorData(stateEvaluator)
        })
    }

    function selectStateDescriptorData(stateEvaluator) {
        print("Selecting stateDescriptorData for", stateEvaluator.stateDescriptor.deviceId, stateEvaluator.stateDescriptor.interfaceName)
        var statePage = pageStack.push(Qt.resolvedUrl("SelectStateDescriptorPage.qml"), {text: "Select state", stateDescriptor: stateEvaluator.stateDescriptor})
        statePage.backPressed.connect(function() {
            statePage.StackView.onRemoved.connect(function() {
                stateEvaluator.destroy();
            })
            pageStack.pop()
        })
        statePage.done.connect(function() {
            root.rule.setStateEvaluator(stateEvaluator)
            pageStack.pop(root);
        })
    }

    function createInterfaceStateEvaluator() {
        createStateEvaluator(true)
    }

    function editStateEvaluator() {
        print("opening page", root.rule.stateEvaluator)
        var page = pageStack.push(Qt.resolvedUrl("EditStateEvaluatorPage.qml"), { stateEvaluator: root.rule.stateEvaluator })
    }

    function addRuleAction(interfaceMode) {
        if (interfaceMode === undefined) {
            interfaceMode = false;
        }

        var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {selectInterface: interfaceMode, showActions: true});
        page.onBackPressed.connect(function() {
            pageStack.pop();
        })
        page.onThingSelected.connect(function(device) {
            var ruleAction = root.rule.actions.createNewRuleAction();
            ruleAction.deviceId = device.id;
            selectRuleActionData(root.rule.actions, ruleAction)
        })
        page.onInterfaceSelected.connect(function(interfaceName) {
            var ruleAction = root.rule.actions.createNewRuleAction();
            ruleAction.interfaceName = interfaceName;
            selectRuleActionData(root.rule.actions, ruleAction)
        })
    }
    function addInterfaceRuleAction() {
        addRuleAction(true);
    }

    function addRuleExitAction(interfaceMode) {
        if (interfaceMode === undefined) {
            interfaceMode = false;
        }

        var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {selectInterface: interfaceMode, showActions: true});
        page.onBackPressed.connect(function() {
            pageStack.pop();
        })
        page.onThingSelected.connect(function(device) {
            var ruleAction = root.rule.exitActions.createNewRuleAction();
            ruleAction.deviceId = device.id;
            selectRuleActionData(root.rule.exitActions, ruleAction)
        })
        page.onInterfaceSelected.connect(function(interfaceName) {
            var ruleAction = root.rule.exitActions.createNewRuleAction();
            ruleAction.interfaceName = interfaceName;
            selectRuleActionData(root.rule.exitActions, ruleAction)
        })
    }
    function addInterfaceRuleExitAction() {
        addRuleExitAction(true);
    }

    function selectRuleActionData(ruleActions, ruleAction) {
        var ruleActionPage = pageStack.push(Qt.resolvedUrl("SelectRuleActionPage.qml"), {text: "Select action", ruleAction: ruleAction, rule: rule });
        ruleActionPage.onBackPressed.connect(function() {
            ruleActionPage.StackView.onRemoved.connect(function() {
                ruleAction.destroy();
            });
            pageStack.pop();
        })
        ruleActionPage.onDone.connect(function() {
            print("Adding rule action", ruleAction)
            ruleActions.addRuleAction(ruleAction)
            pageStack.pop(root);
        })
    }

    function startAddAction() {
        if (root.isEmpty) {
            root.rule.executable = true;
        }
        if (root.initialDeviceToBeAdded !== null) {
            var ruleAction = root.rule.actions.createNewRuleAction();
            ruleAction.deviceId = root.initialDeviceToBeAdded.id;
            root.initialDeviceToBeAdded = null;
            selectRuleActionData(root.rule.actions, ruleAction)
        } else {
            var page = pageStack.push(ruleActionQuestionPageComponent, {exitAction: false});
        }
    }

    header: NymeaHeader {
        text: root.rule.name.length === 0 ? qsTr("Add new magic") : qsTr("Edit %1").arg(root.rule.name)
        onBackPressed: {
            if (root.rule.compare(d.backupRule)) {
                print("Rule has not been changed. Exiting EditRulePage");
                root.cancel();
                return;
            }
            print("Rule has changed. Asking for cancellation dialog")
            var component = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
            var popup = component.createObject(root, {headerIcon: "../images/question.svg",
                                                   title: qsTr("Cancel?"),
                                                   text: qsTr("Any changes to the rule will be lost."),
                                                   standardButtons: Dialog.Yes | Dialog.No
                                               })
            popup.accepted.connect(function() {
                root.cancel();
            })
            popup.open();
        }

        HeaderButton {
            imageSource: "../images/tick.svg"
            enabled: actionsRepeater.count > 0 && root.rule.name.length > 0
            opacity: enabled ? 1 : .3
            onClicked: root.accept()
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.implicitHeight + app.margins

        ColumnLayout {
            id: contentColumn
            anchors { left: parent.left; top: parent.top; right: parent.right; }
            ColumnLayout {
                id: ruleSettings
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: app.margins
                visible: !root.isEmpty

                property bool showDetails: false

                RowLayout {
                    Layout.fillWidth: true
                    spacing: app.margins

                    Label {
                        text: qsTr("Name:")
                    }

                    TextField {
                        Layout.fillWidth: true
                        text: root.rule.name
                        onTextChanged: root.rule.name = text;
                    }

                    ColorIcon {
                        name: "../images/settings.svg"
                        Layout.preferredHeight: app.iconSize
                        Layout.preferredWidth: app.iconSize
                        MouseArea {
                            anchors.fill: parent
                            onClicked: ruleSettings.showDetails = !ruleSettings.showDetails
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: ruleSettings.showDetails ? implicitHeight : 0
                    opacity: ruleSettings.showDetails ? 1 : 0
                    Behavior on Layout.preferredHeight { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad} }
                    Behavior on opacity { NumberAnimation {duration: 200; easing.type: Easing.InOutQuad } }
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("This rule is enabled")
                    }
                    CheckBox {
                        checked: root.rule.enabled
                        onClicked: {
                            root.rule.enabled = checked
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: ruleSettings.showDetails ? implicitHeight : 0
                    opacity: ruleSettings.showDetails ? 1 : 0
                    Behavior on Layout.preferredHeight { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad} }
                    Behavior on opacity { NumberAnimation {duration: 200; easing.type: Easing.InOutQuad } }
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("This is a scene")
                    }

                    CheckBox {
                        checked: root.rule.executable
                        onClicked: {
                            root.rule.executable = checked
                        }
                    }
                }

                GridLayout {
                    id: colorsGrid
                    Layout.fillWidth: true
                    columns: (root.width / 10 < app.iconSize + app.margins) ? 5 : 10
                    columnSpacing: app.margins
                    rowSpacing: app.margins
                    Layout.preferredHeight: opacity > 0 ? implicitHeight : 0
                    opacity: engine.jsonRpcClient.ensureServerVersion(1.6) && ruleSettings.showDetails && root.rule.executable ? 1 : 0
                    Behavior on Layout.preferredHeight { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad} }
                    Behavior on opacity { NumberAnimation {duration: 200; easing.type: Easing.InOutQuad } }

                    Repeater {
                        model: ["red", "orange", "yellow", "lime", "green", "aqua", "skyblue", "blue", "magenta", "purple"]

                        delegate: Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: app.iconSize + app.margins
                            Rectangle {
                                height: parent.height
                                width: height
                                color: "transparent"
                                border.width: 2
                                border.color: modelData === root.ruleColor ? app.accentColor : "transparent"
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    root.ruleColor = modelData
                                }
                            }

                            ColorIcon {
                                height: app.iconSize
                                width: app.iconSize
                                color: modelData
                                name: "../images/" + (root.ruleIcon ? root.ruleIcon : "slideshow") + ".svg"
                                anchors.centerIn: parent
                            }
                        }
                    }
                    Repeater {
                        model: ["light-on", "light-off", "alarm-clock", "media-playback-start", "connections/network-secure", "notification", "sensors", "shutter/shutter-050", "attention", "eye"]
                        delegate: Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: app.iconSize + app.margins
                            Rectangle {
                                height: parent.height
                                width: height
                                color: "transparent"
                                border.width: 2
                                border.color: modelData === root.ruleIcon ? app.accentColor : "transparent"
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    root.ruleIcon = modelData
                                }
                            }

                            ColorIcon {
                                height: app.iconSize
                                width: app.iconSize
                                color: root.ruleColor
                                name: "../images/" + modelData + ".svg"
                                anchors.centerIn: parent
                            }
                        }
                    }
                }
            }

            ThinDivider { visible: root.isEmpty || root.isEventBased }

            Label {
                Layout.fillWidth: true
                Layout.margins: app.margins
                font.pixelSize: app.mediumFont
                wrapMode: Text.WordWrap
                text: eventsRepeater.count === 0 && timeEventRepeater.count === 0 && actionsRepeater.count === 0 ?
                          qsTr("Execute actions when something happens.") :
                          qsTr("When any of these events happen...")
                visible: root.isEmpty || root.isEventBased
                font.bold: true
            }
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                wrapMode: Text.WordWrap
                font.pixelSize: app.smallFont
                font.italic: true
                text: qsTr("Examples:\n• When a button is pressed...\n• When the temperature changes...\n• At 7 am...")
                visible: root.isEmpty
            }


            Repeater {
                id: eventsRepeater
                model: root.rule.eventDescriptors
                delegate: EventDescriptorDelegate {
                    Layout.fillWidth: true
                    implicitWidth: parent.width
                    eventDescriptor: root.rule.eventDescriptors.get(index)
                    onRemoveEventDescriptor: root.rule.eventDescriptors.removeEventDescriptor(index)
                }
            }

            Repeater {
                id: timeEventRepeater
                model: root.rule.timeDescriptor.timeEventItems
                delegate: TimeEventDelegate {
                    Layout.fillWidth: true
                    timeEventItem: root.rule.timeDescriptor.timeEventItems.get(index)
                    onRemoveTimeEventItem: {
                        root.rule.timeDescriptor.timeEventItems.removeTimeEventItem(index);
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.bottomMargin: app.margins
                text: eventsRepeater.count == 0 && timeEventRepeater.count === 0 ? qsTr("Configure...") : qsTr("Add another...")
                visible: root.isEmpty || root.isEventBased
                onClicked: {
                    if (root.initialDeviceToBeAdded !== null) {
                        var eventDescriptor = root.rule.eventDescriptors.createNewEventDescriptor();
                        eventDescriptor.deviceId = root.initialDeviceToBeAdded.id;
                        root.initialDeviceToBeAdded = null;
                        selectEventDescriptorData(eventDescriptor);
                    } else if (root.rule.timeDescriptor.calendarItems.count > 0) {
                        root.addEventDescriptor()
                    } else {
                        pageStack.push(eventQuestionPageComponent)
                    }
                }
            }

            ThinDivider {}

            Label {
                text: root.isEmpty ?
                          qsTr("Do something while a condition is met.") :
                          root.isEventBased ?
                              qsTr("...but only if those conditions are met...") :
                              qsTr("When this condition...")
                font.pixelSize: app.mediumFont
                Layout.fillWidth: true
                Layout.margins: app.margins
                wrapMode: Text.WordWrap
                font.bold: true
                visible: {
                    if (root.isEventBased) {
                        if (root.rule.timeDescriptor.calendarItems.count === 0) {
                            return true;
                        }

                        if (root.rule.stateEvaluator === null) {
                            return false;
                        }
                    } else {
                        if (root.rule.stateEvaluator === null && root.rule.timeDescriptor.calendarItems.count > 0) {
                            return false;
                        }
                    }

                    return true;
                }
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                wrapMode: Text.WordWrap
                font.pixelSize: app.smallFont
                font.italic: true
                text: qsTr("Examples:\n• While I'm at home...\n• When the temperature is below 0...\n• Between 9 am and 6 pm...")
                visible: root.isEmpty
            }

            StateEvaluatorDelegate {
                Layout.fillWidth: true
                stateEvaluator: root.rule.stateEvaluator
                visible: root.rule.stateEvaluator !== null
                onDeleteClicked: {
                    root.rule.stateEvaluator = null
                }
            }

            Label {
                text: root.rule.stateEvaluator === null && !root.isEventBased ?
                          qsTr("When time is in...") :
                          qsTr("...during this time...")
                font.pixelSize: app.mediumFont
                Layout.fillWidth: true
                Layout.margins: app.margins
                font.bold: true
                visible: root.rule.timeDescriptor.timeEventItems.count === 0 && (root.rule.timeDescriptor.calendarItems.count > 0 || root.rule.stateEvaluator !== null)
            }

            Repeater {
                model: root.rule.timeDescriptor.calendarItems
                delegate: CalendarItemDelegate {
                    Layout.fillWidth: true
                    calendarItem: root.rule.timeDescriptor.calendarItems.get(index)
                    onRemoveCalendarItem: {
                        root.rule.timeDescriptor.calendarItems.removeCalendarItem(index)
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.bottomMargin: app.margins
                text: root.rule.stateEvaluator === null || root.rule.timeDescriptor.calendarItems.count === 0 ?
                          qsTr("Configure...") :
                          qsTr("Add another...")
                visible: root.rule.timeDescriptor.timeEventItems.count === 0 || root.rule.stateEvaluator === null
                onClicked: {
                    if (root.initialDeviceToBeAdded !== null) {
                        var stateEvaluator = root.rule.createStateEvaluator();
                        stateEvaluator.stateDescriptor.deviceId = root.initialDeviceToBeAdded.id
                        root.initialDeviceToBeAdded = null;
                        selectStateDescriptorData(stateEvaluator)
                    } else if (root.rule.timeDescriptor.timeEventItems.count > 0) {
                        root.rule.setStateEvaluator(root.rule.createStateEvaluator());
                    } else if (root.rule.stateEvaluator !== null) {
                        root.addCalendarItem();
                    } else {
                        pageStack.push(stateQuestionPageComponent)
                    }
                }
            }

            ThinDivider { visible: root.actionsVisible }

            Label {
                text: root.isEmpty ? qsTr("Create a scene.")
                                   : root.isEventBased ? qsTr("...execute those actions:")
                                   : root.isStateBased ? qsTr("...come true, execute those actions:")
                                   : qsTr("Execute those actions:")
                font.pixelSize: app.mediumFont
                Layout.fillWidth: true
                Layout.margins: app.margins
                wrapMode: Text.WordWrap
                visible: root.actionsVisible
                font.bold: true
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                wrapMode: Text.WordWrap
                font.pixelSize: app.smallFont
                font.italic: true
                text: qsTr("Just pick some actions which will be executed when the scene is activated. Scenes are like any other magic except they can also be activated manually.")
                visible: root.isEmpty
            }

            Repeater {
                id: actionsRepeater
                model: root.actionsVisible ? root.rule.actions : null
                delegate: RuleActionDelegate {
                    Layout.fillWidth: true
                    implicitWidth: parent.width
                    ruleAction: root.rule.actions.get(index)
                    onRemoveRuleAction: root.rule.actions.removeRuleAction(index)
                    onClicked: {
                        var ruleActionPage = pageStack.push(Qt.resolvedUrl("SelectRuleActionPage.qml"), {text: "Select action", ruleAction: ruleAction, rule: root.rule });
                        ruleActionPage.onBackPressed.connect(function() {
                            pageStack.pop();
                        })
                        ruleActionPage.onDone.connect(function() {
                            pageStack.pop(root);
                        })
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.bottomMargin: app.margins
                text: root.isEmpty ? qsTr("Configure...") :
                                     actionsRepeater.count == 0 ? qsTr("Add an action...") : qsTr("Add another action...")
                onClicked: {
                    root.startAddAction();
                }
                visible: root.actionsVisible
            }

            ThinDivider { visible: root.exitActionsVisible }

            Label {
                text: root.isEventBased ? qsTr("If the condition isn't met, execute those actions instead:") : qsTr("When the condition isn't met any more, execute those actions:")

                Layout.fillWidth: true
                Layout.margins: app.margins
                wrapMode: Text.WordWrap
                visible: root.exitActionsVisible
                font.pixelSize: app.mediumFont
                font.bold: true
            }


            Repeater {
                id: exitActionsRepeater
                model: root.exitActionsVisible ? root.rule.exitActions : null
                delegate: RuleActionDelegate {
                    Layout.fillWidth: true
                    implicitWidth: parent.width
                    ruleAction: root.rule.exitActions.get(index)
                    onRemoveRuleAction: root.rule.exitActions.removeRuleAction(index)
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.bottomMargin: app.margins
                text: exitActionsRepeater.count == 0 ? qsTr("Add an action...") : qsTr("Add another action...")
                onClicked: {
                    var page = pageStack.push(ruleActionQuestionPageComponent, {exitAction: true});
                }
                visible: root.exitActionsVisible
            }
        }
    }

    Rectangle {
        id: busyOverlay
        anchors.fill: parent
        color: "#55000000"
        opacity: root.busy ? 1 : 0
        Behavior on opacity { NumberAnimation {duration: 200 } }
        BusyIndicator {
            anchors.centerIn: parent
            running: parent.opacity > 0
        }
    }

    Component {
        id: eventQuestionPageComponent
        Page {
            header: NymeaHeader {
                text: qsTr("Add event")
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent

                Repeater {
                    model: ListModel {
                        ListElement {
                            iconName: "../images/event.svg"
                            text: qsTr("When one of my things triggers an event")
                            method: "addEventDescriptor"
                            minimumJsonRpcVersion: "1.0"
                        }
                        ListElement {
                            iconName: "../images/event-interface.svg"
                            text: qsTr("When a thing of a given type triggers an event")
                            method: "addInterfaceEventDescriptor"
                            minimumJsonRpcVersion: "1.5"
                        }
                        ListElement {
                            iconName: "../images/alarm-clock.svg"
                            text: qsTr("At a particular time or date")
                            method: "addTimeEventItem"
                            minimumJsonRpcVersion: "1.0"
                        }
                    }
                    delegate: NymeaListItemDelegate {
                        Layout.fillWidth: true
                        iconName: model.iconName
                        text: model.text
                        progressive: true
                        iconSize: app.iconSize * 2
                        visible: engine.jsonRpcClient.ensureServerVersion(model.minimumJsonRpcVersion)

                        onClicked: {
                            root[model.method]()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: stateQuestionPageComponent
        Page {
            header: NymeaHeader {
                text: qsTr("Add condition...")

                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent

                Repeater {
                    model: ListModel {
                        ListElement {
                            iconName: "../images/state.svg"
                            text: qsTr("When one of my things is in a certain state")
                            method: "createStateEvaluator"
                            minimumJsonRpcVersion: "1.0"
                        }
                        ListElement {
                            iconName: "../images/state-interface.svg"
                            text: qsTr("When a thing of a given type enters a state")
                            method: "createInterfaceStateEvaluator"
                            minimumJsonRpcVersion: "1.5"
                        }
                        ListElement {
                            iconName: "../images/clock-app-symbolic.svg"
                            text: qsTr("During a given time")
                            method: "addCalendarItem"
                            minimumJsonRpcVersion: "1.0"
                        }
                    }
                    delegate: NymeaListItemDelegate {
                        Layout.fillWidth: true
                        iconName: model.iconName
                        text: model.text
                        progressive: true
                        iconSize: app.iconSize * 2
                        visible: engine.jsonRpcClient.ensureServerVersion(model.minimumJsonRpcVersion)

                        onClicked: {
                            root[model.method]()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: ruleActionQuestionPageComponent
        Page {
            id: ruleActionQuestionPage
            property bool exitAction: false

            header: NymeaHeader {
                text: qsTr("Add action...")

                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent

                Repeater {
                    model: ListModel {
                        ListElement {
                            iconName: "../images/action.svg"
                            text: qsTr("Execute an action on one of my things")
                            method: "addRuleAction"
                            isExitAction: false
                            minimumJsonRpcVersion: "1.0"
                        }
                        ListElement {
                            iconName: "../images/action-interface.svg"
                            text: qsTr("Execute an action on an entire kind of things")
                            method: "addInterfaceRuleAction"
                            isExitAction: false
                            minimumJsonRpcVersion: "1.5"
                        }
                        ListElement {
                            iconName: "../images/action.svg"
                            text: qsTr("Execute an action on one of my things")
                            method: "addRuleExitAction"
                            isExitAction: true
                            minimumJsonRpcVersion: "1.0"
                        }
                        ListElement {
                            iconName: "../images/action-interface.svg"
                            text: qsTr("Execute an action on an entire kind of things")
                            method: "addInterfaceRuleExitAction"
                            isExitAction: true
                            minimumJsonRpcVersion: "1.5"
                        }
                    }
                    delegate: NymeaListItemDelegate {
                        Layout.fillWidth: true
                        iconName: model.iconName
                        text: model.text
                        progressive: true
                        iconSize: app.iconSize * 2
                        visible: ruleActionQuestionPage.exitAction === model.isExitAction && engine.jsonRpcClient.ensureServerVersion(model.minimumJsonRpcVersion)

                        onClicked: {
                            root[model.method]()
                        }
                    }
                }
            }
        }
    }
}
