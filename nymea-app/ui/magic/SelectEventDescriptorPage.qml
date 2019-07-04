import QtQuick 2.4
import QtQuick.Controls 2.1
import "../components"
import Nymea 1.0

Page {
    id: root
    property alias text: header.text

    // an eventDescriptor object needs to be set and prefilled with either deviceId or interfaceName
    property var eventDescriptor: null

    readonly property var device: eventDescriptor && eventDescriptor.deviceId ? engine.deviceManager.devices.getDevice(eventDescriptor.deviceId) : null
    readonly property var deviceClass: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null

    signal backPressed();
    signal done();

    onEventDescriptorChanged: buildInterface()
    Component.onCompleted: buildInterface()

    header: NymeaHeader {
        id: header
        onBackPressed: root.backPressed();

        property bool interfacesMode: root.eventDescriptor.interfaceName !== ""
        onInterfacesModeChanged: root.buildInterface()

        HeaderButton {
            imageSource: header.interfacesMode ? "../images/view-expand.svg" : "../images/view-collapse.svg"
            visible: root.eventDescriptor.interfaceName === ""
            onClicked: header.interfacesMode = !header.interfacesMode
        }
    }

    ListModel {
        id: generatedModel
        ListElement { displayName: ""; eventTypeId: "" }
    }

    function buildInterface() {
        if (header.interfacesMode) {
            if (root.device) {
                generatedModel.clear();
                for (var i = 0; i < Interfaces.count; i++) {
                    var iface = Interfaces.get(i);
                    if (root.deviceClass.interfaces.indexOf(iface.name) >= 0) {
                        for (var j = 0; j < iface.eventTypes.count; j++) {
                            var ifaceEt = iface.eventTypes.get(j);
                            var dcEt = root.deviceClass.eventTypes.findByName(ifaceEt.name)
                            generatedModel.append({displayName: ifaceEt.displayName, eventTypeId: dcEt.id})
                        }
                    }
                }
                listView.model = generatedModel
            } else if (root.eventDescriptor.interfaceName !== "") {
                listView.model = Interfaces.findByName(root.eventDescriptor.interfaceName).eventTypes
            } else {
                console.warn("You need to set device or interfaceName");
            }
        } else {
            if (root.device) {
                listView.model = deviceClass.eventTypes;
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent

        delegate: ItemDelegate {
            width: parent.width
            text: model.displayName
            onClicked: {
                if (header.interfacesMode) {
                    if (root.device) {
                        root.eventDescriptor.eventTypeId = model.eventTypeId;
                        var eventType = root.deviceClass.eventTypes.getEventType(model.eventTypeId)
                        if (eventType.paramTypes.count > 0) {
                            var paramsPage = pageStack.push(Qt.resolvedUrl("SelectEventDescriptorParamsPage.qml"), {eventDescriptor: root.eventDescriptor})
                            paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                            paramsPage.onCompleted.connect(function() {
                                pageStack.pop();
                                root.done();
                            })
                        } else {
                            root.done();
                        }
                    } else if (root.eventDescriptor.interfaceName !== "") {
                        root.eventDescriptor.interfaceEvent = model.name;
                        if (listView.model.get(index).paramTypes.count > 0) {
                            var paramsPage = pageStack.push(Qt.resolvedUrl("SelectEventDescriptorParamsPage.qml"), {eventDescriptor: root.eventDescriptor})
                            paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                            paramsPage.onCompleted.connect(function() {
                                pageStack.pop();
                                root.done();
                            })
                        } else {
                            root.done();
                        }
                    } else {
                        console.warn("Neither deviceId not interfaceName set. Cannot continue...");
                    }
                } else {
                    if (root.device) {
                        var eventType = root.deviceClass.eventTypes.getEventType(model.id);
                        root.eventDescriptor.eventTypeId = model.id;
                        if (eventType.paramTypes.count > 0) {
                            var paramsPage = pageStack.push(Qt.resolvedUrl("SelectEventDescriptorParamsPage.qml"), {eventDescriptor: root.eventDescriptor})
                            paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                            paramsPage.onCompleted.connect(function() {
                                pageStack.pop();
                                root.done();
                            })
                        } else {
                            root.done();
                        }

                        print("have type", eventType.id)
                    } else {
                        console.warn("FIXME: not implemented yet");
                    }
                }
            }
        }
    }
}
