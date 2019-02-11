import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root

    property DeviceClass deviceClass: device ? device.deviceClass : null

    // Optional: If set, it will be reconfigred, otherwise a new one will be created
    property Device device: null

    signal done();

    header: GuhHeader {
        text: qsTr("Set up thing")
        onBackPressed: {
            if (internalPageStack.depth > 1) {
                internalPageStack.pop();
            } else {
                pageStack.pop();
            }
        }

        HeaderButton {
            imageSource: "../images/close.svg"
            onClicked: root.done();
        }
    }

    QtObject {
        id: d
        property var vendorId: null
        property DeviceDescriptor deviceDescriptor: null
        property var discoveryParams: []
        property string deviceName: ""
        property int pairRequestId: 0
        property var pairingTransactionId: null
        property int addRequestId: 0
    }

    Component.onCompleted: {
        if (root.deviceClass.createMethods.indexOf("CreateMethodDiscovery") !== -1) {
            if (deviceClass["discoveryParamTypes"].count > 0) {
                internalPageStack.push(discoveryParamsPage)
            } else {
                discovery.discoverDevices(deviceClass.id)
                internalPageStack.push(discoveryPage, {deviceClass: deviceClass})
            }
        } else if (deviceClass.createMethods.indexOf("CreateMethodUser") !== -1) {
            internalPageStack.push(paramsPage)
        }
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
        onReconfigureDeviceReply: {
            busyOverlay.shown = false;
            internalPageStack.push(resultsPage, {success: params["deviceError"] === "DeviceErrorNoError", deviceId: params["deviceId"]})
        }
    }

    DeviceDiscovery {
        id: discovery
        engine: _engine
    }

    StackView {
        id: internalPageStack
        anchors.fill: parent
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
                            model: root.deviceClass ? root.deviceClass["discoveryParamTypes"] : null
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
                                var paramTypes = root.deviceClass["discoveryParamTypes"];
                                d.discoveryParams = [];
                                for (var i = 0; i < paramTypes.count; i++) {
                                    var param = {};
                                    param["paramTypeId"] = paramTypes.get(i).id;
                                    param["value"] = paramRepeater.itemAt(i).value
                                    d.discoveryParams.push(param);
                                }
                                discovery.discoverDevices(root.deviceClass.id, d.discoveryParams)
                                internalPageStack.push(discoveryPage, {deviceClass: root.deviceClass})
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

            ColumnLayout {
                anchors.fill: parent

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: DeviceDiscoveryProxy {
                        id: discoveryProxy
                        deviceDiscovery: discovery
                        showAlreadyAdded: root.device !== null
                        showNew: root.device === null
                        filterDeviceId: root.device !== null ? root.device.id : null
                    }
                    delegate: MeaListItemDelegate {
                        width: parent.width
                        height: app.delegateHeight
                        text: model.name
                        subText: model.description
                        iconName: app.interfacesToIcon(discoveryView.deviceClass.interfaces)
                        onClicked: {
                            d.deviceDescriptor = discoveryProxy.get(index);
                            d.deviceName = model.name;

                            // Overriding params for reconfiguring discovered devices not supported by core yet
                            // So if we are reconfiguring and discovering, go straight to end

                            if (root.device && d.deviceDescriptor) {
                                busyOverlay.shown = true;

                                switch (root.deviceClass.setupMethod) {
                                case 0:
                                    engine.deviceManager.reconfigureDiscoveredDevice(root.device.id, d.deviceDescriptor.id);
                                    break;
                                case 1:
                                case 2:
                                case 3:
                                    engine.deviceManager.pairDevice(root.deviceClass.id, d.deviceDescriptor.id, root.device.name);
                                    break;
                                }

                                return;
                            }

                            internalPageStack.push(paramsPage)
                        }
                    }
                }
                Button {
                    id: retryButton
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    text: qsTr("Search again")
                    onClicked: discovery.discoverDevices(root.deviceClass.id, d.discoveryParams)
                    visible: !discovery.busy
                }

                Button {
                    id: manualAddButton
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.bottomMargin: app.margins
                    visible: root.deviceClass.createMethods.indexOf("CreateMethodUser") >= 0
                    text: qsTr("Add thing manually")
                    onClicked: internalPageStack.push(paramsPage)
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
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - app.margins * 2
                visible: !discovery.busy && discoveryProxy.count === 0
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

                    ColumnLayout {
                        visible: root.device === null
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
                    }

                    Repeater {
                        id: paramRepeater
                        model: engine.jsonRpcClient.ensureServerVersion("1.12") || d.deviceDescriptor == null ?  root.deviceClass.paramTypes : null
                        delegate: ParamDelegate {
//                            Layout.preferredHeight: 60
                            Layout.fillWidth: true
                            paramType: root.deviceClass.paramTypes.get(index)
                            value: d.deviceDescriptor && d.deviceDescriptor.params.getParam(paramType.id) ?
                                       d.deviceDescriptor.params.getParam(paramType.id).value :
                                       root.deviceClass.paramTypes.get(index).defaultValue
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins

                        text: "OK"
                        onClicked: {
                            print("setupMethod", root.deviceClass.setupMethod)

                            var params = []
                            for (var i = 0; i < paramRepeater.count; i++) {
                                var param = {}
                                param.paramTypeId = paramRepeater.itemAt(i).paramType.id
                                param.value = paramRepeater.itemAt(i).value
                                print("adding param", param.paramTypeId, param.value)
                                params.push(param)
                            }

                            switch (root.deviceClass.setupMethod) {
                            case 0:
                                if (root.device !== null) {
                                    if (d.deviceDescriptor) {
                                        engine.deviceManager.reconfigureDiscoveredDevice(root.device.id, d.deviceDescriptor.id);
                                    } else {
                                        engine.deviceManager.reconfigureDevice(root.device.id, params);
                                    }
                                } else {
                                    if (d.deviceDescriptor) {
                                        engine.deviceManager.addDiscoveredDevice(root.deviceClass.id, d.deviceDescriptor.id, nameTextField.text, params);
                                    } else {
                                        engine.deviceManager.addDevice(root.deviceClass.id, nameTextField.text, params);
                                    }
                                }
                                break;
                            case 1:
                            case 2:
                            case 3:
                                engine.deviceManager.pairDevice(root.deviceClass.id, d.deviceDescriptor.id, nameTextField.text);
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

            readonly property var device: root.device ? root.device : engine.deviceManager.devices.getDevice(deviceId)

            ColumnLayout {
                width: parent.width - app.margins * 2
                anchors.centerIn: parent
                spacing: app.margins * 2
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: resultsView.success ? root.device ? qsTr("Thing reconfigured!") : qsTr("Thing added!") : qsTr("Uh oh")
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
                    onClicked: {
                        root.done();
                    }
                }
            }
        }
    }

    BusyOverlay {
        id: busyOverlay
    }
}
