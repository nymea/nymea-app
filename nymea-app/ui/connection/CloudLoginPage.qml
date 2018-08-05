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

    ColumnLayout {
        anchors.fill: parent
        Label {
            Layout.fillWidth: true
            text: "Username (e-mail)"
        }
        TextField {
            id: usernameTextField
            Layout.fillWidth: true
            placeholderText: "john@dummy.com"
        }
        Label {
            Layout.fillWidth: true
            text: qsTr("Password")
        }
        TextField {
            id: passwordTextField
            Layout.fillWidth: true
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("OK")
            enabled: usernameTextField.displayText.length > 0 && passwordTextField.displayText.length > 0
            onClicked:  {
                Engine.awsClient.login(usernameTextField.text, passwordTextField.text);
            }
        }
    }
}
