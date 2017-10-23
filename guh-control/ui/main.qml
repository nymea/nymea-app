import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import Qt.labs.settings 1.0
import Guh 1.0

ApplicationWindow {
    id: app
    visible: true
    width: 270 * 1.5
    height: 480 * 1.5

    property color guhAccent: "#ff57baae"
//    Material.primary: "#ff57baae"
    Material.primary: "white"
    Material.accent: guhAccent

    property int margins: 10
    property int bigMargins: 20
    property int smallFont: 10
    property int largeFont: 20
    property int iconSize: 30
    property int delegateHeight: 60

    Settings {
        id: settings
        property string lastConnectedHost: ""
    }

    Component.onCompleted: {
        pageStack.push(Qt.resolvedUrl("ConnectPage.qml"))
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
    }

    function init() {
        pageStack.clear()
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
        }
    }

    StackView {
        id: pageStack
        anchors.fill: parent
        initialItem: Page {}
    }

    UpnpDiscovery {
        id: discovery
    }

    function interfaceToString(name) {
        switch(name) {
        case "light":
            return "Lighting"
        case "weather":
            return "Weather"
        case "sensor":
            return "Sensor"
        case "media":
            return "Media"
        }
    }

    function interfaceToIcon(name) {
        switch (name) {
        case "light":
            return Qt.resolvedUrl("images/torch-on.svg")
        case "media":
            return Qt.resolvedUrl("images/media-preview-start.svg")
        }
    }

//    ZeroconfDiscovery {
//        id: discovery
//    }
}
