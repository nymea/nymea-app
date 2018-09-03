import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "components"

Item {
    id: root

    // Workaround flickering on pageStack animations when the white background shines through
    Rectangle {
        anchors.fill: parent
        color: Material.background
    }

    ListModel {
        id: tabModel
        Component.onCompleted: {
            append({})
        }
        function addTab() {
            settings.lastConnectedHost = ""
            tabModel.append({})
        }
    }

    ColumnLayout {
        anchors.fill: parent

        SwipeView {
            id: swipeView
            Layout.fillHeight: true
            Layout.fillWidth: true
            interactive: false

            Repeater {
                id: mainRepeater
                model: tabModel

                delegate: StackView {
                    id: pageStack
                    height: swipeView.height
                    width: swipeView.width
                    objectName: "pageStack"
                    initialItem: Page {}

                    Engine {
                        id: engine
                    }
                    property alias _engine: engine

                    Component.onCompleted: {
                        pageStack.push(Qt.resolvedUrl("connection/ConnectPage.qml"))
                        setupPushNotifications();
                    }

                    function init() {
                        print("calling init. Auth required:", engine.jsonRpcClient.authenticationRequired, "initial setup required:", engine.jsonRpcClient.initialSetupRequired, "jsonrpc connected:", engine.jsonRpcClient.connected)
                        pageStack.clear()
                        if (!engine.connection.connected) {
                            pageStack.push(Qt.resolvedUrl("connection/ConnectPage.qml"))
                            return;
                        }

                        if (engine.jsonRpcClient.authenticationRequired || engine.jsonRpcClient.initialSetupRequired) {
                            if (engine.jsonRpcClient.pushButtonAuthAvailable) {
                                print("opening push button auth")
                                var page = pageStack.push(Qt.resolvedUrl("PushButtonAuthPage.qml"))
                                page.backPressed.connect(function() {
                                    settings.lastConnectedHost = "";
                                    engine.connection.disconnect();
                                    init();
                                })
                            } else {
                                var page = pageStack.push(Qt.resolvedUrl("LoginPage.qml"));
                                page.backPressed.connect(function() {
                                    settings.lastConnectedHost = "";
                                    engine.connection.disconnect()
                                    init();
                                })
                            }
                        } else if (engine.jsonRpcClient.connected) {
                            pageStack.push(Qt.resolvedUrl("MainPage.qml"))
                        } else {
                            pageStack.push(Qt.resolvedUrl("connection/ConnectPage.qml"))
                        }
                    }

                    function handleCloseEvent(close) {
                        if (Qt.platform.os == "android") {
                            // If we're connected, allow going back up to MainPage
                            if ((engine.jsonRpcClient.connected && pageStack.depth > 1)
                                    // if we're not connected, only allow using the back button in wizards
                                    || (!engine.jsonRpcClient.connected && pageStack.depth > 3)) {
                                close.accepted = false;
                                pageStack.pop();
                            }
                        }
                    }                    

                    function setupPushNotifications(askForPermissions) {
                        if (askForPermissions === undefined) {
                            askForPermissions = true;
                        }

                        if (!engine.awsClient.isLoggedIn) {
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
                            engine.awsClient.registerPushNotificationEndpoint(PushNotifications.token, PlatformHelper.deviceManufacturer + " " + PlatformHelper.deviceModel, PlatformHelper.deviceSerial + "+io.guh.nymeaapp");
                        }
                    }

                    Connections {
                        target: engine.jsonRpcClient
                        onConnectedChanged: {
                            print("json client connected changed", engine.jsonRpcClient.connected)
                            if (engine.jsonRpcClient.connected) {
                                settings.lastConnectedHost = engine.connection.url
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
                            settings.lastConnectedHost = ""
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
                        target: engine.awsClient
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
                                    text: qsTr("Sorry, the version of the %1 box you are trying to connect to is too old. This app requires at least version %2 but the %1 box only supports %3").arg(app.systemName).arg(popup.minimumVersion).arg(popup.actualVersion)
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                                Button {
                                    Layout.fillWidth: true
                                    text: qsTr("OK")
                                    onClicked: {
                                        engine.connection.disconnect();
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
            visible: app.showConnectionTabs

            TabBar {
                id: tabbar
                Layout.fillWidth: true

                Repeater {
                    model: mainRepeater.count

                    delegate: TabButton {
                        id: hostTabButton
                        property var engine: mainRepeater.itemAt(index)._engine
                        property string serverName: engine.basicConfiguration.serverName

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
                                    onClicked: tabModel.remove(index)
                                }
                            }
                        }

                        onClicked: {
                            swipeView.currentIndex = index
                        }
                    }
                }
            }

            TabButton {
                Layout.preferredWidth: height
                contentItem: ColorIcon {
                    height: parent.height
                    width: parent.width
                    name: "../images/add.svg"
                }
                onClicked: {
                    tabModel.addTab()
                }
            }
        }
    }
}
