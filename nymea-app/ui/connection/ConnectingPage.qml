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
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"


Page {
    id: root

    signal cancel()

    ColorIcon {
        anchors { top: parent.top; right: parent.right; margins: app.margins }
        height: app.iconSize
        width: height
        name: "../images/logs.svg"
        visible: settings.showHiddenOptions && AppLogController.enabled
        MouseArea {
            anchors.fill: parent
            onClicked: {
                onClicked: pageStack.push(Qt.resolvedUrl("../appsettings/AppLogPage.qml"))
            }
        }
    }

    ColumnLayout {
        id: columnLayout
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: app.margins }
        spacing: app.margins
        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: parent.visible
        }
        Label {
            text: qsTr("Connecting...")
            font.pixelSize: app.largeFont
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
        Label {
            Layout.fillWidth: true
            text: engine.jsonRpcClient.currentHost.name.length > 0 ? engine.jsonRpcClient.currentHost.name : engine.jsonRpcClient.currentHost.uuid
            font.pixelSize: app.smallFont
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
        }
        Label {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            text: {
                var errorMessage;
                switch (engine.jsonRpcClient.connectionStatus) {
                case NymeaConnection.ConnectionStatusUnconnected:
                case NymeaConnection.ConnectionStatusConnecting:
                case NymeaConnection.ConnectionStatusConnected:
                    errorMessage = "";
                    break;
                case NymeaConnection.ConnectionStatusBearerFailed:
                    errorMessage = qsTr("The network connection failed.")
                    break;
                case NymeaConnection.ConnectionStatusNoBearerAvailable:
                    errorMessage = qsTr("It seems you're not connected to the network.");
                    break;
                case NymeaConnection.ConnectionStatusHostNotFound:
                    errorMessage = qsTr("%1:core could not be found on this address. Please make sure you entered the address correctly and that the system is powered on.").arg(app.systemName);
                    break;
                case NymeaConnection.ConnectionStatusConnectionRefused:
                    errorMessage = qsTr("The host has rejected our connection. This probably means that %1 is not running on this host. Perhaps it's restarting?").arg(app.systemName);
                    break;
                case NymeaConnection.ConnectionStatusRemoteHostClosed:
                    errorMessage = qsTr("%1:core has closed the connection. This probably means it has been turned off or restarted.").arg(app.systemName);
                    break;

                case NymeaConnection.ConnectionStatusTimeout:
                    errorMessage = qsTr("%1:core did not respond. Please make sure your network connection works properly").arg(app.systemName);
                    break;
                case NymeaConnection.ConnectionStatusSslError:
                    errorMessage = qsTr("An unrecovareable SSL Error happened. Please make sure certificates are installed correctly.");
                    break;
                case NymeaConnection.ConnectionStatusSslUntrusted:
                    errorMessage = qsTr("The SSL Certificate is not trusted.");
                    break;
                case NymeaConnection.ConnectionStatusUnknownError:
                default:
                    errorMessage = qsTr("An unknown error happened. We're very sorry for that. (Error code: %1)").arg(engine.jsonRpcClient.connectionStatus);
                }
                return errorMessage;
            }
            font.pixelSize: app.smallFont
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Button {
        text: qsTr("Cancel")
        anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
        anchors.margins: app.margins
        onClicked: root.cancel()
    }
}
