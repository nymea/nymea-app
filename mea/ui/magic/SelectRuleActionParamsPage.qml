import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "../components"
import "../paramdelegates-ng"
import Mea 1.0

Page {
    id: root
    // Needs to be set and filled in with deviceId and actionTypeId or interfaceName and interfaceAction
    property var ruleAction

    readonly property var device: ruleAction && ruleAction.deviceId ? Engine.deviceManager.devices.getDevice(ruleAction.deviceId) : null
    readonly property var iface: ruleAction && ruleAction.interfaceName ? Interfaces.findByName(ruleAction.interfaceName) : null
    readonly property var actionType: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId).actionTypes.getActionType(ruleAction.actionTypeId)
                                            : iface ? iface.actionTypes.findByName(ruleAction.interfaceAction) : null

    signal backPressed();
    signal completed();

    header: GuhHeader {
        text: "params"
        onBackPressed: root.backPressed();
    }

    ColumnLayout {
        anchors.fill: parent
        Repeater {
            id: delegateRepeater
            model: root.actionType.paramTypes
            delegate: ParamDelegate {
                Layout.fillWidth: true
                paramType: root.actionType.paramTypes.get(index)
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
        Button {
            text: "OK"
            Layout.fillWidth: true
            Layout.margins: app.margins
            onClicked: {
                var params = [];
                for (var i = 0; i < delegateRepeater.count; i++) {
                    var paramDelegate = delegateRepeater.itemAt(i);
                    root.ruleAction.ruleActionParams.setRuleActionParam(paramDelegate.paramType.id, paramDelegate.value)
                }
                root.completed()
            }
        }
    }
}
