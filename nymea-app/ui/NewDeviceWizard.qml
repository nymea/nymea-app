import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import Nymea 1.0
import "components"
import "delegates"

Page {
    id: root

    header: GuhHeader {
        text: qsTr("Set up new thing")
        backButtonVisible: internalPageStack.depth > 1
        onBackPressed: {
            internalPageStack.pop();
        }

        HeaderButton {
            imageSource: "../images/close.svg"
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
    }

    Connections {
        target: engine.deviceManager
        onPairDeviceReply: {
            busyOverlay.shown = false
            switch (params["setupMethod"]) {
            case "SetupMethodPushButton":
                d.pairingTransactionId = params["pairingTransactionId"];
                print("response", params["displayMessage"], d.pairingTransactionId)
                internalPageStack.push(pairingPageComponent, {text: params["displayMessage"]})
                break;
            case "SetupMethodDisplayPin":
                d.pairingTransactionId = params["pairingTransactionId"];
                internalPageStack.push(pairingPageComponent, {text: params["displayMessage"], setupMethod: params["setupMethod"]})
                break;
            default:
                print("Setup method", params["setupMethod"], "not handled");

            }
        }
        onConfirmPairingReply: {
            busyOverlay.shown = false
            internalPageStack.push(resultsPage, {success: params["deviceError"] === "DeviceErrorNoError", deviceId: params["deviceId"]})
        }
        onAddDeviceReply: {
            busyOverlay.shown = false;
            internalPageStack.push(resultsPage, {success: params["deviceError"] === "DeviceErrorNoError", deviceId: params["deviceId"]})
        }
    }

    DeviceDiscovery {
        id: discovery
        jsonRpcClient: engine.jsonRpcClient
    }

    StackView {
        id: internalPageStack
        anchors.fill: parent
        initialItem: Page {
            ListView {
                anchors.fill: parent
                model: VendorsProxy {
                    vendors: engine.deviceManager.vendors
                }
                delegate: MeaListItemDelegate {
                    width: parent.width
                    text: model.displayName

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
                    deviceClasses: engine.deviceManager.deviceClasses
                }
                delegate: MeaListItemDelegate {
                    id: deviceClassDelegate
                    width: parent.width
                    text: model.displayName
                    iconName: app.interfacesToIcon(deviceClass.interfaces)

                    property var deviceClass: deviceClassesProxy.get(index)

                    onClicked: {
                        d.deviceClass = deviceClass
                        if (deviceClass.createMethods.indexOf("CreateMethodDiscovery") !== -1) {
                            if (deviceClass["discoveryParamTypes"].count > 0) {
                                internalPageStack.push(discoveryParamsPage)
                            } else {
                                discovery.discoverDevices(deviceClass.id)
                                internalPageStack.push(discoveryPage, {deviceClass: deviceClass})
                            }
                        } else if (deviceClass.createMethods.indexOf("CreateMethodUser") !== -1) {
                            internalPageStack.push(paramsPage)
                        }

                        print("should setup", deviceClass.name, deviceClass.setupMethod, deviceClass.createMethods, deviceClass["discoveryParamTypes"].count)
                    }

                    swipe.enabled: true// deviceClass.createMethods.indexOf("CreateMethodUser") !== -1
                    swipe.right: MouseArea {
                        height: deviceClassDelegate.height
                        width: height
                        anchors.right: parent.right
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                        }

                        ColorIcon {
                            anchors.fill: parent
                            anchors.margins: app.margins
                            name: "../images/add.svg"
                        }
                        onClicked: {
                            d.deviceClass = deviceClass
                            internalPageStack.push(paramsPage)
                        }
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

                Flickable {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    ColumnLayout {
                        width: parent.width

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
                                internalPageStack.push(discoveryPage, {deviceClass: d.deviceClass})
                            }
                        }
                    }
                }

                Component {
                    id: searchStringEntryComponent
                    ColumnLayout {
                        property alias value: searchTextField.text
                        Label {
                            text: discoveryParams.displayName
                            Layout.fillWidth: true
                        }
                        TextField {
                            id: searchTextField
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }

    Component {
        id: discoveryPage

        Page {
            id: discoveryView

            property var deviceClass: null

            ListView {
                anchors.fill: parent
                model: discovery
                delegate: MeaListItemDelegate {
                    width: parent.width
                    height: app.delegateHeight
                    text: model.name
                    subText: model.description
                    iconName: app.interfacesToIcon(discoveryView.deviceClass.interfaces)
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
                    text: qsTr("Searching for things...")
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
                    text: qsTr("Too bad...")
                    font.pixelSize: app.largeFont
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("No things of this kind could be found...")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Make sure your things are set up and connected, try searching again or go back and pick a different kind of thing.")
                    wrapMode: Text.WordWrap
                }
                Button {
                    text: qsTr("Try again!")
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
            Flickable {
                anchors.fill: parent
                contentHeight: paramsColumn.implicitHeight

                ColumnLayout {
                    id: paramsColumn
                    width: parent.width

                    Label {
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        Layout.topMargin: app.margins
                        Layout.fillWidth: true
                        text: qsTr("Name the thing:")
                    }
                    TextField {
                        id: nameTextField
                        text: d.deviceName ? d.deviceName : ""
                        Layout.fillWidth: true
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                    }

                    ThinDivider {
                        visible: paramRepeater.count > 0
                    }

                    Repeater {
                        id: paramRepeater
                        model: d.deviceDescriptorId == null ? d.deviceClass.paramTypes : null
                        delegate: ParamDelegate {
//                            Layout.preferredHeight: 60
                            Layout.fillWidth: true
                            paramType: d.deviceClass.paramTypes.get(index)
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins

                        text: "OK"
                        onClicked: {
                            print("setupMethod", d.deviceClass.setupMethod)
                            switch (d.deviceClass.setupMethod) {
                            case 0:
                                if (d.deviceDescriptorId) {
                                    engine.deviceManager.addDiscoveredDevice(d.deviceClass.id, d.deviceDescriptorId, nameTextField.text);
                                } else {
                                    var params = []
                                    for (var i = 0; i < paramRepeater.count; i++) {
                                        var param = {}
                                        param.paramTypeId = paramRepeater.itemAt(i).paramType.id
                                        param.value = paramRepeater.itemAt(i).value
                                        print("adding param", param.paramTypeId, param.value)
                                        params.push(param)
                                    }

                                    engine.deviceManager.addDevice(d.deviceClass.id, nameTextField.text, params);
                                }

                                break;
                            case 1:
                            case 2:
                            case 3:
                                engine.deviceManager.pairDevice(d.deviceClass.id, d.deviceDescriptorId, nameTextField.text);
                                break;
                            }

                            busyOverlay.shown = true;

                        }
                    }
                }
            }
        }
    }

    Component {
        id: pairingPageComponent
        Page {
            id: pairingPage
            property alias text: textLabel.text

            property string setupMethod

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - app.margins * 2
                spacing: app.margins * 2

                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    font.pixelSize: app.largeFont
                    text: qsTr("Pairing...")
                    color: app.accentColor
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    id: textLabel
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
                TextField {
                    id: pinTextField
                    Layout.fillWidth: true
                    visible: pairingPage.setupMethod === "SetupMethodDisplayPin"
                }

                Button {
                    Layout.fillWidth: true
                    text: "OK"
                    onClicked: {
                        engine.deviceManager.confirmPairing(d.pairingTransactionId, pinTextField.displayText);
                    }
                }
            }
        }
    }

    Component {
        id: resultsPage

        Page {
            id: resultsView

            property bool success
            property string deviceId

            readonly property var device: engine.deviceManager.devices.getDevice(deviceId)

            ColumnLayout {
                width: parent.width - app.margins * 2
                anchors.centerIn: parent
                spacing: app.margins * 2
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: resultsView.success ? qsTr("Thing added!") : qsTr("Uh oh")
                    font.pixelSize: app.largeFont
                    color: app.accentColor
                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: resultsView.success ? qsTr("All done. You can now start using %1.").arg(resultsView.device.name) : qsTr("Something went wrong setting up this thing...");
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Ok")
                    onClicked: pageStack.pop();
                }
            }
        }
    }

    BusyOverlay {
        id: busyOverlay
    }
}
