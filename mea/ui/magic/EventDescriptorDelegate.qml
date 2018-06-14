import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Mea 1.0
import "../components"

SwipeDelegate {
    id: root
    implicitHeight: app.delegateHeight

    property var eventDescriptor: null
    readonly property var device: eventDescriptor ? Engine.deviceManager.devices.getDevice(eventDescriptor.deviceId) : null
    readonly property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
    readonly property var iface: eventDescriptor.interfaceName ? Interfaces.findByName(eventDescriptor.interfaceName) : null
    readonly property var eventType: deviceClass ? deviceClass.eventTypes.getEventType(eventDescriptor.eventTypeId)
                                        : iface ? iface.eventTypes.findByName(eventDescriptor.interfaceEvent) : null

    signal removeEventDescriptor()

    contentItem: RowLayout {
        spacing: app.margins
        ColorIcon {
            Layout.preferredHeight: app.iconSize
            Layout.preferredWidth: app.iconSize
            name: "../images/event.svg"
            color: app.guhAccent
        }

        ColumnLayout {
            Label {
                text: qsTr("%1 - %2").arg(root.device ? root.device.name : root.iface.displayName).arg(root.eventType.displayName)
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
            Label {
                Layout.fillWidth: true
                elide: Text.ElideRight
                font.pixelSize: app.smallFont
                text: {
                    var ret = qsTr("anytime");
                    for (var i = 0; i < root.eventDescriptor.paramDescriptors.count; i++) {
                        var paramDescriptor = root.eventDescriptor.paramDescriptors.get(i)
                        var operatorString;
                        switch (paramDescriptor.operatorType) {
                        case ParamDescriptor.ValueOperatorEquals:
                            operatorString = " = ";
                            break;
                        case ParamDescriptor.ValueOperatorNotEquals:
                            operatorString = " != ";
                            break;
                        case ParamDescriptor.ValueOperatorGreater:
                            operatorString = " > ";
                            break;
                        case ParamDescriptor.ValueOperatorGreaterOrEqual:
                            operatorString = " >= ";
                            break;
                        case ParamDescriptor.ValueOperatorLess:
                            operatorString = " < ";
                            break;
                        case ParamDescriptor.ValueOperatorLessOrEqual:
                            operatorString = " <= ";
                            break;
                        default:
                            operatorString = " ? ";
                        }

                        if (i === 0) {
                            // TRANSLATORS: example: "only if temperature > 5"
                            ret = qsTr("only if %1 %2 %3")
                            .arg(root.eventType.paramTypes.getParamType(paramDescriptor.paramTypeId).displayName)
                            .arg(operatorString)
                            .arg(paramDescriptor.value)
                        } else {
                            // TRANSLATORS: example: "and temperature > 5"
                            ret += " " + qsTr("and %1 %2 %3")
                            .arg(root.eventType.paramTypes.getParamType(paramDescriptor.paramTypeId).displayName)
                            .arg(operatorString)
                            .arg(model.value)
                        }
                    }

                    return ret;
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
        onClicked: root.removeEventDescriptor()
    }
}
