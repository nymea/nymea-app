import QtQuick 2.4
import QtQuick.Controls 2.1
import "../components"
import Guh 1.0

Page {
    id: root
    property alias text: header.text

    // a ruleAction object needs to be set and prefilled with either deviceId or interfaceName
    property var ruleAction: null

    readonly property var device: ruleAction && ruleAction.deviceId ? Engine.deviceManager.devices.getDevice(ruleAction.deviceId) : null
    readonly property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null

    signal backPressed();
    signal done();

    onRuleActionChanged: buildInterface()
    Component.onCompleted: buildInterface()

    header: GuhHeader {
        id: header
        onBackPressed: root.backPressed();

        property bool interfacesMode: true
        onInterfacesModeChanged: root.buildInterface()

        HeaderButton {
            imageSource: header.interfacesMode ? "../images/view-expand.svg" : "../images/view-collapse.svg"
            onClicked: header.interfacesMode = !header.interfacesMode
        }
    }

    ListModel {
        id: actionTemplateModel
        ListElement { interfaceName: "light"; text: "Switch light"; identifier: "switchLight"}
        ListElement { interfaceName: "dimmablelight"; text: "Dim light"; identifier: "dimLight"}
        ListElement { interfaceName: "colorlight"; text: "Set light color"; identifier: "colorLight" }
        ListElement { interfaceName: "mediacontroller"; text: "Pause playback"; identifier: "pausePlayback" }
        ListElement { interfaceName: "mediacontroller"; text: "Resume playback"; identifier: "resumePlayback" }
        ListElement { interfaceName: "extendedvolumecontroller"; text: "Set volume"; identifier: "setVolume" }
        ListElement { interfaceName: "extendedvolumecontroller"; text: "Mute"; identifier: "mute" }
        ListElement { interfaceName: "extendedvolumecontroller"; text: "Unmute"; identifier: "unmute" }
        ListElement { interfaceName: "notifications"; text: "Notify me"; identifier: "notify" }
    }

    function buildInterface() {
        actualModel.clear()

        if (header.interfacesMode) {
            if (root.device) {
                print("device supports interfaces", deviceClass.interfaces)
                for (var i = 0; i < actionTemplateModel.count; i++) {
                    print("action is for interface", actionTemplateModel.get(i).interfaceName)
                    if (deviceClass.interfaces.indexOf(actionTemplateModel.get(i).interfaceName) >= 0) {
                        actualModel.append(actionTemplateModel.get(i))
                    }
                }
            } else if (root.ruleAction.interfaceName !== "") {
                for (var i = 0; i < actionTemplateModel.count; i++) {
                    if (actionTemplateModel.get(i).interfaceName === root.ruleAction.interfaceName) {
                        actualModel.append(actionTemplateModel.get(i))
                    }
                }
            } else {
                console.warn("You need to set device or interfaceName");
            }
        } else {
            if (root.device) {
                print("fdsfasdfdsafdas", deviceClass.actionTypes.count)
                for (var i = 0; i < deviceClass.actionTypes.count; i++) {
                    print("bla", deviceClass.actionTypes.get(i).name, deviceClass.actionTypes.get(i).displayName, deviceClass.actionTypes.get(i).id)
                    actualModel.append({text: deviceClass.actionTypes.get(i).displayName, actionTypeId: deviceClass.actionTypes.get(i).id})
                }
            }
        }
    }

    ListModel {
        id: actualModel
        ListElement { text: ""; actionTypeId: "" }
    }

    ListView {
        anchors.fill: parent
        model: actualModel

        delegate: ItemDelegate {
            text: model.text
            onClicked: {
                if (header.interfacesMode) {
                    if (root.device) {
                        print("selected:", model.identifier)
                        switch (model.identfier) {
                        case "switchLight":
                            root.done();
                            break;
                        default:
                            console.warn("FIXME: Unhandled interface action");
                        }
                    }
                } else {
                    if (root.device) {
                        var actionType = root.deviceClass.actionTypes.getActionType(model.actionTypeId);
                        console.log("ActionType", actionType.id, "selected. Has", actionType.paramTypes.count, "params");
                        root.ruleAction.actionTypeId = actionType.id;
                        if (actionType.paramTypes.count > 0) {
                            var paramsPage = pageStack.push(Qt.resolvedUrl("SelectRuleActionParamsPage.qml"), {ruleAction: root.ruleAction})
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
