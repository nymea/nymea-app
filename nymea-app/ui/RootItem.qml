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
import Qt.labs.settings 1.0
import Nymea 1.0
import "components"
import "connection"

Item {
    id: root

    function handleAndroidBackButton() {
        return swipeView.currentItem.handleAndroidBackButton()
    }

    ListModel {
        id: tabModel

        Component.onCompleted: {
            for (var i = 0; i < settings.tabCount; i++) {
                tabModel.append({})
            }
        }

        function addTab() {
            tabModel.append({})
            settings.tabCount++;
            swipeView.currentIndex = settings.tabCount - 1
            tabbar.currentIndex = swipeView.currentIndex
        }
        function removeTab(index) {
            if (swipeView.currentIndex === index) {
                if (swipeView.currentIndex > 0) {
                    swipeView.currentIndex--;
                } else {
                    swipeView.currentIndex++;
                }
            }

            remove(index);
            settings.tabCount--;
            tabbar.currentIndex = swipeView.currentIndex
            orphanedSettings.lastConnectedHost = ""
        }
    }
    Settings {
        id: orphanedSettings
        category: "tabSettings" + tabModel.count
        property string lastConnectedHost
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        SwipeView {
            id: swipeView
            Layout.fillHeight: true
            Layout.fillWidth: true
            interactive: false

            Repeater {
                id: mainRepeater
                model: tabModel

                delegate: Item {
                    height: swipeView.height
                    width: swipeView.width
                    clip: true

                    property var tabSettings: Settings {
                        category: "tabSettings" + index
                        property string lastConnectedHost
                        property int currentMainViewIndex: -1
                    }

                    Engine {
                        id: engineObject
                    }
                    readonly property Engine engine: engineObject
                    readonly property Engine _engine: engineObject // In case a child cannot use "engine"
                    property int connectionTabIndex: index
//                    onConnectionTabIndexChanged: tabSettings.lastConnectedHost = engine.jsonRpcClient.url

                    Binding {
                        target: AWSClient
                        property: "config"
                        value: "cloudEnvironment" in app ? app.cloudEnvironment : settings.cloudEnvironment
                    }

                    Binding {
                        target: _discovery
                        property: "discovering"
                        value: engine.jsonRpcClient.currentHost === null
                    }

                    StackView {
                        id: pageStack
                        objectName: "pageStack"
                        anchors.fill: parent
                        initialItem: Page {}
                    }

                    Component.onCompleted: {
                        setupPushNotifications();
                        if (autoConnectHost.length > 0) {
                            var host = discovery.nymeaHosts.createLanHost("Manual connection", autoConnectHost);
                            engine.jsonRpcClient.connectToHost(host)
                        } else if (tabSettings.lastConnectedHost.length > 0) {
                            print("Last connected host was", tabSettings.lastConnectedHost)
                            var cachedHost = discovery.nymeaHosts.find(tabSettings.lastConnectedHost);
                            if (cachedHost) {
                                engine.jsonRpcClient.connectToHost(cachedHost)
                                return;
                            }
                            print("Warning: There is a last connected host but UUID is unknown to discovery...")
                        }
                        PlatformHelper.hideSplashScreen();
                        pageStack.push(Qt.resolvedUrl("connection/ConnectPage.qml"), StackView.Immediate)
                    }

                    Timer { running: true; repeat: false; interval: 3000; onTriggered: PlatformHelper.hideSplashScreen(); }

                    function init() {
                        print("calling init. Auth required:", engine.jsonRpcClient.authenticationRequired, "initial setup required:", engine.jsonRpcClient.initialSetupRequired, "jsonrpc connected:", engine.jsonRpcClient.connected, "Current host:", engine.jsonRpcClient.currentHost)
                        pageStack.clear()
                        if (!engine.jsonRpcClient.currentHost) {
                            print("pushing ConnectPage")
                            pageStack.push(Qt.resolvedUrl("connection/ConnectPage.qml"))
                            PlatformHelper.hideSplashScreen();
                            return;
                        }

                        if (engine.jsonRpcClient.authenticationRequired || engine.jsonRpcClient.initialSetupRequired) {
                            PlatformHelper.hideSplashScreen();
                            if (engine.jsonRpcClient.pushButtonAuthAvailable) {
                                print("opening push button auth")
                                var page = pageStack.push(Qt.resolvedUrl("PushButtonAuthPage.qml"))
                                page.backPressed.connect(function() {
                                    tabSettings.lastConnectedHost = "";
                                    engine.jsonRpcClient.disconnectFromHost();
                                    init();
                                })
                                return;
                            } else {
                                if (engine.jsonRpcClient.initialSetupRequired) {
                                    var page = pageStack.push(Qt.resolvedUrl("connection/SetupWizard.qml"));
                                    page.backPressed.connect(function() {
                                        tabSettings.lastConnectedHost = "";
                                        engine.jsonRpcClient.disconnectFromHost()
                                        init();
                                    })
                                    return;
                                }

                                var page = pageStack.push(Qt.resolvedUrl("connection/LoginPage.qml"));
                                page.backPressed.connect(function() {
                                    tabSettings.lastConnectedHost = "";
                                    engine.jsonRpcClient.disconnectFromHost()
                                    init();
                                })
                                return;
                            }
                        }

                        if (engine.jsonRpcClient.connected) {
                            pageStack.push(Qt.resolvedUrl("MainPage.qml"))
                            PlatformHelper.hideSplashScreen();
                            return;
                        }

                        var page = pageStack.push(Qt.resolvedUrl("connection/ConnectingPage.qml"));
                        page.cancel.connect(function(){
                            engine.jsonRpcClient.disconnectFromHost();
                        })
                    }

                    function handleAndroidBackButton() {
                        // If we're connected, allow going back up to MainPage
                        if ((engine.jsonRpcClient.connected && pageStack.depth > 1)
                                // if we're not connected, only allow using the back button in wizards
                                || (!engine.jsonRpcClient.connected && pageStack.depth > 3)) {
                            pageStack.pop();
                            return true;
                        }
                        return false;
                    }

                    function setupPushNotifications(askForPermissions) {
                        if (askForPermissions === undefined) {
                            askForPermissions = true;
                        }

                        if (!AWSClient.isLoggedIn) {
                            print("AWS not logged in. Cannot register for push");
                            return;
                        }

                        if (PushNotifications.token.length === 0) {
                            print("Don't have a token yet. Cannot register for push");
                            return;
                        }

                        if (!PlatformHelper.hasPermissions) {
                            if (askForPermissions) {
                                PlatformHelper.requestPermissions();
                            }
                        } else {
                            AWSClient.registerPushNotificationEndpoint(PushNotifications.token, PlatformHelper.machineHostname, PlatformHelper.deviceSerial + "+io.guh.nymeaapp", PlatformHelper.deviceManufacturer, PlatformHelper.deviceModel);
                        }
                    }

                    Connections {
                        target: engine.jsonRpcClient
                        onCurrentHostChanged: {
                            init();
                        }
                        onVerifyConnectionCertificate: {
                            print("Asking user to verify certificate:", serverUuid, issuerInfo, pem)
                            var certDialogComponent = Qt.createComponent(Qt.resolvedUrl("connection/CertificateErrorDialog.qml"));
                            var popup = certDialogComponent.createObject(root);
                            popup.accepted.connect(function(){
                                engine.jsonRpcClient.acceptCertificate(serverUuid, pem);
                                engine.jsonRpcClient.connectToHost(discovery.nymeaHosts.find(serverUuid));
                            })
                            popup.open();
                        }
                        onConnectedChanged: {
                            print("json client connected changed", engine.jsonRpcClient.connected)
                            if (engine.jsonRpcClient.connected) {
                                discovery.cacheHost(engine.jsonRpcClient.currentHost)
                                tabSettings.lastConnectedHost = engine.jsonRpcClient.serverUuid
                            }
                            init();
                        }

                        onAuthenticationRequiredChanged: {
                            print("auth required changed")
                            init();
                        }
                        onInitialSetupRequiredChanged: {
                            print("setup required changed")
                            init();
                        }

                        onInvalidProtocolVersion: {
                            var popup = invalidVersionComponent.createObject(app.contentItem);
                            popup.actualVersion = actualVersion;
                            popup.minimumVersion = minimumVersion
                            popup.open()
                            tabSettings.lastConnectedHost = ""
                        }
                    }

                    Connections {
                        target: Qt.application
                        enabled: engine.jsonRpcClient.connected && settings.returnToHome
                        onStateChanged: {
                            print("App active state changed:", state)
                            if (state !== Qt.ApplicationActive) {
                                init();
                            }
                        }
                    }

                    Connections {
                        target: PlatformHelper
                        onHasPermissionsChanged: {
                            setupPushNotifications(false)
                        }
                    }

                    Connections {
                        target: PushNotifications
                        onTokenChanged: {
                            setupPushNotifications();
                        }
                    }

                    Connections {
                        target: AWSClient
                        onIsLoggedInChanged: {
                            setupPushNotifications()
                        }
                    }

                    Component {
                        id: invalidVersionComponent
                        Popup {
                            id: popup

                            property string actualVersion: "0.0"
                            property string minimumVersion: "1.0"

                            width: app.width * .8
                            height: col.childrenRect.height + app.margins * 2
                            x: (app.width - width) / 2
                            y: (app.height - height) / 2
                            visible: false
                            ColumnLayout {
                                id: col
                                anchors { left: parent.left; right: parent.right }
                                spacing: app.margins
                                Label {
                                    text: qsTr("Connection error")
                                    Layout.fillWidth: true
                                    font.pixelSize: app.largeFont
                                }
                                Label {
                                    text: qsTr("Sorry, the version of the %1:core you are trying to connect to is too old. This app requires at least version %2 but this %1:core only supports %3").arg(app.systemName).arg(popup.minimumVersion).arg(popup.actualVersion)
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                                Button {
                                    Layout.fillWidth: true
                                    text: qsTr("OK")
                                    onClicked: {
                                        engine.jsonRpcClient.disconnectFromHost();
                                        popup.close()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            visible: settings.showConnectionTabs
            spacing: 0

            TabBar {
                id: tabbar
                Layout.fillWidth: true
                Material.elevation: 2
                position: TabBar.Footer

                Repeater {
                    model: tabModel.count

                    delegate: TabButton {
                        id: hostTabButton
                        property var engine: mainRepeater.itemAt(index)._engine
                        property string serverName: engine.nymeaConfiguration.serverName
                        Material.elevation: index
                        width: Math.max(150, tabbar.width / tabModel.count)

                        Rectangle {
                            anchors.fill: parent
                            color: Material.foreground
                            opacity: 0.06
                        }

                        contentItem: RowLayout {
                            Label {
                                Layout.fillWidth: true
                                text: hostTabButton.serverName !== "" ? hostTabButton.serverName : qsTr("New connection")
                                elide: Text.ElideRight
                            }
                            ColorIcon {
                                Layout.fillHeight: true
                                Layout.preferredWidth: height
                                visible: tabModel.count > 1
                                name: "../images/close.svg"
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: tabModel.removeTab(index)
                                }
                            }
                        }

                        onClicked: {
                            swipeView.currentIndex = index
                        }
                    }
                }
            }

            Pane {
                Layout.preferredHeight: tabbar.height
                Layout.preferredWidth: height
                Material.elevation: 2
                padding: 0

                TabButton {
                    anchors.fill: parent
                    contentItem: ColorIcon {
                        height: parent.height
                        width: parent.width
                        name: "../images/tab-new.svg"
                    }
                    onClicked: {
                        tabModel.addTab()
                    }
                }
            }
        }
    }
}
