import QtQuick 2.4
import QtQuick.Controls 2.1
import "../components"
import Guh 1.0

Page {
    id: root
    property alias text: header.text

    // a ruleAction object needs to be set and prefilled with either deviceId or interfaceName
    property var stateDescriptor: null

    readonly property var device: stateDescriptor && stateDescriptor.deviceId ? Engine.deviceManager.devices.getDevice(stateDescriptor.deviceId) : null
    readonly property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null

    signal backPressed();
    signal done();

    header: GuhHeader {
        id: header
        onBackPressed: root.backPressed();
    }

    ListView {
        id: listView
        anchors.fill: parent
        model: root.deviceClass.stateTypes

        delegate: ItemDelegate {
            text: model.displayName
            width: parent.width
            onClicked: {
                var stateType = root.deviceClass.stateTypes.getStateType(model.id);
                console.log("StateType", stateType.id, "selected.")
                root.stateDescriptor.stateTypeId = stateType.id;
                var paramsPage = pageStack.push(Qt.resolvedUrl("SelectStateDescriptorParamsPage.qml"), {stateDescriptor: root.stateDescriptor})
                paramsPage.onBackPressed.connect(function() { pageStack.pop(); });
                paramsPage.onCompleted.connect(function() {
                    pageStack.pop();
                    root.done();
                })
            }
        }
    }
}
