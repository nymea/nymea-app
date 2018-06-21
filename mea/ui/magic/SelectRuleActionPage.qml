import QtQuick 2.4
import QtQuick.Controls 2.1
import "../components"
import Mea 1.0

Page {
    id: root
    property alias text: header.text

    // a ruleAction object needs to be set and prefilled with either deviceId or interfaceName
    property var ruleAction: null

    // optionally, a rule which will be used when determining params for the actions
    property var rule: null

    readonly property var device: ruleAction && ruleAction.deviceId ? Engine.deviceManager.devices.getDevice(ruleAction.deviceId) : null
    readonly property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null

    signal backPressed();
    signal done();

    onRuleActionChanged: buildInterface()
    Component.onCompleted: buildInterface()

    header: GuhHeader {
        id: header
        onBackPressed: root.backPressed();

        property bool interfacesMode: root.ruleAction.interfaceName !== ""
        onInterfacesModeChanged: root.buildInterface()

        HeaderButton {
            imageSource: header.interfacesMode ? "../images/view-expand.svg" : "../images/view-collapse.svg"
            visible: root.ruleAction.interfaceName === ""
            onClicked: header.interfacesMode = !header.interfacesMode
        }
    }

    ListModel {
        id: generatedModel
        ListElement { displayName: ""; actionTypeId: "" }
    }

    function buildInterface() {
        print("building iface", root.ruleAction, root.ruleAction.interfaceName, header.interfacesMode, root.ruleAction.interfaceName === "")
        if (header.interfacesMode) {
            if (root.device) {
                generatedModel.clear();
                for (var i = 0; i < Interfaces.count; i++) {
                    var iface = Interfaces.get(i);
                    if (root.deviceClass.interfaces.indexOf(iface.name) >= 0) {
                        for (var j = 0; j < iface.actionTypes.count; j++) {
                            var ifaceAt = iface.actionTypes.get(j);
                            var dcAt = root.deviceClass.actionTypes.findByName(ifaceAt.name)
                            generatedModel.append({displayName: ifaceAt.displayName, actionTypeId: dcAt.id})
                        }
                    }
                }
                listView.model = generatedModel
            } else if (root.ruleAction.interfaceName !== "") {
                print("showing actions for interface", root.ruleAction.interfaceName)
                listView.model = Interfaces.findByName(root.ruleAction.interfaceName).actionTypes
            } else {
                console.warn("You need to set device or interfaceName");
            }
        } else {
            if (root.device) {
                listView.model = deviceClass.actionTypes
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent

        delegate: ItemDelegate {
            text: model.displayName
            width: parent.width
            onClicked: {
                if (header.interfacesMode) {
                    if (root.device) {
                        root.ruleAction.actionTypeId = model.actionTypeId;
                        var actionType = root.deviceClass.actionTypes.getActionType(model.actionTypeId)
                        if (actionType.paramTypes.count > 0) {
                            var paramsPage = pageStack.push(Qt.resolvedUrl("SelectRuleActionParamsPage.qml"), {ruleAction: root.ruleAction, rule: root.rule})
                            paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                            paramsPage.onCompleted.connect(function() {
                                pageStack.pop();
                                root.done();
                            })
                        } else {
                            root.done();
                        }
                    } else if (root.ruleAction.interfaceName !== "") {
                        root.ruleAction.interfaceAction = model.name;
                        if (listView.model.get(index).paramTypes.count > 0) {
                            var paramsPage = pageStack.push(Qt.resolvedUrl("SelectRuleActionParamsPage.qml"), {ruleAction: root.ruleAction, rule: root.rule})
                            paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                            paramsPage.onCompleted.connect(function() {
                                pageStack.pop();
                                root.done();
                            })
                        } else {
                            root.done();
                        }
                    } else {
                        console.warn("Neither deviceId not interfaceName set. Cannot continue...");
                    }
                } else {
                    if (root.device) {
                        var actionType = root.deviceClass.actionTypes.getActionType(model.id);
                        console.log("ActionType", actionType.id, "selected. Has", actionType.paramTypes.count, "params");
                        root.ruleAction.actionTypeId = actionType.id;
                        if (actionType.paramTypes.count > 0) {
                            var paramsPage = pageStack.push(Qt.resolvedUrl("SelectRuleActionParamsPage.qml"), {ruleAction: root.ruleAction, rule: root.rule})
                            paramsPage.onBackPressed.connect(function() { pageStack.pop(); });
                            paramsPage.onCompleted.connect(function() {
                                pageStack.pop();
                                root.done();
                            })
                        } else {
                            root.done();
                        }
                    }
                }
            }
        }
    }
}
