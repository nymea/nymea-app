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

import "../components"

SettingsPageBase {
    id: root
    signal backPressed();

    header: NymeaHeader {
        text: qsTr("Welcome!")
        backButtonVisible: true
        onBackPressed: root.backPressed()
    }

    Connections {
        target: engine.jsonRpcClient
        onAuthenticationFailed: {
            var popup = errorDialog.createObject(root)
            popup.text = qsTr("Sorry, that wasn't right. Try again please.")
            popup.open();
        }
        onCreateUserSucceeded: {
            engine.jsonRpcClient.authenticate(usernameTextField.text, passwordTextField.password, "nymea-app (" + PlatformHelper.deviceModel + ")");
        }

        onCreateUserFailed: {
            print("createUser failed")
            var message;
            switch (error) {
            case "UserErrorInvalidUserId":
                if (engine.jsonRpcClient.ensureServerVersion("7.0")) {
                    message = qsTr("The email you've entered isn't valid.")
                } else {
                    message = qsTr("The username you've entered isn't valid.")
                }
                break;
            case "UserErrorDuplicateUserId":
                message = qsTr("The username you've entered is already used.")
                break;
            case "UserErrorBadPassword":
                message = qsTr("The password you've chosen is too weak.")
                break;
            case "UserErrorBackendError":
                message = qsTr("An error happened with the user storage. Please make sure your %1 system is installed correctly.").arg(Configuration.systemName)
                break;
            }
            var popup = errorDialog.createObject(root, {text: message});
            popup.open();
        }
    }

    ColumnLayout {
        id: contentColumn
        width: parent.width

        spacing: Style.margins

        RowLayout {
            Layout.margins: Style.margins
            spacing: Style.margins

            ColorIcon {
                Layout.preferredHeight: Style.iconSize * 2
                Layout.preferredWidth: Style.iconSize * 2
                name: "qrc:/icons/lock-closed.svg"
                color: Style.accentColor
            }

            Label {
                Layout.fillWidth: true
                text: engine.jsonRpcClient.initialSetupRequired ?
                          qsTr("In order to use your %1 system, please create an account.").arg(Configuration.systemName)
                        : qsTr("In order to use your %1 system, please log in.").arg(Configuration.systemName)
                wrapMode: Text.WordWrap
            }
        }


        ColumnLayout {
            id: loginForm
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            spacing: app.margins

            property bool showErrors: false

            UsernameTextField {
                id: usernameTextField
                Layout.fillWidth: true
                error: loginForm.showErrors && !acceptableInput
            }
            Label {
                Layout.fillWidth: true
                text: qsTr("Password")
            }
            ConsolinnoPasswordTextField {
                id: passwordTextField
                Layout.fillWidth: true
                signup: engine.jsonRpcClient.initialSetupRequired
                showErrors: loginForm.showErrors
                onAccepted: {
                    if (!signup) {
                        okButton.clicked()
                    }
                }
            }

            TextField {
                id: displayNameTextField
                Layout.fillWidth: true
                placeholderText: qsTr("Your name") + " (" + qsTr("Optional") + ")"
                visible: engine.jsonRpcClient.ensureServerVersion("6.0") && engine.jsonRpcClient.initialSetupRequired
            }

            TextField {
                id: emailTextField
                Layout.fillWidth: true
                placeholderText:  qsTr("Email") + " (" + qsTr("Optional") + ")"
                visible: engine.jsonRpcClient.ensureServerVersion("6.0") && engine.jsonRpcClient.initialSetupRequired
            }
        }

        Button {
            id: okButton
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.bottomMargin: app.margins
            text: qsTr("OK")
            onClicked: {
                loginForm.showErrors = true
                if (!usernameTextField.acceptableInput || !passwordTextField.isValid) {
                    return;
                }

                if (engine.jsonRpcClient.initialSetupRequired) {
                    print("create user")
                    engine.jsonRpcClient.createUser(usernameTextField.text, passwordTextField.password, displayNameTextField.text, emailTextField.text);
                } else {
                    print("authenticate", usernameTextField.text, passwordTextField.text, "nymea-app")
                    engine.jsonRpcClient.authenticate(usernameTextField.text, passwordTextField.password, "nymea-app (" + PlatformHelper.deviceModel + ")");
                }
            }
        }

        ColumnLayout{
            Layout.fillWidth: true
            visible: engine.jsonRpcClient.ensureServerVersion("6.0") && !engine.jsonRpcClient.initialSetupRequired
            spacing: 5
            Label{
                text: qsTr("If you are the owner and do not have your own account, have your installer create an account for you.")
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                Layout.margins: app.margins
            }

            Label{
                text: qsTr("If you are an installer and do not have your own account, you can authenticate yourself using the test button on the leaflet (see quick start guide or user manual).")
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                Layout.margins: app.margins
            }
        }
    }

    Component {
        id: errorDialog
        ErrorDialog {

        }
    }
}
