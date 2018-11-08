import QtQuick 2.4
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../components"
import Nymea 1.0

Page {
    id: root

    property NetworkManagerController networkManagerController: null
    property NymeaDiscovery nymeaDiscovery: null

    property bool accessPointMode: root.networkManagerController.manager.wirelessDeviceMode == WirelessSetupManager.WirelessDeviceModeAccessPoint

    signal done()

    header: GuhHeader {
        text: qsTr("Wireless network setup")
        onBackPressed: {
            pageStack.pop();
        }

        HeaderButton {
            imageSource: "../images/info.svg"
            onClicked: {
                pageStack.push(Qt.resolvedUrl("BoxInfoPage.qml"), {networkManagerController: root.networkManagerController})
            }
        }
        HeaderButton {
            imageSource: "../images/settings.svg"
            onClicked: {
                pageStack.push(Qt.resolvedUrl("NetworkSettingsPage.qml"), {networkManagerController: root.networkManagerController})
            }
        }
    }

    Component.onCompleted: {
        print("created with networkmanagercontroller:", root.networkManagerController)
        updateConnectButton();
    }

    Connections {
        target: root.networkManagerController.manager
        onErrorOccurred: {
            print("Error occurred", errorMessage)
            var errorDialog = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"));
            var popup = errorDialog.createObject(app, {text: errorMessage})
            popup.open()
        }

        onCurrentConnectionChanged: {
            updateConnectButton();

            if (!root.networkManagerController.manager.currentConnection) {
                networkManagerController.manager.loadNetworks()
            }
        }
    }

    Connections {
        target: root.nymeaDiscovery.discoveryModel
        onCountChanged: updateConnectButton();
    }

    function updateConnectButton() {
        if (!root.networkManagerController.manager.currentConnection || root.accessPointMode) {
            connectButton.url = "";
            return;
        }

        // FIXME: We should rather look for the UUID here, but nymea-networkmanager doesn't support getting us the nymea uuid (yet)
        for (var i = 0; i < root.nymeaDiscovery.discoveryModel.count; i++) {
            for (var j = 0; j < root.nymeaDiscovery.discoveryModel.get(i).connections.count; j++) {
                if (root.nymeaDiscovery.discoveryModel.get(i).connections.get(j).url.toString().indexOf(root.networkManagerController.manager.currentConnection.hostAddress) >= 0) {
                    connectButton.url = root.nymeaDiscovery.discoveryModel.get(i).connections.get(j).url
                    return;
                }
            }
            root.nymeaDiscovery.discoveryModel.get(i).connections.countChanged.connect(function() {
                updateConnectButton();
            })
        }
        connectButton.url = "";
    }


    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right }
        spacing: app.margins
        ColorIcon {
            Layout.preferredHeight: app.iconSize * 2
            Layout.preferredWidth: height
            Layout.alignment: Qt.AlignCenter
            Layout.topMargin: app.margins
            name: root.accessPointMode ? "../images/wireless-router.svg" : "../images/tick.svg"
            color: app.accentColor
        }

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            visible: root.accessPointMode
            wrapMode: Text.WordWrap
            text: root.networkManagerController.manager.currentConnection
                  ? qsTr("The %1 box is in access point mode").arg(app.systemName)
                  : ""
        }

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            visible: root.networkManagerController.manager.currentConnection
            text: root.accessPointMode
                  ? qsTr("Access point name: %1").arg(root.networkManagerController.manager.currentConnection.ssid)
                  : qsTr("Your %1 box is connected to %2").arg(app.systemName).arg(root.networkManagerController.manager.currentConnection.ssid)
        }

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            text: root.networkManagerController.manager.currentConnection ? qsTr("IP address: %1").arg(root.networkManagerController.manager.currentConnection.hostAddress) : ""
            elide: Text.ElideRight
        }

        RowLayout {
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            visible: !connectButton.visible && !root.accessPointMode
            spacing: app.margins
            Label {
                Layout.fillWidth: true
                text: qsTr("Waiting for %1:core to appear in your network.").arg(app.systemName)
                wrapMode: Text.WordWrap
            }
            BusyIndicator { }
        }

        Button {
            id: disconnectButton
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            text: root.accessPointMode ? qsTr("Shut down access point") : qsTr("Disconnect from this network")
            onClicked: {
                networkManagerController.manager.disconnectWirelessNetwork()
                var page = pageStack.push(Qt.resolvedUrl("ConnectWiFiPage.qml"), {networkManagerController: root.networkManagerController})
                page.connected.connect(function() {
                    pageStack.pop(root)
                })
            }
        }

        Button {
            id: connectButton
            visible: url != "" && !root.accessPointMode
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            text: qsTr("Connect to %1").arg(app.systemName)
            property string url
            onClicked: {
                engine.connection.connect(url)
            }
        }

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            visible: !root.accessPointMode
            text: qsTr("Change network")
            onClicked: {
                var page = pageStack.push(Qt.resolvedUrl("ConnectWiFiPage.qml"), {networkManagerController: root.networkManagerController})
                page.connected.connect(function() {
                    pageStack.pop(root)
                })
            }
        }

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            text: qsTr("Close wireless setup")
            onClicked: {
                root.done()
            }
        }
    }
}
