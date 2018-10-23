import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {
    id: root

    readonly property bool haveHosts: discovery.discoveryModel.count > 0

    Component.onCompleted: {
        print("completed connectPage for tab", connectionTabIndex, "last connected host:", tabSettings.lastConnectedHost)
        if (tabSettings.lastConnectedHost.length > 0 && engine.connection.connect(tabSettings.lastConnectedHost)) {
            var page = pageStack.push(Qt.resolvedUrl("ConnectingPage.qml"))
            page.cancel.connect(function() {
                engine.connection.disconnect();
                pageStack.pop(root, StackView.Immediate);
                pageStack.push(discoveryPage)
            })
        } else {
            pageStack.push(discoveryPage)
        }
    }

    function connectToHost(url) {
        var page = pageStack.push(Qt.resolvedUrl("ConnectingPage.qml"))
        page.cancel.connect(function() {
            engine.connection.disconnect()
            pageStack.pop(root, StackView.Immediate);
            pageStack.push(discoveryPage)
        })
        engine.connection.connect(url)
    }

    NymeaDiscovery {
        id: discovery
        objectName: "discovery"
        awsClient: AWSClient
        discovering: pageStack.currentItem.objectName === "discoveryPage"
    }

    Connections {
        target: engine.connection
        onVerifyConnectionCertificate: {
            print("verify cert!")
            var popup = certDialogComponent.createObject(root, {url: url, issuerInfo: issuerInfo, fingerprint: fingerprint, pem: pem});
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

            pageStack.pop(root, StackView.Immediate)
            pageStack.push(discoveryPage)

            print("opening ErrorDialog with message:", errorMessage, error)
            var comp = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"))
            var popup = comp.createObject(app, {text: errorMessage})
            popup.open()
        }
        onConnectedChanged: {
            if (!connected) {
                pageStack.pop(root, StackView.Immediate)
                pageStack.push(discoveryPage)
            }
        }
    }

    Component {
        id: discoveryPage

        Page {
            objectName: "discoveryPage"
            header: FancyHeader {
                title: qsTr("Connect %1").arg(app.systemName)
                model: ListModel {
                    ListElement { iconSource: "../images/network-vpn.svg"; text: qsTr("Manual connection"); page: "ManualConnectPage.qml" }
                    ListElement { iconSource: "../images/bluetooth.svg"; text: qsTr("Wireless setup"); page: "wifisetup/BluetoothDiscoveryPage.qml"; }
                    ListElement { iconSource: "../images/private-browsing.svg"; text: qsTr("Demo mode"); page: "" }
                    ListElement { iconSource: "../images/stock_application.svg"; text: qsTr("App settings"); page: "../appsettings/AppSettingsPage.qml" }
                }
                onClicked: {
                    if (index === 2) {
                        root.connectToHost("nymea://nymea.nymea.io:2222")
                    } else {
                        pageStack.push(model.get(index).page, {nymeaDiscovery: discovery});
                    }
                }
            }

            Timer {
                id: startupTimer
                interval: 5000
                repeat: false
                running: true
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
                        property string defaultConnectionIndex: {
                            var usedConfigIndex = 0;
                            for (var i = 1; i < discoveryDevice.connections.count; i++) {
                                var oldConfig = discoveryDevice.connections.get(usedConfigIndex);
                                var newConfig = discoveryDevice.connections.get(i);

                                // Preference of bearerType
                                var bearerPreference = [Connection.BearerTypeEthernet, Connection.BearerTypeWifi, Connection.BearerTypeBluetooth, Connection.BearerTypeCloud]
                                var oldBearerPriority = bearerPreference.indexOf(oldConfig.bearerType);
                                var newBearerPriority = bearerPreference.indexOf(newConfig.bearerType);
                                if (newBearerPriority < oldBearerPriority) {
                                    print(discoveryDevice.name, "switching to preferred index", i, "of bearer type", newConfig.bearerType, "from", oldConfig.bearerType, "new prio:", newBearerPriority, "old:", oldBearerPriority)
                                    usedConfigIndex = i;
                                    continue;
                                }
                                if (oldBearerPriority < newBearerPriority) {
                                    continue; // discard new one the one we have is on a better bearer type
                                }

                                // prefer secure over insecure
                                if (!oldConfig.secure && newConfig.secure) {
                                    usedConfigIndex = i;
                                    continue;
                                }
                                if (oldConfig.secure && !newConfig.secure) {
                                    continue; // discard new one as the one we already have is more secure
                                }

                                // both options are now on the same bearer and either secure or insecure, prefer nymearpc over websocket for less overhead
                                if (oldConfig.url.toString().startsWith("ws") && newConfig.url.toString().startsWith("nymea")) {
                                    usedConfigIndex = i;
                                }
                            }
                            return usedConfigIndex
                        }

                        iconName: {
                            switch (discoveryDevice.connections.get(defaultConnectionIndex).bearerType) {
                            case Connection.BearerTypeWifi:
                                return "../images/network-wifi-symbolic.svg";
                            case Connection.BearerTypeEthernet:
                                return "../images/network-wired-symbolic.svg"
                            case Connection.BearerTypeBluetooth:
                                return "../images/bluetooth.svg";
                            case Connection.BearerTypeCloud:
                                return "../images/cloud.svg"
                            }
                            return ""
                        }

                        text: model.name
                        subText: discoveryDevice.connections.get(defaultConnectionIndex).url
                        wrapTexts: false
                        prominentSubText: false
                        progressive: false
                        property bool isSecure: discoveryDevice.connections.get(defaultConnectionIndex).secure
                        property bool isTrusted: engine.connection.isTrusted(discoveryDeviceDelegate.discoveryDevice.connections.get(defaultConnectionIndex).url)
                        property bool isOnline: discoveryDevice.connections.get(defaultConnectionIndex).online
                        tertiaryIconName: isSecure ? "../images/network-secure.svg" : ""
                        tertiaryIconColor: isTrusted ? app.accentColor : Material.foreground
                        secondaryIconName: !isOnline ? "../images/cloud-error.svg" : ""
                        secondaryIconColor: "red"
                        swipe.enabled: discoveryDeviceDelegate.discoveryDevice.deviceType === DiscoveryDevice.DeviceTypeNetwork

                        onClicked: {
                            root.connectToHost(discoveryDeviceDelegate.discoveryDevice.connections.get(defaultConnectionIndex).url)
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
                                if (model.deviceType === DiscoveryDevice.DeviceTypeNetwork) {
                                    swipe.close()
                                    var popup = infoDialog.createObject(app,{discoveryDevice: discovery.discoveryModel.get(index)})
                                    popup.open()
                                }
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
                    onClicked: pageStack.push(Qt.resolvedUrl("wifisetup/BluetoothDiscoveryPage.qml"), {nymeaDiscovery: discovery})
                }
                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    text: qsTr("Cloud login")
                    visible: !AWSClient.isLoggedIn
                    onClicked: pageStack.push(Qt.resolvedUrl("../appsettings/CloudLoginPage.qml"))
                }

                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    Layout.bottomMargin: app.margins
                    visible: discovery.discoveryModel.count === 0
                    text: qsTr("Demo mode (online)")
                    onClicked: {
                        root.connectToHost("nymea://nymea.nymea.io:2222")
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
            property var pem

            readonly property bool hasOldFingerprint: engine.connection.isTrusted(url)

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
                        color: certDialog.hasOldFingerprint ? "red" : app.accentColor
                    }

                    Label {
                        id: titleLabel
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: certDialog.hasOldFingerprint ? qsTr("Warning") : qsTr("Hi there!")
                        color: certDialog.hasOldFingerprint ? "red" : app.accentColor
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
                engine.connection.acceptCertificate(certDialog.url, certDialog.pem)
                root.connectToHost(certDialog.url)
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
                        color: app.accentColor
                    }

                    Label {
                        id: titleLabel
                        Layout.fillWidth: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: dialog.title
                        color: app.accentColor
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
                            model: dialog.discoveryDevice.connections
                            delegate: MeaListItemDelegate {
                                Layout.fillWidth: true
                                wrapTexts: false
                                progressive: false
                                text: model.name
                                subText: model.url
                                prominentSubText: false
                                iconName: {
                                    switch (model.bearerType) {
                                    case Connection.BearerTypeWifi:
                                        return "../images/network-wifi-symbolic.svg";
                                    case Connection.BearerTypeEthernet:
                                        return "../images/network-wired-symbolic.svg"
                                    case Connection.BearerTypeBluetooth:
                                        return "../images/bluetooth.svg";
                                    case Connection.BearerTypeCloud:
                                        return "../images/cloud.svg"
                                    }
                                    return ""
                                }

                                tertiaryIconName: model.secure ? "../images/network-secure.svg" : ""
                                tertiaryIconColor: isTrusted ? app.accentColor : "gray"
                                readonly property bool isTrusted: engine.connection.isTrusted(url)
                                secondaryIconName: !model.online ? "../images/cloud-error.svg" : ""
                                secondaryIconColor: "red"

                                onClicked: {
                                    root.connectToHost(dialog.discoveryDevice.connections.get(index).url)
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
