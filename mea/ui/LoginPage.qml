import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Mea 1.0
import "components"

Page {
    id: root
    signal backPressed();

    header: GuhHeader {
        text: qsTr("Welcome to %1!").arg(app.systemName)
        backButtonVisible: true
        onBackPressed: root.backPressed()
    }


    Connections {
        target: Engine.jsonRpcClient
        onAuthenticationFailed: {
            var popup = errorDialog.createObject(root)
            popup.text = qsTr("Sorry, that wasn't right. Try again please.")
            popup.open();
        }
        onCreateUserFailed: {
            print("create user failed")
            var text
            switch (error) {
            case "UserErrorInvalidUserId":
                text = qsTr("The email you've entered isn't valid.");
                break;
            case "UserErrorBadPassword":
                text = qsTr("The password you've chose is too weak.");
                break;
            default:
                text = qsTr("An error happened creating the user.");
            }
//            var popup = errorDialog.createObject(root, {title: qsTr("Error creating user"), text: text})
            var popup = errorDialog.createObject(root, {title: "Error creating user", text: text})
            popup.open();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: app.margins
        spacing: app.margins

        Label {
            Layout.fillWidth: true
            text: Engine.jsonRpcClient.initialSetupRequired ?
                      qsTr("In order to use your %1 system, please enter your email address and set a password for your nymea box.").arg(app.systemName)
                    : qsTr("In order to use your %1 system, please log in.").arg(app.systemName)
            wrapMode: Text.WordWrap
        }

        ColumnLayout {
            Layout.fillWidth: true

            Label {
                text: qsTr("Your e-mail address:")
                Layout.fillWidth: true
            }
            TextField {
                id: usernameTextField
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhEmailCharactersOnly
                placeholderText: "john.smith@cooldomain.com"
            }
        }
        ColumnLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                text: qsTr("Password:")
            }
            TextField {
                id: passwordTextField
                Layout.fillWidth: true
                echoMode: TextInput.Password
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: Engine.jsonRpcClient.initialSetupRequired

            Label {
                Layout.fillWidth: true
                text: qsTr("Confirm password:")
            }
            TextField {
                id: confirmPasswordTextField
                Layout.fillWidth: true
                echoMode: TextInput.Password
            }
        }

        Label {
            Layout.fillWidth: true
            visible: Engine.jsonRpcClient.initialSetupRequired
            opacity: (passwordTextField.text.length > 0 && passwordTextField.text.length < 8) || passwordTextField.text != confirmPasswordTextField.text ? 1 : 0
            text: passwordTextField.text.length < 8 ? qsTr("This password isn't long enought to be secure, add some more characters please.")
                                                    : qsTr("The passwords don't match.")
            wrapMode: Text.WordWrap
            Layout.preferredHeight: confirmPasswordTextField.height * 2
            color: app.guhAccent
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("OK")
            enabled: usernameTextField.text.length >= 5 && passwordTextField.text.length >= 8
                     && (!Engine.jsonRpcClient.initialSetupRequired || confirmPasswordTextField.text == passwordTextField.text)
            onClicked: {
                if (Engine.jsonRpcClient.initialSetupRequired) {
                    print("create user")
                    Engine.jsonRpcClient.createUser(usernameTextField.text, passwordTextField.text);
                } else {
                    print("authenticate", usernameTextField.text, passwordTextField.text, "mea")
                    Engine.jsonRpcClient.authenticate(usernameTextField.text, passwordTextField.text, "mea");
                }
            }
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
