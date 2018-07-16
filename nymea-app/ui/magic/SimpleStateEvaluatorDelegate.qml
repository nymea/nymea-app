import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"

SwipeDelegate {
    id: root
    Layout.fillWidth: true
    clip: true

    property var stateEvaluator: null
    property bool showChilds: false

    readonly property var device: stateEvaluator ? Engine.deviceManager.devices.getDevice(stateEvaluator.stateDescriptor.deviceId) : null
    readonly property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
    readonly property var iface: stateEvaluator ? Interfaces.findByName(stateEvaluator.stateDescriptor.interfaceName) : null
    readonly property var stateType: deviceClass ? deviceClass.stateTypes.getStateType(stateEvaluator.stateDescriptor.stateTypeId)
                                                 : iface ? iface.stateTypes.findByName(stateEvaluator.stateDescriptor.interfaceState) : null

    signal deleteClicked();

    Rectangle {
        anchors.fill: parent
        border.color: "black"
        border.width: 1
        color: "transparent"
    }

    contentItem: ColumnLayout {
        RowLayout {
            Layout.fillWidth: true
            ColorIcon {
                Layout.preferredHeight: childEvaluatorsRepeater.count > 0 ? app.iconSize * .6 : app.iconSize
                Layout.preferredWidth: height
                name: root.stateEvaluator.stateDescriptor.interfaceName.length === 0 ? "../images/state.svg" : "../images/state-interface.svg"
                color: app.guhAccent
            }

            Label {
                Layout.fillWidth: true
                font.pixelSize: childEvaluatorsRepeater.count > 0 ? app.smallFont : app.mediumFont
                wrapMode: Text.WordWrap
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
                    if (!root.stateType) {
                        return qsTr("Press to edit condition")
                    }
                    if (root.device) {
                        return qsTr("%1: %2 %3 %4").arg(root.device.name).arg(root.stateType.displayName).arg(operatorString).arg(root.stateEvaluator.stateDescriptor.value)
                    } else if (root.iface) {
                        return qsTr("%1: %2 %3 %4").arg(root.iface.displayName).arg(root.stateType.displayName).arg(operatorString).arg(root.stateEvaluator.stateDescriptor.value)
                    }
                    return "--";
                }
            }
        }

        Repeater {
            id: childEvaluatorsRepeater
            model: root.showChilds ? root.stateEvaluator.childEvaluators : null
            delegate: RowLayout {
                id: childEvaluatorDelegate
                Layout.fillWidth: true

                property var stateEvaluator: root.stateEvaluator.childEvaluators.get(index)
                property var stateDescriptor: stateEvaluator.stateDescriptor
                readonly property var device: Engine.deviceManager.devices.getDevice(stateDescriptor.deviceId)
                readonly property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
                readonly property var iface: Interfaces.findByName(stateEvaluator.stateDescriptor.interfaceName)
                readonly property var stateType: device ? deviceClass.stateTypes.getStateType(stateDescriptor.stateTypeId)
                                                        : iface ? iface.stateTypes.findByName(stateEvaluator.stateDescriptor.interfaceState)
                                                                : null

                ColorIcon {
                    Layout.preferredHeight: app.iconSize * .6
                    Layout.preferredWidth: height
                    name: childEvaluatorDelegate.stateDescriptor.interfaceName.length === 0 ? "../images/state.svg" : "../images/state-interface.svg"
                    color: app.guhAccent
                }
                Label {
                    font.pixelSize: app.smallFont
                    Layout.fillWidth: true

                    property string operatorString: {
                        switch (childEvaluatorDelegate.stateDescriptor.valueOperator) {
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
                    text: device ? ("%1 %2: %3 %4 %5%6").arg(root.stateEvaluator.stateOperator === StateEvaluator.StateOperatorAnd ? "and" : "or").arg(childEvaluatorDelegate.device.name).arg(childEvaluatorDelegate.stateType.displayName).arg(operatorString).arg(childEvaluatorDelegate.stateDescriptor.value).arg(childEvaluatorDelegate.stateEvaluator.childEvaluators.count > 0 ? "..." : "")
                                 : iface ? ("%1 %2: %3 %4 %5%6").arg(root.stateEvaluator.stateOperator === StateEvaluator.StateOperatorAnd ? "and" : "or").arg(childEvaluatorDelegate.iface.displayName).arg(childEvaluatorDelegate.stateType.displayName).arg(operatorString).arg(childEvaluatorDelegate.stateDescriptor.value).arg(childEvaluatorDelegate.stateEvaluator.childEvaluators.count > 0 ? "..." : "")
                                         : "???"
                }
            }
        }
    }

    swipe.right: MouseArea {
        height: parent.height
        width: height
        anchors.right: parent.right
        Rectangle {
            anchors.fill: parent
            color: "red"
        }

        ColorIcon {
            anchors.fill: parent
            anchors.margins: app.margins
            name: "../images/delete.svg"
            color: "white"
        }
        onClicked: {
            swipe.close()
            root.deleteClicked();
        }
    }
}
