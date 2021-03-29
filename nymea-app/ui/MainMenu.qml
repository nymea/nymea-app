import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import "components"
import Nymea 1.0

Drawer {
    id: root

    property Engine currentEngine: null

    signal openThingSettings();
    signal openMagicSettings();
    signal openAppSettings();
    signal openSystemSettings();
    signal configureMainView();

    signal startWirelessSetup();
    signal startManualConnection();
    signal startDemoMode();

    background: Rectangle {
        color: Style.backgroundColor
    }


    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: topSectionLayout.implicitHeight + app.margins * 2
            color: Qt.tint(Style.backgroundColor, Qt.rgba(Style.foregroundColor.r, Style.foregroundColor.g, Style.foregroundColor.b, 0.05))
            ColumnLayout {
                id: topSectionLayout
                anchors { left: parent.left; top: parent.top; right: parent.right; margins: app.margins }
                spacing: app.margins

                Image {
                    Layout.preferredHeight: app.hugeIconSize
                    // w : h = ss.w : ss.h
                    Layout.preferredWidth: app.hugeIconSize * sourceSize.width / sourceSize.height
                    source: "qrc:/styles/%1/logo-wide.svg".arg(styleController.currentStyle)
                }

                RowLayout {
                    visible: root.currentEngine && root.currentEngine.jsonRpcClient.currentHost
                    ColumnLayout {
                        Label {
                            Layout.fillWidth: true
                            text: root.currentEngine && root.currentEngine.jsonRpcClient.currentHost ? root.currentEngine.jsonRpcClient.currentHost.name : Configuration.systemName
                        }
                        Label {
                            Layout.fillWidth: true
                            text: root.currentEngine.jsonRpcClient.currentConnection ? root.currentEngine.jsonRpcClient.currentConnection.url : ""
                            font.pixelSize: app.extraSmallFont
                            enabled: false
                        }
                    }
                    ProgressButton {
                        longpressEnabled: false
                        imageSource: "../images/close.svg"
                        onClicked: {
                            root.currentEngine.jsonRpcClient.disconnectFromHost();
                            root.close();
                        }
                    }
                }
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: contentColumn.implicitHeight
            interactive: contentHeight > height
            clip: true

            ScrollBar.vertical: ScrollBar {}

            ColumnLayout {
                id: contentColumn
                width: parent.width
                spacing: 0

                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Wireless setup")
                    iconName: "../images/connections/bluetooth.svg"
                    progressive: false
                    visible: root.currentEngine && root.currentEngine.jsonRpcClient.currentHost == null
                    onClicked: {
                        root.startWirelessSetup();
                        root.close();
                    }
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Manual connection")
                    iconName: "../images/connections/network-vpn.svg"
                    progressive: false
                    visible: root.currentEngine && root.currentEngine.jsonRpcClient.currentHost == null
                    onClicked: {
                        root.startManualConnection();
                        root.close();
                    }
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Demo mode")
                    iconName: "../images/private-browsing.svg"
                    progressive: false
                    visible: root.currentEngine && root.currentEngine.jsonRpcClient.currentHost == null
                    onClicked: {
                        root.startDemoMode();
                        root.close();
                    }
                }

                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Configure things")
                    iconName: "../images/things.svg"
                    visible: root.currentEngine && root.currentEngine.jsonRpcClient.currentHost
                    progressive: false
                    onClicked: {
                        root.openThingSettings()
                        root.close();
                    }
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Magic")
                    iconName: "../images/magic.svg"
                    progressive: false
                    visible: root.currentEngine && root.currentEngine.jsonRpcClient.currentHost
                    onClicked: {
                        root.openMagicSettings();
                        root.close();
                    }
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Configure main view")
                    iconName: "../images/configure.svg"
                    progressive: false
                    visible: root.currentEngine && root.currentEngine.jsonRpcClient.currentHost
                    onClicked: {
                        root.configureMainView();
                        root.close();
                    }
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("App settings")
                    iconName: "../images/stock_application.svg"
                    progressive: false
                    onClicked: {
                        root.openAppSettings();
                        root.close();
                    }
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("System settings")
                    iconName: "../images/settings.svg"
                    progressive: false
                    visible: root.currentEngine && root.currentEngine.jsonRpcClient.currentHost
                    onClicked: {
                        root.openSystemSettings();
                        root.close();
                    }
                }


                NymeaItemDelegate {
                    Layout.fillWidth: true
                    Layout.topMargin: app.margins
                    text: qsTr("Help")
                    iconName: "../images/help.svg"
                    progressive: false
                    onClicked: Qt.openUrlExternally("https://nymea.io/documentation/users/usage/first-steps")
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Forum")
                    iconName: "../images/discourse.svg"
                    progressive: false
                    onClicked: Qt.openUrlExternally("https://forum.nymea.io")
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Telegram")
                    iconName: "../images/telegram.svg"
                    progressive: false
                    onClicked: Qt.openUrlExternally("https://t.me/nymeacommunity")
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Discord")
                    iconName: "../images/discord.svg"
                    progressive: false
                    onClicked: Qt.openUrlExternally("https://discord.gg/tX9YCpD")
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Twitter")
                    iconName: "../images/twitter.svg"
                    progressive: false
                    onClicked: Qt.openUrlExternally("https://twitter.com/nymea_io")
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Facebook")
                    iconName: "../images/facebook.svg"
                    progressive: false
                    onClicked: Qt.openUrlExternally("https://m.facebook.com/groups/nymea")
                }
            }
        }
    }
}

