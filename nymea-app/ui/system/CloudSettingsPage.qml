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
            target: engine.jsonRpcClient
            onCloudConnectionStateChanged: {
                print("cloud connection state changed", engine.jsonRpcClient.cloudConnectionState)
                if (engine.jsonRpcClient.cloudConnectionState === JsonRpcClient.CloudConnectionStateConnected) {
                    d.deploymentStarted = false;
                    if (engine.awsClient.awsDevices.getDevice(engine.jsonRpcClient.serverUuid) === null) {
                        engine.jsonRpcClient.setupRemoteAccess(engine.awsClient.idToken, engine.awsClient.userId)
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
//            onClicked: engine.jsonRpcClient.setupRemoteAccess(engine.awsClient.idToken, engine.awsClient.userId)
//        }

        SwitchDelegate {
            Layout.fillWidth: true
            text: qsTr("Cloud connection enabled")
            checked: engine.basicConfiguration.cloudEnabled
            onToggled: {
                engine.basicConfiguration.cloudEnabled = checked;
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
                name: engine.jsonRpcClient.cloudConnectionState === JsonRpcClient.CloudConnectionStateConnected
                      ? "../images/cloud.svg"
                      : engine.jsonRpcClient.cloudConnectionState === JsonRpcClient.CloudConnectionStateUnconfigured
                        ? "../images/cloud-error.svg"
                        : "../images/cloud-offline.svg"
            }

            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: {
                    switch (engine.jsonRpcClient.cloudConnectionState) {
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
                    return engine.jsonRpcClient.cloudConnectionState
                }
            }
            BusyIndicator {
                id: busyIndicator
                visible: (engine.jsonRpcClient.cloudConnectionState == JsonRpcClient.CloudConnectionStateUnconfigured && d.deploymentStarted) ||
                         engine.jsonRpcClient.cloudConnectionState == JsonRpcClient.CloudConnectionStateConnecting
            }
        }

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            visible: engine.jsonRpcClient.cloudConnectionState === JsonRpcClient.CloudConnectionStateUnconfigured && !d.deploymentStarted
            text: qsTr("This box is not configured to access the %1:cloud. In order for a box to connect to %1:cloud it needs to be registered first.").arg(app.systemName)
            wrapMode: Text.WordWrap
        }

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            visible: engine.jsonRpcClient.cloudConnectionState === JsonRpcClient.CloudConnectionStateUnconfigured && !d.deploymentStarted
            text: engine.awsClient.isLoggedIn ? qsTr("Register box") : qsTr("Log in to cloud")
            onClicked: {
                if (engine.awsClient.isLoggedIn) {
                    d.deploymentStarted = true
                    engine.deployCertificate();
                } else {
                    pageStack.push(Qt.resolvedUrl("qrc:/ui/appsettings/CloudLoginPage.qml"))
                }
            }
        }


//        Label {
//            Layout.fillWidth: true
//            Layout.leftMargin: app.margins
//            Layout.rightMargin: app.margins
//            visible: engine.basicConfiguration.cloudEnabled && engine.awsClient.isLoggedIn
//            text: engine.awsClient.awsDevices.getDevice(engine.jsonRpcClient.serverUuid) !== null ?
//                      qsTr("This box is connected to a nymea:cloud.") :
//                      qsTr("Connecting to nymea:cloud...")
//        }
    }
}
