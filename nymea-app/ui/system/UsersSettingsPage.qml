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
import QtQuick.Controls.Material
import QtQuick.Layouts

import Nymea
import NymeaApp.Utils

import "../components"
import "../delegates"

SettingsPageBase {
    id: root
    title: qsTr("User settings")

    UserManager {
        id: userManager
        engine: _engine

        onChangePasswordReply: (id, error) => {
            if (error !== UserManager.UserErrorNoError) {
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

    RowLayout {
        Layout.margins: Style.margins
        spacing: Style.margins
        //visible: !engine.jsonRpcClient.pushButtonAuthAvailable
        ColorIcon {
            size: Style.hugeIconSize
            source: "qrc:/icons/account.svg"
            color: Style.accentColor
        }
        ColumnLayout {
            Label {
                Layout.fillWidth: true
                text: userManager.userInfo.displayName || userManager.userInfo.username
                font: Style.bigFont
            }
            Label {
                Layout.fillWidth: true
                text: userManager.userInfo.username
                visible: userManager.userInfo.displayName !== ""
            }
            Label {
                Layout.fillWidth: true
                text: userManager.userInfo.email
                font: Style.smallFont
            }
        }
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Change password")
        iconName: "qrc:/icons/key.svg"
        visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) && !engine.jsonRpcClient.pushButtonAuthAvailable
        onClicked: {
            var page = pageStack.push(changePasswordComponent)
            page.confirmed.connect(function(newPassword) {
                userManager.changePassword(newPassword)
            })
        }
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Edit user information")
        iconName: "qrc:/icons/edit.svg"
        onClicked: pageStack.push(editUserInfoComponent)
        visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) && !engine.jsonRpcClient.pushButtonAuthAvailable
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Manage authorized devices")
        iconName: "qrc:/icons/smartphone.svg"
        visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin)
        onClicked: pageStack.push(manageTokensComponent)
    }

    SettingsPageSectionHeader {
        text: qsTr("Admin")
        visible: (userManager.userInfo.scopes & UserInfo.PermissionScopeAdmin) //&& !engine.jsonRpcClient.pushButtonAuthAvailable
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Manage users")
        visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) //&& !engine.jsonRpcClient.pushButtonAuthAvailable
        iconName: "qrc:/icons/contact-group.svg"
        onClicked: pageStack.push(manageUsersComponent)
    }

    Component {
        id: editUserInfoComponent
        SettingsPageBase {
            id: editUserInfoPage
            title: qsTr("Edit user information")

            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: Style.margins
                spacing: Style.margins

                TextField {
                    id: displayNameTextField
                    Layout.fillWidth: true
                    placeholderText: qsTr("Your name")
                    text: userManager.userInfo.displayName
                }

                TextField {
                    id: emailTextField
                    Layout.fillWidth: true
                    placeholderText: qsTr("Email")
                    text: userManager.userInfo.email
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.margins: Style.margins
                text: qsTr("OK")
                onClicked: {
                    editUserInfoPage.busy = true
                    userManager.setUserInfo(userManager.userInfo.username, displayNameTextField.text, emailTextField.text)
                }
            }

            Connections {
                target: userManager
                onSetUserInfoReply: (id, error) => {
                    editUserInfoPage.busy = false
                    if (error !== UserManager.UserErrorNoError) {
                        var component = Qt.createComponent("../components/ErrorDialog.qml")
                        var text = qsTr("Un unexpected error happened when creating the user. We're sorry for this. (Error code: %1)").arg(error);
                        var popup = component.createObject(app, {text: text});
                        popup.open()
                    } else {
                        pageStack.pop()
                    }
                }
            }
        }
    }

    Component {
        id: configureAllowedThingsComponent

        Page {
            id: configureAllowedThingsPage

            property UserInfo userInfo: null
            property bool existingUser: true

            title: qsTr("Accessable things for") + " \"" + userInfo.username + "\""

            header: NymeaHeader {
                text: configureAllowedThingsPage.title
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent

                ListFilterInput {
                    id: filterInput
                    Layout.fillWidth: true
                }

                GroupedListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    model: ThingsProxy {
                        id: thingsProxy
                        engine: _engine
                        groupByInterface: true
                        nameFilter: filterInput.shown ? filterInput.text : ""
                    }

                    delegate: ThingDelegate {
                        id: thingDelegate
                        thing: thingsProxy.getThing(model.id)
                        canDelete: false
                        progressive: false
                        additionalItem: CheckBox {
                            checked: configureAllowedThingsPage.userInfo.thingAllowed(thingDelegate.thing.id)
                            onCheckedChanged: {
                                configureAllowedThingsPage.userInfo.allowThingId(thingDelegate.thing.id, checked)
                                if (configureAllowedThingsPage.existingUser) {
                                    // Only update if this user already exists
                                    userManager.setUserScopes(configureAllowedThingsPage.userInfo.username, configureAllowedThingsPage.userInfo.scopes, configureAllowedThingsPage.userInfo.allowedThingIds)
                                }
                            }
                        }
                    }
                }
            }
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
                bottomPadding: Style.margins
                text: qsTr("Please enter the new password for %1").arg(userManager.userInfo.username)
                wrapMode: Text.WordWrap
            }

            ConsolinnoPasswordTextField {
                id: passwordTextField
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
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

            Component {
                id: confirmTokenDeletionComponent
                NymeaDialog {
                    headerIcon: "qrc:/icons/lock-closed.svg"
                    title: qsTr("Remove device access")
                    text: qsTr("Are you sure you want to remove %1 from accessing your %2 system?").arg("<b>" + tokenInfo.deviceName + "</b>").arg(Configuration.systemName)
                    property TokenInfo tokenInfo: null
                    standardButtons: Dialog.Yes | Dialog.No
                    onAccepted: {
                        userManager.removeToken(tokenInfo.id)
                    }
                }
            }

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
                    iconName: "qrc:/icons/smartphone.svg"

                    onClicked: deleteClicked()
                    onDeleteClicked: {
                        var popup = confirmTokenDeletionComponent.createObject(manageTokensPage, {tokenInfo: userManager.tokenInfos.get(index)})
                        popup.open()
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
                    imageSource: Qt.resolvedUrl("qrc:/icons/add.svg")
                    onClicked: {
                        var page = pageStack.push(addUserComponent)
                        page.done.connect(function(){
                            reloadUserList()
                            pageStack.pop()
                        })
                    }
                }
            }

            SettingsPageSectionHeader {
                text: qsTr("Manage users for this %1 system").arg(Configuration.systemName)
            }

            ListModel{
                id: users
            }

            Component.onCompleted: {
                reloadUserList()
            }

            function reloadUserList(){
                // empty the ListModel so it can reload
                users.clear()
                for(var i = 0; i < userManager.users.count  ; i++ ){
                    if (usrManager.users.get(i)){
                        users.append(userManager.users.get(i))
                    }
                }
            }

            Repeater {
                id: userRepeater
                model: users
                delegate: NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: engine.jsonRpcClient.ensureServerVersion("6.0") && model.displayName !== "" ? model.displayName : model.username !== "" ? model.username : qsTr("User login via authentication")
                    subText: engine.jsonRpcClient.ensureServerVersion("6.0") && model.displayName ? model.username : ""
                    iconName: "qrc:/icons/account.svg"
                    iconColor: userManager.userInfo.scopes & UserInfo.PermissionScopeAdmin ? Style.accentColor : Style.iconColor

                    canDelete: true
                    onClicked: {
                        var page = pageStack.push(userDetailsComponent, {userInfo: userManager.users.get(index)})
                        page.done.connect(function(){
                            reloadUserList()
                            pageStack.pop()
                        })

                    }
                }
            }
        }
    }

    Component {
        id: userDetailsComponent

        SettingsPageBase {
            id: userDetailsPage
            title: userInfo.username ? qsTr("Manage %1").arg(userInfo.username) : qsTr("Authenticated user")
            signal done

            property UserInfo userInfo: null

            Component {
                id: confirmUserDeletionComponent
                NymeaDialog {
                    headerIcon: "qrc:/icons/lock-closed.svg"
                    title: qsTr("Remove user")
                    text: qsTr("Are you sure you want to remove %1 from accessing your %2 system?").arg("<b>" + userInfo.username + "</b>").arg(Configuration.systemName)
                    property UserInfo userInfo: null
                    standardButtons: Dialog.Yes | Dialog.No
                    onAccepted: {
                        userDetailsPage.busy = true
                        userManager.removeUser(userInfo.username)
                    }
                }
            }

            SettingsPageSectionHeader {
                text: qsTr("User information for %1").arg(userDetailsPage.userInfo.username)
            }

            ColumnLayout {
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                spacing: Style.margins

                NymeaTextField {
                    id: displayNameTextField
                    Layout.fillWidth: true
                    placeholderText: qsTr("Name")
                    text: userDetailsPage.userInfo.displayName
                }

                NymeaTextField {
                    id: emailTextField
                    Layout.fillWidth: true
                    placeholderText: qsTr("Email")
                    text: userDetailsPage.userInfo.email
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.margins: Style.margins
                text: qsTr("Save")
                onClicked: {
                    userManager.setUserInfo(userDetailsPage.userInfo.username, displayNameTextField.text, emailTextField.text)
                }
            }

            SettingsPageSectionHeader {
                text: qsTr("Permissions")
            }

            Repeater {
                id: permissionRepeater

                model: engine.jsonRpcClient.ensureServerVersion("8.4") ? NymeaUtils.scopesModel : NymeaUtils.scopesModelPre8dot4
                delegate: NymeaSwipeDelegate {

                    Layout.fillWidth: true

                    text: model.text
                    subText: model.description
                    progressive: false

                    CheckBox {
                        anchors.right: parent.right
                        anchors.rightMargin: app.margins
                        anchors.verticalCenter: parent.verticalCenter

                        checked: (userDetailsPage.userInfo.scopes & model.scope) === model.scope
                        enabled: {
                            // Prevent an admin to lock himself out as admin
                            if (model.scope === UserInfo.PermissionScopeAdmin && userDetailsPage.userInfo.username == userManager.userInfo.username) {
                                return false
                            } else {
                                return model.scope === UserInfo.PermissionScopeAdmin || ((userDetailsPage.userInfo.scopes & UserInfo.PermissionScopeAdmin) !== UserInfo.PermissionScopeAdmin)
                            }
                        }

                        onClicked: {
                            var scopes = userDetailsPage.userInfo.scopes
                            if (checked) {
                                scopes |= model.scope
                            } else {
                                scopes &= ~model.scope
                            }

                            // make sure the new permissions are consistant before sending them to the core
                            scopes = NymeaUtils.getPermissionScopeAdjustments(model.scope, checked, scopes)
                            userManager.setUserScopes(userDetailsPage.userInfo.username, scopes, userDetailsPage.userInfo.allowedThingIds)
                        }
                    }
                }
            }

            SettingsPageSectionHeader {
                text: qsTr("Acessable things")
                visible: engine.jsonRpcClient.ensureServerVersion("8.4") &&
                         (userDetailsPage.userInfo.scopes & UserInfo.PermissionScopeAccessAllThings) !== UserInfo.PermissionScopeAccessAllThings
                Layout.fillWidth: true
            }

            NymeaSwipeDelegate {
                id: allowedThingsEntry
                Layout.fillWidth: true
                text: qsTr("Allowed things for this user")
                subText: userDetailsPage.userInfo.allowedThingIds.length + " " + qsTr("things accessable")
                visible: engine.jsonRpcClient.ensureServerVersion("8.4") &&
                         (userDetailsPage.userInfo.scopes & UserInfo.PermissionScopeAccessAllThings) !== UserInfo.PermissionScopeAccessAllThings
                progressive: true
                onClicked: pageStack.push(configureAllowedThingsComponent, {userInfo: userDetailsPage.userInfo})
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
                    var popup = confirmUserDeletionComponent.createObject(userDetailsPage, {userInfo: userDetailsPage.userInfo})
                    popup.open()
                }
            }

            Connections {
                target: userManager
                onRemoveUserReply: (id, error) => {
                    userDetailsPage.busy = false
                    if (error !== UserManager.UserErrorNoError) {
                        var component = Qt.createComponent("../components/ErrorDialog.qml")
                        var text = qsTr("Un unexpected error happened when creating the user. We're sorry for this. (Error code: %1)").arg(error);
                        var popup = component.createObject(app, {text: text});
                        popup.open()
                    } else {
                        userDetailsPage.done()
                    }
                }
            }
        }
    }

    Component {
        id: addUserComponent

        SettingsPageBase {
            id: createUserPage
            title: qsTr("Add a user")

            signal done
            // Consolinno change: New users are admin by default.
             property var permissionScopes: UserInfo.PermissionScopeAdmin

            SettingsPageSectionHeader {
                text: qsTr("User information")
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                spacing: Style.margins

                UsernameTextField {
                    id: usernameTextField
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("Password:") + "*"
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: Style.smallMargins
                }
                ConsolinnoPasswordTextField {
                    id: passwordTextField
                    Layout.fillWidth: true
                }

                TextField {
                    id: displayNameTextField
                    placeholderText: qsTr("Full name:")  + " (" + qsTr("Optional") + ")"
                    Layout.fillWidth: true
                }

                TextField {
                    id: emailTextField
                    placeholderText: qsTr("Email") + " (" + qsTr("Optional") + ")"
                    Layout.fillWidth: true
                }
            }

            SettingsPageSectionHeader {
                text: qsTr("Permissions")
            }

            Repeater {
                id: scopesRepeater

                model: engine.jsonRpcClient.ensureServerVersion("8.4") ? NymeaUtils.scopesModel : NymeaUtils.scopesModelPre8dot4

                delegate: NymeaSwipeDelegate {

                    Layout.fillWidth: true

                    text: model.text
                    subText: model.description
                    progressive: false

                    CheckBox {
                        anchors.right: parent.right
                        anchors.rightMargin: app.margins
                        anchors.verticalCenter: parent.verticalCenter
                        enabled: model.scope === UserInfo.PermissionScopeAdmin || ((newUserInfo.scopes & UserInfo.PermissionScopeAdmin) !== UserInfo.PermissionScopeAdmin)
                        checked: (newUserInfo.scopes & model.scope) === model.scope
                        onClicked: {
                            var scopes = newUserInfo.scopes
                            if (checked) {
                                scopes |= model.scope
                            } else {
                                scopes &= ~model.scope
                            }

                            // make sure the new permissions are consistant before sending them to the core
                            scopes = NymeaUtils.getPermissionScopeAdjustments(model.scope, checked, scopes)
                            newUserInfo.scopes = scopes
                        }
                    }
                }
            }

            SettingsPageSectionHeader {
                text: qsTr("Acessable things")
                visible: engine.jsonRpcClient.ensureServerVersion("8.4") &&
                         (newUserInfo.scopes & UserInfo.PermissionScopeAccessAllThings) !== UserInfo.PermissionScopeAccessAllThings
                Layout.fillWidth: true
            }

            NymeaSwipeDelegate {
                id: allowedThingsEntry
                Layout.fillWidth: true
                text: qsTr("Allowed things for this user")
                subText: newUserInfo.allowedThingIds.length + " " + qsTr("things accessable")
                visible: engine.jsonRpcClient.ensureServerVersion("8.4") &&
                         (newUserInfo.scopes & UserInfo.PermissionScopeAccessAllThings) !== UserInfo.PermissionScopeAccessAllThings
                progressive: true
                onClicked: pageStack.push(configureAllowedThingsComponent, {userInfo: newUserInfo, existingUser: false})
            }

            Button {
                text: qsTr("Create new user")
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                enabled: usernameTextField.displayText.length >= 3 && passwordTextField.isValid
                onClicked: {
                    createUserPage.busy = true
                    userManager.createUser(usernameTextField.displayText, passwordTextField.password, displayNameTextField.text, emailTextField.text, newUserInfo.scopes, newUserInfo.allowedThingIds)
                }
            }
            Connections {
                target: userManager
                onCreateUserReply: (id, error) => {
                    createUserPage.busy = false
                    if (error !== UserManager.UserErrorNoError) {
                        var component = Qt.createComponent("../components/ErrorDialog.qml")
                        var text;
                        switch (error) {
                        case UserManager.UserErrorInvalidUserId:
                            text = qsTr("The given username is not valid. It needs to be at least three characters long and not contain special characters.");
                            break;
                        case UserManager.UserErrorDuplicateUserId:
                            text = qsTr("The given username is already in use. Please choose a different username.");
                            break;
                        case UserManager.UserErrorBadPassword:
                            text = qsTr("The given password is not valid.");
                            break;
                        case UserManager.UserErrorPermissionDenied:
                            text = qsTr("Permission denied.");
                            break;
                        default:
                            text = qsTr("Un unexpected error happened when creating the user. We're sorry for this. (Error code: %1)").arg(error);
                            break;
                        }

                        var popup = component.createObject(app, {text: text});
                        popup.open()
                    } else {
                        createUserPage.done()
                    }
                }
            }
        }
    }
}
