/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../components"
import Nymea 1.0

Page {
    id: root

    property BtWiFiSetup wifiSetup: null

    signal done()

    header: NymeaHeader {
        text: qsTr("Wireless network setup")
        onBackPressed: {
            pageStack.pop();
        }

        HeaderButton {
            imageSource: "../images/info.svg"
            onClicked: {
                pageStack.push(Qt.resolvedUrl("BoxInfoPage.qml"), {wifiSetup: root.wifiSetup})
            }
        }
        HeaderButton {
            imageSource: "../images/settings.svg"
            onClicked: {
                pageStack.push(Qt.resolvedUrl("NetworkSettingsPage.qml"), {wifiSetup: root.wifiSetup})
            }
        }
    }

    Component.onCompleted: {
        updateConnectButton();
    }

    Connections {
        target: root.wifiSetup
        onWifiSetupError: {
            print("Error occurred", errorMessage)
            var errorDialog = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"));
            var popup = errorDialog.createObject(app, {text: errorMessage})
            popup.open()
        }

        onCurrentConnectionChanged: {
            updateConnectButton();
        }
    }

    Connections {
        target: nymeaDiscovery.nymeaHosts
        onCountChanged: updateConnectButton();
    }

    function updateConnectButton() {
        if (!root.wifiSetup.currentConnection) {
            connectButton.host = null;
            return;
        }

        // FIXME: We should rather look for the UUID here, but nymea-networkmanager doesn't support getting us the nymea uuid (yet)
        for (var i = 0; i < nymeaDiscovery.nymeaHosts.count; i++) {
            for (var j = 0; j < nymeaDiscovery.nymeaHosts.get(i).connections.count; j++) {
                if (nymeaDiscovery.nymeaHosts.get(i).connections.get(j).url.toString().indexOf(root.wifiSetup.currentConnection.hostAddress) >= 0) {
                    connectButton.host = nymeaDiscovery.nymeaHosts.get(i)
                    return;
                }
            }
            nymeaDiscovery.nymeaHosts.get(i).connections.countChanged.connect(function() {
                updateConnectButton();
            })
        }
        connectButton.host = null;
    }

    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right }
        spacing: app.margins
        ColorIcon {
            Layout.preferredHeight: Style.iconSize * 2
            Layout.preferredWidth: height
            Layout.alignment: Qt.AlignCenter
            name: "../images/tick.svg"
            color: Style.accentColor
        }
        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            wrapMode: Text.WordWrap
            text: root.wifiSetup.currentConnection
                  ? qsTr("Your %1 system is connected to %2").arg(Configuration.systemName).arg(root.wifiSetup.currentConnection.ssid)
                  : ""
        }

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            text: qsTr("IP address: %1").arg(root.wifiSetup.currentConnection.hostAddress)
            elide: Text.ElideRight
        }

        RowLayout {
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            visible: !connectButton.visible
            spacing: app.margins
            Label {
                Layout.fillWidth: true
                text: qsTr("Waiting for the %1 to appear in your network.").arg(Configuration.systemName)
                wrapMode: Text.WordWrap
            }
            BusyIndicator { }
        }

        Button {
            id: connectButton
            visible: host !== null
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            text: qsTr("Connect to %1").arg(Configuration.systemName)
            property NymeaHost host: null
            onClicked: {
                print("connecting to", host)
                engine.jsonRpcClient.connectToHost(host)
            }
        }

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            text: qsTr("Change network")
            onClicked: {
                var page = pageStack.push(Qt.resolvedUrl("ConnectWiFiPage.qml"), {wifiSetup: root.wifiSetup})
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
