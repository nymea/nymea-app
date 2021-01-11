/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.4
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../components"
import Nymea 1.0

Page {
    id: root

    property BtWiFiSetup wifiSetup: null

    signal connected();

    header: NymeaHeader {
        text: qsTr("Select wireless network")
        onBackPressed: {
            pageStack.pop();
        }

        HeaderButton {
            imageSource: "../images/info.svg"
            onClicked: {
                pageStack.push(Qt.resolvedUrl("BoxInfoPage.qml"), {wifiSetup: root.wifiSetup})
            }
        }
        HeaderButton {
            imageSource: "../images/settings.svg"
            onClicked: {
                pageStack.push(Qt.resolvedUrl("NetworkSettingsPage.qml"), {wifiSetup: root.wifiSetup})
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: WirelessAccessPointsProxy {
                accessPoints: wifiSetup.accessPoints
            }
            clip: true

            Timer {
                interval: 5000
                repeat: true
                onTriggered: wifiSetup.scanWiFi()
                running: wifiSetup.accessPoints.count === 0
            }

            BusyIndicator {
                anchors.centerIn: parent
                visible: wifiSetup.accessPoints.count === 0
                running: visible
            }

            delegate: NymeaSwipeDelegate {
                width: parent.width
                text: model.ssid !== "" ? model.ssid : qsTr("Hidden Network")
                subText: model.hostAddress

                iconColor: model.selectedNetwork ? Style.accentColor : "#808080"
                iconName:  {
                    if (model.protected) {
                        if (model.signalStrength <= 25)
                            return  Qt.resolvedUrl("../../images/connections/nm-signal-25-secure.svg")

                        if (model.signalStrength <= 50)
                            return  Qt.resolvedUrl("../../images/connections/nm-signal-50-secure.svg")

                        if (model.signalStrength <= 75)
                            return  Qt.resolvedUrl("../../images/connections/nm-signal-75-secure.svg")

                        if (model.signalStrength <= 100)
                            return  Qt.resolvedUrl("../../images/connections/nm-signal-100-secure.svg")

                    } else {

                        if (model.signalStrength <= 25)
                            return  Qt.resolvedUrl("../../images/connections/nm-signal-25.svg")

                        if (model.signalStrength <= 50)
                            return  Qt.resolvedUrl("../../images/connections/nm-signal-50.svg")

                        if (model.signalStrength <= 75)
                            return  Qt.resolvedUrl("../../images/connections/nm-signal-75.svg")

                        if (model.signalStrength <= 100)
                            return  Qt.resolvedUrl("../../images/connections/nm-signal-100.svg")

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
            header: NymeaHeader {
                text: qsTr("Authenticate")
                onBackPressed: pageStack.pop()
            }

            property string ssid
            property string macAddress

            Connections {
                target: root.wifiSetup
                onCurrentConnectionChanged: {
                    if (root.wifiSetup.currentConnection && root.wifiSetup.currentConnection.ssid === authenticationPage.ssid) {
                        print("**** connected!")
                        root.connected();
                    }
                }
                onWirelessStatusChanged: {
                    print("Wireless status changed:", wifiSetup.networkStatus)
                    if (wifiSetup.wirelessStatus === BtWiFiSetup.WirelessStatusFailed) {
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
                        color: passwordTextField.showPassword ? Style.accentColor : Style.iconColor
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
                        root.wifiSetup.connectDeviceToWiFi(authenticationPage.ssid, passwordTextField.text)
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
                    text: qsTr("Connecting the %1:core to %2").arg(app.systemName).arg(connectingWifiWaitPage.ssid)
                }
            }
        }
    }
}
