import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import Guh 1.0
import "components"
import "paramdelegates"

Page {
    id: root

    header: GuhHeader {
        text: "Set up new thing"
        backButtonVisible: internalPageStack.depth > 1
        onBackPressed: {
            internalPageStack.pop();
        }

        HeaderButton {
            imageSource: "images/close.svg"
            onClicked: pageStack.pop();
        }
    }

    QtObject {
        id: d
        property var vendorId: null
        property var deviceClass: null
        property var deviceDescriptorId: null
        property var discoveryParams: []
        property var deviceName: null
        property int pairRequestId: 0
        property var pairingTransactionId: null
        property int addRequestId: 0
        property bool addResult: false
    }

    DeviceDiscovery {
        id: discovery
    }

    Connections {
        target: Engine.deviceManager
        onPairDeviceReply: {
            switch (params["setupMethod"]) {
            case "SetupMethodPushButton":
                d.pairingTransactionId = params["pairingTransactionId"];
                print("response", params["displayMessage"], d.pairingTransactionId)
                internalPageStack.push(pairingPage, {text: params["displayMessage"]})
                break;
            default:
                print("Setup method", params["setupMethod"], "not handled");

            }
        }
        onConfirmPairingReply: {
            print("result", params["deviceError"])
            d.addResult = (params["deviceError"] === "DeviceErrorNoError")
            internalPageStack.push(resultsPage)
        }
        onAddDeviceReply: {
            d.addResult = (params["deviceError"] === "DeviceErrorNoError")
            internalPageStack.push(resultsPage)
        }
    }

    StackView {
        id: internalPageStack
        anchors.fill: parent
        initialItem: Page {
            ListView {
                anchors.fill: parent
                model: VendorsProxy {
                    vendors: Engine.deviceManager.vendors
                }
                delegate: ItemDelegate {
                    width: parent.width
                    height: app.delegateHeight
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: app.margins
                        Label {
                            text: model.displayName
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    onClicked: {
                        d.vendorId = model.id
                        internalPageStack.push(deviceClassesPage)
                    }
                }
            }
        }
    }


    Component {
        id: deviceClassesPage
        Page {
            ListView {
                anchors.fill: parent
                model: DeviceClassesProxy {
                    id: deviceClassesProxy
                    vendorId: d.vendorId ? d.vendorId : ""
                    deviceClasses: Engine.deviceManager.deviceClasses
                }
                delegate: ItemDelegate {
                    width: parent.width
                    height: app.delegateHeight
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: app.margins
                        Label {
                            text: model.displayName
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    onClicked: {
                        var deviceClass = deviceClassesProxy.get(index)
                        d.deviceClass = deviceClass
                        if (deviceClass.createMethods.indexOf("CreateMethodDiscovery") !== -1) {
                            if (deviceClass["discoveryParamTypes"].count > 0) {
                                internalPageStack.push(discoveryParamsPage)
                            } else {
                                discovery.discoverDevices(deviceClass.id)
                                internalPageStack.push(discoveryPage)
                            }
                        } else if (deviceClass.createMethods.indexOf("CreateMethodUser") !== -1) {
                            internalPageStack.push(paramsPage)
                        }

                        print("should setup", deviceClass.name, deviceClass.setupMethod, deviceClass.createMethods, deviceClass["discoveryParamTypes"].count)
                    }
                }
            }
        }
    }
    Component {
        id: discoveryParamsPage
        Page {

            id: discoveryParamsView
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                Repeater {
                    id: paramRepeater
                    model: d.deviceClass ? d.deviceClass["discoveryParamTypes"] : null
                    Loader {
                        Layout.fillWidth: true
                        sourceComponent: searchStringEntryComponent
                        property var discoveryParams: model
                        property var value: item ? item.value : null
                    }
                }
                Component {
                    id: searchStringEntryComponent
                    ColumnLayout {
                        property alias value: searchTextField.text
                        Label {
                            text: discoveryParams.name
                            Layout.fillWidth: true
                        }
                        TextField {
                            id: searchTextField
                            Layout.fillWidth: true
                        }
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: "Next"
                    onClicked: {
                        var paramTypes = d.deviceClass["discoveryParamTypes"];
                        d.discoveryParams = [];
                        for (var i = 0; i < paramTypes.count; i++) {
                            var param = {};
                            param["paramTypeId"] = paramTypes.get(i).id;
                            param["value"] = paramRepeater.itemAt(i).value
                            d.discoveryParams.push(param);
                        }
                        discovery.discoverDevices(d.deviceClass.id, d.discoveryParams)
                        internalPageStack.push(discoveryPage)
                    }
                }
            }
        }
    }


    Component {
        id: discoveryPage

        Page {
            id: discoveryView
            ListView {
                anchors.fill: parent
                model: discovery
                delegate: ItemDelegate {
                    width: parent.width
                    height: app.delegateHeight
                    ColumnLayout {
                        anchors { fill: parent; margins: app.margins }
                        Label {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: model.name
                        }
                        Label {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: model.description
                            font.pixelSize: app.smallFont
                        }
                    }
                    onClicked: {
                        d.deviceDescriptorId = model.id;
                        d.deviceName = model.name;
                        internalPageStack.push(paramsPage)
                    }
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - app.margins * 2
                visible: discovery.busy
                spacing: app.margins * 2
                Label {
                    text: "Searching for things..."
                    Layout.fillWidth: true
                    font.pixelSize: app.largeFont
                    horizontalAlignment: Text.AlignHCenter
                }
                BusyIndicator {
                    running: visible
                    onRunningChanged: print("********* running changed", running)
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - app.margins * 2
                visible: !discovery.busy && discovery.count == 0
                spacing: app.margins * 2
                Label {
                    text: "Too bad..."
                    font.pixelSize: app.largeFont
                    Layout.fillWidth: true
                }
                Label {
                    text: "No things of this kind could be found..."
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                Label {
                    Layout.fillWidth: true
                    text: "Make sure your things are set up and connected, try searching again or go back and pick a different kind of thing."
                    wrapMode: Text.WordWrap
                }
                Button {
                    text: "Try again!"
                    Layout.fillWidth: true
                    onClicked: {
                        discovery.discoverDevices(d.deviceClass.id, d.discoveryParams)
                    }
                }
            }
        }
    }

    Component {
        id: paramsPage

        Page {
            id: paramsView
            ColumnLayout {
                anchors.fill: parent
                spacing: app.margins
                ColumnLayout {
                    Layout.margins: app.margins
                    Layout.fillWidth: true
                    Label {
                        text: "Name the thing:"
                        Layout.fillWidth: true
                    }
                    TextField {
                        id: nameTextField
                        text: d.deviceName ? d.deviceName : ""
                        Layout.fillWidth: true
                    }
                }

                ThinDivider {}
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Column {
                        width: parent.width
                        Repeater {
                            id: paramRepeater
                            model: d.deviceClass.paramTypes
                            delegate: ParamDelegate {
                                width: parent.width
                                paramType: d.deviceClass.paramTypes.get(index)
                            }
                        }
                    }
                }


                Button {
                    Layout.fillWidth: true
                    text: "OK"
                    onClicked: {
                        print("setupMethod", d.deviceClass.setupMethod)
                        switch (d.deviceClass.setupMethod) {
                        case 0:
                            if (d.deviceDescriptorId) {
                                Engine.deviceManager.addDiscoveredDevice(d.deviceClass.id, d.deviceDescriptorId, nameTextField.text);
                            } else {
                                var params = []
                                for (var i = 0; i < paramRepeater.count; i++) {
                                    var param = {}
                                    param.paramTypeId = paramRepeater.itemAt(i).paramType.id
                                    param.value = paramRepeater.itemAt(i).value
                                    params.push(param)
                                }

                                Engine.deviceManager.addDevice(d.deviceClass.id, nameTextField.text, params);
                            }

                            break;
                        case 1:
                        case 2:
                        case 3:
                            Engine.deviceManager.pairDevice(d.deviceClass.id, d.deviceDescriptorId);
                            break;
                        }

                    }
                }
            }
        }
    }

    Component {
        id: pairingPage
        Page {
            property alias text: textLabel.text

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - app.margins * 2
                Label {
                    id: textLabel
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: app.largeFont
                }
                Button {
                    Layout.fillWidth: true
                    text: "OK"
                    onClicked: {
                        Engine.deviceManager.confirmPairing(d.pairingTransactionId, d.deviceDescriptorId);
                    }
                }
            }
        }
    }

    Component {
        id: resultsPage

        Page {
            id: resultsView
            Column {
                width: parent.width - 20
                anchors.centerIn: parent
                spacing: 20
                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: d.addResult ? "Thing added!" : "Uh oh, something went wrong...";
                }
                Button {
                    width: parent.width
                    text: "Ok"
                    onClicked: pageStack.pop();
                }
            }
        }
    }
}
