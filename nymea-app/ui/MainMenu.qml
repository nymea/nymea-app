import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import "components"
import Nymea 1.0

Drawer {
    id: root

    property ConfiguredHostsModel configuredHosts: null
    readonly property Engine currentEngine: configuredHosts.count > 0 ? configuredHosts.get(configuredHosts.currentIndex).engine : null

    signal openThingSettings();
    signal openMagicSettings();
    signal openAppSettings();
    signal openSystemSettings();
    signal configureMainView();

    signal startWirelessSetup();
    signal startManualConnection();

    background: Rectangle {
        color: Style.backgroundColor
    }

    onClosed: topSectionLayout.configureConnections = false;

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: topSectionLayout.implicitHeight
            color: Qt.tint(Style.backgroundColor, Qt.rgba(Style.foregroundColor.r, Style.foregroundColor.g, Style.foregroundColor.b, 0.05))

            ColumnLayout {
                id: topSectionLayout
                anchors { left: parent.left; top: parent.top; right: parent.right }
                spacing: 0

                property bool configureConnections: false

                RowLayout {
                    Layout.margins: Style.margins
                    Image {
                        Layout.preferredHeight: Style.hugeIconSize
                        sourceSize.height: Style.hugeIconSize
                        Layout.fillWidth: true
                        fillMode: Image.PreserveAspectFit
                        horizontalAlignment: Image.AlignLeft
                        source: "qrc:/styles/%1/logo-wide.svg".arg(styleController.currentStyle)
                    }
                    ProgressButton {
                        imageSource: "/ui/images/configure.svg"
                        longpressEnabled: false
                        Layout.alignment: Qt.AlignBottom
                        color: topSectionLayout.configureConnections ? Style.accentColor : Style.iconColor
                        onClicked: {
                            topSectionLayout.configureConnections = !topSectionLayout.configureConnections
                        }
                    }
                }


                Repeater {
                    model: root.configuredHosts
                    delegate: NymeaItemDelegate {

                        readonly property ConfiguredHost configuredHost: root.configuredHosts.get(index)

                        Layout.fillWidth: true
                        text: model.name.length > 0 ? model.name : qsTr("New connection")
                        subText: configuredHost.engine.jsonRpcClient.currentConnection ? configuredHost.engine.jsonRpcClient.currentConnection.url : ""
                        prominentSubText: false
                        progressive: false
                        additionalItem: RowLayout {
                            anchors.verticalCenter: parent.verticalCenter
                            Rectangle {
                                height: Style.smallIconSize
                                width: height
                                radius: height / 2
                                color: Style.accentColor
                                Layout.alignment: Qt.AlignVCenter
                                visible: index === configuredHostsModel.currentIndex && !topSectionLayout.configureConnections
                            }
                            ProgressButton {
                                imageSource: "/ui/images/close.svg"
                                visible: topSectionLayout.configureConnections
                                longpressEnabled: false
                                onClicked: {
                                    configuredHostsModel.removeHost(index)
                                }
                            }
                        }
                        onClicked: {
                            configuredHostsModel.currentIndex = index
                            root.close()
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: topSectionLayout.configureConnections ? childrenRect.height : 0
                    Behavior on Layout.preferredHeight { NumberAnimation { duration: Style.animationDuration; easing.type: Easing.InOutQuad }}
                    clip: true
                    NymeaItemDelegate {
                        width: parent.width
                        text: qsTr("Set up another...")
                        iconName: "add"
                        progressive: false
                        onClicked: {
                            var host = configuredHostsModel.createHost()
                            configuredHostsModel.currentIndex = configuredHosts.indexOf(host)
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
                    visible: root.currentEngine && root.currentEngine.jsonRpcClient.currentHost &&
                             !Configuration.hasOwnProperty("mainViewsFilter")
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
                    visible: Configuration.showCommunityLinks
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Forum")
                    iconName: "../images/discourse.svg"
                    progressive: false
                    onClicked: Qt.openUrlExternally("https://forum.nymea.io")
                    visible: Configuration.showCommunityLinks
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Telegram")
                    iconName: "../images/telegram.svg"
                    progressive: false
                    onClicked: Qt.openUrlExternally("https://t.me/nymeacommunity")
                    visible: Configuration.showCommunityLinks
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Discord")
                    iconName: "../images/discord.svg"
                    progressive: false
                    onClicked: Qt.openUrlExternally("https://discord.gg/tX9YCpD")
                    visible: Configuration.showCommunityLinks
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Twitter")
                    iconName: "../images/twitter.svg"
                    progressive: false
                    onClicked: Qt.openUrlExternally("https://twitter.com/nymea_io")
                    visible: Configuration.showCommunityLinks
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Facebook")
                    iconName: "../images/facebook.svg"
                    progressive: false
                    onClicked: Qt.openUrlExternally("https://m.facebook.com/groups/nymea")
                    visible: Configuration.showCommunityLinks
                }
            }
        }
    }
}

