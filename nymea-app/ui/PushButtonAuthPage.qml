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

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

import "components"

Page {
    id: root
    signal backPressed();

    header: NymeaHeader {
        text: qsTr("Welcome to %1!").arg(Configuration.systemName)
        backButtonVisible: true
        onBackPressed: {
            root.backPressed();
        }
    }

    Component.onCompleted: {
        engine.jsonRpcClient.requestPushButtonAuth("nymea-app (" + PlatformHelper.deviceModel + ")");
    }

    Connections {
        target: engine.jsonRpcClient
        onPushButtonAuthFailed: {
            var popup = errorDialog.createObject(root)
            popup.text = qsTr("Sorry, something went wrong during the setup. Try again please.")
            popup.open();
            popup.accepted.connect(function() {root.backPressed()})
        }
    }

    ColumnLayout {
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
        anchors.margins: app.margins
        spacing: app.margins * 2

        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            color: Style.accentColor
            text: qsTr("Finish authentication")
            wrapMode: Text.WordWrap
            font.pixelSize: app.largeFont
        }

        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("To complete authentication, press the test button again for 5 sec. until the status LED lights up green.").arg(Configuration.systemName)
            wrapMode: Text.WordWrap
        }

        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("If the status LED flashes red briefly or this screen remains displayed, the authentication has failed. Please go back and restart the process.")
            wrapMode: Text.WordWrap
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    Component {
        id: errorDialog
        ErrorDialog {

        }
    }
}
