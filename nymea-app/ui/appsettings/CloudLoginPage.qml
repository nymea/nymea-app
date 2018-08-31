import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Cloud login")
        onBackPressed: pageStack.pop()
    }

    Component.onCompleted: {
        if (Engine.awsClient.isLoggedIn) {
            Engine.awsClient.fetchDevices();
        }
    }

    Connections {
        target: Engine.awsClient
        onLoginResult: {
            busyOverlay.shown = false;
            if (error === AWSClient.LoginErrorNoError) {
                Engine.awsClient.fetchDevices();
            }
        }
    }

    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right }
        visible: Engine.awsClient.isLoggedIn
        Label {
            Layout.fillWidth: true
            Layout.topMargin: app.margins
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            wrapMode: Text.WordWrap
            text: qsTr("Logged in as %1").arg(Engine.awsClient.username)
        }

        Button {
            Layout.fillWidth: true
            Layout.margins: app.margins
            text: qsTr("Log out")
            onClicked: {
                logoutDialog.open()
            }
        }

        ThinDivider {}

        Label {
            Layout.fillWidth: true
            Layout.topMargin: app.margins
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            wrapMode: Text.WordWrap
            text: Engine.awsClient.awsDevices.count === 0 ?
                      qsTr("There are no boxes connected to your cloud yet.") :
                      qsTr("There are %n boxes connected to your cloud", "", Engine.awsClient.awsDevices.count)
        }
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: Engine.awsClient.awsDevices
            delegate: MeaListItemDelegate {
                width: parent.width
                text: model.name
                subText: model.id
                progressive: false
                prominentSubText: false
                canDelete: true
                iconName: "../images/cloud.svg"
                secondaryIconName: model.online ? "../images/cloud.svg" : "../images/cloud-offline.svg"
                onDeleteClicked: {
                    Engine.awsClient.unpairDevice(model.id);
                }
            }
        }
    }

    MeaDialog {
        id: logoutDialog
        title: qsTr("Goodbye")
        // Deleting user profile not working in cloud yet
//        text: qsTr("Sorry to see you go. If you log out you won't be able to connect to %1 boxes remotely any more. However, you can come back any time, we'll keep your user account. If you whish to completely delete your account and all the data associated with it, check the box below before hitting ok.").arg(app.systemName)
        text: qsTr("Sorry to see you go. If you log out you won't be able to connect to %1 boxes remotely any more. However, you can come back any time.").arg(app.systemName)
        headerIcon: "../images/dialog-warning-symbolic.svg"
        standardButtons: Dialog.Cancel | Dialog.Ok

//        RowLayout {
//            CheckBox {
//                id: deleteCheckbox
//            }
//            Label {
//                Layout.fillWidth: true
//                wrapMode: Text.WordWrap
//                text: qsTr("Delete my account")
//            }
//        }

        onAccepted: {
//            if (deleteCheckbox.checked) {
//                Engine.awsClient.deleteAccount()
//            } else {
                Engine.awsClient.logout()
//            }
        }
    }

    ColumnLayout {
        anchors { left: parent.left; right: parent.right; top: parent.top }
        visible: !Engine.awsClient.isLoggedIn
        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
            wrapMode: Text.WordWrap
            text: qsTr("Log in to %1:cloud in order to connect to %1 boxes from anywhere.").arg(app.systemName)
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
        TextField {
            id: passwordTextField
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            Layout.fillWidth: true
            echoMode: TextInput.Password
        }

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
            text: qsTr("OK")
            enabled: usernameTextField.acceptableInput
            onClicked:  {
                busyOverlay.shown = true
                Engine.awsClient.login(usernameTextField.text, passwordTextField.text);
            }
        }

        Connections {
            target: Engine.awsClient
            onLoginResult: {
                errorLabel.visible = (error !== AWSClient.LoginErrorNoError)
            }
        }

        Label {
            id: errorLabel
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.bottomMargin: app.margins
            wrapMode: Text.WordWrap
            text: qsTr("Failed to log in. Please try again. Do you perhaps have <a href=\"#\">forgotten your password?</a>")
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
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
            text: qsTr("Sign Up")
            onClicked: {
                pageStack.push(signupPageComponent)
            }
        }
    }

    BusyOverlay {
        id: busyOverlay
    }

    Component {
        id: signupPageComponent
        Page {
            id: signupPage
            header: GuhHeader {
                text: qsTr("Sign up")
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors { left: parent.left; top: parent.top; right: parent.right }

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
                    wrapMode: Text.WordWrap
                    text: qsTr("Welcome to %1:cloud.").arg(app.systemName)
                    color: app.accentColor
                    font.pixelSize: app.largeFont
                }

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
                    wrapMode: Text.WordWrap
                    text: qsTr("Please enter your email address and pick a password in order to create a new account.")
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
                AWSPasswordTextField {
                    id: passwordTextField
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    Layout.fillWidth: true
                }

                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
                    text: qsTr("Sign Up")
                    enabled: usernameTextField.acceptableInput && passwordTextField.isValidPassword
                    onClicked: {
                        Engine.awsClient.signup(usernameTextField.text, passwordTextField.password)
                    }
                }

                Connections {
                    target: Engine.awsClient
                    onSignupResult: {
                        switch (error) {
                        case AWSClient.LoginErrorNoError:
                            signUpResultLabel.text = ""
                            pageStack.push(enterCodeComponent)
                            break;
                        case AWSClient.LoginErrorInvalidUserOrPass:
                            signUpResultLabel.text = qsTr("The given username or password are not valid.")
                            break;
                        default:
                            signUpResultLabel.text = qsTr("Uh oh, something went wrong. Please try again.")
                        }
                    }
                }

                Label {
                    id: signUpResultLabel
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    Component {
        id: enterCodeComponent
        Page {
            header: GuhHeader {
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
                        Engine.awsClient.confirmRegistration(confirmationCodeTextField.text)
                    }
                }

                Connections {
                    target: Engine.awsClient
                    onConfirmationResult: {
                        switch (error) {
                        case AWSClient.LoginErrorNoError:
                            confirmResultLabel.text = ""
                            pageStack.pop(root)
                            break;
                        case AWSClient.LoginErrorUserExists:
                            confirmResultLabel.text = qsTr("The given user already exists. Did you forget the password?")
                            break;
                        case AWSClient.LoginErrorInvalidCode:
                            confirmResultLabel.text = qsTr("That wasn't the right code. Please try again.")
                            break;
                        case AWSClient.LoginErrorUnknownError:
                            confirmResultLabel.text = qsTr("Uh oh, something went wrong. Please try again.")
                            break;
                        }
                    }
                }

                Label {
                    id: confirmResultLabel
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    Component {
        id: resetPasswordComponent
        Page {
            id: resetPasswordPage

            property alias email: emailTextField.text

            header: GuhHeader {
                text: qsTr("Reset password")
                onBackPressed: pageStack.pop()
            }

            Connections {
                target: Engine.awsClient
                onForgotPasswordResult: {
                    busyOverlay.shown = false
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

            ColumnLayout {
                anchors { left: parent.left; top: parent.top; right: parent.right }
                spacing: app.margins

                Label {
                    Layout.fillWidth: true; Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
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
                        Engine.awsClient.forgotPassword(emailTextField.text)
                        busyOverlay.shown = true
                    }
                }
            }

            BusyOverlay {
                id: busyOverlay
            }
        }
    }

    Component {
        id: confirmResetPasswordComponent

        Page {
            id: confirmResetPasswordPage

            Connections {
                target: Engine.awsClient
                onConfirmForgotPasswordResult: {
                    busyOverlay.shown = false
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
            header: GuhHeader {
                text: qsTr("Reset password")
                onBackPressed: pageStack.pop()
            }
            ColumnLayout {
                anchors { left: parent.left; top: parent.top; right: parent.right }
                spacing: app.margins

                Label {
                    Layout.fillWidth: true; Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
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

                AWSPasswordTextField {
                    id: passwordTextField
                    Layout.fillWidth: true; Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                }

                Button {
                    Layout.fillWidth: true; Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    text: qsTr("Reset password")
                    enabled: passwordTextField.isValidPassword && codeTextField.text.length > 0
                    onClicked: {
                        busyOverlay.shown = true
                        Engine.awsClient.confirmForgotPassword(confirmResetPasswordPage.email, codeTextField.text, passwordTextField.password)
                    }
                }
                BusyOverlay {
                    id: busyOverlay
                }
            }
        }
    }
}
