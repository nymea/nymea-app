import QtQuick 2.4
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../components"
import Nymea 1.0

Page {
    id: root

    property var networkManagerController: null

    signal connected();

    header: GuhHeader {
        text: qsTr("Select wireless network")
        onBackPressed: {
            pageStack.pop();
        }

        HeaderButton {
            imageSource: "../images/info.svg"
            onClicked: {
                pageStack.push(Qt.resolvedUrl("BoxInfoPage.qml"), {networkManagerController: root.networkManagerController})
            }
        }
        HeaderButton {
            imageSource: "../images/settings.svg"
            onClicked: {
                pageStack.push(Qt.resolvedUrl("NetworkSettingsPage.qml"), {networkManagerController: root.networkManagerController})
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: WirelessAccessPointsProxy {
                accessPoints: networkManagerController.manager.accessPoints
            }
            clip: true

            delegate: MeaListItemDelegate {
                width: parent.width
                text: model.ssid
                enabled: !networkManagerController.manager.working
                subText: model.hostAddress

                iconColor: model.selectedNetwork ? app.accentColor : "#808080"
                iconName:  {
                    if (model.protected) {
                        if (model.signalStrength <= 25)
                            return  Qt.resolvedUrl("../../images/nm-signal-25-secure.svg")

                        if (model.signalStrength <= 50)
                            return  Qt.resolvedUrl("../../images/nm-signal-50-secure.svg")

                        if (model.signalStrength <= 75)
                            return  Qt.resolvedUrl("../../images/nm-signal-75-secure.svg")

                        if (model.signalStrength <= 100)
                            return  Qt.resolvedUrl("../../images/nm-signal-100-secure.svg")

                    } else {

                        if (model.signalStrength <= 25)
                            return  Qt.resolvedUrl("../../images/nm-signal-25.svg")

                        if (model.signalStrength <= 50)
                            return  Qt.resolvedUrl("../../images/nm-signal-50.svg")

                        if (model.signalStrength <= 75)
                            return  Qt.resolvedUrl("../../images/nm-signal-75.svg")

                        if (model.signalStrength <= 100)
                            return  Qt.resolvedUrl("../../images/nm-signal-100.svg")

                    }
                }

                onClicked: {
                    print("Connect to ", model.ssid, " --> ", model.macAddress)
                    if (model.selectedNetwork) {
                        pageStack.push(networkInformationPage, { ssid: model.ssid, macAddress: model.macAddress })
                    } else {
                        pageStack.push(authenticationPageComponent, { ssid: model.ssid, macAddress: model.macAddress })
                    }
                }
            }
        }
    }

    Component {
        id: authenticationPageComponent
        Page {
            id: authenticationPage
            header: GuhHeader {
                text: qsTr("Authenticate")
                onBackPressed: pageStack.pop()
            }

            property string ssid
            property string macAddress

            Connections {
                target: root.networkManagerController.manager
                onCurrentConnectionChanged: {
                    if (root.networkManagerController.manager.currentConnection && root.networkManagerController.manager.currentConnection.ssid === authenticationPage.ssid) {
                        print("**** connected!")
                        root.connected();
                    }
                }
                onWirelessStatusChanged: {
                    print("Wireless status changed:", networkManagerController.manager.networkStatus)
                    if (networkManagerController.manager.wirelessStatus === WirelessSetupManager.WirelessStatusFailed) {
                        wrongPasswordText.visible = true
                        pageStack.pop(authenticationPage)
                    }
                }
            }

            ColumnLayout {
                anchors { left: parent.left; top: parent.top; right: parent.right; }

                Label {
                    Layout.fillWidth: true
                    Layout.margins: app.margins
                    text: qsTr("Enter the password for %1").arg(authenticationPage.ssid)
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

                Label {
                    id: wrongPasswordText
                    text: qsTr("Sorry, the password is wrong. Please try again.")
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    color: "red"
                    visible: false
                }

                Button {
                    Layout.fillWidth: true
                    Layout.margins: app.margins
                    text: qsTr("OK")
                    enabled: passwordTextField.displayText.length >= 8
                    onClicked: {
                        root.networkManagerController.manager.connectWirelessNetwork(authenticationPage.ssid, passwordTextField.text)
                        pageStack.push(connectingWifiWaitPageComponent, {ssid: authenticationPage.ssid })
                    }
                }
            }
        }
    }

    Component {
        id: connectingWifiWaitPageComponent

        Page {
            id: connectingWifiWaitPage
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
                    text: qsTr("Connecting the %1 box to %2").arg(app.systemName).arg(connectingWifiWaitPage.ssid)
                }
            }
        }
    }
}
