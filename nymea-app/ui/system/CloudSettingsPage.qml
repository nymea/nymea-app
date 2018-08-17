import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Cloud settings")
        onBackPressed: pageStack.pop();
    }

    Connections {
        target: Engine.basicConfiguration
        onCloudEnabledChanged: {
            if (Engine.jsonRpcClient.cloudConnectionState === JsonRpcClient.CloudConnectionStateUnconfigured) {
                Engine.deployCertificate();
            }
        }
    }

    Connections {
        target: Engine.jsonRpcClient
        onCloudConnectionStateChanged: {
            if (Engine.awsClient.isLoggedIn && Engine.awsClient.awsDevices.getDevice(Engine.jsonRpcClient.serverUuid) === null) {
                print("Pairing user and box...")
                Engine.jsonRpcClient.setupRemoteAccess(Engine.awsClient.idToken, Engine.awsClient.userId);
            }
        }
    }

    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right }

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            Layout.topMargin: app.margins
            text: qsTr("You can connect a nymea:box to a nymea:cloud in order to access it from anywhere")
            wrapMode: Text.WordWrap
        }

        SwitchDelegate {
            Layout.fillWidth: true
            text: qsTr("Cloud connection enabled")
            checked: Engine.basicConfiguration.cloudEnabled
            onToggled: {
                Engine.basicConfiguration.cloudEnabled = checked;
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            visible: Engine.basicConfiguration.cloudEnabled

            BusyIndicator {
                visible: Engine.jsonRpcClient.cloudConnectionState == JsonRpcClient.CloudConnectionStateUnconfigured ||
                         Engine.jsonRpcClient.cloudConnectionState == JsonRpcClient.CloudConnectionStateConnecting
            }
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: {
                    switch (Engine.jsonRpcClient.cloudConnectionState) {
                    case JsonRpcClient.CloudConnectionStateDisabled:
                        return ""
                    case JsonRpcClient.CloudConnectionStateUnconfigured:
                        return qsTr("Configuring the box to connect to nymea:cloud...");
                    case JsonRpcClient.CloudConnectionStateConnecting:
                        return qsTr("Connecting the box to nymea:cloud...");
                    case JsonRpcClient.CloudConnectionStateConnected:
                        return qsTr("The box is connected to nymea:cloud.");
                    }
                    return Engine.jsonRpcClient.cloudConnectionState
                }
            }
        }


//        Label {
//            Layout.fillWidth: true
//            Layout.leftMargin: app.margins
//            Layout.rightMargin: app.margins
//            visible: Engine.basicConfiguration.cloudEnabled && Engine.awsClient.isLoggedIn
//            text: Engine.awsClient.awsDevices.getDevice(Engine.jsonRpcClient.serverUuid) !== null ?
//                      qsTr("This box is connected to a nymea:cloud.") :
//                      qsTr("Connecting to nymea:cloud...")
//        }
    }
}
