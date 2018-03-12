import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Mea 1.0

SwipeDelegate {
    id: root
    Layout.fillWidth: true

    property var stateEvaluator: null
    property bool showChilds: false

    readonly property var device: stateEvaluator ? Engine.deviceManager.devices.getDevice(stateEvaluator.stateDescriptor.deviceId) : null
    readonly property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
    readonly property var stateType: deviceClass ? deviceClass.stateTypes.getStateType(stateEvaluator.stateDescriptor.stateTypeId) : null

    Rectangle {
        anchors.fill: parent
        border.color: "black"
        border.width: 1
        color: "transparent"
    }

    contentItem: ColumnLayout {
        Label {
            Layout.fillWidth: true
            property string operatorString: {
                if (!root.stateEvaluator) {
                    return "";
                }

                switch (root.stateEvaluator.stateDescriptor.valueOperator) {
                case StateDescriptor.ValueOperatorEquals:
                    return "=";
                case StateDescriptor.ValueOperatorNotEquals:
                    return "!=";
                case StateDescriptor.ValueOperatorGreater:
                    return ">";
                case StateDescriptor.ValueOperatorGreaterOrEqual:
                    return ">=";
                case StateDescriptor.ValueOperatorLess:
                    return "<";
                case StateDescriptor.ValueOperatorLessOrEqual:
                    return "<=";
                }
                return "FIXME"
            }

            text: {
                if (!root.device) {
                    return qsTr("Press to edit condition")
                }
                return qsTr("%1: %2 %3 %4").arg(root.device.name).arg(root.stateType.displayName).arg(operatorString).arg(root.stateEvaluator.stateDescriptor.value)
            }
        }
        Repeater {
            model: root.showChilds ? root.stateEvaluator.childEvaluators : null
            delegate: Label {
                Layout.fillWidth: true
                property var stateEvaluator: root.stateEvaluator.childEvaluators.get(index)
                property var stateDescriptor: stateEvaluator.stateDescriptor
                readonly property var device: Engine.deviceManager.devices.getDevice(stateDescriptor.deviceId)
                readonly property var deviceClass: Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId)
                readonly property var stateType: deviceClass.stateTypes.getStateType(stateDescriptor.stateTypeId)

                property string operatorString: {
                    switch (stateDescriptor.valueOperator) {
                    case StateDescriptor.ValueOperatorEquals:
                        return "=";
                    case StateDescriptor.ValueOperatorNotEquals:
                        return "!=";
                    case StateDescriptor.ValueOperatorGreater:
                        return ">";
                    case StateDescriptor.ValueOperatorGreaterOrEqual:
                        return ">=";
                    case StateDescriptor.ValueOperatorLess:
                        return "<";
                    case StateDescriptor.ValueOperatorLessOrEqual:
                        return "<=";
                    }
                    return "FIXME"
                }
                text: qsTr("%1 %2: %3 %4 %5%6").arg(root.stateEvaluator.stateOperator === StateEvaluator.StateOperatorAnd ? "and" : "or").arg(device.name).arg(stateType.displayName).arg(operatorString).arg(stateDescriptor.value).arg(stateEvaluator.childEvaluators.count > 0 ? "..." : "")
            }
        }
    }
}
