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

        onChangePasswordResponse: {
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
        text: qsTr("Devices / Apps accessing nymea:core")
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
}
