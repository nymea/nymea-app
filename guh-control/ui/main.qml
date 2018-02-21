import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Qt.labs.settings 1.0
import Guh 1.0

ApplicationWindow {
    id: app
    visible: true
    width: 270 * 1.5
    height: 480 * 1.5
    visibility: settings.viewMode


    property color guhAccent: "#ff57baae"
//    Material.primary: "#ff57baae"
    Material.primary: "white"
    Material.accent: guhAccent

    property int margins: 14
    property int bigMargins: 20
    property int smallFont: 14
    property int mediumFont: 16
    property int largeFont: 20
    property int iconSize: 30
    property int delegateHeight: 60

    Settings {
        id: settings
        property string lastConnectedHost: ""
        property int viewMode: ApplicationWindow.Maximized
        property bool returnToHome: false
        property string graphStyle: "bars"
    }

    Component.onCompleted: {
        pageStack.push(Qt.resolvedUrl("ConnectPage.qml"))
        discovery.discovering = true
    }

    Connections {
        target: Engine.jsonRpcClient
        onConnectedChanged: {
            print("json client connected changed")
            if (Engine.jsonRpcClient.connected) {
                settings.lastConnectedHost = Engine.connection.url
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

    function init() {
        pageStack.clear()
        discovery.discovering = false;
        if (Engine.jsonRpcClient.authenticationRequired || Engine.jsonRpcClient.initialSetupRequired) {
            var page = pageStack.push(Qt.resolvedUrl("LoginPage.qml"));
            page.backPressed.connect(function() {
                settings.lastConnectedHost = "";
                Engine.connection.disconnect()
            })
        } else if (Engine.jsonRpcClient.connected) {
            pageStack.push(Qt.resolvedUrl("MainPage.qml"))
        } else {
            pageStack.push(Qt.resolvedUrl("ConnectPage.qml"))
            print("starting discovery")
            discovery.discovering = true;
        }
    }

    StackView {
        id: pageStack
        anchors.fill: parent
        initialItem: Page {}
    }

    GuhDiscovery {
        id: discovery
    }

    Connections {
        target: Qt.application
        enabled: Engine.jsonRpcClient.connected && settings.returnToHome
        onStateChanged: {
            print("App active state changed:", state)
            if (state !== Qt.ApplicationActive) {
                init();
            }
        }
    }

    function interfaceToString(name) {
        switch(name) {
        case "light":
            return "Lighting"
        case "weather":
            return "Weather"
        case "sensor":
            return "Sensors"
        case "media":
            return "Media"
        case "button":
            return "Switches"
        case "gateway":
            return "Gateways"
        case "notifications":
            return "Notifications"
        case "temperaturesensor":
            return "Temperature";
        case "humiditysensor":
            return "Humidity";
        }
    }

    function interfaceToIcon(name) {
        switch (name) {
        case "light":
        case "colorlight":
        case "dimmablelight":
            return Qt.resolvedUrl("images/torch-on.svg")
        case "sensor":
            return Qt.resolvedUrl("images/sensors.svg")
        case "media":
        case "mediacontroller":
            return Qt.resolvedUrl("images/mediaplayer-app-symbolic.svg")
        case "button":
        case "longpressbutton":
        case "multibutton":
        case "longpressmultibutton":
            return Qt.resolvedUrl("images/system-shutdown.svg")
        case "weather":
            return Qt.resolvedUrl("images/weather-app-symbolic.svg")
        case "temperaturesensor":
            return Qt.resolvedUrl("images/temperature.svg")
        case "humiditysensor":
            return Qt.resolvedUrl("images/weathericons/humidity.svg")
        case "gateway":
            return Qt.resolvedUrl("images/network-wired-symbolic.svg")
        case "notifications":
            return Qt.resolvedUrl("images/notification.svg")
        }
    }

    function interfaceToColor(name) {
        switch (name) {
        case "temperaturesensor":
            return "red";
        case "humiditysensor":
            return "deepskyblue";
        }
        return "grey";
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
                    text: "Connection error"
                    Layout.fillWidth: true
                    font.pixelSize: app.largeFont
                }
                Label {
                    text: qsTr("Sorry, the version of the guh box you are trying to connect to is too old. This app requires at least version %1 but the guh box only supports %2").arg(popup.minimumVersion).arg(popup.actualVersion)
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
                Button {
                    Layout.fillWidth: true
                    text: "OK"
                    onClicked: {
                        Engine.connection.disconnect();
                        popup.close()
                    }
                }
            }
        }
    }
}
