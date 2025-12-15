/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2025, nymea GmbH
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

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Nymea
import NymeaApp.Utils

import Nymea.EvDash

import "../components"

SettingsPageBase {
    id: root

    header: NymeaHeader {
        text: qsTr("EV Dash")
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: Qt.resolvedUrl("qrc:/icons/add.svg")
            onClicked: {
                var popup = addUserPopup.createObject(app);
                popup.open();
            }
        }
    }

    EvDashManager {
        id: evDashManager
        engine: _engine
    }

    Component {
        id: errorDialog
        ErrorDialog {}
    }


    Component {
        id: removeUserPopup

        NymeaDialog {
            id: removeUserDialog

            property string username

            headerIcon: "qrc:/icons/dialog-warning-symbolic.svg"
            standardButtons: Dialog.Yes | Dialog.No
            title: qsTr("Remove user")
            text: qsTr("Are you sure you want to remove \"%1\"?").arg(username)

            onAccepted:  {
                evDashManager.removeUser(username);
                removeUserDialog.close();
            }
        }
    }

    Connections {
        target: evDashManager
        onAddUserReply: (commandId, error) => {
            if (error === EvDashManager.EvDashErrorNoError)
                return

            var text;
            switch (error) {
            case EvDashManager.EvDashErrorDuplicateUser:
                text = qsTr("The given username is already in use. Please choose a different username.");
                break;
            case EvDashManager.EvDashErrorBadPassword:
                text = qsTr("The given password is not valid.");
                break;
            default:
                text = qsTr("Un unexpected error happened when creating the user. We're sorry for this. (Error code: %1)").arg(error);
                break;
            }

            var popup = errorDialog.createObject(app, {text: text});
            popup.open()
        }

        onRemoveUserReply: (commandId, error) => {
            if (error === EvDashManager.EvDashErrorNoError)
                return

            var text;
            switch (error) {
            case EvDashManager.EvDashErrorDuplicateUser:
                text = qsTr("The given username is already in use. Please choose a different username.");
                break;
            case EvDashManager.EvDashErrorBadPassword:
                text = qsTr("The given password is not valid.");
                break;
            default:
                text = qsTr("Un unexpected error happened when creating the user. We're sorry for this. (Error code: %1)").arg(error);
                break;
            }

            var popup = errorDialog.createObject(app, {text: text});
            popup.open()
        }
    }

    Component {
        id: addUserPopup

        NymeaDialog {
            id: addUserDialog

            title: qsTr("Create a new user")
            standardButtons: Dialog.NoButton

            NymeaTextField {
                id: usernameTextField
                placeholderText: qsTr("Username")
                Layout.fillWidth: true
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.margins
            }

            PasswordTextField {
                id: passwordTextField

                Layout.fillWidth: true
                minPasswordLength: 4
                requireSpecialChar: false
                requireNumber: false
                requireUpperCaseLetter: false
                requireLowerCaseLetter: false
            }

            Button {
                Layout.fillWidth: true
                text: qsTr("Add user")
                onClicked: {
                    evDashManager.addUser(usernameTextField.text, passwordTextField.password)
                    addUserDialog.close()
                }
            }

            Button {
                Layout.fillWidth: true
                text: qsTr("Cancel")
                onClicked: {
                    addUserDialog.close()
                }
            }
        }
    }


    SwitchDelegate {
        text: qsTr("Dashboard enabled")
        checked: evDashManager.enabled
        onCheckedChanged: evDashManager.enabled = checked
        Layout.fillWidth: true
    }

    SettingsPageSectionHeader {
        text: qsTr("Manage users")
    }

    Repeater {
        id: usersList
        model: evDashManager.users

        delegate: NymeaItemDelegate {
            Layout.fillWidth: true
            text: model.name
            iconName: "account"
            progressive: false
            additionalItem: ColorIcon {
                name: "delete"
                color: Style.foregroundColor
                anchors.verticalCenter:  parent.verticalCenter
            }

            onClicked: {
                var popup = removeUserPopup.createObject(app, {username: model.name});
                popup.open()
            }
        }
    }
}
