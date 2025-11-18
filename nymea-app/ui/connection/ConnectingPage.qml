// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
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

    ProgressButton {
        anchors { top: parent.top; left: parent.left; margins: Style.margins }
        imageSource: "qrc:/icons/navigation-menu.svg"
        longpressEnabled: false
        onClicked: mainMenu.open()
    }

    ProgressButton {
        anchors { top: parent.top; right: parent.right; margins: Style.margins }
        imageSource: "qrc:/icons/logs.svg"
        visible: settings.showHiddenOptions && AppLogController.enabled
        onClicked: pageStack.push(Qt.resolvedUrl("../appsettings/AppLogPage.qml"))
    }

    ColumnLayout {
        id: columnLayout
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: Style.margins }
        spacing: Style.margins
        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: parent.visible
        }
        Label {
            text: qsTr("Connecting...")
            font: Style.bigFont
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
        Label {
            Layout.fillWidth: true
            text: engine.jsonRpcClient.currentHost.name.length > 0 ? engine.jsonRpcClient.currentHost.name : engine.jsonRpcClient.currentHost.uuid
            font: Style.smallFont
            elide: Text.ElideRight
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
                    errorMessage = qsTr("%1 could not be found on this address. Please make sure you entered the address correctly and that the system is powered on.").arg(Configuration.systemName);
                    break;
                case NymeaConnection.ConnectionStatusConnectionRefused:
                    errorMessage = qsTr("The host has rejected our connection. This probably means that %1 is not running on this host. Perhaps it's restarting?").arg(Configuration.systemName);
                    break;
                case NymeaConnection.ConnectionStatusRemoteHostClosed:
                    errorMessage = qsTr("%1 has closed the connection. This probably means it has been turned off or restarted.").arg(Configuration.systemName);
                    break;

                case NymeaConnection.ConnectionStatusTimeout:
                    errorMessage = qsTr("%1 did not respond. Please make sure your network connection works properly").arg(Configuration.systemName);
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
            font: Style.smallFont
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
        }
    }

//    Button {
//        text: qsTr("Cancel")
//        anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
//        anchors.margins: app.margins
//        onClicked: root.cancel()
//    }
}
