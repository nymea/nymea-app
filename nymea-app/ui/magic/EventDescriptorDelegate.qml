import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

MeaListItemDelegate {
    id: root
    implicitHeight: app.delegateHeight
    canDelete: true
    progressive: false

    property EventDescriptor eventDescriptor: null
    readonly property Device device: eventDescriptor ? engine.deviceManager.devices.getDevice(eventDescriptor.deviceId) : null
    readonly property DeviceClass deviceClass: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
    readonly property Interface iface: eventDescriptor.interfaceName ? Interfaces.findByName(eventDescriptor.interfaceName) : null
    readonly property EventType eventType: deviceClass ? deviceClass.eventTypes.getEventType(eventDescriptor.eventTypeId)
                                                 : iface ? iface.eventTypes.findByName(eventDescriptor.interfaceEvent) : null

    signal removeEventDescriptor()

    onDeleteClicked: root.removeEventDescriptor()

    iconName: root.device ? "../images/event.svg" : "../images/event-interface.svg"
    text: qsTr("%1 - %2").arg(root.device ? root.device.name : root.iface.displayName).arg(root.eventType.displayName)
    subText: {
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

            var paramType = paramDescriptor.paramTypeId
                    ? root.eventType.paramTypes.getParamType(paramDescriptor.paramTypeId)
                    : root.eventType.paramTypes.findByName(paramDescriptor.paramName)

            if (i === 0) {
                // TRANSLATORS: example: "only if temperature > 5"
                ret = qsTr("only if %1 %2 %3")
                .arg(paramType.displayName)
                .arg(operatorString)
                .arg(paramDescriptor.value)
            } else {
                // TRANSLATORS: example: "and temperature > 5"
                ret += " " + qsTr("and %1 %2 %3")
                .arg(paramType.displayName)
                .arg(operatorString)
                .arg(model.value)
            }
        }

        return ret;
    }
}
