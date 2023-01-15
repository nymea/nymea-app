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

    QtObject {
        id: d
        // We want only one of them pushed at a time
        property var currentSettingsPage: null

        function pushSettingsPage(page) {
            if (d.currentSettingsPage != null) {
                d.currentSettingsPage = swipeView.currentItem.pageStack.replace(d.currentSettingsPage, page);
            } else {
                d.currentSettingsPage = swipeView.currentItem.pageStack.push(page)
            }
        }
    }

    function openThingSettings() {
        d.pushSettingsPage("thingconfiguration/EditThingsPage.qml")
    }
    function openMagicSettings() {
        d.pushSettingsPage("MagicPage.qml")
    }
    function openAppSettings() {
        d.pushSettingsPage("appsettings/AppSettingsPage.qml")
    }
    function openSystemSettings() {
        d.pushSettingsPage("SettingsPage.qml")
    }
    function openCustomPage(page) {
        d.pushSettingsPage(page)
    }

    function configureMainView() {
        swipeView.currentItem.pageStack.pop(null)
        swipeView.currentItem.pageStack.currentItem.configureViews()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        SwipeView {
            id: swipeView
            Layout.fillHeight: true
            Layout.fillWidth: true
            interactive: false
            currentIndex: configuredHostsModel.currentIndex

            onCurrentIndexChanged: visibleHackTimer.start();

            // Hack: we only want the current one visible for performance reasons, however, during transitions this might look odd
            // as we need to show two views partially at the same time.
            // Couldn't find a way to determine the swipeView position, so let's assume it's moving for a second after currentIndex changed
            Timer {
                id: visibleHackTimer
                repeat: false
                interval: 500
                running: false
            }

            Repeater {
                id: mainRepeater
                model: configuredHostsModel

                delegate: Item {
                    height: swipeView.height
                    width: swipeView.width
                    clip: true
                    visible: SwipeView.isCurrentItem || visibleHackTimer.running

                    readonly property ConfiguredHost configuredHost: configuredHostsModel.get(index)

                    property var tabSettings: Settings {
                        category: "tabSettings" + index
                        property int currentMainViewIndex: -1
                    }

                    readonly property Engine engine: configuredHost.engine
                    readonly property Engine _engine: configuredHost.engine // In case a child cannot use "engine"

                    Binding {
                        target: nymeaDiscovery
                        property: "discovering"
                        value: engine.jsonRpcClient.currentHost === null
                               && (PlatformPermissions.localNetworkPermission === PlatformPermissions.PermissionStatusGranted
                                   // This OR wouldn't be needed but we introduced the permission handling later and the localNetworkPerm can't be read on iOS.
                                   // If there are configured hosts, it means that we actally already have the permission even though PlatformPermissions thinks we wouldn't...
                                   // So skipping the check in that case for now (1.6)
                                   || configuredHostsModel.count > 0)

                    }

                    readonly property alias pageStack: _pageStack
                    StackView {
                        id: _pageStack
                        objectName: "pageStack"
                        anchors.fill: parent
                        initialItem: Page {}
                    }

                    Component.onCompleted: {
                        if (configuredHost.uuid.toString() !== "{00000000-0000-0000-0000-000000000000}") {
                            print("Configured host id is", configuredHost.uuid)
                            var cachedHost = nymeaDiscovery.nymeaHosts.find(configuredHost.uuid);
                            if (cachedHost) {
                                engine.jsonRpcClient.connectToHost(cachedHost)
                                return;
                            }
                            console.warn("There is a last connected host but UUID is unknown to discovery...")
                        } else if (autoConnectHost.length > 0 && index === 0) {
                            var host = nymeaDiscovery.nymeaHosts.createLanHost(Configuration.systemName, autoConnectHost);
                            engine.jsonRpcClient.connectToHost(host)

                            return;
                        } else {
                            // Only hide the splash right away if we're not trying to connect to something
                            // If it's not hidden here it will be hidden in 3 seconds or when the connection is up, whichever comes first
                            PlatformHelper.hideSplashScreen();
                        }

                        pageStack.push(Configuration.connectionWizard, StackView.Immediate)
                    }

                    Timer { running: true; repeat: false; interval: 3000; onTriggered: PlatformHelper.hideSplashScreen(); }

                    function init() {
                        print("calling init. Auth required:", engine.jsonRpcClient.authenticationRequired, "initial setup required:", engine.jsonRpcClient.initialSetupRequired, "jsonrpc connected:", engine.jsonRpcClient.connected, "Current host:", engine.jsonRpcClient.currentHost)
                        pageStack.clear()
//                        var page = pageStack.push(Qt.resolvedUrl("connection/ConnectingPage.qml"));
//                        return

                        if (!engine.jsonRpcClient.currentHost) {
                            print("pushing ConnectPage")
                            pageStack.push(Configuration.connectionWizard)
                            PlatformHelper.hideSplashScreen();
                            return;
                        }

                        if (engine.jsonRpcClient.authenticationRequired || engine.jsonRpcClient.initialSetupRequired) {
                            PlatformHelper.hideSplashScreen();
                            if (engine.jsonRpcClient.pushButtonAuthAvailable) {
                                print("opening push button auth")
                                var page = pageStack.push(Qt.resolvedUrl("PushButtonAuthPage.qml"))
                                page.backPressed.connect(function() {
                                    engine.jsonRpcClient.disconnectFromHost();
                                    init();
                                })
                                return;
                            } else {
                                if (engine.jsonRpcClient.initialSetupRequired) {
                                    var page = pageStack.push(Qt.resolvedUrl("connection/SetupWizard.qml"));
                                    page.backPressed.connect(function() {
                                        engine.jsonRpcClient.disconnectFromHost()
                                        init();
                                    })
                                    return;
                                }

                                var page = pageStack.push(Qt.resolvedUrl("connection/LoginPage.qml"));
                                page.backPressed.connect(function() {
                                    engine.jsonRpcClient.disconnectFromHost()
                                    init();
                                })
                                return;
                            }
                        }

                        if (engine.jsonRpcClient.connected) {
                            print("Connected to", engine.jsonRpcClient.currentHost.uuid, engine.jsonRpcClient.currentHost.name)
                            pageStack.push(Qt.resolvedUrl("MainPage.qml"))
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

                    // New, nymea thing based push notifactions
                    function updatePushNotificationThings() {
                        if (PushNotifications.service == "") {
                            print("This platform does not support push notifications")
                            return;
                        }
                        if (!PushNotifications.token) {
                            print("No push notification token available at this time. Not updating...");
                            return;
                        }

                        var clientId = PushNotifications.clientId + "+" + Configuration.appId
                        print("Updating push notifications")
                        print("Own push service:", PushNotifications.service);
                        print("Own client ID:", clientId);
                        print("Current token:", PushNotifications.token);


                        for (var i = 0; i < engine.thingManager.things.count; i++) {
                            var thing = engine.thingManager.things.get(i);
                            if (thing.thingClass.id.toString().match(/\{?f0dd4c03-0aca-42cc-8f34-9902457b05de\}?/)) {
                                var serviceParam = thing.paramByName("service");
                                var clientIdParam = thing.paramByName("clientId")
                                var tokenParam = thing.paramByName("token")
                                print("Found a push notification thing for client id:", clientIdParam.value)
                                if (clientIdParam.value === clientId) {
                                    if (PlatformPermissions.notificationsPermission !== PlatformPermissions.PermissionStatusGranted) {
                                        PlatformPermissions.requestPermission(PlatformPermissions.PermissionNotifications)
                                    }

                                    if (tokenParam.value !== PushNotifications.token) {
                                        var params = [
                                                    { "paramTypeId": serviceParam.paramTypeId, "value": PushNotifications.service },
                                                    { "paramTypeId": clientIdParam.paramTypeId, "value": clientId },
                                                    { "paramTypeId": tokenParam.paramTypeId, "value": PushNotifications.token }
                                                ];
                                        print("Reconfiguring PushNotifications for", thing.name)
                                        engine.thingManager.reconfigureThing(thing.id, params);
                                    } else {
                                        print("Push notifications don't need to be updated. Token is valid.")
                                    }
                                }
                            }
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
                                engine.jsonRpcClient.connectToHost(nymeaDiscovery.nymeaHosts.find(serverUuid));
                            })
                            popup.open();
                        }
                        onConnectedChanged: {
                            print("json client connected changed", engine.jsonRpcClient.connected, engine.jsonRpcClient.serverUuid)
                            if (engine.jsonRpcClient.connected) {
                                nymeaDiscovery.cacheHost(engine.jsonRpcClient.currentHost)
                                configuredHost.uuid = engine.jsonRpcClient.serverUuid

                                for (var i = 0; i < configuredHostsModel.count; i++) {
                                    if (i != index && configuredHostsModel.get(i).uuid == engine.jsonRpcClient.serverUuid) {
                                        configuredHostsModel.removeHost(i);
                                        break;
                                    }
                                }
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

                        onInvalidMinimumVersion: {
                            var popup = invalidVersionComponent.createObject(app.contentItem);
                            popup.actualVersion = actualVersion;
                            popup.minVersion = minVersion;
                            popup.open()
                        }
                        onInvalidMaximumVersion: {
                            var popup = invalidVersionComponent.createObject(app.contentItem);
                            popup.actualVersion = actualVersion;
                            popup.maxVersion = maxVersion;
                            popup.open()
                        }
                        onInvalidServerUuid: {
                            var connection = engine.jsonRpcClient.currentConnection;
                            engine.jsonRpcClient.disconnectFromHost();
                            engine.jsonRpcClient.currentHost.connections.removeConnection(connection);
                            nymeaDiscovery.cacheHost(engine.jsonRpcClient.currentHost);
                        }
                    }

                    Connections {
                        target: engine.nymeaConfiguration
                        onFetchingDataChanged: {
                            print("fetching NymeaConfigration:", engine.nymeaConfiguration.fetchingData)
                            if (!engine.nymeaConfiguration.fetchingData) {
                                syncRemoteConnection()
                            }
                        }
                    }
                    Connections {
                        target: engine.nymeaConfiguration.tunnelProxyServerConfigurations
                        onCountChanged: {
                            print("tunnel proxy count changed:", engine.nymeaConfiguration.tunnelProxyServerConfigurations.count)
                            if (!engine.nymeaConfiguration.fetchingData) {
                                syncRemoteConnection();
                            }
                        }
                    }

                    function syncRemoteConnection() {
                        if (engine.jsonRpcClient.currentConnection.url.toString().startsWith("tunnel")) {
                            // Not resyncing tunnel configurations while we're connected through a tunnel ourselves
                            // (We could, maybe even should, but currently libnymea-app borrows the "NymeaHost" pointer from
                            // the hostsmodel and will crash if we delete the used Connection object)
                            return;
                        }

                        for (var i = 0; i < engine.jsonRpcClient.currentHost.connections.count; i++) {
                            var connection = engine.jsonRpcClient.currentHost.connections.get(i)
                            if (connection.url.toString().startsWith("tunnel")) {
                                console.log("Removing tunnel proxy connection:", connection.url)
                                engine.jsonRpcClient.currentHost.connections.removeConnection(i--);
                            }
                        }

                        for (var i = 0; i < engine.nymeaConfiguration.tunnelProxyServerConfigurations.count; i++) {
                            var tunnelProxyConfig = engine.nymeaConfiguration.tunnelProxyServerConfigurations.get(i);
                            console.debug("tunnelProxyConfig:", JSON.stringify(tunnelProxyConfig))
                            var url = tunnelProxyConfig.sslEnabled ? "tunnels://" : "tunnel://";
                            url += tunnelProxyConfig.address
                            url += ":" + tunnelProxyConfig.port
                            url += "?uuid=" + engine.jsonRpcClient.currentHost.uuid
                            console.info("Adding tunnel proxy connection:", url)
                            engine.jsonRpcClient.currentHost.connections.addConnection(url, Connection.BearerTypeCloud, tunnelProxyConfig.sslEnabled, "Remote proxy connection", true);
                        }
                        nymeaDiscovery.cacheHost(engine.jsonRpcClient.currentHost)
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
                        target: engine.thingManager
                        onFetchingDataChanged: {
                            if (!engine.thingManager.fetchingData) {
                                processPendingPushNotificationActions();
                                updatePushNotificationThings()
                            }
                            PlatformHelper.hideSplashScreen();
                        }
                    }

                    Connections {
                        target: PlatformHelper
                        onPendingNotificationActionsChanged: {
                            processPendingPushNotificationActions()
                        }
                    }
                    function processPendingPushNotificationActions() {
                        print("pending notification actions changed:", PlatformHelper.pendingNotificationActions)
                        if (PlatformHelper.pendingNotificationActions.length > 0) {
                            var notificationAction = PlatformHelper.pendingNotificationActions[0]
                            if (notificationAction.serverUuid.replace(/[{]]/g, "") !== engine.jsonRpcClient.serverUuid.toString().replace(/[{}]/g, "")) {
                                print("notification action for different server")
                                return;
                            }
                            print("handling action", JSON.stringify(notificationAction))

                            if (notificationAction.dataMap.hasOwnProperty("open")) {
                                // It could be just a thing ID
                                var target = notificationAction.dataMap["open"]
                                var thing = engine.thingManager.things.getThing(target)
                                if (thing) {
                                    print("opening thing:", thing.name)
                                    pageStack.push("/ui/devicepages/" + NymeaUtils.interfaceListToDevicePage(thing.thingClass.interfaces), {thing: thing})
                                } else {
                                    // or a view name
                                    console.log("going to main view:", target)
                                    pageStack.currentItem.goToView(target, notificationAction.dataMap)
                                }
                            }

                            if (notificationAction.dataMap.hasOwnProperty("execute")) {
                                var action = notificationAction.dataMap["execute"]
                                var thingId = notificationAction.dataMap["thingId"]
                                var actionParams = JSON.parse(notificationAction.dataMap["actionParams"])
                                print("executing:", thingId, action, actionParams)
                                engine.thingManager.things.getThing(thingId).executeAction(action, actionParams);
                            }


                            PlatformHelper.notificationActionHandled(notificationAction.id)
                        }
                    }


                    Component {
                        id: invalidVersionComponent
                        Popup {
                            id: popup

                            property string actualVersion: ""
                            property string minVersion: ""
                            property string maxVersion: ""

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
                                    text: popup.minVersion != ""
                                          ? qsTr("The version of the %1 system you are trying to connect to is too old. This app requires at least API version %2 but this %1 system only supports API version %3. Please update your %1 system.").arg(Configuration.systemName).arg(popup.minVersion).arg(popup.actualVersion)
                                          : qsTr("The version of the %1 system you are trying to connect to is too new. This app supports only up to API version %2 but this %1 system provides API version %3. Please update %4.").arg(Configuration.systemName).arg(popup.maxVersion).arg(popup.actualVersion).arg(Configuration.appName)
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
            Layout.fillWidth: true
            visible: settings.showConnectionTabs
            spacing: 0

            TabBar {
                id: tabbar
                Layout.fillWidth: true
                Material.elevation: 2
                position: TabBar.Footer
                currentIndex: configuredHostsModel.currentIndex

                Repeater {
                    model: configuredHostsModel

                    delegate: TabButton {
                        id: hostTabButton
                        readonly property ConfiguredHost configuredHost: configuredHostsModel.get(index)
                        Material.elevation: index
                        width: Math.max(150, tabbar.width / configuredHostsModel.count)

                        Rectangle {
                            anchors.fill: parent
                            color: Material.foreground
                            opacity: 0.06
                        }

                        contentItem: Label {
                            Layout.fillWidth: true
                            text: hostTabButton.configuredHost.name !== "" ? hostTabButton.configuredHost.name : qsTr("New connection")
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        onClicked: {
                            configuredHostsModel.currentIndex = index
                        }
                    }
                }
            }
        }
    }
}
