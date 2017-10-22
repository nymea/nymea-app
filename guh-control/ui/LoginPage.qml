import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Guh 1.0
import "components"

Page {
    id: root
    signal backPressed();

    header: GuhHeader {
        text: "Welcome to guh!"
        backButtonVisible: true
        onBackPressed: root.backPressed()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: app.margins

        Label {
            Layout.fillWidth: true
            text: Engine.jsonRpcClient.initialSetupRequired ?
                      "In order to use your guh system, please enter your email address and set a password for your guh box."
                    : "In order to use your guh system, please log in."
            wrapMode: Text.WordWrap
        }

        Label {
            text: "Username:"
            Layout.fillWidth: true
        }
        TextField {
            id: usernameTextField
            Layout.fillWidth: true

        }
        Label {
            Layout.fillWidth: true
            text: "Password:"
        }
        TextField {
            id: passwordTextField
            Layout.fillWidth: true

        }
        Button {
            Layout.fillWidth: true
            text: "OK"
            onClicked: {
                console.log("foooo")
                if (Engine.jsonRpcClient.initialSetupRequired) {
                    print("create user")
                    Engine.jsonRpcClient.createUser(usernameTextField.text, passwordTextField.text);
                } else {
                    print("authenticate", usernameTextField.text, passwordTextField.text, "guh-control")
                    Engine.jsonRpcClient.authenticate(usernameTextField.text, passwordTextField.text, "guh-control");
                }
            }
        }
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
