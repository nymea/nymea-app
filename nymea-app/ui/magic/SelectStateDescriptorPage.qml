import QtQuick 2.4
import QtQuick.Controls 2.1
import "../components"
import Nymea 1.0

Page {
    id: root
    property alias text: header.text

    // a ruleAction object needs to be set and prefilled with either deviceId or interfaceName
    property var stateDescriptor: null

    readonly property var device: stateDescriptor && stateDescriptor.deviceId ? engine.deviceManager.devices.getDevice(stateDescriptor.deviceId) : null
    readonly property var deviceClass: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null

    signal backPressed();
    signal done();

    onStateDescriptorChanged: buildInterface()
    Component.onCompleted: buildInterface()

    header: NymeaHeader {
        id: header
        onBackPressed: root.backPressed();

        property bool interfacesMode: root.stateDescriptor && root.stateDescriptor.interfaceName && root.stateDescriptor.interfaceName.length > 0
        onInterfacesModeChanged: root.buildInterface()

        HeaderButton {
            imageSource: header.interfacesMode ? "../images/view-expand.svg" : "../images/view-collapse.svg"
            visible: root.stateDescriptor && root.stateDescriptor.interfaceName.length === 0
            onClicked: header.interfacesMode = !header.interfacesMode
        }
    }

    ListModel {
        id: generatedModel
        ListElement { displayName: ""; stateTypeId: "" }
    }

    function buildInterface() {
        print("building interface:", header.interfacesMode, root.stateDescriptor, root.stateDescriptor.interfaceName)
        if (header.interfacesMode) {
            if (root.device) {
                generatedModel.clear();
                for (var i = 0; i < Interfaces.count; i++) {
                    var iface = Interfaces.get(i);
                    if (root.deviceClass.interfaces.indexOf(iface.name) >= 0) {
                        print("root has device class:", iface.name, iface.stateTypes.count)
                        for (var j = 0; j < iface.stateTypes.count; j++) {
                            var ifaceSt = iface.stateTypes.get(j);
                            print("ifaceSt:", ifaceSt, j, iface.stateTypes.count)
                            var dcSt = root.deviceClass.stateTypes.findByName(ifaceSt.name)
                            print("adding:", ifaceSt.displayName, dcSt.id)
                            generatedModel.append({displayName: ifaceSt.displayName, stateTypeId: dcSt.id})
                        }
                    }
                }
                listView.model = generatedModel
            } else if (root.stateDescriptor.interfaceName !== "") {
                listView.model = Interfaces.findByName(root.stateDescriptor.interfaceName).stateTypes
            } else {
                console.warn("You need to set device or interfaceName");
            }
        } else {
            if (root.device) {
                listView.model = deviceClass.stateTypes;
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent

        delegate: ItemDelegate {
            text: model.displayName
            width: parent.width
            onClicked: {
                if (header.interfacesMode) {
                    if (root.device) {
                        print("selected:", model.stateTypeId)
                        root.stateDescriptor.stateTypeId = model.stateTypeId;
                        var stateType = root.deviceClass.stateTypes.getStateType(model.stateTypeId)
                        var paramsPage = pageStack.push(Qt.resolvedUrl("SelectStateDescriptorParamsPage.qml"), {stateDescriptor: root.stateDescriptor})
                        paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                        paramsPage.onCompleted.connect(function() {
                            pageStack.pop();
                            root.done();
                        })
                    } else if (root.stateDescriptor.interfaceName !== "") {
                        root.stateDescriptor.interfaceState = model.name;
                        var paramsPage = pageStack.push(Qt.resolvedUrl("SelectStateDescriptorParamsPage.qml"), {stateDescriptor: root.stateDescriptor})
                        paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                        paramsPage.onCompleted.connect(function() {
                            pageStack.pop();
                            root.done();
                        })
                    } else {
                        console.warn("Neither deviceId not interfaceName set. Cannot continue...");
                    }
                } else {
                    if (root.device) {
                        var stateType = root.deviceClass.stateTypes.getStateType(model.id);
                        root.stateDescriptor.stateTypeId = model.id;
                        var paramsPage = pageStack.push(Qt.resolvedUrl("SelectStateDescriptorParamsPage.qml"), {stateDescriptor: root.stateDescriptor})
                        paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                        paramsPage.onCompleted.connect(function() {
                            pageStack.pop();
                            root.done();
                        })

                        print("have type", stateType.id)
                    } else {
                        console.warn("FIXME: not implemented yet");
                    }
                }
            }
        }
    }
}
