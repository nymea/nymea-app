import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {
    id: root

    property var device: null
    readonly property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
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
            // If we already have a thing selected for this selectionIndex, use that
            if (selectedThings.length > eventDescriptorTemplate.selectionId) {
                var device = Engine.deviceManager.devices.getDevice(selectedThings[eventDescriptorTemplate.selectionId]);
                var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                var eventDescriptor = rule.eventDescriptors.createNewEventDescriptor();
                eventDescriptor.deviceId = device.id
                eventDescriptor.eventTypeId = deviceClass.eventTypes.findByName(eventDescriptorTemplate.interfaceEvent).id
                fillRuleFromTemplate(rule, ruleTemplate, selectedThings);
                return;
            }
            // Ok, we didn't pick a thing for this selectionId before. Did we already use the one we opened this page from?
            if (selectedThings.indexOf(root.device.id) === -1 && root.deviceClass.interfaces.indexOf(eventDescriptorTemplate.interfaceName) >= 0) {
                var eventDescriptor = rule.eventDescriptors.createNewEventDescriptor();
                eventDescriptor.deviceId = root.device.id;
                eventDescriptor.eventTypeId = root.deviceClass.eventTypes.findByName(eventDescriptorTemplate.interfaceEvent).id
                rule.eventDescriptors.addEventDescriptor(eventDescriptor);
                selectedThings.push(root.device.id);
                fillRuleFromTemplate(rule, ruleTemplate, selectedThings);
                return;
            }

            // We need to pick a thing
            var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {shownInterfaces: [eventDescriptorTemplate.interfaceName]});
            page.thingSelected.connect(function(device) {
                var eventDescriptor = rule.eventDescriptors.createNewEventDescriptor();
                eventDescriptor.deviceId = device.id;
                var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                eventDescriptor.eventTypeId = deviceClass.eventTypes.findByName(eventDescriptorTemplate.interfaceEvent).id;
                rule.eventDescriptors.addEventDescriptor(eventDescriptor);
                selectedThings.push(device.id);
                fullRuleFromTemplate(rule, ruleTemplate, selectedThings);
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

            // Did we pick a thing for this index before?
            if (selectedThings.length > ruleActionTemplate.selectionId) {
                var ruleAction = rule.actions.createNewRuleAction();
                var deviceId = selectedThings[ruleActionTemplate.selectionId];
                var device = Engine.deviceManager.devices.getDevice(deviceId);
                var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                ruleAction.deviceId = deviceId;
                ruleAction.actionTypeId = deviceClass.actionTypes.findByName(ruleActionTemplate.interfaceAction).id
                for (var j = 0; j < ruleActionTemplate.ruleActionParams.count; j++) {
                    var ruleActionParam = ruleActionTemplate.ruleActionParams.get(j)
                    var actionType = deviceClass.actionTypes.getActionType(ruleAction.actionTypeId);
                    var paramType = actionType.paramTypes.findByName(ruleActionParam.paramName);
                    ruleAction.ruleActionParams.setRuleActionParam(paramType.id, ruleActionParam.value)
                }
                rule.actions.addRuleAction(ruleAction);
                fillRuleFromTemplate(rule, ruleTemplate, selectedThings);
                return;
            }

            // Did we already use the thing we opened this page from?
            if (selectedThings.indexOf(root.device.id) === -1 && root.deviceClass.interfaces.indexOf(ruleActionTemplate.interfaceName) >= 0) {
                var ruleAction = rule.actions.createNewRuleAction();
                ruleAction.deviceId = root.device.id;
                ruleAction.actionTypeId = root.deviceClass.actionTypes.findByName(ruleActionTemplate.interfaceAction).id
                for (var j = 0; j < ruleActionTemplate.ruleActionParams.count; j++) {
                    var ruleActionParam = ruleActionTemplate.ruleActionParams.get(j)
                    var actionType = deviceClass.actionTypes.getActionType(ruleAction.actionTypeId);
                    var paramType = actionType.paramTypes.findByName(ruleActionParam.paramName);
                    ruleAction.ruleActionParams.setRuleActionParam(paramType.id, ruleActionParam.value)
                }
                rule.actions.addRuleAction(ruleAction);
                selectedThings.push(root.device.id);
                fillRuleFromTemplate(rule, ruleTemplate, selectedThings);
                return;
            }

            // Ok, we need to pick a thing
            var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {shownInterfaces: [ruleActionTemplate.interfaceName]});
            page.thingSelected.connect(function(device) {
                var ruleAction = rule.actions.createNewRuleAction();
                ruleAction.deviceId = device.id;
                var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                ruleAction.actionTypeId = deviceClass.actionTypes.findByName(ruleActionTemplate.interfaceAction).id;
                for (var j = 0; j < ruleActionTemplate.ruleActionParams.count; j++) {
                    var ruleActionParam = ruleActionTemplate.ruleActionParams.get(j)
                    var actionType = deviceClass.actionTypes.getActionType(ruleAction.actionTypeId);
                    var paramType = actionType.paramTypes.findByName(ruleActionParam.paramName);
                    ruleAction.ruleActionParams.setRuleActionParam(paramType.id, ruleActionParam.value)
                }
                rule.actions.addRuleAction(ruleAction);
                selectedThings.push(device.id);
                fillRuleFromTemplate(rule, ruleTemplate, selectedThings);
                return;
            })
            page.backPressed.connect(function() {rule.destroy(); root.done();})
            return;
        }


        for (var i = rule.exitActions.count; i < ruleTemplate.ruleExitActionTemplates.count; i++) {
            var ruleExitActionTemplate = ruleTemplate.ruleExitActionTemplates.get(i);

            // Did we pick a thing for this index before?
            if (selectedThings.length > ruleExitActionTemplate.selectionId) {
                var ruleAction = rule.exitActions.createNewRuleAction();
                var deviceId = selectedThings[ruleExitActionTemplate.selectionId];
                var device = Engine.deviceManager.devices.getDevice(deviceId);
                var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                ruleAction.deviceId = deviceId;
                ruleAction.actionTypeId = deviceClass.actionTypes.findByName(ruleExitActionTemplate.interfaceAction).id
                for (var j = 0; j < ruleExitActionTemplate.ruleActionParams.count; j++) {
                    var ruleActionParam = ruleExitActionTemplate.ruleActionParams.get(j)
                    var actionType = deviceClass.actionTypes.getActionType(ruleAction.actionTypeId);
                    var paramType = actionType.paramTypes.findByName(ruleActionParam.paramName);
                    ruleAction.ruleActionParams.setRuleActionParam(paramType.id, ruleActionParam.value)
                }
                rule.exitActions.addRuleAction(ruleAction);
                fillRuleFromTemplate(rule, ruleTemplate, selectedThings);
                return;
            }

            // Did we already use the thing we opened this page from?
            if (selectedThings.indexOf(root.device.id) === -1 && root.deviceClass.interfaces.indexOf(ruleExitActionTemplate.interfaceName) >= 0) {
                var ruleAction = rule.exitActions.createNewRuleAction();
                ruleAction.deviceId = root.device.id;
                ruleAction.actionTypeId = root.deviceClass.actionTypes.findByName(ruleExitActionTemplate.interfaceAction).id
                for (var j = 0; j < ruleExitActionTemplate.ruleActionParams.count; j++) {
                    var ruleActionParam = ruleExitActionTemplate.ruleActionParams.get(j)
                    var actionType = deviceClass.actionTypes.getActionType(ruleAction.actionTypeId);
                    var paramType = actionType.paramTypes.findByName(ruleActionParam.paramName);
                    ruleAction.ruleActionParams.setRuleActionParam(paramType.id, ruleActionParam.value)
                }
                rule.exitActions.addRuleAction(ruleAction);
                selectedThings.push(root.device.id);
                fillRuleFromTemplate(rule, ruleTemplate, selectedThings);
                return;
            }

            // Ok, we need to pick a thing
            var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {shownInterfaces: [ruleExitActionTemplate.interfaceName]});
            page.thingSelected.connect(function(device) {
                var ruleAction = rule.exitActions.createNewRuleAction();
                ruleAction.deviceId = device.id;
                var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                ruleAction.actionTypeId = deviceClass.actionTypes.findByName(ruleExitActionTemplate.interfaceAction).id;
                for (var j = 0; j < ruleExitActionTemplate.ruleActionParams.count; j++) {
                    var ruleActionParam = ruleExitActionTemplate.ruleActionParams.get(j)
                    var actionType = deviceClass.actionTypes.getActionType(ruleAction.actionTypeId);
                    var paramType = actionType.paramTypes.findByName(ruleActionParam.paramName);
                    ruleAction.ruleActionParams.setRuleActionParam(paramType.id, ruleActionParam.value)
                }
                rule.exitActions.addRuleAction(ruleAction);
                selectedThings.push(device.id);
                fillRuleFromTemplate(rule, ruleTemplate, selectedThings);
                return;
            })
            page.backPressed.connect(function() {rule.destroy(); root.done();})
            return;
        }


        rule.name = ruleTemplate.ruleNameTemplate;
        for (var i = 0; i < selectedThings.length; i++) {
            var device = Engine.deviceManager.devices.getDevice(selectedThings[i]);
            rule.name = rule.name.arg(device.name)
        }

        print("Rule complete!")
        Engine.ruleManager.addRule(rule);
        rule.destroy();
        root.done();
    }

    function fillStateEvaluatorFromTemplate(rule, ruleTemplate, stateEvaluator, stateEvaluatorTemplate, selectedThings) {
        if (stateEvaluatorTemplate.stateDescriptorTemplate !== null && selectedThings.indexOf(stateEvaluator.stateDescriptor.deviceId) === -1) {
            // need to fill stateDescriptor
            // did we pick a thing for this index before?
            if (selectedThings.length > stateEvaluatorTemplate.stateDescriptorTemplate.selectionId) {
                var deviceId = selectedThings[stateEvaluatorTemplate.stateDescriptorTemplate.selectionId]
                var device = Engine.deviceManager.devices.getDevice(deviceId)
                var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                stateEvaluator.stateDescriptor.deviceId = deviceId;
                stateEvaluator.stateDescriptor.stateTypeId = deviceClass.stateTypes.findByName(stateEvaluatorTemplate.stateDescriptorTemplate.interfaceState).id
                stateEvaluator.stateDescriptor.valueOperator = stateEvaluatorTemplate.stateDescriptorTemplate.valueOperator;
                stateEvaluator.stateDescriptor.value = stateEvaluatorTemplate.stateDescriptorTemplate.value;
                fillRuleFromTemplate(rule, ruleTemplate, selectedThings);
                return true;
            }
            if (selectedThings.indexOf(root.device.id) === -1 && root.deviceClass.interfaces.indexOf(stateEvaluatorTemplate.stateDescriptorTemplate.interfaceName) >= 0) {
                stateEvaluator.stateDescriptor.deviceId = root.device.id;
                stateEvaluator.stateDescriptor.stateTypeId = root.deviceClass.stateTypes.findByName(stateEvaluatorTemplate.stateDescriptorTemplate.interfaceState).id
                stateEvaluator.stateDescriptor.valueOperator = stateEvaluatorTemplate.stateDescriptorTemplate.valueOperator;
                stateEvaluator.stateDescriptor.value = stateEvaluatorTemplate.stateDescriptorTemplate.value;
                selectedThings.push(root.device.id);
                fillRuleFromTemplate(rule, ruleTemplate, selectedThings);
                return true;
            }
            var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {shownInterfaces: [stateEvaluatorTemplate.stateDescriptorTemplate.interfaceName]});
            page.thingSelected.connect(function(device) {
                var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                stateEvaluator.stateDescriptor.deviceId = device.id;
                stateEvaluator.stateDescriptor.stateTypeId = deviceClass.stateTypes.findByName(stateEvaluatorTemplate.stateDescriptorTemplate.interfaceState).id;
                stateEvaluator.stateDescriptor.valueOperator = stateEvaluatorTemplate.stateDescriptorTemplate.valueOperator;
                stateEvaluator.stateDescriptor.value = stateEvaluatorTemplate.stateDescriptorTemplate.value;
                selectedThings.push(device.id);
                fillRuleFromTemplate(rule, ruleTemplate, selectedThings)
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
                    var rule = Engine.ruleManager.createNewRule();
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
