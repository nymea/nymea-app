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

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    signal backPressed();

    header: NymeaHeader {
        text: qsTr("Welcome to %1!").arg(Configuration.systemName)
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
                message = qsTr("The email you've entered isn't valid.")
                break;
            case "UserErrorDuplicateUserId":
                message = qsTr("The email you've entered is already used.")
                break;
            case "UserErrorBadPassword":
                message = qsTr("The password you've chose is too weak.")
                break;
            case "UserErrorBackendError":
                message = qsTr("An error happened with the user storage. Please make sure your %1 system is installed correctly.").arg(Configuration.systemName)
                break;
            }
            var popup = errorDialog.createObject(root, {text: message});
            popup.open();
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.implicitHeight

        ColumnLayout {
            id: contentColumn
            width: parent.width

            spacing: app.margins

            RowLayout {
                Layout.margins: app.margins
                spacing: app.margins

                ColorIcon {
                    Layout.preferredHeight: Style.iconSize * 2
                    Layout.preferredWidth: Style.iconSize * 2
                    name: "../images/lock-closed.svg"
                    color: Style.accentColor
                }

                Label {
                    Layout.fillWidth: true
                    text: engine.jsonRpcClient.initialSetupRequired ?
                              qsTr("In order to use your %1 system, please enter your email address and set a password for it.").arg(Configuration.systemName)
                            : qsTr("In order to use your %1 system, please log in.").arg(Configuration.systemName)
                    wrapMode: Text.WordWrap
                }
            }


            GridLayout {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                columns: app.width > 500 ? 2 : 1
                columnSpacing: app.margins

                Label {
                    text: qsTr("Your e-mail address:")
                    Layout.fillWidth: true
                    Layout.minimumWidth: implicitWidth
                }
                TextField {
                    id: usernameTextField
                    Layout.fillWidth: true
                    inputMethodHints: Qt.ImhEmailCharactersOnly | Qt.ImhNoAutoUppercase
//                    placeholderText: "john.smith@cooldomain.com"
                }
                Label {
                    Layout.fillWidth: true
                    text: qsTr("Password:")
                }
                PasswordTextField {
                    id: passwordTextField
                    Layout.fillWidth: true
                    minPasswordLength: 8
                    requireLowerCaseLetter: true
                    requireUpperCaseLetter: true
                    requireNumber: true
                    requireSpecialChar: false
                    signup: engine.jsonRpcClient.initialSetupRequired
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.bottomMargin: app.margins
                text: qsTr("OK")
                enabled: passwordTextField.isValid
                onClicked: {
                    if (engine.jsonRpcClient.initialSetupRequired) {
                        print("create user")
                        engine.jsonRpcClient.createUser(usernameTextField.text, passwordTextField.password);
                    } else {
                        print("authenticate", usernameTextField.text, passwordTextField.text, "nymea-app")
                        engine.jsonRpcClient.authenticate(usernameTextField.text, passwordTextField.password, "nymea-app (" + PlatformHelper.deviceModel + ")");
                    }
                }
            }
        }
    }


    Component {
        id: errorDialog
        ErrorDialog {

        }
    }
}
