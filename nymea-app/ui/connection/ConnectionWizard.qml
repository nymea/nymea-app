import QtQuick 2.3
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import Qt.labs.settings 1.1

import "../components"
import Nymea 1.0

WizardPageBase {
    id: root
    title: qsTr("Welcome")
    text: qsTr("This wizard will guide you through the process of setting up a new nymea system.")
    showBackButton: false
    showExtraButton: true
    extraButtonText: qsTr("Demo mode")

    onNext: {
        if (PlatformPermissions.localNetworkPermission !== PlatformPermissions.PermissionStatusGranted) {
            PlatformPermissions.requestPermission(PlatformPermissions.PermissionLocalNetwork)
        }
        pageStack.push(connectionSelectionComponent)
    }
    onExtraButtonPressed: {
        var host = nymeaDiscovery.nymeaHosts.createWanHost("Demo server", "nymea://nymea.nymea.io:2223")
        engine.jsonRpcClient.addToken("{6c047fec-78da-46af-990a-8f687216ae1b}", "demousertoken");
        engine.jsonRpcClient.connectToHost(host)
    }

    content: ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        Layout.preferredHeight: root.visibleContentHeight

        Item { Layout.fillHeight: true }

        ColumnLayout {
            Layout.fillHeight: false
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: Style.hugeIconSize * 2
                ColorIcon {
                    anchors.centerIn: parent
                    size: Math.min(parent.width, parent.height, Style.hugeIconSize * 2)
                    name: "nymea-logo"
                }
            }

            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                horizontalAlignment: Text.AlignHCenter
                text: "nymea"
                font: Style.hugeFont
            }
        }
        Item { Layout.fillHeight: true }

        ColumnLayout {
            Layout.fillHeight: false
            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                wrapMode: Text.WordWrap
                font: Style.smallFont
                text: qsTr("In order to use nymea, you will need to install nymea:core on a computer in your network. This can be a Raspberry Pi or any generic Linux computer.")
                horizontalAlignment: Text.AlignHCenter
            }
            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                wrapMode: Text.WordWrap
                font: Style.smallFont
                text: qsTr("Please follow the installation instructions on %1 to install a nymea system.").arg('<a href="https://nymea.io/documentation/users/installation/core">nymea.io</a>')
                horizontalAlignment: Text.AlignHCenter
                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
        Item { Layout.fillHeight: true }
    }

    Component {
        id: connectionSelectionComponent
        WizardPageBase {
            id: connectionSelectionPage
            title: qsTr("Connectivity")
            text: qsTr("How would you like to connect nymea to your network?")

            nextButtonText: qsTr("Skip")

            onNext: pageStack.push(selectInstanceComponent)
            onBack: pageStack.pop()

            content: ColumnLayout {
                Layout.fillWidth: true
                Layout.maximumWidth: 500
                Layout.preferredHeight: connectionSelectionPage.visibleContentHeight
                Layout.alignment: Qt.AlignHCenter

                BigTile {
                    Layout.fillWidth: true

                    onClicked: pageStack.push(wiredInstructionsComponent)

                    contentItem: RowLayout {
                        spacing: Style.margins
                        ColorIcon {
                            size: Style.hugeIconSize
                            name: "connections/network-wired"
                            color: Style.accentColor
                        }
                        ColumnLayout {
                            Label {
                                Layout.fillWidth: true
                                text: qsTr("Wired network")
                            }
                            Label {
                                Layout.fillWidth: true
                                text: qsTr("Connect nymea to your network using a network cable. This is recommended for best performance.")
                                font: Style.smallFont
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }

                BigTile {
                    Layout.fillWidth: true

                    onClicked: {
                        if (PlatformPermissions.bluetoothPermission != PlatformPermissions.PermissionStatusGranted) {
                            PlatformPermissions.requestPermission(PlatformPermissions.PermissionBluetooth)
                        }
                        pageStack.push(wirelessInstructionsComponent)
                    }

                    contentItem: RowLayout {
                        spacing: Style.margins
                        ColorIcon {
                            size: Style.hugeIconSize
                            name: "connections/network-wifi"
                            color: Style.accentColor
                        }
                        ColumnLayout {
                            Label {
                                Layout.fillWidth: true
                                text: qsTr("Wireless network")
                            }
                            Label {
                                Layout.fillWidth: true
                                text: qsTr("Connect nymea to your WiFi network.")
                                font: Style.smallFont
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }

                Label {
                    Layout.fillWidth: true
                    Layout.margins: Style.smallMargins
                    wrapMode: Text.WordWrap
                    text: qsTr("If your nymea system is already connected to the network you can skip this step.")
                    horizontalAlignment: Qt.AlignHCenter
                    font: Style.smallFont
                }
            }
        }
    }

    Component {
        id: selectInstanceComponent
        WizardPageBase {
            title: qsTr("Connection")
            text: qsTr("Select nymea system")
            nextButtonText: qsTr("Manual connection")
            onNext: pageStack.push(manualConnectionComponent)

            onBack: pageStack.pop()

            content: ColumnLayout {
                Layout.maximumWidth: 500
                Layout.alignment: Qt.AlignHCenter

                Repeater {
                    model: NymeaHostsFilterModel {
                        id: hostsProxy
                        discovery: nymeaDiscovery
                        showUnreachableBearers: false
                        jsonRpcClient: engine.jsonRpcClient
                        showUnreachableHosts: false
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        width: parent.width
                        visible: hostsProxy.count == 0
                        spacing: Style.margins
                        BusyIndicator {
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Label {
                            Layout.fillWidth: true
                            Layout.margins: Style.margins
                            text: qsTr("Please wait while your nymea system is being discovered.")
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }


                    delegate: NymeaSwipeDelegate {
                        id: nymeaHostDelegate
                        Layout.fillWidth: true
                        property var nymeaHost: hostsProxy.get(index)
                        property string defaultConnectionIndex: {
                            if (!nymeaHost) {
                                return -1
                            }

                            var bestIndex = -1
                            var bestPriority = 0;
                            for (var i = 0; i < nymeaHost.connections.count; i++) {
                                var connection = nymeaHost.connections.get(i);
                                if (bestIndex === -1 || connection.priority > bestPriority) {
                                    bestIndex = i;
                                    bestPriority = connection.priority;
                                }
                            }
                            return bestIndex;
                        }
                        iconName: {
                            if (!nymeaHost) {
                                return
                            }

                            switch (nymeaHost.connections.get(defaultConnectionIndex).bearerType) {
                            case Connection.BearerTypeLan:
                            case Connection.BearerTypeWan:
                                if (engine.jsonRpcClient.availableBearerTypes & NymeaConnection.BearerTypeEthernet != NymeaConnection.BearerTypeNone) {
                                    return "qrc:/icons/connections/network-wired.svg"
                                }
                                return "qrc:/icons/connections/network-wifi.svg";
                            case Connection.BearerTypeBluetooth:
                                return "qrc:/icons/connections/bluetooth.svg";
                            case Connection.BearerTypeCloud:
                                return "qrc:/icons/connections/cloud.svg"
                            case Connection.BearerTypeLoopback:
                                return "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
                            }
                            return ""
                        }
                        text: model.name
                        subText: nymeaHost ? nymeaHost.connections.get(defaultConnectionIndex).url : ""
                        wrapTexts: false
                        prominentSubText: false
                        progressive: false
                        property bool isSecure: nymeaHost && nymeaHost.connections.get(defaultConnectionIndex).secure
                        property bool isOnline: nymeaHost && nymeaHost.connections.get(defaultConnectionIndex).bearerType !== Connection.BearerTypeWan ? nymeaHost.connections.get(defaultConnectionIndex).online : true
                        tertiaryIconName: isSecure ? "qrc:/icons/connections/network-secure.svg" : ""
                        secondaryIconName: !isOnline ? "qrc:/icons/connections/cloud-error.svg" : ""
                        secondaryIconColor: "red"

                        onClicked: {
                            engine.jsonRpcClient.connectToHost(nymeaHostDelegate.nymeaHost)
                        }

                        contextOptions: [
                            {
                                text: qsTr("Info"),
                                icon: Qt.resolvedUrl("qrc:/icons/info.svg"),
                                callback: function() {
                                    var nymeaHost = hostsProxy.get(index);
                                    var connectionInfoDialog = Qt.createComponent("/ui/components/ConnectionInfoDialog.qml")
                                    print("**", connectionInfoDialog.errorString())
                                    var popup = connectionInfoDialog.createObject(app,{nymeaEngine: engine, nymeaHost: nymeaHost})
                                    popup.open()
                                    popup.connectionSelected.connect(function(connection) {
                                        engine.jsonRpcClient.disconnectFromHost();
                                        engine.jsonRpcClient.connectToHost(nymeaHost, connection)
                                    })
                                }
                            }
                        ]
                    }
                }
            }
        }
    }

    Component {
        id: manualConnectionComponent
        WizardPageBase {
            title: qsTr("Manual connection")
            text: qsTr("Please enter the connection information for your nymea system")
            onBack: pageStack.pop()

            onNext: {
                var rpcUrl = manualEntry.rpcUrl;
                print("Try to connect ", rpcUrl)
                var host = nymeaDiscovery.nymeaHosts.createWanHost("Manual connection", rpcUrl);
                engine.jsonRpcClient.connectToHost(host)
            }

            content: ManualConnectionEntry {
                id: manualEntry
                Layout.fillWidth: true
                Layout.margins: Style.margins
                Layout.maximumWidth: 500
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    Component {
        id: wiredInstructionsComponent
        WizardPageBase {
            id: wiredInstructionsPage
            title: qsTr("Wired connection")
            text: qsTr("Connect the nymea system to your network using an ethernet cable and turn it on.")

            onNext: pageStack.push(selectInstanceComponent)
            onBack: pageStack.pop()

            content:Image {
                Layout.fillWidth: true
                Layout.preferredHeight: wiredInstructionsPage.visibleContentHeight - Style.margins * 2
                Layout.margins: Style.margins
                fillMode: Image.PreserveAspectFit
                sourceSize.width: width
                source: "qrc:/icons/setupwizard/wired-connection.svg"
            }
        }
    }

    Component {
        id: wirelessInstructionsComponent
        WizardPageBase {
            id: wirelessInstructionsPage
            title: qsTr("Wireless connection")
            text: qsTr("Turn the nymea system on by connecting the power cable and wait for it to start up.")

            onNext: pageStack.push(wirelessBluetoothDiscoveryComponent)
            onBack: pageStack.pop()

            content: Image {
                Layout.fillWidth: true
                Layout.preferredHeight: wirelessInstructionsPage.visibleContentHeight - Style.margins * 2
                Layout.margins: Style.margins
                fillMode: Image.PreserveAspectFit
                sourceSize.width: width
                source: "qrc:/icons/setupwizard/wireless-connection.svg"
            }
        }
    }
    Component {
        id: wirelessBluetoothDiscoveryComponent
        WizardPageBase {
            id: wirelessBluetoothDiscoveryPage
            title: qsTr("Wireless setup")
            text: qsTr("Searching for the nymea system...")
            showNextButton: false
            onBack: pageStack.pop()

            BtWiFiSetup {
                id: wifiSetup

                onBluetoothStatusChanged: {
                    print("status changed", status)
                    switch (status) {
                    case BtWiFiSetup.BluetoothStatusDisconnected:
                        pageStack.pop(wirelessBluetoothDiscoveryPage)
                        break;
                    case BtWiFiSetup.BluetoothStatusConnectingToBluetooth:
                        break;
                    case BtWiFiSetup.BluetoothStatusConnectedToBluetooth:
                        break;
                    case BtWiFiSetup.BluetoothStatusLoaded:
                        if (!wifiSetup.networkingEnabled) {
                            wifiSetup.networkingEnabled = true;
                        }
                        if (!wifiSetup.wirelessEnabled) {
                            wifiSetup.wirelessEnabled = true;
                        }
                        pageStack.pop(wirelessBluetoothDiscoveryPage, StackView.Immediate)
                        pageStack.push(wirelessSelectWifiComponent, {wifiSetup: wifiSetup})
                        break;
                    }
                }
                onBluetoothConnectionError: {
                    pageStack.pop(wirelessBluetoothDiscoveryPage, StackView.Immediate)
                    pageStack.push(wirelessBtErrorComponent)
                }

                onCurrentConnectionChanged: {
                    if (wifiSetup.currentConnection) {
                        print("**** connected!")
                        pageStack.push(wirelessConnectionCompletedComponent, {wifiSetup: wifiSetup})
                    }
                }
                onWirelessStatusChanged: {
                    print("Wireless status changed:", wifiSetup.networkStatus)
                    if (wifiSetup.wirelessStatus === BtWiFiSetup.WirelessStatusFailed) {
                        pageStack.pop()
                    }
                }
            }

            BluetoothDiscovery {
                id: bluetoothDiscovery
                discoveryEnabled: pageStack.currentItem === wirelessBluetoothDiscoveryPage && PlatformHelper.locationServicesEnabled
            }

            content: ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: visibleContentHeight
                Layout.maximumWidth: 500
                Layout.alignment: Qt.AlignHCenter

                model: BluetoothDeviceInfosProxy {
                    id: deviceInfosProxy
                    model: bluetoothDiscovery.deviceInfos
                    filterForLowEnergy: true
                    filterForServiceUUID: "e081fec0-f757-4449-b9c9-bfa83133f7fc"
                    nameWhitelist: ["BT WLAN setup"]
                }

                BusyIndicator {
                    anchors.centerIn: parent
                    visible: bluetoothDiscovery.discovering && deviceInfosProxy.count == 0 && bluetoothDiscovery.bluetoothAvailable && bluetoothDiscovery.bluetoothEnabled && PlatformHelper.locationServicesEnabled
                }

                delegate: NymeaSwipeDelegate {
                    width: parent.width
                    iconName: Qt.resolvedUrl("qrc:/icons/connections/bluetooth.svg")
                    text: model.name
                    subText: model.address

                    onClicked: {
                        wifiSetup.connectToDevice(deviceInfosProxy.get(index))
                        pageStack.push(wirelessBluetoothConnectingComponent)
                    }
                }

                ColumnLayout {
                    width: parent.width - Style.margins * 2
                    anchors.centerIn: parent
                    spacing: Style.bigMargins
                    visible: !bluetoothDiscovery.bluetoothAvailable || !bluetoothDiscovery.bluetoothEnabled || !PlatformHelper.locationServicesEnabled

                    ColorIcon {
                        name: "qrc:/icons/connections/bluetooth.svg"
                        size: Style.iconSize * 5
                        color: !bluetoothDiscovery.bluetoothAvailable ? Style.red : Style.gray
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        visible: !bluetoothDiscovery.bluetoothAvailable || !bluetoothDiscovery.bluetoothEnabled
                        text: !bluetoothDiscovery.bluetoothAvailable
                              ? qsTr("Bluetooth doesn't seem to be available on this system.")
                              : qsTr("Bluetooth is turned off. Please enable Bluetooth on this device.")
                    }

                    Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        visible: !PlatformHelper.locationServicesEnabled
                        text: qsTr("Location services are disabled. Please enable location services on this device in order to search for nearby nymea systems.")
                    }
                }

            }
        }
    }

    Component {
        id: wirelessBluetoothConnectingComponent
        WizardPageBase {
            title: qsTr("Wireless setup")
            text: qsTr("Connecting to the nymea system...")
            showNextButton: false
            showBackButton: false

            content: Item {
                Layout.fillWidth: true
                Layout.preferredHeight: visibleContentHeight
                BusyIndicator {
                    anchors.centerIn: parent
                }
            }
        }
    }

    Component {
        id: wirelessSelectWifiComponent
        WizardPageBase {
            title: qsTr("Wireless setup")
            text: qsTr("Select the WiFi you want to use.")
            showNextButton: false
            onBack: pageStack.pop()

            headerButtons: [
                {
                    iconSource: "qrc:/icons/filters.svg",
                    color: Style.iconColor,
                    trigger: function() {
                        pageStack.push(Qt.createComponent("/ui/system/WirelessNetworksFilterSettingsPage.qml"),
                                       { wirelessAccessPointsProxy: wirelessAccessPointsModel });
                    },
                    visible: true
                }
            ]

            Settings {
                id: settings
                property bool wirelessShowDuplicates: false
            }

            WirelessAccessPointsProxy {
                id: wirelessAccessPointsModel
                showDuplicates: settings.wirelessShowDuplicates
                accessPoints: wifiSetup.accessPoints
            }

            property var wifiSetup: null

            Component.onCompleted: {
                wifiSetup.scanWiFi()
            }

            content: ColumnLayout {
                Layout.fillWidth: true
                Layout.maximumWidth: 500
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: visibleContentHeight

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    model: wirelessAccessPointsModel
                    clip: true

                    delegate: NymeaItemDelegate {
                        width: parent.width
                        text: model.ssid !== "" ? model.ssid : qsTr("Hidden Network")
                        subText: model.macAddress + (model.hostAddress === "" ? "" : (" (" + model.hostAddress + ")"))
                        prominentSubText: false
                        iconColor: model.selectedNetwork ? Style.accentColor : "#808080"
                        iconName:  {
                            if (model.protected) {
                                if (model.signalStrength <= 25)
                                    return  Qt.resolvedUrl("qrc:/icons/connections/nm-signal-25-secure.svg")

                                if (model.signalStrength <= 50)
                                    return  Qt.resolvedUrl("qrc:/icons/connections/nm-signal-50-secure.svg")

                                if (model.signalStrength <= 75)
                                    return  Qt.resolvedUrl("qrc:/icons/connections/nm-signal-75-secure.svg")

                                if (model.signalStrength <= 100)
                                    return  Qt.resolvedUrl("qrc:/icons/connections/nm-signal-100-secure.svg")

                            } else {

                                if (model.signalStrength <= 25)
                                    return  Qt.resolvedUrl("qrc:/icons/connections/nm-signal-25.svg")

                                if (model.signalStrength <= 50)
                                    return  Qt.resolvedUrl("qrc:/icons/connections/nm-signal-50.svg")

                                if (model.signalStrength <= 75)
                                    return  Qt.resolvedUrl("qrc:/icons/connections/nm-signal-75.svg")

                                if (model.signalStrength <= 100)
                                    return  Qt.resolvedUrl("qrc:/icons/connections/nm-signal-100.svg")

                            }
                        }

                        onClicked: {
                            print("Connect to ", model.ssid, " --> ", model.macAddress)
                            if (model.selectedNetwork) {
                                pageStack.push(networkInformationPage, { ssid: model.ssid})
                            } else {
                                pageStack.push(wirelessAuthenticationComponent, { wifiSetup: wifiSetup, ssid: model.ssid })
                            }
                        }
                    }
                }

                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Hidden WiFi")
                    visible: wifiSetup.wirelessServiceVersion >= 2
                    onClicked: {
                        pageStack.push(hiddenWifiComponent, {wifiSetup: wifiSetup})
                    }
                }
            }
        }
    }

    Component {
        id: hiddenWifiComponent
        WizardPageBase {
            title: qsTr("Hidden WiFi")
            text: qsTr("Enter the information for the hidden WiFi")

            property var wifiSetup: null

            onBack: pageStack.pop();

            onNext: {
                print("connecting to", ssidTextField.text, passwordTextField.password)
                wifiSetup.connectDeviceToWiFi(ssidTextField.text, passwordTextField.password, true)
                pageStack.push(wirelessConnectingWiFiComponent)
            }

            content: ColumnLayout {
                Layout.fillWidth: true
                Layout.maximumWidth: 500
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: Style.margins

                Label {
                    Layout.fillWidth: true
                    text: qsTr("SSID")
                }

                NymeaTextField {
                    id: ssidTextField
                    Layout.fillWidth: true

                }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Password")
                }

                ConsolinnoPasswordTextField {
                    id: passwordTextField
                    Layout.fillWidth: true
                    signup: false
                    requireLowerCaseLetter: false
                    requireUpperCaseLetter: false
                    requireNumber: false
                    requireSpecialChar: false
                    minPasswordLength: 8
                }
            }
        }
    }

    Component {
        id: wirelessAuthenticationComponent
        WizardPageBase {
            title: qsTr("Wireless setup")
            text: qsTr("Enter the password for the WiFi network.")
            showNextButton: passwordTextField.isValidPassword

            onNext: {
                print("connecting to", ssid, passwordTextField.password)
                wifiSetup.connectDeviceToWiFi(ssid, passwordTextField.password)
                pageStack.push(wirelessConnectingWiFiComponent)
            }

            onBack: pageStack.pop()

            property BtWiFiSetup wifiSetup: null
            property string ssid: ""

            content: ColumnLayout {
                Layout.fillWidth: true
                Layout.maximumWidth: 500
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: Style.margins

                Label {
                    Layout.fillWidth: true
                    text: ssid
                }

                ConsolinnoPasswordTextField {
                    id: passwordTextField
                    Layout.fillWidth: true
                    signup: false
                    requireLowerCaseLetter: false
                    requireUpperCaseLetter: false
                    requireNumber: false
                    requireSpecialChar: false
                    minPasswordLength: 8
                }
            }
        }
    }

    Component {
        id: wirelessBtErrorComponent
        WizardPageBase {
            title: qsTr("Wireless setup")
            text: qsTr("An error happened in the Bluetooth connection. Please try again.")
            showNextButton: false
            onBack: pageStack.pop()
        }
    }

    Component {
        id: wirelessConnectingWiFiComponent
        WizardPageBase {
            title: qsTr("Wireless setup")
            text: qsTr("Please wait while the nymea system is being connected to the WiFi.")
            showNextButton: false
            onBack: pageStack.pop()

            content: Item {
                Layout.fillWidth: true
                Layout.preferredHeight: visibleContentHeight
                BusyIndicator {
                    anchors.centerIn: parent
                }
            }
        }
    }

    Component {
        id: wirelessConnectionCompletedComponent
        WizardPageBase {
            id: wirelessConnectionCompletedPage
            title: qsTr("Wireless setup")
            text: qsTr("The nymea system has been connected successfully.")

            showNextButton: host != null
            showBackButton: false

            onNext: engine.jsonRpcClient.connectToHost(host)

            property BtWiFiSetup wifiSetup: null

            property NymeaHost host: null

            Component.onCompleted: updateNextButton()

            Connections {
                target: nymeaDiscovery.nymeaHosts
                onCountChanged: updateNextButton();
            }

            function updateNextButton() {
                if (!wifiSetup.currentConnection) {
                    wirelessConnectionCompletedPage.host = null;
                    return;
                }

                // FIXME: We should rather look for the UUID here, but nymea-networkmanager doesn't support getting us the nymea uuid (yet)
                for (var i = 0; i < nymeaDiscovery.nymeaHosts.count; i++) {
                    for (var j = 0; j < nymeaDiscovery.nymeaHosts.get(i).connections.count; j++) {
                        if (nymeaDiscovery.nymeaHosts.get(i).connections.get(j).url.toString().indexOf(wifiSetup.currentConnection.hostAddress) >= 0) {
                            wirelessConnectionCompletedPage.host = nymeaDiscovery.nymeaHosts.get(i)
                            return;
                        }
                    }
                    nymeaDiscovery.nymeaHosts.get(i).connections.countChanged.connect(function() {
                        updateNextButton();
                    })
                }
                wirelessConnectionCompletedPage.host = null;
            }

            content: ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                Layout.maximumWidth: 500
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: visibleContentHeight
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: qsTr("You can now go ahead and configure your nymea system.")
                    visible: wirelessConnectionCompletedPage.host != null
                    horizontalAlignment: Text.AlignHCenter
                }
                BusyIndicator {
                    Layout.alignment: Qt.AlignHCenter
                    visible: wirelessConnectionCompletedPage.host == null
                }

                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    visible: wirelessConnectionCompletedPage.host == null
                    text: qsTr("Waiting for your nymea setup to appear in the network.")
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
