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

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

import "../components"

Page {
    id: root

    property Thing thing: null
    readonly property ThingClass thingClass: thing ? thing.thingClass : null
    property bool busy: false

    signal done();
    signal manualCreation();

    function createRuleFromTemplate(ruleTemplate) {
        d.selectedThings = {}
        d.selectedInterfaces = {}
        var rule = engine.ruleManager.createNewRule();
        d.fillRuleFromTemplate(rule, ruleTemplate);
    }

    QtObject {
        id: d
        property var selectedThings: ({})
        property var selectedThingNames: ({})
        property var selectedInterfaces: ({})

        function fillRuleFromTemplate(rule, ruleTemplate) {
            print("***** Filling rule")

            // Fill in all EventDescriptors
            for (var i = rule.eventDescriptors.count; i < ruleTemplate.eventDescriptorTemplates.count; i++) {
                var eventDescriptorTemplate = ruleTemplate.eventDescriptorTemplates.get(i);
                print("RuleFromTemplate: Filling eventDescriptor:", eventDescriptorTemplate.interfaceName, eventDescriptorTemplate.eventName, eventDescriptorTemplate.selectionId)
                // If we already have a thing selected for this selectionIndex, use that
                if (eventDescriptorTemplate.selectionId in selectedThings) {
                    var thing = engine.thingManager.things.getThing(selectedThings[eventDescriptorTemplate.selectionId]);
                    print("Already have a thing for selectionId", eventDescriptorTemplate.selectionId, ":", thing.name)
                    createEventDescriptor(rule, ruleTemplate, thing, eventDescriptorTemplate)
                    return;
                }
                // Ok, we didn't pick a thing for this selectionId before. Did we already use the one we opened this page from?
                if (root.thing && !thingIsUsed(root.thing.id) && root.thingClass.interfaces.indexOf(eventDescriptorTemplate.interfaceName) >= 0) {
                    print("Root thing is matching and not used. Using for selectionId", eventDescriptorTemplate.selectionId, ":", root.thing.name)
                    selectedThings[eventDescriptorTemplate.selectionId] = root.thing.id;
                    selectedThingNames[eventDescriptorTemplate.selectionId] = root.thing.name;
                    createEventDescriptor(rule, ruleTemplate, root.thing, eventDescriptorTemplate)
                    return;
                }

                // We need to pick a thing
                print("We need to pick a new thing for selectionId", eventDescriptorTemplate.selectionId)
                var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {shownInterfaces: [eventDescriptorTemplate.interfaceName], requiredEventName: eventDescriptorTemplate.eventName});
                page.thingSelected.connect(function(thing) {
                    selectedThings[eventDescriptorTemplate.selectionId] = thing.id;
                    selectedThingNames[eventDescriptorTemplate.selectionId] = thing.name;
                    createEventDescriptor(rule, ruleTemplate, thing, eventDescriptorTemplate)
                    return;
                })
                page.backPressed.connect(function() {rule.destroy(); root.done();})
                return;
            }

            // Fill in TimeDescriptor
            if (ruleTemplate.timeDescriptorTemplate !== null) {
                print("RuleFromTemplate: Filling timeDescriptor.", rule.timeDescriptor.calendarItems.count, ruleTemplate.timeDescriptorTemplate.calendarItemTemplates.count);
                for (var i = rule.timeDescriptor.calendarItems.count; i < ruleTemplate.timeDescriptorTemplate.calendarItemTemplates.count; i++) {
                    print("Need more CalendarItems");
                    var calendarItemTemplate = ruleTemplate.timeDescriptorTemplate.calendarItemTemplates.get(i);
                    var calendarItem = calendarItemTemplate.createCalendarItem();
                    if (!calendarItemTemplate.editable) {
                        rule.timeDescriptor.calendarItems.addCalendarItem(calendarItem);
                        fillRuleFromTemplate(rule, ruleTemplate);
                        return;
                    }

                    var page = pageStack.push(Qt.resolvedUrl("EditCalendarItemPage.qml"), {calendarItem: calendarItem})
                    page.done.connect(function() {
                        rule.timeDescriptor.calendarItems.addCalendarItem(calendarItem);
                        fillRuleFromTemplate(rule, ruleTemplate);
                    });
                    page.backPressed.connect(function() {rule.destroy(); root.done();});
                    return;
                }

                for (var i = rule.timeDescriptor.timeEventItems.count; i < ruleTemplate.timeDescriptorTemplate.timeEventItemTemplates.count; i++) {
                    print("Need more TimeEventItems");
                    var timeEventItemTemplate = ruleTemplate.timeDescriptorTemplate.timeEventItemTemplates.get(i);
                    var timeEventItem = timeEventItemTemplate.createTimeEventItem();
                    if (!timeEventItemTemplate.editable) {
                        rule.timeDescriptor.timeEventItems.addTimeEventItem(timeEventItem);
                        fillRuleFromTemplate(rule, ruleTemplate);
                        return;
                    }

                    var page = pageStack.push(Qt.resolvedUrl("EditTimeEventItemPage.qml"), {timeEventItem: timeEventItem});
                    page.done.connect(function() {
                        rule.timeDescriptor.timeEventItems.addTimeEventItem(timeEventItem);
                        fillRuleFromTemplate(rule, ruleTemplate);
                    })
                    page.backPressed.connect(function() {rule.destroy(); root.done()});
                    return;
                }
            }

            // Fill in StateEvaluator
            if (ruleTemplate.stateEvaluatorTemplate !== null) {
                print("RuleFromTemplate: Filling stateEvaluator")
                if (rule.stateEvaluator === null) {
                    var stateEvaluator = rule.createStateEvaluator();
                    rule.setStateEvaluator(stateEvaluator);
                    fillStateEvaluatorFromTemplate(rule, ruleTemplate, stateEvaluator, ruleTemplate.stateEvaluatorTemplate);
                    return;
                }
                var more = fillStateEvaluatorFromTemplate(rule, ruleTemplate, rule.stateEvaluator, ruleTemplate.stateEvaluatorTemplate);
                if (more) {
                    return;
                }
            }

            for (var i = rule.actions.count; i < ruleTemplate.ruleActionTemplates.count; i++) {
                var ruleActionTemplate = ruleTemplate.ruleActionTemplates.get(i);
                print("RuleFromTemplate: Filling ruleAction:", ruleActionTemplate.interfaceName, ruleActionTemplate.actionName, ruleActionTemplate.selectionId)

                if (ruleActionTemplate.selectionMode === RuleActionTemplate.SelectionModeInterface) {
                    // TODO: Implement blacklist for interface based actions
                    var ruleAction = rule.actions.createNewRuleAction();
                    ruleAction.interfaceName = ruleActionTemplate.interfaceName;
                    ruleAction.interfaceAction = ruleActionTemplate.actionName;
                    for (var j = 0; j < ruleActionTemplate.ruleActionParamTemplates.count; j++) {
                        var ruleActionParam = ruleActionTemplate.ruleActionParamTemplates.get(j)
                        ruleAction.ruleActionParams.setRuleActionParamByName(ruleActionParam.paramName, ruleActionParam.value)
                    }
                    selectedInterfaces[ruleActionTemplate.selectionId] = ruleAction.interfaceName;
                    rule.actions.addRuleAction(ruleAction);
                    fillRuleFromTemplate(rule, ruleTemplate);
                    return;
                }

                // Did we pick a thing for this index before?
                if (ruleActionTemplate.selectionId in selectedThings) {
                    var thing = engine.thingManager.things.getThing(selectedThings[ruleActionTemplate.selectionId]);
                    print("Already have a thing for selectionId", ruleActionTemplate.selectionId, ":", thing.name)
                    createRuleAction(rule, ruleTemplate, rule.actions, [thing], ruleActionTemplate)
                    return;
                }

                // Did we already use the thing we opened this page from?
                if (root.thing && !thingIsUsed(root.thing.id) && root.thingClass.interfaces.indexOf(ruleActionTemplate.interfaceName) >= 0) {
                    print("Root thing is matching and not used. Using for selectionId", ruleActionTemplate.selectionId, ":", root.thing.name)
                    selectedThings[ruleActionTemplate.selectionId] = root.thing.id;
                    selectedThingNames[ruleActionTemplate.selectionId] = root.thing.name;
                    createRuleAction(rule, ruleTemplate, rule.actions, [root.thing], ruleActionTemplate)
                    return;
                }

                // Ok, we need to pick a thing
                var multipleSelection = ruleActionTemplate.selectionMode === RuleActionTemplate.SelectionModeDevices;
                var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {shownInterfaces: [ruleActionTemplate.interfaceName], requiredActionName: ruleActionTemplate.actionName, multipleSelection: multipleSelection});
                page.thingSelected.connect(function(thing) {
                    selectedThings[ruleActionTemplate.selectionId] = thing.id;
                    selectedThingNames[ruleActionTemplate.selectionId] = thing.name;
                    createRuleAction(rule, ruleTemplate, rule.actions, [thing], ruleActionTemplate)
                })
                page.thingsSelected.connect(function(things) {
                    var names = []
                    for (var i = 0; i < things.length; i++) {
                         names.push(things[i].name)
                    }
                    selectedThingNames[ruleActionTemplate.selectionId] = names.join(", ");

                    createRuleAction(rule, ruleTemplate, rule.actions, things, ruleActionTemplate)
                });

                page.backPressed.connect(function() {rule.destroy(); root.done();})
                return;
            }


            for (var i = rule.exitActions.count; i < ruleTemplate.ruleExitActionTemplates.count; i++) {
                var ruleExitActionTemplate = ruleTemplate.ruleExitActionTemplates.get(i);

                if (ruleExitActionTemplate.selectionMode === RuleActionTemplate.SelectionModeInterface) {
                    // TODO: Implement blacklist for interface based actions
                    var ruleExitAction = rule.exitActions.createNewRuleAction();
                    ruleExitAction.interfaceName = ruleExitActionTemplate.interfaceName;
                    ruleExitAction.interfaceAction = ruleExitActionTemplate.actionName;
                    for (var j = 0; j < ruleExitActionTemplate.ruleActionParamTemplates.count; j++) {
                        var ruleActionParam = ruleExitActionTemplate.ruleActionParamTemplates.get(j)
                        ruleExitAction.ruleActionParams.setRuleActionParam(ruleActionParam.paramName, ruleActionParam.value)
                    }
                    selectedInterfaces[ruleExitActionTemplate.selectionId] = ruleExitAction.interfaceName;
                    rule.exitActions.addRuleAction(ruleExitAction);
                    fillRuleFromTemplate(rule, ruleTemplate);
                    return;
                }

                // Did we pick a thing for this index before?
                if (ruleExitActionTemplate.selectionId in selectedThings) {
                    var thing = engine.thingManager.things.getThing(selectedThings[ruleExitActionTemplate.selectionId]);
                    createRuleAction(rule, ruleTemplate, rule.exitActions, [thing], ruleExitActionTemplate);
                    return;
                }

                // Did we already use the thing we opened this page from?
                if (root.thing && !thingIsUsed(root.thing.id) && root.thingClass.interfaces.indexOf(ruleExitActionTemplate.interfaceName) >= 0) {
                    selectedThings[ruleExitActionTemplate.selectionId] = root.thing.id;
                    selectedThingNames[ruleExitActionTemplate.selectionId] = root.thing.name;
                    createRuleAction(rule, ruleTemplate, rule.exitActions, [root.thing], ruleExitActionTemplate);
                    return;
                }

                // Ok, we need to pick a thing
                var multipleSelection = ruleActionTemplate.selectionMode === RuleActionTemplate.SelectionModeDevices;
                var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {shownInterfaces: [ruleExitActionTemplate.interfaceName], requiredActionName: ruleExitActionTemplate.actionName, multipleSelection: multipleSelection});
                page.thingSelected.connect(function(thing) {
                    selectedThings[ruleExitActionTemplate.selectionId] = thing.id;
                    selectedThingNames[ruleExitActionTemplate.selectionId] = thing.name;
                    createRuleAction(rule, ruleTemplate, rule.exitActions, [thing], ruleExitActionTemplate);
                    return;
                })
                page.thingsSelected.connect(function(things) {
                    var names = []
                    for (var i = 0; i < things.length; i++) {
                         names.push(things[i].name)
                    }
                    selectedThingNames[ruleExitActionTemplate.selectionId] = things.join(", ");
                    createRuleAction(rule, ruleTemplate, rule.exitActions, [things], ruleExitActionTemplate);
                });
                page.backPressed.connect(function() {rule.destroy(); root.done();})
                return;
            }


            // Now replace %i in title and action params with selectedThingNames[id]
            rule.name = ruleTemplate.ruleNameTemplate;
            for (var selectionId in selectedThingNames) {
                print("Replacing", selectionId, "with", selectedThingNames[selectionId], selectedInterfaces[selectionId])
                var thingName = selectedThingNames[selectionId];
                rule.name = rule.name.replace("%" + selectionId, thingName)

                for (var j = 0; j < rule.actions.count; j++) {
                    var action = rule.actions.get(j);
                    for(var k = 0; k < action.ruleActionParams.count; k++) {
                        var actionParam = action.ruleActionParams.get(k);
                        print("replacing args", typeof actionParam.value)
                        if (typeof actionParam.value === "string") {
                            actionParam.value = actionParam.value.replace("%" + selectionId, thingName);
                            actionParam.value = actionParam.value.replace("$" + selectionId, selectedThings[selectionId]);
                        }
                    }
                }
                for (var j = 0; j < rule.exitActions.count; j++) {
                    var action = rule.exitActions.get(j);
                    for(var k = 0; k < action.ruleActionParams.count; k++) {
                        var actionParam = action.ruleActionParams.get(k);
                        if (typeof actionParam.value === "string") {
                            actionParam.value = actionParam.value.replace("%" + selectionId, thingName);
                            actionParam.value = actionParam.value.replace("$" + selectionId, selectedThings[selectionId]);
                        }
                    }
                }
            }
            for (selectionId in selectedInterfaces) {
                rule.name = rule.name.replace("%" + selectionId, qsTr("any " + app.interfaceToDisplayName(selectedInterfaces[selectionId])))
                for (var j = 0; j < rule.actions.count; j++) {
                    var action = rule.actions.get(j);
                    for(var k = 0; k < action.ruleActionParams.count; k++) {
                        var actionParam = action.ruleActionParams.get(k);
                        print("replacing args", typeof actionParam.value)
                        if (typeof actionParam.value === "string") {
                            actionParam.value = actionParam.value.replace("%" + selectionId, qsTr("A thing"));
                        }
                    }
                }
                for (var j = 0; j < rule.exitActions.count; j++) {
                    var action = rule.exitActions.get(j);
                    for(var k = 0; k < action.ruleActionParams.count; k++) {
                        var actionParam = action.ruleActionParams.get(k);
                        if (typeof actionParam.value === "string") {
                            actionParam.value = actionParam.value.replace("%" + selectionId, qsTr("A thing"));
                        }
                    }
                }
            }

            print("Rule complete!")
            engine.ruleManager.addRule(rule);
            rule.destroy();
            print("emitting done")
            root.done();
        }

        function fillStateEvaluatorFromTemplate(rule, ruleTemplate, stateEvaluator, stateEvaluatorTemplate) {
            if (stateEvaluatorTemplate.stateDescriptorTemplate !== null && !thingIsUsed(stateEvaluator.stateDescriptor.thingId) && stateEvaluator.stateDescriptor.interfaceName.length === 0) {
                // need to fill stateDescriptor

                print("filling in state evaluator for selection mode:", stateEvaluatorTemplate.stateDescriptorTemplate.selectionMode)
                if (stateEvaluatorTemplate.stateDescriptorTemplate.selectionMode === StateDescriptor.SelectionModeInterface) {
                    stateEvaluator.stateDescriptor.interfaceName = stateEvaluatorTemplate.stateDescriptorTemplate.interfaceName;
                    stateEvaluator.stateDescriptor.interfaceState = stateEvaluatorTemplate.stateDescriptorTemplate.stateName;
                    stateEvaluator.stateDescriptor.valueOperator = stateEvaluatorTemplate.stateDescriptorTemplate.valueOperator;
                    stateEvaluator.stateDescriptor.value = stateEvaluatorTemplate.stateDescriptorTemplate.value;
                    selectedInterfaces[stateEvaluatorTemplate.stateDescriptorTemplate.selectionId] = stateEvaluator.stateDescriptor.interfaceName;
                    fillRuleFromTemplate(rule, ruleTemplate);
                    return true;
                }

                // did we pick a thing for this index before?
                if (stateEvaluatorTemplate.stateDescriptorTemplate.selectionId in selectedThings) {
                    var thingId = selectedThings[stateEvaluatorTemplate.stateDescriptorTemplate.selectionId]
                    var thing = engine.thingManager.things.getThing(thingId)
                    stateEvaluator.stateDescriptor.thingId = thingId;
                    stateEvaluator.stateDescriptor.stateTypeId = thing.thingClass.stateTypes.findByName(stateEvaluatorTemplate.stateDescriptorTemplate.stateName).id
                    stateEvaluator.stateDescriptor.valueOperator = stateEvaluatorTemplate.stateDescriptorTemplate.valueOperator;
                    stateEvaluator.stateDescriptor.value = stateEvaluatorTemplate.stateDescriptorTemplate.value;
                    fillRuleFromTemplate(rule, ruleTemplate);
                    return true;
                }
                if (root.thing && !thingIsUsed(root.thing.id) && root.thingClass.interfaces.indexOf(stateEvaluatorTemplate.stateDescriptorTemplate.interfaceName) >= 0) {
                    stateEvaluator.stateDescriptor.thingId = root.thing.id;
                    stateEvaluator.stateDescriptor.stateTypeId = root.thingClass.stateTypes.findByName(stateEvaluatorTemplate.stateDescriptorTemplate.stateName).id
                    stateEvaluator.stateDescriptor.valueOperator = stateEvaluatorTemplate.stateDescriptorTemplate.valueOperator;
                    stateEvaluator.stateDescriptor.value = stateEvaluatorTemplate.stateDescriptorTemplate.value;
                    selectedThings[stateEvaluatorTemplate.stateDescriptorTemplate.selectionId] = root.thing.id;
                    selectedThingNames[stateEvaluatorTemplate.stateDescriptorTemplate.selectionId] = root.thing.name;
                    fillRuleFromTemplate(rule, ruleTemplate);
                    return true;
                }
                print("opening SelectThingPage for shownInterfaces:")
                print("..", stateEvaluatorTemplate.stateDescriptorTemplate.interfaceName)
                var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {shownInterfaces: [stateEvaluatorTemplate.stateDescriptorTemplate.interfaceName], requiredStateName: stateEvaluatorTemplate.stateDescriptorTemplate.stateName, allowSelectAny: stateEvaluatorTemplate.stateDescriptorTemplate.selectionMode === StateDescriptorTemplate.SelectionModeAny});
                page.thingSelected.connect(function(thing) {
                    stateEvaluator.stateDescriptor.thingId = thing.id;
                    stateEvaluator.stateDescriptor.stateTypeId = thing.thingClass.stateTypes.findByName(stateEvaluatorTemplate.stateDescriptorTemplate.stateName).id;
                    stateEvaluator.stateDescriptor.valueOperator = stateEvaluatorTemplate.stateDescriptorTemplate.valueOperator;
                    stateEvaluator.stateDescriptor.value = stateEvaluatorTemplate.stateDescriptorTemplate.value;
                    selectedThings[stateEvaluatorTemplate.stateDescriptorTemplate.selectionId] = thing.id;
                    selectedThingNames[stateEvaluatorTemplate.stateDescriptorTemplate.selectionId] = thing.name;
                    fillRuleFromTemplate(rule, ruleTemplate)
                })
                page.onAnySelected.connect(function() {
                    stateEvaluator.stateDescriptor.interfaceName = stateEvaluatorTemplate.stateDescriptorTemplate.interfaceName;
                    stateEvaluator.stateDescriptor.interfaceState = stateEvaluatorTemplate.stateDescriptorTemplate.stateName;
                    stateEvaluator.stateDescriptor.valueOperator = stateEvaluatorTemplate.stateDescriptorTemplate.valueOperator;
                    stateEvaluator.stateDescriptor.value = stateEvaluatorTemplate.stateDescriptorTemplate.value;
                    selectedInterfaces[stateEvaluatorTemplate.stateDescriptorTemplate.selectionId] = stateEvaluator.stateDescriptor.interfaceName;
                    fillRuleFromTemplate(rule, ruleTemplate);
                })
                page.backPressed.connect(function() {rule.destroy(); root.done();})
                return true;
            }
            stateEvaluator.stateOperator = stateEvaluatorTemplate.stateOperator;
            print("Added stateOperator", stateEvaluator.stateOperator)
            if (stateEvaluatorTemplate.childEvaluatorTemplates.count > stateEvaluator.childEvaluators.count) {
                print("Adding more child evaluators. Have:", stateEvaluator.childEvaluators.count, "need:", stateEvaluatorTemplate.childEvaluatorTemplates.count)
                print("getting", stateEvaluator.childEvaluators.count)
                print("getting", stateEvaluatorTemplate.childEvaluatorTemplates.get(stateEvaluator.childEvaluators.count))
                var childEvaluator = rule.createStateEvaluator();
                stateEvaluator.childEvaluators.addStateEvaluator(childEvaluator);
                var more = fillStateEvaluatorFromTemplate(rule, ruleTemplate, childEvaluator, stateEvaluatorTemplate.childEvaluatorTemplates.get(stateEvaluator.childEvaluators.count-1))
                return more;
            }
            return false;
        }

        function createEventDescriptor(rule, ruleTemplate, thing, eventDescriptorTemplate) {
            var eventDescriptor = rule.eventDescriptors.createNewEventDescriptor();
            eventDescriptor.thingId = thing.id;
            var eventType = thing.thingClass.eventTypes.findByName(eventDescriptorTemplate.eventName)
            var stateType = thing.thingClass.stateTypes.findByName(eventDescriptorTemplate.eventName)
            var needsParams = false;
            print("Creating event descriptor from template:", eventDescriptorTemplate.interfaceName, eventDescriptorTemplate.eventName, thing.name, eventType, stateType)
            if (eventType) {
                eventDescriptor.eventTypeId = eventType.id

                for (var j = 0; j < eventType.paramTypes.count; j++) {
                    var paramType = eventType.paramTypes.get(j);
                    var paramDescriptorTemplate = eventDescriptorTemplate.paramDescriptors.getParamDescriptorByName(paramType.name)
                    // has the template a value for this? If so, set it, otherwise flag as needsParams
                    print("template:", paramType.id, eventDescriptorTemplate.paramDescriptors.count)
                    if (paramDescriptorTemplate && paramDescriptorTemplate.value !== undefined) {
                        print("filling in param descriptor:", paramDescriptorTemplate.value)
                        eventDescriptor.paramDescriptors.setParamDescriptorByName(paramDescriptorTemplate.paramName, paramDescriptorTemplate.value, paramDescriptorTemplate.operatorType);
                    } else {
                        needsParams = true;
                    }
                }
            } else if (stateType) {
                eventDescriptor.eventTypeId = stateType.id
                var paramType = stateType.id
                var paramDescriptorTemplate = eventDescriptorTemplate.paramDescriptors.getParamDescriptorByName(stateType.name)
                // has the template a value for this? If so, set it, otherwise flag as needsParams
                print("template:", paramType.id, eventDescriptorTemplate.paramDescriptors.count)
                if (paramDescriptorTemplate && paramDescriptorTemplate.value !== undefined) {
                    print("filling in param descriptor:", paramDescriptorTemplate.value)
                    eventDescriptor.paramDescriptors.setParamDescriptorByName(paramDescriptorTemplate.paramName, paramDescriptorTemplate.value, paramDescriptorTemplate.operatorType);
                } else {
                    needsParams = true;
                }
            }

            if (needsParams) {
                var page = pageStack.push(Qt.resolvedUrl("SelectEventDescriptorParamsPage.qml"), { eventDescriptor: eventDescriptor })
                page.completed.connect(function() {
                    rule.eventDescriptors.addEventDescriptor(eventDescriptor);
                    fillRuleFromTemplate(rule, ruleTemplate);
                })
                page.onBackPressed.connect(function() {
                    eventDescriptor.destroy();
                    pageStack.pop();
                });
                return;
            }
            rule.eventDescriptors.addEventDescriptor(eventDescriptor);
            fillRuleFromTemplate(rule, ruleTemplate);
        }

        function createRuleAction(rule, ruleTemplate, ruleActions, things, ruleActionTemplate) {

            var thing = things.shift();
            // thing param -> things
            // take first, run code
            // at end, if things is empty, continue with fillRuleFromTemplate otherwise run again

            var ruleAction = ruleActions.createNewRuleAction();

            ruleAction.actionTypeId = thing.thingClass.actionTypes.findByName(ruleActionTemplate.actionName).id
            ruleAction.thingId = thing.id;
            print("Creating action", ruleActionTemplate.actionName, "on thing class", thing.thingClass.displayName)

            var actionType = thing.thingClass.actionTypes.getActionType(ruleAction.actionTypeId);

            for (var j = 0; j < ruleActionTemplate.ruleActionParamTemplates.count; j++) {
                var ruleActionParamTemplate = ruleActionTemplate.ruleActionParamTemplates.get(j)
                var paramType = actionType.paramTypes.findByName(ruleActionParamTemplate.paramName);
                if (!paramType) {
                    print("Skipping template action param", ruleActionParamTemplate, "as action type does not have this param")
                    continue;
                }

                if (ruleActionParamTemplate.value !== undefined) {
                    ruleAction.ruleActionParams.setRuleActionParam(paramType.id, ruleActionParamTemplate.value)
                } else if (ruleActionParamTemplate.eventInterface && ruleActionParamTemplate.eventName && ruleActionParamTemplate.eventParamName) {
                    print("should create rule action param from interface", ruleActionParamTemplate.eventInterface, ruleActionParamTemplate.eventName, ruleActionParamTemplate.eventParamName)
                    // find matching eventDescriptor
                    var eventDescriptorTemplate = null;
                    for (var k = 0; k < ruleTemplate.eventDescriptorTemplates.count; k++) {
                        var tmp = ruleTemplate.eventDescriptorTemplates.get(k);
                        print("evaluating eventDescriptor", tmp.interfaceName)
                        if (tmp.interfaceName === ruleActionParamTemplate.eventInterface && tmp.eventName === ruleActionParamTemplate.eventName) {
                            eventDescriptorTemplate = tmp;
                            break;
                        }
                    }
                    if (eventDescriptorTemplate === null) {
                        console.warn("Unable to find an event matching the criteria:", ruleActionParamTemplate.eventInterface, ruleActionParamTemplate.eventName, ruleActionParamTemplate.eventParamName)
                        break
                    }
                    print("selected thing:", selectedThings, eventDescriptorTemplate.selectionId)
                    var eventThing = engine.thingManager.things.getThing(selectedThings[eventDescriptorTemplate.selectionId])
                    var eventType = eventThing.thingClass.eventTypes.findByName(ruleActionParamTemplate.eventName);
                    var eventParamType = eventType.paramTypes.findByName(ruleActionParamTemplate.eventParamName);

                    ruleAction.ruleActionParams.setRuleActionParamEvent(paramType.id, eventType.id, eventParamType.id)
                } else {
                    console.warn("Invalid RuleActionParamTemplate. Has neither value nor event spec")
                }
            }
            // Check if the action has more paramTypes than there are defined in the ruleActionTemplate
            for (var i = 0; i < actionType.paramTypes.count; i++) {
                var paramType = actionType.paramTypes.get(i);
                if (!ruleAction.ruleActionParams.hasRuleActionParam(paramType.id)) {
                    print("Missing param!", paramType.name)
                    var paramsPage = pageStack.push(Qt.resolvedUrl("SelectRuleActionParamsPage.qml"), {ruleAction: ruleAction, rule: rule})
                    paramsPage.onBackPressed.connect(function() {
                        ruleAction.destroy()
                        pageStack.pop();
                    });
                    paramsPage.onCompleted.connect(function() {
                        pageStack.pop();
                        ruleActions.addRuleAction(ruleAction);
                        if (things.length === 0) {
                            fillRuleFromTemplate(rule, ruleTemplate);
                        } else {
                            createRuleAction(rule, ruleTemplate, rule.actions, things, ruleActionTemplate)
                        }
                    })
                    return;
                }
            }

            ruleActions.addRuleAction(ruleAction);
            if (things.length === 0) {
                fillRuleFromTemplate(rule, ruleTemplate);
            } else {
                createRuleAction(rule, ruleTemplate, rule.actions, things, ruleActionTemplate)
            }
        }

        function thingIsUsed(thingId) {
            for (var key in selectedThings) {
                if (selectedThings.hasOwnProperty(key) && selectedThings[key] === thingId) {
                    return true;
                }
            }
            return false;
        }
    }

    header: NymeaHeader {
        text: root.thing ? qsTr("New magic for %1").arg(root.thing.name) : qsTr("New magic")
        onBackPressed: root.done()
    }

    ColumnLayout {
        anchors.fill: parent
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: RuleTemplatesFilterModel {
                id: ruleTemplatesModel
                ruleTemplates: RuleTemplates {}
                filterByThings: ThingsProxy {
                    engine: _engine
                }

                filterInterfaceNames: root.thing ? root.thing.thingClass.interfaces : []
            }
            delegate: NymeaSwipeDelegate {
                width: parent.width
                text: model.description
                iconName: app.interfacesToIcon(model.interfaces)

                onClicked: {
                    var ruleTemplate = ruleTemplatesModel.get(index);
                    root.createRuleFromTemplate(ruleTemplate)
                }
            }
        }

        ThinDivider {}

        Button {
            Layout.fillWidth: true
            Layout.margins: app.margins
            text: qsTr("Create some magic manually")
            onClicked: {
                root.manualCreation();
            }
        }
    }
}
