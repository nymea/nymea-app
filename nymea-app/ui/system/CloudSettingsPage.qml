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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

SettingsPageBase {
    id: root
    title: qsTr("%1:core cloud settings").arg(app.systemName)

    Item {
        id: d
        property bool deploymentStarted: false

        Connections {
            target: engine.jsonRpcClient
            onCloudConnectionStateChanged: {
                print("cloud connection state changed", engine.jsonRpcClient.cloudConnectionState)
                if (engine.jsonRpcClient.cloudConnectionState === JsonRpcClient.CloudConnectionStateConnected) {
                    d.deploymentStarted = false;
                    if (AWSClient.awsDevices.getDevice(engine.jsonRpcClient.serverUuid) === null) {
                        engine.jsonRpcClient.setupRemoteAccess(AWSClient.idToken, AWSClient.userId)
                    }
                }
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Cloud connection")
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        text: qsTr("Connect %1:core to %1:cloud in order to access it from anywhere and send push notifications from %1:core to %2.").arg(app.systemName).arg(app.appName)
        wrapMode: Text.WordWrap
    }

    //        Button {
    //            text: "pair"
    //            onClicked: engine.jsonRpcClient.setupRemoteAccess(AWSClient.idToken, AWSClient.userId)
    //        }

    SwitchDelegate {
        Layout.fillWidth: true
        text: qsTr("Cloud connection enabled")
        checked: engine.nymeaConfiguration.cloudEnabled
        onToggled: {
            engine.nymeaConfiguration.cloudEnabled = checked;
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Status")
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins

        ColorIcon {
            Layout.preferredHeight: busyIndicator.height
            Layout.preferredWidth: height
            name: engine.jsonRpcClient.cloudConnectionState === JsonRpcClient.CloudConnectionStateConnected
                  ? "../images/cloud.svg"
                  : engine.jsonRpcClient.cloudConnectionState === JsonRpcClient.CloudConnectionStateUnconfigured
                    ? "../images/cloud-error.svg"
                    : "../images/cloud-offline.svg"
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: {
                switch (engine.jsonRpcClient.cloudConnectionState) {
                case JsonRpcClient.CloudConnectionStateDisabled:
                    return qsTr("This box is not connected to %1:cloud").arg(app.systemName)
                case JsonRpcClient.CloudConnectionStateUnconfigured:
                    if (d.deploymentStarted) {
                        return qsTr("Registering box in %1:cloud...").arg(app.systemName)
                    }
                    return qsTr("This box is not configured to connect to %1:cloud.").arg(app.systemName);
                case JsonRpcClient.CloudConnectionStateConnecting:
                    return qsTr("Connecting the box to %1:cloud...").arg(app.systemName);
                case JsonRpcClient.CloudConnectionStateConnected:
                    return qsTr("The box is connected to %1:cloud.").arg(app.systemName);
                }
                return engine.jsonRpcClient.cloudConnectionState
            }
        }
        BusyIndicator {
            id: busyIndicator
            visible: (engine.jsonRpcClient.cloudConnectionState == JsonRpcClient.CloudConnectionStateUnconfigured && d.deploymentStarted) ||
                     engine.jsonRpcClient.cloudConnectionState == JsonRpcClient.CloudConnectionStateConnecting
        }
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
        visible: engine.jsonRpcClient.cloudConnectionState === JsonRpcClient.CloudConnectionStateUnconfigured && !d.deploymentStarted
        text: qsTr("This box is not configured to access the %1:cloud. In order for a box to connect to %1:cloud it needs to be registered first.").arg(app.systemName)
        wrapMode: Text.WordWrap
    }

    Button {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
        visible: engine.jsonRpcClient.cloudConnectionState === JsonRpcClient.CloudConnectionStateUnconfigured && !d.deploymentStarted
        text: AWSClient.isLoggedIn ? qsTr("Register box") : qsTr("Log in to cloud")
        onClicked: {
            if (AWSClient.isLoggedIn) {
                d.deploymentStarted = true
                engine.deployCertificate();
            } else {
                pageStack.push(Qt.resolvedUrl("qrc:/ui/appsettings/CloudLoginPage.qml"))
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Remote connection")
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        wrapMode: Text.WordWrap
        text: qsTr("In order to remotely connect to this %1:core, %2 needs to be logged into %1:cloud as well.").arg(app.systemName).arg(app.appName)
    }

    NymeaListItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Go to app settings")
        subText: qsTr("Set up cloud connection for %1").arg(app.appName)
        prominentSubText: false
        onClicked: {
            pageStack.push(Qt.resolvedUrl("../appsettings/CloudLoginPage.qml"))
        }
    }
}
