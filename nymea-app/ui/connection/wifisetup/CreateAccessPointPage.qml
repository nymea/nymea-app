import QtQuick 2.4
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../components"
import Nymea 1.0

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Create access point")
        onBackPressed: pageStack.pop()
    }

    property NetworkManagerController networkManagerController: null

    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right; }

        Label {
            Layout.fillWidth: true
            Layout.margins: app.margins
            text: qsTr("Enter the SSID of access point")
            wrapMode: Text.WordWrap
        }

        TextField {
            id: ssidTextField
            Layout.fillWidth: true
            Layout.margins: app.margins
        }

        Label {
            Layout.fillWidth: true
            Layout.margins: app.margins
            text: qsTr("Enter the password for the access point")
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            TextField {
                id: passwordTextField
                Layout.fillWidth: true
                property bool showPassword: false
                echoMode: showPassword ? TextInput.Normal : TextInput.Password
            }

            ColorIcon {
                Layout.preferredHeight: app.iconSize
                Layout.preferredWidth: app.iconSize
                name: "../images/eye.svg"
                color: passwordTextField.showPassword ? app.accentColor : keyColor
                MouseArea {
                    anchors.fill: parent
                    onClicked: passwordTextField.showPassword = !passwordTextField.showPassword
                }
            }
        }

        Button {
            Layout.fillWidth: true
            Layout.margins: app.margins
            text: qsTr("OK")
            enabled: passwordTextField.displayText.length >= 8 && ssidTextField.text != ""
            onClicked: {
                networkManagerController.manager.startAccessPoint(ssidTextField.text, passwordTextField.text)
                pageStack.push(createAccessPointWaitPageComponent, {ssid: ssidTextField.text })
            }
        }
    }

    Component {
        id: createAccessPointWaitPageComponent

        Page {
            id: createAccessPointWaitPage
            property string ssid

            ColumnLayout {
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: app.margins }
                spacing: app.margins * 2
                BusyIndicator {
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Creating access point \"%1\" on %2 box").arg(createAccessPointWaitPage.ssid).arg(app.systemName)
                }
            }
        }
    }
}
