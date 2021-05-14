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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import Qt.labs.settings 1.1
import "../components"

Page {
    id: root

    header: ToolBar {
        RowLayout {
            anchors.fill: parent

            HeaderButton {
                imageSource: "../images/navigation-menu.svg"
                onClicked: app.mainMenu.open()
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Connect %1").arg(Configuration.systemName)
            }
        }
    }

    readonly property bool haveHosts: hostsProxy.count > 0


    function connectToHost(host, noAnimations) {
        var page = pageStack.push(Qt.resolvedUrl("ConnectingPage.qml"), noAnimations ? StackView.Immediate : StackView.PushTransition)
        page.cancel.connect(function() {
            engine.jsonRpcClient.disconnectFromHost()
            pageStack.pop(root, StackView.Immediate);
            pageStack.push(discoveryPage)
        })
        print("Connecting to host", host)
        engine.jsonRpcClient.connectToHost(host)
    }

    NymeaHostsFilterModel {
        id: hostsProxy
        discovery: nymeaDiscovery
        showUnreachableBearers: false
        jsonRpcClient: engine.jsonRpcClient
        showUnreachableHosts: false
    }


    Timer {
        id: splashHideTimeout
        interval: 3000
        repeat: false
        running: true
        onTriggered: {
            PlatformHelper.hideSplashScreen()
            startupTimer.start()
        }
    }

    Timer {
        id: startupTimer
        interval: 10000
        repeat: false
        running: false
    }


    ColumnLayout {
        anchors.fill: parent
        spacing: app.margins

        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            Layout.topMargin: app.margins
            spacing: app.margins

            Label {
                Layout.fillWidth: true
                text: root.haveHosts ? qsTr("Oh, look!") : startupTimer.running ? qsTr("Just a moment...") : qsTr("Uh oh")
                //color: "black"
                font.pixelSize: app.largeFont
            }

            Label {
                Layout.fillWidth: true
                text: root.haveHosts ?
                          qsTr("There are %n %1 systems in your network! Which one would you like to use?", "", hostsProxy.count).arg(Configuration.systemName)
                        : startupTimer.running ? qsTr("We haven't found a %1 system in your network yet.").arg(Configuration.systemName)
                                               : qsTr("There doesn't seem to be a %1 system installed in your network. Please make sure your %1 system is correctly set up and connected.").arg(Configuration.systemName)
                wrapMode: Text.WordWrap
            }
        }

        ThinDivider { }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: hostsProxy
            clip: true

            delegate: NymeaSwipeDelegate {
                id: nymeaHostDelegate
                width: parent.width
                height: app.delegateHeight
                objectName: "discoveryDelegate" + index
                property var nymeaHost: hostsProxy.get(index)
                property string defaultConnectionIndex: {
                    var bestIndex = -1
                    var bestPriority = 0;
                    for (var i = 0; i < nymeaHost.connections.count; i++) {
                        var connection = nymeaHost.connections.get(i);
                        if (bestIndex === -1 || connection.priority > bestPriority) {
                            bestIndex = i;
                            bestPriority = connection.priority;
                        }
                    }
                    return bestIndex;
                }

                iconName: {
                    switch (nymeaHost.connections.get(defaultConnectionIndex).bearerType) {
                    case Connection.BearerTypeLan:
                    case Connection.BearerTypeWan:
                        if (engine.jsonRpcClient.availableBearerTypes & NymeaConnection.BearerTypeEthernet != NymeaConnection.BearerTypeNone) {
                            return "../images/connections/network-wired.svg"
                        }
                        return "../images/connections/network-wifi.svg";
                    case Connection.BearerTypeBluetooth:
                        return "../images/connections/bluetooth.svg";
                    case Connection.BearerTypeCloud:
                        return "../images/connections/cloud.svg"
                    case Connection.BearerTypeLoopback:
                        return "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
                    }
                    return ""
                }

                text: model.name
                subText: nymeaHost.connections.get(defaultConnectionIndex).url
                wrapTexts: false
                prominentSubText: false
                progressive: false
                property bool isSecure: nymeaHost.connections.get(defaultConnectionIndex).secure
                property bool isOnline: nymeaHost.connections.get(defaultConnectionIndex).bearerType !== Connection.BearerTypeWan ? nymeaHost.connections.get(defaultConnectionIndex).online : true
                tertiaryIconName: isSecure ? "../images/connections/network-secure.svg" : ""
                secondaryIconName: !isOnline ? "../images/connections/cloud-error.svg" : ""
                secondaryIconColor: "red"

                onClicked: {
                    root.connectToHost(nymeaHostDelegate.nymeaHost)
                }

                contextOptions: [
                    {
                        text: qsTr("Info"),
                        icon: Qt.resolvedUrl("../images/info.svg"),
                        callback: function() {
                            var nymeaHost = hostsProxy.get(index);
                            var popup = infoDialog.createObject(app,{nymeaHost: nymeaHost})
                            popup.open()
                        }
                    }
                ]
            }

            Column {
                anchors.centerIn: parent
                spacing: app.margins
                visible: !root.haveHosts

                Label {
                    text: qsTr("Searching for %1 systems...").arg(Configuration.systemName)
                }

                BusyIndicator {
                    running: visible
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        ThinDivider {}

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            wrapMode: Text.WordWrap
            visible: nymeaDiscovery.nymeaHosts.count === 0
            text: qsTr("Do you have a %1 system but it's not connected to your network yet? Use the wireless setup to connect it!").arg(Configuration.systemName)
        }
        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            visible: nymeaDiscovery.nymeaHosts.count === 0
            text: qsTr("Start wireless setup")
            onClicked: pageStack.push(Qt.resolvedUrl("wifisetup/BluetoothDiscoveryPage.qml"))
        }
        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            text: qsTr("Cloud login")
            visible: !AWSClient.isLoggedIn
            onClicked: pageStack.push(Qt.resolvedUrl("../appsettings/CloudLoginPage.qml"))
        }

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            Layout.bottomMargin: app.margins
            visible: nymeaDiscovery.nymeaHosts.count === 0
            text: qsTr("Demo mode (online)")
            onClicked: {
                var host = nymeaDiscovery.nymeaHosts.createWanHost("Demo server", "nymea://nymea.nymea.io:2222")
                engine.jsonRpcClient.connectToHost(host)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            Layout.bottomMargin: app.margins
            visible: root.haveHosts
            Label {
                Layout.fillWidth: true
                text: qsTr("Not the ones you're looking for? We're looking for more!")
                wrapMode: Text.WordWrap
            }

            BusyIndicator { }
        }
    }

    Component {
        id: infoDialog
        Dialog {
            id: dialog
            width: Math.min(parent.width, contentGrid.implicitWidth)
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true
            title: qsTr("Box information")

            standardButtons: Dialog.Ok

            property NymeaHost nymeaHost: null

            header: Item {
                implicitHeight: headerRow.height + app.margins * 2
                implicitWidth: parent.width
                RowLayout {
                    id: headerRow
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: app.margins }
                    spacing: app.margins
                    ColorIcon {
                        Layout.preferredHeight: Style.iconSize * 2
                        Layout.preferredWidth: height
                        name: "../images/info.svg"
                        color: Style.accentColor
                    }

                    Label {
                        id: titleLabel
                        Layout.fillWidth: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: dialog.title
                        color: Style.accentColor
                        font.pixelSize: app.largeFont
                    }
                }
            }

            GridLayout {
                id: contentGrid
                anchors.fill: parent
                rowSpacing: app.margins
                columns: 2
                Label {
                    text: "Name:"
                }
                Label {
                    text: dialog.nymeaHost.name
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Label {
                    text: "UUID:"
                }
                Label {
                    text: dialog.nymeaHost.uuid
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Label {
                    text: "Version:"
                }
                Label {
                    text: dialog.nymeaHost.version
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                ThinDivider { Layout.columnSpan: 2 }
                Label {
                    Layout.columnSpan: 2
                    text: qsTr("Available connections")
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Logout")
                    onClicked: tokenSettings.setValue(dialog.nymeaHost.uuid, "")
                    visible: tokenSettings.value(dialog.nymeaHost.uuid) !== ""

                    Settings {
                        id: tokenSettings
                        category: "jsonTokens"
                    }
                }

                Flickable {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    contentHeight: contentColumn.implicitHeight
                    clip: true
                    ColumnLayout {
                        id: contentColumn
                        width: parent.width
                        Repeater {
                            model: dialog.nymeaHost.connections
                            delegate: NymeaSwipeDelegate {
                                Layout.fillWidth: true
                                wrapTexts: false
                                progressive: false
                                text: model.name
                                subText: model.url
                                prominentSubText: false
                                iconName: {
                                    switch (model.bearerType) {
                                    case Connection.BearerTypeLan:
                                    case Connection.BearerTypeWan:
                                        if (engine.jsonRpcClient.availableBearerTypes & NymeaConnection.BearerTypeEthernet != NymeaConnection.BearerTypeNone) {
                                            return "../images/connections/network-wired.svg"
                                        }
                                        return "../images/connections/network-wifi.svg";
                                    case Connection.BearerTypeBluetooth:
                                        return "../images/connections/bluetooth.svg";
                                    case Connection.BearerTypeCloud:
                                        return "../images/connections/cloud.svg"
                                    case Connection.BearerTypeLoopback:
                                        return "../images/connections/network-wired.svg"
                                    }
                                    return ""
                                }

                                tertiaryIconName: model.secure ? "../images/connections/network-secure.svg" : ""
                                secondaryIconName: !model.online ? "../images/connections/cloud-error.svg" : ""
                                secondaryIconColor: "red"

                                onClicked: {
                                    dialog.close()
                                    engine.jsonRpcClient.connectToHost(dialog.nymeaHost, dialog.nymeaHost.connections.get(index))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
