import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Guh 1.0
import "components"

Page {
    id: root

    readonly property bool haveHosts: discovery.discoveryModel.count > 0

    Component.onCompleted: {
        print("completed connectPage. last connected host:", settings.lastConnectedHost)
        if (settings.lastConnectedHost.length > 0) {
            pageStack.push(connectingPage)
            Engine.connection.connect(settings.lastConnectedHost)
        }
    }

    Connections {
        target: Engine.connection
        onVerifyConnectionCertificate: {
            print("verify cert!")
            certDialog.commonName = commonName
            certDialog.fingerprint = fingerprint
            certDialog.open();
        }
        onConnectionError: {
            pageStack.pop(root)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: app.bigMargins
        spacing: app.margins

        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: app.margins
            spacing: app.margins

            Label {
                Layout.fillWidth: true
                text: root.haveHosts ? "Oh, look!" : "Uh oh"
                color: "black"
                font.pixelSize: app.largeFont
            }

            Label {
                Layout.fillWidth: true
                text: root.haveHosts ?
                          qsTr("There are %1 guh boxes in your network! Which one would you like to use?").arg(discovery.discoveryModel.count)
                        : qsTr("There doesn't seem to be a guh box installed in your network. Please make sure your guh box is correctly set up and connected.")
                wrapMode: Text.WordWrap
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Material.accent
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: discovery.discoveryModel
            clip: true

            delegate: ItemDelegate {
                width: parent.width
                height: app.delegateHeight
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: app.margins
                    Label {
                        text: model.name
                    }
                    Label {
                        text: model.hostAddress
                        font.pixelSize: app.smallFont
                    }
                }
                onClicked: {
                    print("should connect to", model.guhRpcUrl)
                    Engine.connection.connect(model.guhRpcUrl)
                    pageStack.push(connectingPage)
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: app.margins
                visible: !root.haveHosts

                Label {
                    text: qsTr("Searching for guh boxes...")
                }

                BusyIndicator {
                    running: visible
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Material.accent
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: app.margins
            visible: root.haveHosts
            Label {
                Layout.fillWidth: true
                text: "Not the ones you're looking for? We're looking for more!"
                wrapMode: Text.WordWrap
            }
            BusyIndicator {
            }
        }
    }

    Component {
        id: connectingPage
        Page {
            Label {
                anchors.centerIn: parent
                width: parent.width - app.margins * 2
                text: "Connecting to your guh box..."
                font.pixelSize: app.largeFont
            }
        }
    }

    Dialog {
        id: certDialog
        width: parent.width * .8
        height: parent.height * .8
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        standardButtons: Dialog.Yes | Dialog.No

        property var fingerprint
        property string commonName

        ColumnLayout {
            anchors.fill: parent
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: "The authenticity of this guh box cannot be verified. Do you want to trust this device?"
            }
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: "Device name: " + certDialog.commonName
            }
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: "Fingerprint: " + certDialog.fingerprint
            }
        }

        onAccepted: {
            Engine.connection.acceptCertificate(certDialog.fingerprint)
        }
    }
}
