import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import "components"
import Nymea 1.0

Rectangle {
    id: root
    visible: !Qt.colorEqual(color, "transparent")
    property bool shown: false

    property Engine currentEngine: null

    signal openThingSettings();
    signal openMagicSettings();
    signal openAppSettings();
    signal openSystemSettings();

    function show() {
        shown = true;
    }
    function hide() {
        shown = false;
    }

    color: root.shown ? "#88000000" : "transparent"
    Behavior on color { ColorAnimation { duration: 200 } }

    MouseArea {
        anchors.fill: parent
        onClicked: root.hide()
        hoverEnabled: true
    }

    Pane {
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
        width: Math.min(root.width, 300)
        anchors.leftMargin: root.shown ? 0 : -width
        Behavior on anchors.leftMargin { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        leftPadding: 0
        topPadding: 0
        rightPadding: 0
        bottomPadding: 0

        ColumnLayout {
            anchors { left: parent.left; top: parent.top; right: parent.right }
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: topSectionLayout.implicitHeight + app.margins * 2
                color: Qt.tint(app.backgroundColor, Qt.rgba(app.foregroundColor.r, app.foregroundColor.g, app.foregroundColor.b, 0.05))
                ColumnLayout {
                    id: topSectionLayout
                    anchors { left: parent.left; top: parent.top; right: parent.right; margins: app.margins }

                    RowLayout {
                        Image {
                            Layout.preferredHeight: app.hugeIconSize
                            Layout.preferredWidth: height
                            sourceSize.width: width
                            sourceSize.height: height

                            source: "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                        }
                        ColorIcon {
                            Layout.preferredHeight: app.iconSize
                            Layout.preferredWidth: app.iconSize
                            name: {
                                if (root.currentEngine === null) {
                                    return "";
                                }

                                switch (root.currentEngine.jsonRpcClient.currentConnection.bearerType) {
                                case Connection.BearerTypeLan:
                                case Connection.BearerTypeWan:
                                    if (root.currentEngine.jsonRpcClient.availableBearerTypes & NymeaConnection.BearerTypeEthernet != NymeaConnection.BearerTypeNone) {
                                        return "../images/connections/network-wired.svg"
                                    }
                                    return "../images/connections/network-wifi.svg";
                                case Connection.BearerTypeBluetooth:
                                    return "../images/connections/network-wifi.svg";
                                case Connection.BearerTypeCloud:
                                    return "../images/connections/cloud.svg"
                                case Connection.BearerTypeLoopback:
                                }
                                return ""
                            }

                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        text: root.currentEngine.jsonRpcClient.currentHost.name
                    }
                    Label {
                        Layout.fillWidth: true
                        text: root.currentEngine.jsonRpcClient.currentConnection.url
                        font.pixelSize: app.smallFont
                        enabled: false
                    }

                }
            }

            SettingsPageSectionHeader {
                text: qsTr("Configuration")
            }

            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("Configure things")
                iconName: "../images/things.svg"
                visible: root.currentEngine != null
                progressive: false
                onClicked: {
                    root.openThingSettings()
                    root.hide();
                }
            }
            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("Magic")
                iconName: "../images/magic.svg"
                progressive: false
                visible: root.currentEngine != null
            }
            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("App settings")
                iconName: "../images/stock_application.svg"
                progressive: false
            }
            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("System settings")
                iconName: "../images/settings.svg"
                progressive: false
                visible: root.currentEngine != null
            }
            SettingsPageSectionHeader {
                text: qsTr("Community")
            }

            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("Forum")
                iconName: "../images/discourse.svg"
                progressive: false
            }
            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("Telegram")
                iconName: "../images/telegram.svg"
                progressive: false
            }
            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("Twitter")
                iconName: "../images/twitter.svg"
                progressive: false
            }
        }
    }
}
