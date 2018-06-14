import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Mea 1.0
import "../components"

SwipeDelegate {
    id: root
    implicitHeight: app.delegateHeight
    property var ruleAction: null

    property var device: ruleAction.deviceId ? Engine.deviceManager.devices.getDevice(ruleAction.deviceId) : null
    property var iface: ruleAction.interfaceName ? Interfaces.findByName(ruleAction.interfaceName) : null
    property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
    property var actionType: deviceClass ? deviceClass.actionTypes.getActionType(ruleAction.actionTypeId)
                                         : iface ? iface.actionTypes.findByName(ruleAction.interfaceAction) : null

    signal removeRuleAction()

    contentItem: RowLayout {
        spacing: app.margins
        ColorIcon {
            Layout.preferredHeight: app.iconSize
            Layout.preferredWidth: app.iconSize
            name: "../images/action.svg"
            color: app.guhAccent
        }

        ColumnLayout {
            Label {
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: qsTr("%1 - %2").arg(root.device ? root.device.name : root.iface.displayName).arg(root.actionType.displayName)
            }
            Label {
                Layout.fillWidth: true
                elide: Text.ElideRight
                font.pixelSize: app.smallFont
                text: {
                    var ret = [];
                    for (var i = 0; i < root.ruleAction.ruleActionParams.count; i++) {
                        var ruleActionParam = root.ruleAction.ruleActionParams.get(i)
                        var paramString = qsTr("%1: %2")
                        .arg(root.actionType.paramTypes.getParamType(ruleActionParam.paramTypeId).displayName)
                        .arg(ruleActionParam.eventParamTypeId.length > 0 ? qsTr("value from event") : ruleActionParam.value)
                        ret.push(paramString)
                    }
                    return ret.join(', ')
                }

            }
        }
    }
    swipe.right: MouseArea {
        height: root.height
        width: height
        anchors.right: parent.right
        ColorIcon {
            anchors.fill: parent
            anchors.margins: app.margins
            name: "../images/delete.svg"
            color: "red"
        }
        onClicked: root.removeRuleAction()
    }
}
