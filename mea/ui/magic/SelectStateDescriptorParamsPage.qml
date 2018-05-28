import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "../components"
import "../delegates"
import Mea 1.0

Page {
    id: root
    // Needs to be set and filled in with deviceId and eventTypeId
    property var stateDescriptor: null

    readonly property var device: stateDescriptor && stateDescriptor.deviceId ? Engine.deviceManager.devices.getDevice(stateDescriptor.deviceId) : null
    readonly property var stateType: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId).stateTypes.getStateType(stateDescriptor.stateTypeId) : null

    signal backPressed();
    signal completed();

    header: GuhHeader {
        text: qsTr("params")
        onBackPressed: root.backPressed();
    }

    ColumnLayout {
        anchors.fill: parent
        ParamDescriptorDelegate {
            id: paramDelegate
            Layout.fillWidth: true
            paramType: root.stateType
            value: paramType.defaultValue
        }
        Button {
            text: qsTr("OK")
            Layout.fillWidth: true
            Layout.margins: app.margins
            onClicked: {
                root.stateDescriptor.valueOperator = paramDelegate.operatorType
                root.stateDescriptor.value = paramDelegate.value
                root.completed()
            }
        }
    }
}
