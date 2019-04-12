import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"


Page {
    id: root

    signal cancel()

    ColorIcon {
        anchors { top: parent.top; right: parent.right; margins: app.margins }
        height: app.iconSize
        width: height
        name: "../images/logs.svg"
        visible: settings.showHiddenOptions && AppLogController.enabled
        MouseArea {
            anchors.fill: parent
            onClicked: {
                onClicked: pageStack.push(Qt.resolvedUrl("../appsettings/AppLogPage.qml"))
            }
        }
    }

    ColumnLayout {
        id: columnLayout
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: app.margins }
        spacing: app.margins
        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: parent.visible
        }
        Label {
            text: qsTr("Connecting...")
            font.pixelSize: app.largeFont
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
        Label {
            Layout.fillWidth: true
            text: engine.connection.currentHost.name.length > 0 ? engine.connection.currentHost.name : engine.connection.currentHost.uuid
            font.pixelSize: app.smallFont
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
        }
        Label {
            Layout.fillWidth: true
            text: {
                var errorMessage;
                switch (engine.connection.connectionStatus) {
                case NymeaConnection.ConnectionStatusUnconnected:
                case NymeaConnection.ConnectionStatusConnecting:
                case NymeaConnection.ConnectionStatusConnected:
                    errorMessage = "";
                    break;
                case NymeaConnection.ConnectionStatusBearerFailed:
                    errorMessage = qsTr("The network connection failed.")
                    break;
                case NymeaConnection.ConnectionStatusNoBearerAvailable:
                    errorMessage = qsTr("It seems you're not connected to the network.");
                    break;
                case NymeaConnection.ConnectionStatusHostNotFound:
                    errorMessage = qsTr("%1:core could not be found on this address. Please make sure you entered the address correctly and that the box is powered on.").arg(app.systemName);
                    break;
                case NymeaConnection.ConnectionStatusConnectionRefused:
                    errorMessage = qsTr("The host has rejected our connection. This probably means that %1 is not running on this host. Perhaps it's restarting?").arg(app.systemName);
                    break;
                case NymeaConnection.ConnectionStatusRemoteHostClosed:
                    errorMessage = qsTr("%1:core has closed the connection. This probably means it has been turned off or restarted.").arg(app.systemName);
                    break;

                case NymeaConnection.ConnectionStatusTimeout:
                    errorMessage = qsTr("%1:core did not respond. Please make sure your network connection works properly").arg(app.systemName);
                    break;
                case NymeaConnection.ConnectionStatusSslError:
                    errorMessage = qsTr("An unrecovareable SSL Error happened. Please make sure certificates are installed correctly.");
                    break;
                case NymeaConnection.ConnectionStatusSslUntrusted:
                    errorMessage = qsTr("The SSL Certificate is not trusted.");
                    break;
                case NymeaConnection.ConnectionStatusUnknownError:
                default:
                    errorMessage = qsTr("An unknown error happened. We're very sorry for that.").arg(engine.connection.connectionStatus);
                }
                return errorMessage;
            }
            font.pixelSize: app.smallFont
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Button {
        text: qsTr("Cancel")
        anchors { left: parent.left; top: columnLayout.bottom; right: parent.right }
        anchors.margins: app.margins
        onClicked: root.cancel()
    }
}
