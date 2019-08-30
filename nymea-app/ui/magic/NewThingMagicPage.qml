import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {
    id: root

    property Device device: null
    readonly property DeviceClass deviceClass: device ? device.deviceClass : null
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
        property var selectedInterfaces: ({})

        function fillRuleFromTemplate(rule, ruleTemplate) {
            print("***** Filling rule")

            // Fill in all EventDescriptors
            for (var i = rule.eventDescriptors.count; i < ruleTemplate.eventDescriptorTemplates.count; i++) {
                var eventDescriptorTemplate = ruleTemplate.eventDescriptorTemplates.get(i);
                print("RuleFromTemplate: Filling eventDescriptor:", eventDescriptorTemplate.interfaceName, eventDescriptorTemplate.interfaceEvent, eventDescriptorTemplate.selectionId)
                // If we already have a thing selected for this selectionIndex, use that
                if (eventDescriptorTemplate.selectionId in selectedThings) {
                    var device = engine.deviceManager.devices.getDevice(selectedThings[eventDescriptorTemplate.selectionId]);
                    print("Already have a device for selectionId", eventDescriptorTemplate.selectionId, ":", device.name)
                    createEventDescriptor(rule, ruleTemplate, device, eventDescriptorTemplate)
                    return;
                }
                // Ok, we didn't pick a thing for this selectionId before. Did we already use the one we opened this page from?
                if (root.device && !deviceIsUsed(root.device.id) && root.deviceClass.interfaces.indexOf(eventDescriptorTemplate.interfaceName) >= 0) {
                    print("Root device is matching and not used. Using for selectionId", eventDescriptorTemplate.selectionId, ":", root.device.name)
                    selectedThings[eventDescriptorTemplate.selectionId] = root.device.id;
                    createEventDescriptor(rule, ruleTemplate, root.device, eventDescriptorTemplate)
                    return;
                }

                // We need to pick a thing
                print("We need to pick a new device for selectionId", eventDescriptorTemplate.selectionId)
                var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {shownInterfaces: [eventDescriptorTemplate.interfaceName]});
                page.thingSelected.connect(function(device) {
                    selectedThings[eventDescriptorTemplate.selectionId] = device.id;
                    createEventDescriptor(rule, ruleTemplate, device, eventDescriptorTemplate)
                    return;
                })
                page.backPressed.connect(function() {rule.destroy(); root.done();})
                return;
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
                print("RuleFromTemplate: Filling ruleAction:", ruleActionTemplate.interfaceName, ruleActionTemplate.interfaceAction, ruleActionTemplate.selectionId)

                if (ruleActionTemplate.selectionMode === RuleActionTemplate.SelectionModeInterface) {
                    // TODO: Implement blacklist for interface based actions
                    var ruleAction = rule.actions.createNewRuleAction();
                    ruleAction.interfaceName = ruleActionTemplate.interfaceName;
                    ruleAction.interfaceAction = ruleActionTemplate.interfaceAction;
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
                    var device = engine.deviceManager.devices.getDevice(selectedThings[ruleActionTemplate.selectionId]);
                    print("Already have a device for selectionId", ruleActionTemplate.selectionId, ":", device.name)
                    createRuleAction(rule, ruleTemplate, rule.actions, device, ruleActionTemplate)
                    return;
                }

                // Did we already use the thing we opened this page from?
                if (root.device && !deviceIsUsed(root.device.id) && root.deviceClass.interfaces.indexOf(ruleActionTemplate.interfaceName) >= 0) {
                    print("Root device is matching and not used. Using for selectionId", ruleActionTemplate.selectionId, ":", root.device.name)
                    selectedThings[ruleActionTemplate.selectionId] = root.device.id;
                    createRuleAction(rule, ruleTemplate, rule.actions, root.device, ruleActionTemplate)
                    return;
                }

                // Ok, we need to pick a thing
//              print("Need to select a thing.")
                var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {shownInterfaces: [ruleActionTemplate.interfaceName]});
                page.thingSelected.connect(function(device) {
                    selectedThings[ruleActionTemplate.selectionId] = device.id;
                    createRuleAction(rule, ruleTemplate, rule.actions, device, ruleActionTemplate)
                    return;
                })
                page.backPressed.connect(function() {rule.destroy(); root.done();})
                return;
            }


            for (var i = rule.exitActions.count; i < ruleTemplate.ruleExitActionTemplates.count; i++) {
                var ruleExitActionTemplate = ruleTemplate.ruleExitActionTemplates.get(i);

                if (ruleExitActionTemplate.selectionMode === RuleActionTemplate.SelectionModeInterface) {
                    // TODO: Implement blacklist for interface based actions
                    var ruleExitAction = rule.exitActions.createNewRuleAction();
                    ruleExitAction.interfaceName = ruleExitActionTemplate.interfaceName;
                    ruleExitAction.interfaceAction = ruleExitActionTemplate.interfaceAction;
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
                    var device = engine.deviceManager.devices.getDevice(selectedThings[ruleExitActionTemplate.selectionId]);
                    createRuleAction(rule, ruleTemplate, rule.exitActions, device, ruleExitActionTemplate);
                    return;
                }

                // Did we already use the thing we opened this page from?
                if (root.device && !deviceIsUsed(root.device.id) && root.deviceClass.interfaces.indexOf(ruleExitActionTemplate.interfaceName) >= 0) {
                    selectedThings[ruleExitActionTemplate.selectionId] = root.device.id;
                    createRuleAction(rule, ruleTemplate, rule.exitActions, root.device, ruleExitActionTemplate);
                    return;
                }

                // Ok, we need to pick a thing
                var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {shownInterfaces: [ruleExitActionTemplate.interfaceName]});
                page.thingSelected.connect(function(device) {
                    selectedThings[ruleExitActionTemplate.selectionId] = device.id;
                    createRuleAction(rule, ruleTemplate, rule.exitActions, device, ruleExitActionTemplate);
                    return;
                })
                page.backPressed.connect(function() {rule.destroy(); root.done();})
                return;
            }


            // Now replace %i in title and action params with selectedThings[i].name
            rule.name = ruleTemplate.ruleNameTemplate;
            for (var selectionId in selectedThings) {
                print("Replacing", selectionId, "with", selectedThings[selectionId], selectedInterfaces[selectionId])
                var device = engine.deviceManager.devices.getDevice(selectedThings[selectionId]);
                rule.name = rule.name.replace("%" + selectionId, device.name)

                for (var j = 0; j < rule.actions.count; j++) {
                    var action = rule.actions.get(j);
                    for(var k = 0; k < action.ruleActionParams.count; k++) {
                        var actionParam = action.ruleActionParams.get(k);
                        print("replacing args", typeof actionParam.value)
                        if (typeof actionParam.value === "string") {
                            actionParam.value = actionParam.value.replace("%" + selectionId, device.name);
                        }
                    }
                }
                for (var j = 0; j < rule.exitActions.count; j++) {
                    var action = rule.exitActions.get(j);
                    for(var k = 0; k < action.ruleActionParams.count; k++) {
                        var actionParam = action.ruleActionParams.get(k);
                        if (typeof actionParam.value === "string") {
                            actionParam.value = actionParam.value.replace("%" + selectionId, device.name);
                        }
                    }
                }
            }
            for (selectionId in selectedInterfaces) {
                rule.name = rule.name.replace("%" + selectionId, qsTr("any " + app.interfaceToDisplayName(selectedInterfaces[selectionId])))
            }

            print("Rule complete!")
            engine.ruleManager.addRule(rule);
            rule.destroy();
            print("emitting done")
            root.done();
        }

        function fillStateEvaluatorFromTemplate(rule, ruleTemplate, stateEvaluator, stateEvaluatorTemplate) {
            if (stateEvaluatorTemplate.stateDescriptorTemplate !== null && !deviceIsUsed(stateEvaluator.stateDescriptor.deviceId) && stateEvaluator.stateDescriptor.interfaceName.length === 0) {
                // need to fill stateDescriptor

                print("filling in state evaluator for selection mode:", stateEvaluatorTemplate.stateDescriptorTemplate.selectionMode)
                if (stateEvaluatorTemplate.stateDescriptorTemplate.selectionMode === StateDescriptor.SelectionModeInterface) {
                    stateEvaluator.stateDescriptor.interfaceName = stateEvaluatorTemplate.stateDescriptorTemplate.interfaceName;
                    stateEvaluator.stateDescriptor.interfaceState = stateEvaluatorTemplate.stateDescriptorTemplate.interfaceState;
                    stateEvaluator.stateDescriptor.valueOperator = stateEvaluatorTemplate.stateDescriptorTemplate.valueOperator;
                    stateEvaluator.stateDescriptor.value = stateEvaluatorTemplate.stateDescriptorTemplate.value;
                    selectedInterfaces[stateEvaluatorTemplate.stateDescriptorTemplate.selectionId] = stateEvaluator.stateDescriptor.interfaceName;
                    fillRuleFromTemplate(rule, ruleTemplate);
                    return true;
                }

                // did we pick a thing for this index before?
                if (stateEvaluatorTemplate.stateDescriptorTemplate.selectionId in selectedThings) {
                    var deviceId = selectedThings[stateEvaluatorTemplate.stateDescriptorTemplate.selectionId]
                    var device = engine.deviceManager.devices.getDevice(deviceId)
                    var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                    stateEvaluator.stateDescriptor.deviceId = deviceId;
                    stateEvaluator.stateDescriptor.stateTypeId = deviceClass.stateTypes.findByName(stateEvaluatorTemplate.stateDescriptorTemplate.interfaceState).id
                    stateEvaluator.stateDescriptor.valueOperator = stateEvaluatorTemplate.stateDescriptorTemplate.valueOperator;
                    stateEvaluator.stateDescriptor.value = stateEvaluatorTemplate.stateDescriptorTemplate.value;
                    fillRuleFromTemplate(rule, ruleTemplate);
                    return true;
                }
                if (root.device && !deviceIsUsed(root.device.id) && root.deviceClass.interfaces.indexOf(stateEvaluatorTemplate.stateDescriptorTemplate.interfaceName) >= 0) {
                    stateEvaluator.stateDescriptor.deviceId = root.device.id;
                    stateEvaluator.stateDescriptor.stateTypeId = root.deviceClass.stateTypes.findByName(stateEvaluatorTemplate.stateDescriptorTemplate.interfaceState).id
                    stateEvaluator.stateDescriptor.valueOperator = stateEvaluatorTemplate.stateDescriptorTemplate.valueOperator;
                    stateEvaluator.stateDescriptor.value = stateEvaluatorTemplate.stateDescriptorTemplate.value;
                    selectedThings[stateEvaluatorTemplate.stateDescriptorTemplate.selectionId] = root.device.id;
                    fillRuleFromTemplate(rule, ruleTemplate);
                    return true;
                }
                print("opening SelectThingPage for shownInterfaces:")
                print("..", stateEvaluatorTemplate.stateDescriptorTemplate.interfaceName)
                var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {shownInterfaces: [stateEvaluatorTemplate.stateDescriptorTemplate.interfaceName], allowSelectAny: stateEvaluatorTemplate.stateDescriptorTemplate.selectionMode === StateDescriptorTemplate.SelectionModeAny});
                page.thingSelected.connect(function(device) {
                    var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                    stateEvaluator.stateDescriptor.deviceId = device.id;
                    stateEvaluator.stateDescriptor.stateTypeId = deviceClass.stateTypes.findByName(stateEvaluatorTemplate.stateDescriptorTemplate.interfaceState).id;
                    stateEvaluator.stateDescriptor.valueOperator = stateEvaluatorTemplate.stateDescriptorTemplate.valueOperator;
                    stateEvaluator.stateDescriptor.value = stateEvaluatorTemplate.stateDescriptorTemplate.value;
                    selectedThings[stateEvaluatorTemplate.stateDescriptorTemplate.selectionId] = device.id;
                    fillRuleFromTemplate(rule, ruleTemplate)
                })
                page.onAnySelected.connect(function() {
                    stateEvaluator.stateDescriptor.interfaceName = stateEvaluatorTemplate.stateDescriptorTemplate.interfaceName;
                    stateEvaluator.stateDescriptor.interfaceState = stateEvaluatorTemplate.stateDescriptorTemplate.interfaceState;
                    stateEvaluator.stateDescriptor.valueOperator = stateEvaluatorTemplate.stateDescriptorTemplate.valueOperator;
                    stateEvaluator.stateDescriptor.value = stateEvaluatorTemplate.stateDescriptorTemplate.value;
                    selectedInterfaces[stateEvaluatorTemplate.stateDescriptorTemplate.selectionId] = stateEvaluator.stateDescriptor.interfaceName;
                    fillRuleFromTemplate(rule, ruleTemplate);
                })
                page.backPressed.connect(function() {rule.destroy(); root.done();})
                return true;
            }
            stateEvaluator.stateOperator = stateEvaluatorTemplate.stateOperator;
            if (stateEvaluatorTemplate.childEvaluatorTemplates.count > stateEvaluator.childEvaluators.count) {
                var childEvaluator = rule.createStateEvaluator();
                var more = fillStateEvaluatorFromTemplate(rule, ruleTemplate, childEvaluator, stateEvaluatorTemplate.childEvaluatorTemplates.get(stateEvaluator.childEvaluators.count))
                stateEvaluator.childEvaluators.addStateEvaluator(childEvaluator);
                return more;
            }
            return false;
        }

        function createEventDescriptor(rule, ruleTemplate, device, eventDescriptorTemplate) {
            var eventDescriptor = rule.eventDescriptors.createNewEventDescriptor();
            eventDescriptor.deviceId = device.id;
            var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
            eventDescriptor.eventTypeId = deviceClass.eventTypes.findByName(eventDescriptorTemplate.interfaceEvent).id
            var needsParams = false;

            var eventType = deviceClass.eventTypes.getEventType(eventDescriptor.eventTypeId);
            for (var j = 0; j < eventType.paramTypes.count; j++) {
                var paramType = eventType.paramTypes.get(j);
                var paramDescriptorTemplate = eventDescriptorTemplate.paramDescriptors.getParamDescriptorByName(paramType.name)
                // has the template a value for this? If so, set it, otherwise flag as needsParams
                print("template:", paramType.id, eventDescriptorTemplate.paramDescriptors.count)
                if (paramDescriptorTemplate && paramDescriptorTemplate.value !== undefined) {
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

        function createRuleAction(rule, ruleTemplate, ruleActions, device, ruleActionTemplate) {
            var ruleAction = ruleActions.createNewRuleAction();
            var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);

            ruleAction.actionTypeId = deviceClass.actionTypes.findByName(ruleActionTemplate.interfaceAction).id
            ruleAction.deviceId = device.id;
            print("Creating action", ruleActionTemplate.interfaceAction, "on device class", deviceClass.displayName)

            var actionType = deviceClass.actionTypes.getActionType(ruleAction.actionTypeId);

            for (var j = 0; j < ruleActionTemplate.ruleActionParamTemplates.count; j++) {
                var ruleActionParamTemplate = ruleActionTemplate.ruleActionParamTemplates.get(j)
                var paramType = actionType.paramTypes.findByName(ruleActionParamTemplate.paramName);
                if (ruleActionParamTemplate.value !== undefined) {
                    ruleAction.ruleActionParams.setRuleActionParam(paramType.id, ruleActionParamTemplate.value)
                } else if (ruleActionParamTemplate.eventInterface && ruleActionParamTemplate.eventName && ruleActionParamTemplate.eventParamName) {
                    print("should create rule action param from interface", ruleActionParamTemplate.eventInterface, ruleActionParamTemplate.eventName, ruleActionParamTemplate.eventParamName)
                    // find matching eventDescriptor
                    var eventDescriptorTemplate = null;
                    for (var k = 0; k < ruleTemplate.eventDescriptorTemplates.count; k++) {
                        var tmp = ruleTemplate.eventDescriptorTemplates.get(k);
                        print("evaluating eventDescriptor", tmp.interfaceName)
                        if (tmp.interfaceName === ruleActionParamTemplate.eventInterface && tmp.interfaceEvent === ruleActionParamTemplate.eventName) {
                            eventDescriptorTemplate = tmp;
                            break;
                        }
                    }
                    if (eventDescriptorTemplate === null) {
                        console.warn("Unable to find an event matching the criteria:", ruleActionParamTemplate.eventInterface, ruleActionParamTemplate.eventName, ruleActionParamTemplate.eventParamName)
                        break
                    }
                    print("selected device:", selectedThings, eventDescriptorTemplate.selectionId)
                    var eventDevice = engine.deviceManager.devices.getDevice(selectedThings[eventDescriptorTemplate.selectionId])
                    var eventDeviceClass = engine.deviceManager.deviceClasses.getDeviceClass(eventDevice.deviceClassId);
                    var eventType = eventDeviceClass.eventTypes.findByName(ruleActionParamTemplate.eventName);
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
                        fillRuleFromTemplate(rule, ruleTemplate);
                    })
                    return;
                }
            }

            ruleActions.addRuleAction(ruleAction);
            fillRuleFromTemplate(rule, ruleTemplate);
        }

        function deviceIsUsed(deviceId) {
            for (var key in selectedThings) {
                if (selectedThings.hasOwnProperty(key) && selectedThings[key] === deviceId) {
                    return true;
                }
            }
            return false;
        }
    }

    header: NymeaHeader {
        text: root.device ? qsTr("New magic for %1").arg(root.device.name) : qsTr("New magic")
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
                filterByDevices: DevicesProxy {
                    engine: _engine
                }

                filterInterfaceNames: root.device ? root.device.deviceClass.interfaces : []
            }
            delegate: NymeaListItemDelegate {
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
