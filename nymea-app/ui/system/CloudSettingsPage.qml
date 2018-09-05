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

    Item {
        id: d
        property bool deploymentStarted: false

        Connections {
            target: Engine.jsonRpcClient
            onCloudConnectionStateChanged: {
                print("cloud connection state changed", Engine.jsonRpcClient.cloudConnectionState)
                if (Engine.jsonRpcClient.cloudConnectionState == JsonRpcClient.CloudConnectionStateConnected) {
                    d.deploymentStarted = false;
                    if (Engine.awsClient.awsDevices.getDevice(Engine.jsonRpcClient.serverUuid) === null) {
                        Engine.jsonRpcClient.setupRemoteAccess(Engine.awsClient.idToken, Engine.awsClient.userId)
                    }
                }
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

//        Button {
//            text: "pair"
//            onClicked: Engine.jsonRpcClient.setupRemoteAccess(Engine.awsClient.idToken, Engine.awsClient.userId)
//        }

        SwitchDelegate {
            Layout.fillWidth: true
            text: qsTr("Cloud connection enabled")
            checked: Engine.basicConfiguration.cloudEnabled
            onToggled: {
                Engine.basicConfiguration.cloudEnabled = checked;
            }
        }

        ThinDivider {}

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins

            ColorIcon {
                Layout.preferredHeight: busyIndicator.height
                Layout.preferredWidth: height
                name: Engine.jsonRpcClient.cloudConnectionState === JsonRpcClient.CloudConnectionStateConnected
                      ? "../images/cloud.svg"
                      : Engine.jsonRpcClient.cloudConnectionState === JsonRpcClient.CloudConnectionStateUnconfigured
                        ? "../images/cloud-error.svg"
                        : "../images/cloud-offline.svg"
            }

            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: {
                    switch (Engine.jsonRpcClient.cloudConnectionState) {
                    case JsonRpcClient.CloudConnectionStateDisabled:
                        return qsTr("This box is not connected to %1:cloud").arg(app.systemName)
                    case JsonRpcClient.CloudConnectionStateUnconfigured:
                        if (d.deploymentStarted) {
                            return qsTr("Registering box in %1:cloud...").arg(app.systemName)
                        }
                        return qsTr("This box is not configured to connect to %1:cloud.").arg(app.systemName);
                    case JsonRpcClient.CloudConnectionStateConnecting:
                        return qsTr("Connecting the box to %1:cloud...").arg(app.systemName);
                    case JsonRpcClient.CloudConnectionStateConnected:
                        return qsTr("The box is connected to %1:cloud.").arg(app.systemName);
                    }
                    return Engine.jsonRpcClient.cloudConnectionState
                }
            }
            BusyIndicator {
                id: busyIndicator
                visible: (Engine.jsonRpcClient.cloudConnectionState == JsonRpcClient.CloudConnectionStateUnconfigured && d.deploymentStarted) ||
                         Engine.jsonRpcClient.cloudConnectionState == JsonRpcClient.CloudConnectionStateConnecting
            }
        }

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            visible: Engine.jsonRpcClient.cloudConnectionState === JsonRpcClient.CloudConnectionStateUnconfigured && !d.deploymentStarted
            text: qsTr("This box is not configured to access the %1:cloud. In order for a box to connect to %1:cloud it needs to be registered first.").arg(app.systemName)
            wrapMode: Text.WordWrap
        }

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            visible: Engine.jsonRpcClient.cloudConnectionState === JsonRpcClient.CloudConnectionStateUnconfigured && !d.deploymentStarted
            text: qsTr("Register box")
            onClicked: {
                d.deploymentStarted = true
                Engine.deployCertificate();
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
