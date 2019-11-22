import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    signal backPressed();

    header: NymeaHeader {
        text: qsTr("Welcome to %1!").arg(app.systemName)
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
            engine.jsonRpcClient.authenticate(usernameTextField.text, passwordTextField.password, "nymea-app");
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
                message = qsTr("An error happened with the user storage. Please make sure your %1:core system is installed correctly.").arg(app.systemName)
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
                    Layout.preferredHeight: app.iconSize * 2
                    Layout.preferredWidth: app.iconSize * 2
                    name: "../images/lock-closed.svg"
                    color: app.accentColor
                }

                Label {
                    Layout.fillWidth: true
                    text: engine.jsonRpcClient.initialSetupRequired ?
                              qsTr("In order to use your %1 system, please enter your email address and set a password for it.").arg(app.systemName)
                            : qsTr("In order to use your %1 system, please log in.").arg(app.systemName)
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
                    inputMethodHints: Qt.ImhEmailCharactersOnly
                    placeholderText: "john.smith@cooldomain.com"
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
                        engine.jsonRpcClient.authenticate(usernameTextField.text, passwordTextField.password, "nymea-app");
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
