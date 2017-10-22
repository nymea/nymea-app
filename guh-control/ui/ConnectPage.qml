import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Guh 1.0
import "components"

Page {

    Component.onCompleted: {
        print("completed connectPage. last connected host:", settings.lastConnectedHost)
        if (settings.lastConnectedHost.length > 0) {
            internalPageStack.push(connectingPage)
            Engine.connection.connect(settings.lastConnectedHost)
        } else if (upnpDiscovery.discoveryModel.count <= 1) {
            upnpDiscovery.discover()
        } else {
            internalPageStack.pop();
            internalPageStack.push(searchResultsPage)
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
            upnpDiscovery.discover();
        }
    }


    Connections {
        target: upnpDiscovery

        onDiscoveringChanged: {
            print("discoverying changed", upnpDiscovery.discovering)
            if (upnpDiscovery.discovering) {
                internalPageStack.pop();
            } else {
                switch (upnpDiscovery.discoveryModel.count) {
                case 0:
                    internalPageStack.push(noResultsPage);
                    break;
                case 1:
                    Engine.connection.connect(upnpDiscovery.discoveryModel.get(0, "guhRpcUrl"))
                    internalPageStack.push(connectingPage);
                    break;
                default:
                    internalPageStack.push(searchResultsPage)
                }
            }
        }
    }

    StackView {
        id: internalPageStack
        anchors.fill: parent

        initialItem: Page {
            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - app.margins * 2
                spacing: app.margins

                Label {
                    Layout.fillWidth: true
                    text: "Just a second, looking for your guh box..."
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: app.largeFont
                }

                BusyIndicator {
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: upnpDiscovery.discovering
                }
            }
        }
    }

    Component {
        id: noResultsPage
        Page {
            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - app.margins * 2
                spacing: app.margins

                Label {
                    Layout.fillWidth: true
                    font.pixelSize: app.largeFont
                    horizontalAlignment: Text.AlignHCenter
                    text: "Uh oh!"
                }

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "There doesn't seem to be a guh box installed in your network. Please make sure your guh box is correctly set up and connected and try searching for it again."
                }
                Button {
                    Layout.fillWidth: true
                    text: "Try again!"
                    onClicked: upnpDiscovery.discover()
                }
            }
        }
    }

    Component {
        id: searchResultsPage

        Page {
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
                        text: "Oh, look!"
                        color: "black"
                        font.pixelSize: app.largeFont
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("There are %1 guh boxes in your network! Which one would you like to use?").arg(upnpDiscovery.discoveryModel.count)
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
                    model: upnpDiscovery.discoveryModel
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
                            internalPageStack.push(connectingPage)
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Material.accent
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.margins: app.margins
                    spacing: app.margins

                    Label {
                        Layout.fillWidth: true
                        text: "Not the ones you're looking for? Try again!"
                        wrapMode: Text.WordWrap
                    }

                    Button {
                        text: "Search again!"
                        Layout.fillWidth: true
                        onClicked: {
                            upnpDiscovery.discover()
                        }
                    }
                }
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
