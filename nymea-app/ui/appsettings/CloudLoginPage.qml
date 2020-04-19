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
    title: qsTr("%1 cloud login").arg(app.appName)

    Component.onCompleted: {
        if (AWSClient.isLoggedIn) {
            AWSClient.fetchDevices();
        }
    }

    Connections {
        target: AWSClient
        onLoginResult: {
            root.busy = false;
            if (error === AWSClient.LoginErrorNoError) {
                AWSClient.fetchDevices();
            }
        }
        onDeleteAccountResult: {
            root.busy = false;
            if (error !== AWSClient.LoginErrorNoError) {
                var errorDialog = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"));
                var text = qsTr("Sorry, an error happened removing the account. Please try again later.");
                var popup = errorDialog.createObject(app, {text: text})
                popup.open()
                return;
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        visible: AWSClient.isLoggedIn

        SettingsPageSectionHeader {
            text: qsTr("Login")
        }

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            wrapMode: Text.WordWrap
            text: qsTr("Logged in as %1").arg(AWSClient.username)
        }

        Button {
            Layout.fillWidth: true
            Layout.margins: app.margins
            text: qsTr("Log out")
            onClicked: {
                logoutDialogComponent.createObject(root).open()
            }
        }

        RowLayout {
            SettingsPageSectionHeader {
                text: qsTr("Connected %1:core systems").arg(app.systemName)
            }
            BusyIndicator {
                running: AWSClient.awsDevices.busy
                height: app.iconSize
                width: height
            }
        }


        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            wrapMode: Text.WordWrap
            text: AWSClient.awsDevices.count === 0 ?
                      qsTr("There are no %1:core systems connected to your cloud yet.").arg(app.systemName) :
                      qsTr("There are %n %1:core systems connected to your cloud.", "", AWSClient.awsDevices.count).arg(app.systemName)
        }

        Repeater {
            model: AWSClient.awsDevices
            delegate: NymeaListItemDelegate {
                Layout.fillWidth: true
                text: model.name
                subText: model.id
                progressive: false
                prominentSubText: false
                canDelete: true
                iconName: "../images/cloud.svg"
                secondaryIconName: !model.online ? "../images/cloud-error.svg" : ""

                onClicked: {
                    print("clicked, connected:", engine.jsonRpcClient.connected, model.id)
                    if (!engine.jsonRpcClient.connected) {
                        var host = discovery.nymeaHosts.find(model.id)
                        engine.jsonRpcClient.connectToHost(host);
                    }
                }

                onDeleteClicked: {
                    AWSClient.unpairDevice(model.id);
                }
            }

        }
    }


    ColumnLayout {
        id: loginColumn
        visible: !AWSClient.isLoggedIn
        Layout.fillWidth: true
        SettingsPageSectionHeader {
            text: qsTr("Login")
        }
        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
            wrapMode: Text.WordWrap
            text: qsTr("Log %1 in to %2:cloud in order to connect to %2:core systems from anywhere and receive push notifications from %2:core systems.").arg(app.appName).arg(app.systemName)
        }
        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
            wrapMode: Text.WordWrap
            font.pixelSize: app.smallFont
            text: qsTr("See our <a href=\"%1\">privacy policy</a> to find out what information is processed.").arg(app.privacyPolicyUrl)
            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
        }

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
            text: "Username (e-mail)"
        }
        TextField {
            id: usernameTextField
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            placeholderText: "john.smith@cooldomain.com"
            inputMethodHints: Qt.ImhEmailCharactersOnly
            validator: RegExpValidator { regExp:/\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/ }
        }
        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
            text: qsTr("Password")
        }
        RowLayout {
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            PasswordTextField {
                id: passwordTextField
                Layout.fillWidth: true
                signup: false
            }
        }


        Button {
            Layout.fillWidth: true
            Layout.margins: app.margins
            text: qsTr("OK")
            enabled: usernameTextField.acceptableInput
            onClicked:  {
                root.busy = true
                AWSClient.login(usernameTextField.text, passwordTextField.password);
            }
        }

        Connections {
            target: AWSClient
            onLoginResult: {
                switch (error) {
                case AWSClient.LoginErrorInvalidUserOrPass:
                    errorLabel.text = qsTr("Failed to log in. Please try again. Do you perhaps have <a href=\"#\">forgotten your password?</a>")
                    break;
                case AWSClient.LoginErrorNetworkError:
                    errorLabel.text = qsTr("Failed to connect to the login server. Please mase sure your network connection is working.")
                    break;
                default:
                    errorLabel.text = qsTr("An unexpected error happened. Please report this isse. Error code: %1").arg(error)
                    break;
                }
                errorLabel.visible = (error !== AWSClient.LoginErrorNoError)
            }
        }

        Label {
            id: errorLabel
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.bottomMargin: app.margins
            wrapMode: Text.WordWrap
            font.pixelSize: app.smallFont
            color: "red"
            visible: false
            onLinkActivated: {
                pageStack.push(resetPasswordComponent, {email: usernameTextField.text})
            }
        }

        ThinDivider {}

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
            wrapMode: Text.WordWrap
            text: qsTr("Don't have a user yet?")
        }

        Button {
            Layout.fillWidth: true
            Layout.margins: app.margins
            text: qsTr("Sign Up")
            onClicked: {
                pageStack.push(signupPageComponent)
            }
        }
    }


    Component {
        id: signupPageComponent
        SettingsPageBase {
            id: signupPage
            title: qsTr("Sign up")

            Connections {
                target: AWSClient
                onSignupResult: {
                    signupPage.busy = false;
                    var text;
                    switch (error) {
                    case AWSClient.LoginErrorNoError:
                        pageStack.push(enterCodeComponent)
                        return;
                    case AWSClient.LoginErrorInvalidUserOrPass:
                        text = qsTr("The given username or password are not valid.")
                        break;
                    default:
                        text = qsTr("Uh oh, something went wrong. Please try again.")
                    }
                    var errorDialog = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"));
                    var popup = errorDialog.createObject(app, {text: text})
                    popup.open()
                }
            }


            SettingsPageSectionHeader {
                text: qsTr("Welcome to %1:cloud.").arg(app.systemName)
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                wrapMode: Text.WordWrap
                text: qsTr("Please enter your email address and pick a password in order to create a new account.");
                onLinkActivated: {
                    print("clicked", link)
                    Qt.openUrlExternally(link)
                }
            }
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
                wrapMode: Text.WordWrap
                font.pixelSize: app.smallFont
                text: qsTr("See our <a href=\"%1\">privacy policy</a> to find out what information is processed. By signing up to %2:cloud you accept those terms and conditions.").arg(app.privacyPolicyUrl).arg(app.systemName)
                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
                text: "Username (e-mail)"
            }
            TextField {
                id: usernameTextField
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                placeholderText: "john.smith@cooldomain.com"
                inputMethodHints: Qt.ImhEmailCharactersOnly
                validator: RegExpValidator { regExp:/\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/ }
            }
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
                text: qsTr("Password")
            }
            PasswordTextField {
                id: passwordTextField
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                Layout.fillWidth: true
                minPasswordLength: 8
                requireLowerCaseLetter: true
                requireUpperCaseLetter: true
                requireNumber: true
                requireSpecialChar: false
            }

            Button {
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: qsTr("Sign up")
                enabled: usernameTextField.acceptableInput && passwordTextField.isValid
                onClicked: {
                    signupPage.busy = true;
                    AWSClient.signup(usernameTextField.text, passwordTextField.password)
                }
            }
        }




    }

    Component {
        id: enterCodeComponent
        Page {
            header: NymeaHeader {
                text: qsTr("Confirm account")
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors { left: parent.left; top: parent.top; right: parent.right }

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
                    wrapMode: Text.WordWrap
                    text: qsTr("Thanks for signing up. We will send you an email with a confirmation code. Please enter that code in the field below.")
                }

                TextField {
                    id: confirmationCodeTextField
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
                    inputMethodHints: Qt.ImhDigitsOnly
                }

                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
                    text: qsTr("OK")
                    onClicked: {
                        root.busy = true;
                        AWSClient.confirmRegistration(confirmationCodeTextField.text)
                    }
                }

                Connections {
                    target: AWSClient
                    onConfirmationResult: {
                        root.busy = false;
                        var text
                        switch (error) {
                        case AWSClient.LoginErrorNoError:
                            pageStack.pop(root)
                            return;
                        case AWSClient.LoginErrorUserExists:
                            text = qsTr("The given user already exists. Did you forget the password?")
                            break;
                        case AWSClient.LoginErrorInvalidCode:
                            text = qsTr("That wasn't the right code. Please try again.")
                            break;
                        case AWSClient.LoginErrorUnknownError:
                            text = qsTr("Uh oh, something went wrong. Please try again.")
                            break;
                        }
                        var errorDialog = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"));
                        var popup = errorDialog.createObject(app, {text: text})
                        popup.open()
                        return;

                    }
                }
            }
        }
    }

    Component {
        id: resetPasswordComponent
        SettingsPageBase {
            id: resetPasswordPage
            title: qsTr("Reset password")

            property alias email: emailTextField.text

            Connections {
                target: AWSClient
                onForgotPasswordResult: {
                    resetPasswordPage.busy = false
                    if (error !== AWSClient.LoginErrorNoError) {
                        var errorDialog = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"));
                        var text = qsTr("Sorry, this wasn't right. Did you misspell the email address?");
                        if (error === AWSClient.LoginErrorLimitExceeded) {
                            text = qsTr("Sorry, there were too many attempts. Please try again after some time.")
                        }
                        var popup = errorDialog.createObject(app, {text: text})
                        popup.open()
                        return;
                    }
                    pageStack.push(confirmResetPasswordComponent, {email: emailTextField.text })
                }
            }


            Label {
                Layout.fillWidth: true
                Layout.margins: app.margins
                wrapMode: Text.WordWrap
                text: qsTr("Password forgotten?")
                font.pixelSize: app.largeFont
                color: app.accentColor
            }
            Label {
                Layout.fillWidth: true; Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                wrapMode: Text.WordWrap
                text: qsTr("No problem. Enter your email address here and we'll send you a confirmation code to change your password.")
            }
            TextField {
                id: emailTextField
                Layout.fillWidth: true; Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            }
            Button {
                Layout.fillWidth: true; Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                text: qsTr("Reset password")
                onClicked: {
                    AWSClient.forgotPassword(emailTextField.text)
                    resetPasswordPage.busy = true
                }
            }
        }
    }

    Component {
        id: confirmResetPasswordComponent

        SettingsPageBase {
            id: confirmResetPasswordPage

            Connections {
                target: AWSClient
                onConfirmForgotPasswordResult: {
                    confirmResetPasswordPage.busy = false
                    if (error !== AWSClient.LoginErrorNoError) {
                        var errorDialog = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"));
                        var popup = errorDialog.createObject(app, {text: qsTr("Sorry, couldn't reset your password. Did you enter the wrong confirmation code?")})
                        popup.open()
                        return;
                    }
                    var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
                    var popup = dialog.createObject(app, {headerIcon: "../images/tick.svg", title: qsTr("Yay!"), text: qsTr("Your password has been reset.")})
                    popup.accepted.connect(function() {
                        pageStack.pop(root);
                    })
                    popup.open()
                    return;
                }
            }

            property string email
            title: qsTr("Reset password")

            Label {
                Layout.fillWidth: true
                Layout.margins: app.margins
                wrapMode: Text.WordWrap
                text: qsTr("Check your email!")
                color: app.accentColor
                font.pixelSize: app.largeFont
            }

            Label {
                Layout.fillWidth: true; Layout.leftMargin: app.margins; Layout.rightMargin: app.margins;
                wrapMode: Text.WordWrap
                text: qsTr("Enter the confirmation code you've received and a new password for your user %1.").arg(confirmResetPasswordPage.email)
            }

            Label {
                Layout.fillWidth: true; Layout.leftMargin: app.margins; Layout.rightMargin: app.margins;
                text: qsTr("Confirmation code:")
            }

            TextField {
                id: codeTextField
                Layout.fillWidth: true; Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            }
            Label {
                Layout.fillWidth: true; Layout.leftMargin: app.margins; Layout.rightMargin: app.margins;
                text: qsTr("Pick a new password:")
            }

            PasswordTextField {
                id: passwordTextField
                minPasswordLength: 8
                requireLowerCaseLetter: true
                requireUpperCaseLetter: true
                requireNumber: true
                requireSpecialChar: false
                Layout.fillWidth: true; Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            }

            Button {
                Layout.fillWidth: true; Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                text: qsTr("Reset password")
                enabled: passwordTextField.isValid && codeTextField.text.length > 0
                onClicked: {
                    confirmResetPasswordPage.busy = true
                    AWSClient.confirmForgotPassword(confirmResetPasswordPage.email, codeTextField.text, passwordTextField.password)
                }
            }
        }
    }

    Component {
        id : logoutDialogComponent
        MeaDialog {
            id: logoutDialog
            title: qsTr("Goodbye")
            text: qsTr("Sorry to see you go. If you log out you won't be able to connect to %1:core systems remotely any more. However, you can come back any time, we'll keep your user account. If you whish to completely delete your account and all the data associated with it, check the box below before hitting ok. If you decide to delete your account, all your personal information will be removed from %1:cloud and cannot be restored.").arg(app.systemName)
            headerIcon: "../images/dialog-warning-symbolic.svg"
            standardButtons: Dialog.Cancel | Dialog.Ok

            RowLayout {
                CheckBox {
                    id: deleteCheckbox
                }
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: qsTr("Delete my account")
                }
            }

            onAccepted: {
                if (deleteCheckbox.checked) {
                    root.busy = true;
                    AWSClient.deleteAccount()
                } else {
                    AWSClient.logout()
                }
            }
        }
    }
}
