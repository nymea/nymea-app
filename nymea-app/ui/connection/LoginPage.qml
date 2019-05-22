import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    signal backPressed();

    header: GuhHeader {
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
            engine.jsonRpcClient.authenticate(usernameTextField.text, passwordTextField.text, "nymea-app");
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
                message = qsTr("An error happened with the user storage. Please make sure your %1 box is installed correctly.")
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
                              qsTr("In order to use your %1 system, please enter your email address and set a password for your %1 box.").arg(app.systemName)
                            : qsTr("In order to use your %1 system, please log in.").arg(app.systemName)
                    wrapMode: Text.WordWrap
                }
            }


            GridLayout {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                columns: app.width > 400 ? 2 : 1

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
                Label {
                    Layout.fillWidth: true
                    text: qsTr("Password:")
                }
                TextField {
                    id: passwordTextField
                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                }

                Label {
                    visible: engine.jsonRpcClient.initialSetupRequired
                    Layout.fillWidth: true
                    text: qsTr("Confirm password:")
                }
                TextField {
                    id: confirmPasswordTextField
                    visible: engine.jsonRpcClient.initialSetupRequired
                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                }
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                visible: engine.jsonRpcClient.initialSetupRequired
                opacity: (passwordTextField.text.length > 0 && passwordTextField.text.length < 8) || passwordTextField.text != confirmPasswordTextField.text ? 1 : 0
                text: passwordTextField.text.length < 8 ? qsTr("This password isn't long enought to be secure, add some more characters please.")
                                                        : qsTr("The passwords don't match.")
                wrapMode: Text.WordWrap
                color: app.accentColor
                font.pixelSize: app.smallFont
            }

            Button {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.bottomMargin: app.margins
                text: qsTr("OK")
                enabled: usernameTextField.text.length >= 5 && passwordTextField.text.length >= 8
                         && (!engine.jsonRpcClient.initialSetupRequired || confirmPasswordTextField.text == passwordTextField.text)
                onClicked: {
                    if (engine.jsonRpcClient.initialSetupRequired) {
                        print("create user")
                        engine.jsonRpcClient.createUser(usernameTextField.text, passwordTextField.text);
                    } else {
                        print("authenticate", usernameTextField.text, passwordTextField.text, "nymea-app")
                        engine.jsonRpcClient.authenticate(usernameTextField.text, passwordTextField.text, "nymea-app");
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
