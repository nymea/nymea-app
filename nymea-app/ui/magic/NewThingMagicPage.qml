import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {
    id: root

    property var device: null
    readonly property var deviceClass: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
    property bool busy: false

    signal done();
    signal manualCreation();

    function fillRuleFromTemplate(rule, ruleTemplate, selectedThings) {
        if (selectedThings === undefined) {
            selectedThings = [];
        }

        // Fill in all EventDescriptors
        for (var i = rule.eventDescriptors.count; i < ruleTemplate.eventDescriptorTemplates.count; i++) {
            var eventDescriptorTemplate = ruleTemplate.eventDescriptorTemplates.get(i);
            print("RuleFromTemplate: Filling eventDescriptor:", eventDescriptorTemplate.interfaceName, eventDescriptorTemplate.interfaceEvent, eventDescriptorTemplate.selectionId)
            // If we already have a thing selected for this selectionIndex, use that
            if (selectedThings.length > eventDescriptorTemplate.selectionId) {
                var device = engine.deviceManager.devices.getDevice(selectedThings[eventDescriptorTemplate.selectionId]);
                createEventDescriptor(rule, ruleTemplate, selectedThings, device, eventDescriptorTemplate)
                return;
            }
            // Ok, we didn't pick a thing for this selectionId before. Did we already use the one we opened this page from?
            if (selectedThings.indexOf(root.device.id) === -1 && root.deviceClass.interfaces.indexOf(eventDescriptorTemplate.interfaceName) >= 0 && eventDescriptorTemplate.interfaceName === ruleTemplate.interfaceName) {
                selectedThings.push(root.device.id);
                createEventDescriptor(rule, ruleTemplate, selectedThings, root.device, eventDescriptorTemplate)
                return;
            }

            // We need to pick a thing
            var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {shownInterfaces: [eventDescriptorTemplate.interfaceName]});
            page.thingSelected.connect(function(device) {
                selectedThings.push(device.id);
                createEventDescriptor(rule, ruleTemplate, selectedThings, device, eventDescriptorTemplate)
                return;
            })
            page.backPressed.connect(function() {rule.destroy(); root.done();})
            return;
        }

        // Fill in StateEvaluator
        if (ruleTemplate.stateEvaluatorTemplate !== null) {
            if (rule.stateEvaluator === null) {
                var stateEvaluator = rule.createStateEvaluator();
                rule.setStateEvaluator(stateEvaluator);
                fillStateEvaluatorFromTemplate(rule, ruleTemplate, stateEvaluator, ruleTemplate.stateEvaluatorTemplate, selectedThings);
                return;
            }
            var more = fillStateEvaluatorFromTemplate(rule, ruleTemplate, rule.stateEvaluator, ruleTemplate.stateEvaluatorTemplate, selectedThings);
            if (more) {
                return;
            }
        }

        for (var i = rule.actions.count; i < ruleTemplate.ruleActionTemplates.count; i++) {
            var ruleActionTemplate = ruleTemplate.ruleActionTemplates.get(i);

            if (ruleActionTemplate.selectionMode === RuleActionTemplate.SelectionModeInterface) {
                // TODO: Implement blacklist for interface based actions
                var ruleAction = rule.actions.createNewRuleAction();
                ruleAction.interfaceName = ruleActionTemplate.interfaceName;
                ruleAction.interfaceAction = ruleActionTemplate.interfaceAction;
                for (var j = 0; j < ruleActionTemplate.ruleActionParams.count; j++) {
                    var ruleActionParam = ruleActionTemplate.ruleActionParams.get(j)
                    ruleAction.ruleActionParams.setRuleActionParamByName(ruleActionParam.paramName, ruleActionParam.value)
                }
                rule.actions.addRuleAction(ruleAction);
                fillRuleFromTemplate(rule, ruleTemplate, selectedThings);
                return;
            }

            // Did we pick a thing for this index before?
            if (selectedThings.length > ruleActionTemplate.selectionId) {
                var device = engine.deviceManager.devices.getDevice(selectedThings[ruleActionTemplate.selectionId]);
                createRuleAction(rule, ruleTemplate, selectedThings, rule.actions, device, ruleActionTemplate)
                return;
            }

            // Did we already use the thing we opened this page from?
            if (selectedThings.indexOf(root.device.id) === -1 && root.deviceClass.interfaces.indexOf(ruleActionTemplate.interfaceName) >= 0 && ruleActionTemplate.interfaceName === ruleTemplate.interfaceName) {
                selectedThings.push(root.device.id);
                createRuleAction(rule, ruleTemplate, selectedThings, rule.actions, root.device, ruleActionTemplate)
                return;
            }

            // Ok, we need to pick a thing
            print("Need to select a thing")
            var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {shownInterfaces: [ruleActionTemplate.interfaceName]});
            page.thingSelected.connect(function(device) {
                selectedThings.push(device.id);
                createRuleAction(rule, ruleTemplate, selectedThings, rule.actions, device, ruleActionTemplate)
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
                for (var j = 0; j < ruleExitActionTemplate.ruleActionParams.count; j++) {
                    var ruleActionParam = ruleExitActionTemplate.ruleActionParams.get(j)
                    ruleExitAction.ruleActionParams.setRuleActionParam(ruleActionParam.paramName, ruleActionParam.value)
                }
                rule.exitActions.addRuleAction(ruleAction);
                fillRuleFromTemplate(rule, ruleTemplate, selectedThings);
                return;
            }

            // Did we pick a thing for this index before?
            if (selectedThings.length > ruleExitActionTemplate.selectionId) {
                var device = engine.deviceManager.devices.getDevice(selectedThings[ruleExitActionTemplate.selectionId]);
                createRuleAction(rule, ruleTemplate, selectedThings, rule.exitActions, device, ruleExitActionTemplate);
                return;
            }

            // Did we already use the thing we opened this page from?
            if (selectedThings.indexOf(root.device.id) === -1 && root.deviceClass.interfaces.indexOf(ruleExitActionTemplate.interfaceName) >= 0 && ruleExitActionTemplate.interfaceName === ruleTemplate.interfaceName) {
                selectedThings.push(root.device.id);
                createRuleAction(rule, ruleTemplate, selectedThings, rule.exitActions, root.device, ruleExitActionTemplate);
                return;
            }

            // Ok, we need to pick a thing
            var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {shownInterfaces: [ruleExitActionTemplate.interfaceName]});
            page.thingSelected.connect(function(device) {
                selectedThings.push(device.id);
                createRuleAction(rule, ruleTemplate, selectedThings, rule.exitActions, device, ruleExitActionTemplate);
                return;
            })
            page.backPressed.connect(function() {rule.destroy(); root.done();})
            return;
        }


        // Now replace %i in title and action params with selectedThings[i].name
        rule.name = ruleTemplate.ruleNameTemplate;
        for (var i = 0; i < selectedThings.length; i++) {
            var device = engine.deviceManager.devices.getDevice(selectedThings[i]);
            rule.name = rule.name.arg(device.name)

            for (var j = 0; j < rule.actions.count; j++) {
                var action = rule.actions.get(j);
                for(var k = 0; k < action.ruleActionParams.count; k++) {
                    var actionParam = action.ruleActionParams.get(k);
                    print("replacing args", typeof actionParam.value)
                    if (typeof actionParam.value === "string") {
                        actionParam.value = actionParam.value.arg(device.name);
                    }
                }
            }
            for (var j = 0; j < rule.exitActions.count; j++) {
                var action = rule.exitActions.get(j);
                for(var k = 0; k < action.ruleActionParams.count; k++) {
                    var actionParam = action.ruleActionParams.get(k);
                    if (typeof actionParam.value === "string") {
                        actionParam.value = actionParam.value.arg(device.name);
                    }
                }
            }
        }

        print("Rule complete!")
        engine.ruleManager.addRule(rule);
        rule.destroy();
        root.done();
    }

    function fillStateEvaluatorFromTemplate(rule, ruleTemplate, stateEvaluator, stateEvaluatorTemplate, selectedThings) {
        if (stateEvaluatorTemplate.stateDescriptorTemplate !== null && selectedThings.indexOf(stateEvaluator.stateDescriptor.deviceId) === -1 && stateEvaluator.stateDescriptor.interfaceName.length === 0) {
            // need to fill stateDescriptor

            print("filling in state evaluator for selection mode:", stateEvaluatorTemplate.stateDescriptorTemplate.selectionMode)
            if (stateEvaluatorTemplate.stateDescriptorTemplate.selectionMode === StateDescriptor.SelectionModeInterface) {
                stateEvaluator.stateDescriptor.interfaceName = stateEvaluatorTemplate.stateDescriptorTemplate.interfaceName;
                stateEvaluator.stateDescriptor.interfaceState = stateEvaluatorTemplate.stateDescriptorTemplate.interfaceState;
                stateEvaluator.stateDescriptor.valueOperator = stateEvaluatorTemplate.stateDescriptorTemplate.valueOperator;
                stateEvaluator.stateDescriptor.value = stateEvaluatorTemplate.stateDescriptorTemplate.value;
                fillRuleFromTemplate(rule, ruleTemplate, selectedThings);
                return true;
            }

            // did we pick a thing for this index before?
            if (selectedThings.length > stateEvaluatorTemplate.stateDescriptorTemplate.selectionId) {
                var deviceId = selectedThings[stateEvaluatorTemplate.stateDescriptorTemplate.selectionId]
                var device = engine.deviceManager.devices.getDevice(deviceId)
                var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                stateEvaluator.stateDescriptor.deviceId = deviceId;
                stateEvaluator.stateDescriptor.stateTypeId = deviceClass.stateTypes.findByName(stateEvaluatorTemplate.stateDescriptorTemplate.interfaceState).id
                stateEvaluator.stateDescriptor.valueOperator = stateEvaluatorTemplate.stateDescriptorTemplate.valueOperator;
                stateEvaluator.stateDescriptor.value = stateEvaluatorTemplate.stateDescriptorTemplate.value;
                fillRuleFromTemplate(rule, ruleTemplate, selectedThings);
                return true;
            }
            if (selectedThings.indexOf(root.device.id) === -1 && root.deviceClass.interfaces.indexOf(stateEvaluatorTemplate.stateDescriptorTemplate.interfaceName) >= 0 && stateEvaluatorTemplate.stateDescriptorTemplate.interfaceName === ruleTemplate.interfaceName) {
                stateEvaluator.stateDescriptor.deviceId = root.device.id;
                stateEvaluator.stateDescriptor.stateTypeId = root.deviceClass.stateTypes.findByName(stateEvaluatorTemplate.stateDescriptorTemplate.interfaceState).id
                stateEvaluator.stateDescriptor.valueOperator = stateEvaluatorTemplate.stateDescriptorTemplate.valueOperator;
                stateEvaluator.stateDescriptor.value = stateEvaluatorTemplate.stateDescriptorTemplate.value;
                selectedThings.push(root.device.id);
                fillRuleFromTemplate(rule, ruleTemplate, selectedThings);
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
                selectedThings.push(device.id);
                fillRuleFromTemplate(rule, ruleTemplate, selectedThings)
            })
            page.onAnySelected.connect(function() {
                stateEvaluator.stateDescriptor.interfaceName = stateEvaluatorTemplate.stateDescriptorTemplate.interfaceName;
                stateEvaluator.stateDescriptor.interfaceState = stateEvaluatorTemplate.stateDescriptorTemplate.interfaceState;
                stateEvaluator.stateDescriptor.valueOperator = stateEvaluatorTemplate.stateDescriptorTemplate.valueOperator;
                stateEvaluator.stateDescriptor.value = stateEvaluatorTemplate.stateDescriptorTemplate.value;
                fillRuleFromTemplate(rule, ruleTemplate, selectedThings);
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

    function createEventDescriptor(rule, ruleTemplate, selectedThings, device, eventDescriptorTemplate) {
        var eventDescriptor = rule.eventDescriptors.createNewEventDescriptor();
        eventDescriptor.deviceId = device.id;
        var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
        eventDescriptor.eventTypeId = deviceClass.eventTypes.findByName(eventDescriptorTemplate.interfaceEvent).id
        var needsParams = false;
        for (var j = 0; j < eventDescriptorTemplate.paramDescriptors.count; j++) {
            var paramDescriptorTemplate = eventDescriptorTemplate.paramDescriptors.get(j);
            if (paramDescriptorTemplate.value !== undefined) {
                eventDescriptor.paramDescriptors.addParamDescriptor(paramDescriptorTemplate.paramName, paramDescriptorTemplate.value);
            } else {
                needsParams = true;
            }
        }
        if (needsParams) {
            var page = pageStack.push(Qt.resolvedUrl("SelectEventDescriptorParamsPage.qml"), { eventDescriptor: eventDescriptor })
            page.completed.connect(function() {
                rule.eventDescriptors.addEventDescriptor(eventDescriptor);
                fillRuleFromTemplate(rule, ruleTemplate, selectedThings);
            })
            return;
        }
        rule.eventDescriptors.addEventDescriptor(eventDescriptor);
        fillRuleFromTemplate(rule, ruleTemplate, selectedThings);
    }

    function createRuleAction(rule, ruleTemplate, selectedThings, ruleActions, device, ruleActionTemplate) {
        var ruleAction = ruleActions.createNewRuleAction();
        var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
        ruleAction.deviceId = device.id;
        ruleAction.actionTypeId = deviceClass.actionTypes.findByName(ruleActionTemplate.interfaceAction).id
        for (var j = 0; j < ruleActionTemplate.ruleActionParams.count; j++) {
            var ruleActionParam = ruleActionTemplate.ruleActionParams.get(j)
            var actionType = deviceClass.actionTypes.getActionType(ruleAction.actionTypeId);
            var paramType = actionType.paramTypes.findByName(ruleActionParam.paramName);
            ruleAction.ruleActionParams.setRuleActionParam(paramType.id, ruleActionParam.value)
        }
        ruleActions.addRuleAction(ruleAction);
        fillRuleFromTemplate(rule, ruleTemplate, selectedThings);
    }

    header: GuhHeader {
        text: qsTr("New magic")
        onBackPressed: root.done()
    }

    ColumnLayout {
        anchors.fill: parent
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: RuleTemplatesFilterModel {
                id: ruleTemplatesModel
                ruleTemplates: RuleTemplates {}
                filterInterfaceNames: root.deviceClass ? root.deviceClass.interfaces : []
            }
            delegate: MeaListItemDelegate {
                width: parent.width
                text: model.description

                onClicked: {
                    var ruleTemplate = ruleTemplatesModel.get(index);
                    var rule = engine.ruleManager.createNewRule();
                    root.fillRuleFromTemplate(rule, ruleTemplate)
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
