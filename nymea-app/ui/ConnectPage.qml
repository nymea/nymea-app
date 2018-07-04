import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "components"

Page {
    id: root

    readonly property bool haveHosts: discovery.discoveryModel.count > 0

    Component.onCompleted: {
        print("completed connectPage. last connected host:", settings.lastConnectedHost)
        if (settings.lastConnectedHost.length > 0) {
            pageStack.push(connectingPage)
            Engine.connection.connect(settings.lastConnectedHost)
        } else {
            pageStack.push(discoveryPage)
        }
    }

    NymeaDiscovery {
        id: discovery
        objectName: "discovery"
        discovering: pageStack.currentItem.objectName === "discoveryPage"
    }

    Connections {
        target: Engine.connection
        onVerifyConnectionCertificate: {
            print("verify cert!")
            var popup = certDialogComponent.createObject(app, {url: url, issuerInfo: issuerInfo, fingerprint: fingerprint});
            popup.open();
        }
        onConnectionError: {
            var errorMessage;
            switch (error) {
            case "ConnectionRefusedError":
                errorMessage = qsTr("The host has rejected our connection. This probably means that %1 stopped running. Did you unplug your %1 box?").arg(app.systemName);
                break;
            case "SslInvalidUserDataError":
            case "SslHandshakeFailedError":
                // silently ignore. They'll be handled by the SSL logic
                return;
            case "HostNotFoundError":
                errorMessage = qsTr("The %1 box could not be found on this address. Please make sure you entered the address correctly and that the box is powered on.").arg(app.systemName);
                break;
            case "NetworkError":
                errorMessage = qsTr("It seems you're not connected to the network.");
                break;
            case "RemoteHostClosedError":
                errorMessage = qsTr("The %1 box has closed the connection. This probably means it has been turned off or restarted.").arg(app.systemName);
                break;
            default:
                errorMessage = qsTr("Un unknown error happened. We're very sorry for that. (Error code: %1)").arg(error);
            }
            print("opening ErrorDialog with message:", errorMessage, error)
            var comp = Qt.createComponent(Qt.resolvedUrl("components/ErrorDialog.qml"))
            var popup = comp.createObject(app, {text: errorMessage})
            popup.open()

            pageStack.pop(root)
            pageStack.push(discoveryPage)
        }
        onConnectedChanged: {
            if (!connected) {
                pageStack.pop(root)
                pageStack.push(discoveryPage)
            }
        }
    }

    Component {
        id: discoveryPage

        Page {
            objectName: "discoveryPage"
            header: GuhHeader {
                text: qsTr("Connect %1").arg(app.systemName)
                backButtonVisible: false
                menuButtonVisible: true
                onMenuPressed: connectionMenu.open()
            }

            Timer {
                id: startupTimer
                interval: 5000
                repeat: false
                running: true
            }

            Menu {
                id: connectionMenu
                objectName: "connectionMenu"
                width: implicitWidth + app.margins

                IconMenuItem {
                    objectName: "manualConnectMenuItem"
                    iconSource: "../images/network-vpn.svg"
                    text: qsTr("Manual connection")
                    onTriggered: pageStack.push(manualConnectPage)
                }

                IconMenuItem {
                    iconSource: "../images/bluetooth.svg"
                    text: qsTr("Wireless setup")
                    onTriggered: pageStack.push(Qt.resolvedUrl("BluetoothDiscoveryPage.qml"))
                }

                IconMenuItem {
                    iconSource: "../images/private-browsing.svg"
                    text: qsTr("Demo mode")
                    onTriggered: {
                        pageStack.push(connectingPage)
                        Engine.connection.connect("nymea://nymea.nymea.io:2222")
                    }
                }

                MenuSeparator { }

                IconMenuItem {
                    iconSource: "../images/stock_application.svg"
                    text: qsTr("App settings")
                    onTriggered: pageStack.push(Qt.resolvedUrl("AppSettingsPage.qml"))
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: app.margins

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    Layout.topMargin: app.margins
                    spacing: app.margins

                    Label {
                        Layout.fillWidth: true
                        text: root.haveHosts ? qsTr("Oh, look!") : startupTimer.running ? qsTr("Just a moment...") : qsTr("Uh oh")
                        //color: "black"
                        font.pixelSize: app.largeFont
                    }

                    Label {
                        Layout.fillWidth: true
                        text: root.haveHosts ?
                                  qsTr("There are %1 %2 boxes in your network! Which one would you like to use?").arg(discovery.discoveryModel.count).arg(app.systemName)
                                : startupTimer.running ? qsTr("We haven't found any %1 boxes in your network yet.").arg(app.systemName)
                                                       : qsTr("There doesn't seem to be a %1 box installed in your network. Please make sure your %1 box is correctly set up and connected.").arg(app.systemName)
                        wrapMode: Text.WordWrap
                    }
                }

                ThinDivider { }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: discovery.discoveryModel
                    clip: true

                    delegate: MeaListItemDelegate {
                        id: discoveryDeviceDelegate
                        width: parent.width
                        height: app.delegateHeight
                        objectName: "discoveryDelegate" + index
                        property var discoveryDevice: discovery.discoveryModel.get(index)
                        property string defaultPortConfigIndex: {
                            var usedConfigIndex = 0;
                            for (var i = 1; i < discoveryDevice.portConfigs.count; i++) {
                                var oldConfig = discoveryDevice.portConfigs.get(usedConfigIndex);
                                var newConfig = discoveryDevice.portConfigs.get(i);

                                // prefer secure over insecure
                                if (!oldConfig.sslEnabled && newConfig.sslEnabled) {
                                    usedConfigIndex = i;
                                    continue;
                                }
                                if (oldConfig.sslEnabled && !newConfig.sslEnabled) {
                                    continue; // discard new one as the one we already have is more secure
                                }

                                // both options are new either secure or insecure, prefer nymearpc over websocket for less overhead
                                if (oldConfig.protocol === PortConfig.ProtocolWebSocket && newConfig.protocol === PortConfig.ProtocolNymeaRpc) {
                                    usedConfigIndex = i;
                                }
                            }
                            return usedConfigIndex
                        }

                        iconName: model.type === DiscoveryDevice.DeviceTypeNetwork ? "../images/network-vpn.svg" : "../images/bluetooth.svg"
                        text: model.name
                        subText: model.type === DiscoveryDevice.DeviceTypeNetwork ? model.hostAddress : model.bluetoothAddress
                        property bool hasSecurePort: discoveryDeviceDelegate.discoveryDevice.portConfigs.get(discoveryDeviceDelegate.defaultPortConfigIndex).sslEnabled
                        property bool isTrusted: Engine.connection.isTrusted(discoveryDeviceDelegate.discoveryDevice.toUrl(discoveryDeviceDelegate.defaultPortConfigIndex))
                        progressive: hasSecurePort
                        secondaryIconName: "../images/network-secure.svg"
                        secondaryIconColor: isTrusted ? app.guhAccent : Material.foreground
                        swipe.enabled: true

                        onClicked: {
                            if (model.type === DiscoveryDevice.DeviceTypeNetwork) {
                                Engine.connection.connect(discoveryDevice.toUrl(defaultPortConfigIndex))
                            } else if (model.type === DiscoveryDevice.DeviceTypeNetwork) {
                                Engine.connection.connect(discoveryDevice.toUrl(model.bluetoothAddress))
                            }

                            pageStack.push(connectingPage)
                        }

                        swipe.right: MouseArea {
                            height: parent.height
                            width: height
                            anchors.right: parent.right
                            ColorIcon {
                                anchors.fill: parent
                                anchors.margins: app.margins
                                name: "../images/info.svg"
                            }
                            onClicked: {
                                swipe.close()
                                var popup = infoDialog.createObject(app,{discoveryDevice: discovery.discoveryModel.get(index)})
                                popup.open()
                            }
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: app.margins
                        visible: !root.haveHosts

                        Label {
                            text: qsTr("Searching for %1 boxes...").arg(app.systemName)
                        }

                        BusyIndicator {
                            running: visible
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                }

                ThinDivider {}

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    wrapMode: Text.WordWrap
                    visible: discovery.discoveryModel.count === 0
                    text: qsTr("Do you have a %1 box but it's not connected to your network yet? Use the wireless setup to connect it!").arg(app.systemName)
                }
                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    visible: discovery.discoveryModel.count === 0
                    text: qsTr("Start wireless setup")
                    onClicked: pageStack.push(Qt.resolvedUrl("BluetoothDiscoveryPage.qml"))
                }
                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    Layout.bottomMargin: app.margins
                    visible: discovery.discoveryModel.count === 0
                    text: qsTr("Demo mode (online)")
                    onClicked: {
                        pageStack.push(connectingPage)
                        Engine.connection.connect("nymea://nymea.nymea.io:2222")
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    Layout.bottomMargin: app.margins
                    visible: root.haveHosts
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Not the ones you're looking for? We're looking for more!")
                        wrapMode: Text.WordWrap
                    }

                    BusyIndicator { }
                }
            }
        }
    }


    Component {
        id: manualConnectPage

        Page {
            objectName: "manualConnectPage"
            header: GuhHeader {
                text: qsTr("Manual connection")
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors { left: parent.left; top: parent.top; right: parent.right }
                anchors.margins: app.margins
                spacing: app.margins

                GridLayout {
                    columns: 2

                    Label {
                        text: qsTr("Protocol")
                    }

                    ComboBox {
                        id: connectionTypeComboBox
                        Layout.fillWidth: true
                        model: [ qsTr("TCP"), qsTr("Websocket") ]
                    }

                    Label { text: qsTr("Address:") }
                    TextField {
                        id: addressTextInput
                        objectName: "addressTextInput"
                        Layout.fillWidth: true
                        placeholderText: "127.0.0.1"
                    }

                    Label { text: qsTr("Port:") }
                    TextField {
                        id: portTextInput
                        Layout.fillWidth: true
                        placeholderText: connectionTypeComboBox.currentIndex === 0 ? "2222" : "4444"
                        validator: IntValidator{bottom: 1; top: 65535;}
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Encrypted connection:")
                    }
                    CheckBox {
                        id: secureCheckBox
                        checked: true
                    }
                }


                Button {
                    text: qsTr("Connect")
                    objectName: "connectButton"
                    Layout.fillWidth: true
                    onClicked: {
                        var rpcUrl
                        var hostAddress
                        var port

                        // Set default to placeholder
                        if (addressTextInput.text === "") {
                            hostAddress = addressTextInput.placeholderText
                        } else {
                            hostAddress = addressTextInput.text
                        }

                        if (portTextInput.text === "") {
                            port = portTextInput.placeholderText
                        } else {
                            port = portTextInput.text
                        }

                        if (connectionTypeComboBox.currentIndex == 0) {
                            if (secureCheckBox.checked) {
                                rpcUrl = "nymeas://" + hostAddress + ":" + port
                            } else {
                                rpcUrl = "nymea://" + hostAddress + ":" + port
                            }
                        } else if (connectionTypeComboBox.currentIndex == 1) {
                            if (secureCheckBox.checked) {
                                rpcUrl = "wss://" + hostAddress + ":" + port
                            } else {
                                rpcUrl = "ws://" + hostAddress + ":" + port
                            }
                        }

                        print("Try to connect ", rpcUrl)
                        Engine.connection.connect(rpcUrl)
                        pageStack.push(connectingPage)
                    }
                }
            }
        }
    }

    Component {
        id: connectingPage
        Page {

            ColumnLayout {
                id: columnLayout
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: app.margins }
                spacing: app.margins
                BusyIndicator {
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: parent.visible
                }
                Label {
                    text: qsTr("Trying to connect...")
                    font.pixelSize: app.largeFont
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Button {
                text: qsTr("Cancel")
                anchors { left: parent.left; top: columnLayout.bottom; right: parent.right }
                anchors.margins: app.margins
                onClicked: {
                    Engine.connection.disconnect()
                    pageStack.pop(root);
                    pageStack.push(discoveryPage);
                }
            }
        }
    }

    Component {
        id: certDialogComponent

        Dialog {
            id: certDialog
            width: Math.min(parent.width * .9, 400)
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            standardButtons: Dialog.Yes | Dialog.No

            property string url
            property var fingerprint
            property var issuerInfo

            readonly property bool hasOldFingerprint: Engine.connection.isTrusted(url)

            ColumnLayout {
                id: certLayout
                anchors.fill: parent
//                spacing: app.margins

                RowLayout {
                    Layout.fillWidth: true
                    spacing: app.margins
                    ColorIcon {
                        Layout.preferredHeight: app.iconSize * 2
                        Layout.preferredWidth: height
                        name: certDialog.hasOldFingerprint ? "../images/lock-broken.svg" : "../images/info.svg"
                        color: certDialog.hasOldFingerprint ? "red" : app.guhAccent
                    }

                    Label {
                        id: titleLabel
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: certDialog.hasOldFingerprint ? qsTr("Warning") : qsTr("Hi there!")
                        color: certDialog.hasOldFingerprint ? "red" : app.guhAccent
                        font.pixelSize: app.largeFont
                    }
                }

                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: certDialog.hasOldFingerprint ? qsTr("The certificate of this %1 box has changed!").arg(app.systemName) : qsTr("It seems this is the first time you connect to this %1 box.").arg(app.systemName)
                }

                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: certDialog.hasOldFingerprint ? qsTr("Did you change the box's configuration? Verify if this information is correct.") : qsTr("This is the box's certificate. Once you trust it, an encrypted connection will be established.")
                }

                ThinDivider {}
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    implicitHeight: certGridLayout.implicitHeight
                    Flickable {
                        anchors.fill: parent
                        contentHeight: certGridLayout.implicitHeight
                        clip: true

                        ScrollBar.vertical: ScrollBar {
                            policy: contentHeight > height ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded
                        }

                        GridLayout {
                            id: certGridLayout
                            columns: 2
                            width: parent.width

                            Repeater {
                                model: certDialog.issuerInfo

                                Label {
                                    Layout.fillWidth: true
                                    wrapMode: Text.WordWrap
                                    text: modelData
                                }
                            }
                            Label {
                                Layout.fillWidth: true
                                Layout.columnSpan: 2
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: qsTr("Fingerprint: ") + certDialog.fingerprint
                            }
                        }
                    }
                }

                ThinDivider {}

                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: certDialog.hasOldFingerprint ? qsTr("Do you want to connect nevertheless?") : qsTr("Do you want to trust this device?")
                    font.bold: true
                }
            }


            onAccepted: {
                Engine.connection.acceptCertificate(certDialog.url, certDialog.fingerprint)
                Engine.connection.connect(certDialog.url)
            }
        }
    }


    Component {
        id: infoDialog
        Dialog {
            id: dialog
            width: Math.min(parent.width, contentGrid.implicitWidth)
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true
            title: qsTr("Box information")

            standardButtons: Dialog.Ok

            property var discoveryDevice: null

            header: Item {
                implicitHeight: headerRow.height + app.margins * 2
                implicitWidth: parent.width
                RowLayout {
                    id: headerRow
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: app.margins }
                    spacing: app.margins
                    ColorIcon {
                        Layout.preferredHeight: app.iconSize * 2
                        Layout.preferredWidth: height
                        name: "../images/info.svg"
                        color: app.guhAccent
                    }

                    Label {
                        id: titleLabel
                        Layout.fillWidth: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: dialog.title
                        color: app.guhAccent
                        font.pixelSize: app.largeFont
                    }
                }
            }

            GridLayout {
                id: contentGrid
                anchors.fill: parent
                rowSpacing: app.margins
                columns: 2
                Label {
                    text: "Name:"
                }
                Label {
                    text: dialog.discoveryDevice.name
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Label {
                    text: "UUID:"
                }
                Label {
                    text: dialog.discoveryDevice.uuid
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Label {
                    text: "Version:"
                }
                Label {
                    text: dialog.discoveryDevice.version
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Label {
                    text: "IP Address:"
                }
                Label {
                    text: dialog.discoveryDevice.hostAddress
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                ThinDivider { Layout.columnSpan: 2 }
                Label {
                    Layout.columnSpan: 2
                    text: qsTr("Available connections")
                }

                Flickable {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    contentHeight: contentColumn.implicitHeight
                    clip: true
                    ColumnLayout {
                        id: contentColumn
                        width: parent.width
                        Repeater {
                            model: dialog.discoveryDevice.portConfigs
                            ItemDelegate {
                                Layout.fillWidth: true
                                contentItem: RowLayout {
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Label {
                                            text: qsTr("Port: %1").arg(model.port)
                                        }
                                        Label {
                                            text: model.protocol === PortConfig.ProtocolNymeaRpc ? "nymea-rpc" : "websocket"
                                            Layout.fillWidth: true
                                            font.pixelSize: app.smallFont
                                        }
                                    }

                                    ColorIcon {
                                        Layout.preferredHeight: app.iconSize
                                        Layout.preferredWidth: height
                                        visible: model.sslEnabled
                                        name: "../images/network-secure.svg"
                                        property bool isTrusted: Engine.connection.isTrusted(dialog.discoveryDevice.toUrl(index))
                                        color: isTrusted ? app.guhAccent : keyColor
                                    }
                                }
                                onClicked: {
                                    Engine.connection.connect(dialog.discoveryDevice.toUrl(index))
                                    dialog.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
