import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

SettingsPageBase {
    id: root
    title: qsTr("User settings")

    UserManager {
        id: userManager
        engine: _engine

        onChangePasswordReply: {
            if (error != UserManager.UserErrorNoError) {
                var component = Qt.createComponent("../components/ErrorDialog.qml")
                var text;
                switch (error) {
                case UserManager.UserErrorBadPassword:
                    text = qsTr("The given password is not valid.");
                    break;
                case UserManager.UserErrorPermissionDenied:
                    text = qsTr("Permission denied.");
                    break;
                case UserManager.UserErrorBackendError:
                    text = qsTr("The new password could not be stored.")
                    break;
                default:
                    text = qsTr("Un unexpected error happened when changing the password. We're sorry for this. (Error code: %1)").arg(error);
                    break;
                }

                var popup = component.createObject(app, {text: text});
                popup.open()
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("User info")
    }

    NymeaSwipeDelegate {
        Layout.fillWidth: true
        text: userManager.userInfo.username
        subText: qsTr("Username")
        progressive: false
        prominentSubText: false
        iconName: "../images/account.svg"
    }

    NymeaSwipeDelegate {
        Layout.fillWidth: true
        text: qsTr("Change password")
        iconName: "../images/key.svg"
        onClicked: {
            var page = pageStack.push(changePasswordComponent)
            page.confirmed.connect(function(newPassword) {
                userManager.changePassword(newPassword)
            })
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Device access")
    }

    Button {
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        text: qsTr("Manage authorized devices")
        onClicked: {
            pageStack.push(manageTokensComponent)
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Admin")
        visible: userManager.userInfo.scopes & UserInfo.PermissionScopeAdmin
    }

    Button {
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        text: qsTr("Manage users")
        visible: userManager.userInfo.scopes & UserInfo.PermissionScopeAdmin
        onClicked: {
            pageStack.push(manageUsersComponent)
        }
    }


    Component {
        id: changePasswordComponent
        SettingsPageBase {
            id: changePasswordPage
            title: qsTr("Change password")

            signal confirmed(string newPassword)

            SettingsPageSectionHeader {
                text: qsTr("Change password")
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                text: qsTr("Please enter the new password for %1").arg(userManager.userInfo.username)
                wrapMode: Text.WordWrap
            }

            PasswordTextField {
                id: passwordTextField
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                minPasswordLength: 8
                requireLowerCaseLetter: true
                requireUpperCaseLetter: true
                requireNumber: true
                requireSpecialChar: false
                signup: true
            }

            Button {
                text: qsTr("OK")
                Layout.fillWidth: true
                Layout.margins: app.margins
                enabled: passwordTextField.isValid
                onClicked: {
                    changePasswordPage.confirmed(passwordTextField.password)
                    pageStack.pop();
                }
            }
        }
    }

    Component {
        id: manageTokensComponent
        SettingsPageBase {
            id: manageTokensPage
            title: qsTr("Device access")

            SettingsPageSectionHeader {
                text: qsTr("Devices / Apps accessing %1").arg(Configuration.systemName)
            }

            Repeater {
                model: userManager.tokenInfos

                delegate: NymeaSwipeDelegate {
                    Layout.fillWidth: true
                    text: model.deviceName
                    subText: qsTr("Created on %1").arg(Qt.formatDateTime(model.creationTime, Qt.DefaultLocaleShortDate))
                    prominentSubText: false
                    progressive: false
                    canDelete: true

                    onDeleteClicked: {
                        userManager.removeToken(model.id)
                    }
                }
            }
        }
    }

    Component {
        id: manageUsersComponent
        SettingsPageBase {
            id: manageUsersPage

            header: NymeaHeader {
                text: qsTr("Users")
                onBackPressed: pageStack.pop()

                HeaderButton {
                    imageSource: Qt.resolvedUrl("../images/add.svg")
                    onClicked: {
                        pageStack.push(addUserComponent)
                    }
                }
            }

            SettingsPageSectionHeader {
                text: qsTr("Manage users for this %1 system").arg(Configuration.systemName)
            }

            Repeater {
                model: userManager.users
                delegate: NymeaSwipeDelegate {
                    Layout.fillWidth: true
                    text: model.username
                    iconName: "/ui/images/account.svg"
                    iconColor: userManager.userInfo.scopes & UserInfo.PermissionScopeAdmin ? Style.accentColor : Style.iconColor

                    canDelete: true
                    onClicked: {
                        pageStack.push(userDetailsComponent, {userInfo: userManager.users.get(index)})
                    }

                    onDeleteClicked: {
                        userManager.removeUser(model.username)
                    }
                }
            }
        }
    }

    Component {
        id: userDetailsComponent
        SettingsPageBase {
            id: userDetailsPage
            title: qsTr("Manage user")

            property UserInfo userInfo: null

            SettingsPageSectionHeader {
                text: qsTr("User info")
            }

            NymeaItemDelegate {
                Layout.fillWidth: true
                text: userDetailsPage.userInfo.username
                progressive: false
            }

            SettingsPageSectionHeader {
                text: qsTr("Permissions")
            }

            Repeater {
                model: NymeaUtils.scopesModel

                delegate: CheckDelegate {
                    Layout.fillWidth: true
                    text: model.text
                    checked: (userDetailsPage.userInfo.scopes & model.scope) === model.scope
                    enabled: model.scope === UserInfo.ScopeAdmin ||
                             (userDetailsPage.userInfo.scopes & UserInfo.ScopeAdmin) == 0
                    onClicked: {
                        print("scopes:", userDetailsPage.userInfo.scopes)
                        var scopes = userDetailsPage.userInfo.scopes
                        if (checked) {
                            scopes |= model.scope
                        } else {
                            scopes &= ~model.scope
                            scopes |= model.resetOnUnset
                        }
                        userManager.setUserScopes(userDetailsPage.userInfo.username, scopes)
                    }
                }
            }

            SettingsPageSectionHeader {
                text: qsTr("Remove")
            }

            Button {
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                text: qsTr("Remove this user")
                onClicked: {
                    userManager.removeUser(userDetailsPage.userInfo.username)
                }
            }
        }
    }

    Component {
        id: addUserComponent

        SettingsPageBase {
            id: createUserPage
            title: qsTr("Add a user")

            property var permissionScopes: UserInfo.PermissionScopeNone

            SettingsPageSectionHeader {
                text: qsTr("Login information")
            }

            TextField {
                id: usernameTextField
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                placeholderText: qsTr("Username")
                inputMethodHints: Qt.ImhEmailCharactersOnly | Qt.ImhNoAutoUppercase
            }
            PasswordTextField {
                id: passwordTextField
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
            }

            SettingsPageSectionHeader {
                text: qsTr("Permissions")
            }


            Repeater {
                id: scopesRepeater
                model: NymeaUtils.scopesModel

                delegate: CheckDelegate {
                    Layout.fillWidth: true
                    text: model.text
                    checked: (createUserPage.permissionScopes & model.scope) === model.scope
                    onClicked: {
                        var scopes = createUserPage.permissionScopes
                        if (checked) {
                            scopes |= model.scope
                        } else {
                            scopes &= ~model.scope
                            scopes |= model.resetOnUnset
                        }
                        createUserPage.permissionScopes = scopes
                    }
                }
            }

            Button {
                text: qsTr("Create new user")
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                enabled: usernameTextField.displayText.length > 3 && passwordTextField.isValid
                onClicked: {
                    userManager.createUser(usernameTextField.displayText, passwordTextField.password, createUserPage.permissionScopes)
                }
            }
        }
    }
}
