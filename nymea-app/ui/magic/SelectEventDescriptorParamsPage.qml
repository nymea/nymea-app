import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "../components"
import "../delegates"
import Nymea 1.0

Page {
    id: root
    // Needs to be set and filled in with deviceId and eventTypeId
    property var eventDescriptor: null

    readonly property var device: eventDescriptor && eventDescriptor.deviceId ? Engine.deviceManager.devices.getDevice(eventDescriptor.deviceId) : null
    readonly property var iface: eventDescriptor && eventDescriptor.interfaceName ? Interfaces.findByName(eventDescriptor.interfaceName) : null
    readonly property var eventType: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId).eventTypes.getEventType(eventDescriptor.eventTypeId)
                                            : iface ? iface.eventTypes.findByName(eventDescriptor.interfaceEvent) : null

    signal backPressed();
    signal completed();

    header: GuhHeader {
        text: "Options"
        onBackPressed: root.backPressed();
    }

    ColumnLayout {
        anchors.fill: parent
        Repeater {
            id: delegateRepeater
            model: root.eventType.paramTypes
            delegate: ColumnLayout {
                Layout.fillWidth: true
                property alias paramType: paramDescriptorDelegate.paramType
                property alias value: paramDescriptorDelegate.value
                property alias considerParam: paramCheckBox.checked
                property alias operatorType: paramDescriptorDelegate.operatorType
                CheckBox {
                    id: paramCheckBox
                    text: qsTr("Only consider event if")
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                }

                ParamDescriptorDelegate {
                    id: paramDescriptorDelegate
                    enabled: paramCheckBox.checked
                    Layout.fillWidth: true
                    paramType: root.eventType.paramTypes.get(index)
                    value: paramType.defaultValue
                }
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
                root.eventDescriptor.paramDescriptors.clear();
                for (var i = 0; i < delegateRepeater.count; i++) {
                    var paramDelegate = delegateRepeater.itemAt(i);
                    if (paramDelegate.considerParam) {
                        if (root.device) {
                            root.eventDescriptor.paramDescriptors.setParamDescriptor(paramDelegate.paramType.id, paramDelegate.value, paramDelegate.operatorType)
                        } else if (root.iface) {
                            print("setting param descriptors by name", root.eventType.paramTypes.get(i), root.eventType.paramTypes.get(i).name)
                            root.eventDescriptor.paramDescriptors.setParamDescriptorByName(root.eventType.paramTypes.get(i).name, paramDelegate.value, paramDelegate.operatorType)
                        }
                    }
                }
                root.completed()
            }
        }
    }
}
