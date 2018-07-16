import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Qt.labs.settings 1.0
import Nymea 1.0

ApplicationWindow {
    id: app
    visible: true
    width: 360
    height: 580
    visibility: ApplicationWindow.Maximized
    font: Qt.application.font
    title: appName

    property int margins: 14
    property int bigMargins: 20
    property int extraSmallFont: 10
    property int smallFont: 13
    property int mediumFont: 16
    property int largeFont: 20
    property int iconSize: 30
    property int delegateHeight: 60

    property bool landscape: app.width > app.height

    property var settings: Settings {
        property string lastConnectedHost: ""
        property alias viewMode: app.visibility
        property bool returnToHome: false
        property bool darkTheme: false
        property string graphStyle: "bars"
        property string style: "light"
        property int currentMainViewIndex: 0
    }

    Component.onCompleted: {
        pageStack.push(Qt.resolvedUrl("ConnectPage.qml"))
    }

    Connections {
        target: Engine.jsonRpcClient
        onConnectedChanged: {
            print("json client connected changed", Engine.jsonRpcClient.connected)
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
        print("calling init. Auth required:", Engine.jsonRpcClient.authenticationRequired, "initial setup required:", Engine.jsonRpcClient.initialSetupRequired, "jsonrpc connected:", Engine.jsonRpcClient.connected)
        pageStack.clear()
        if (!Engine.connection.connected) {
            pageStack.push(Qt.resolvedUrl("ConnectPage.qml"))
            return;
        }

        if (Engine.jsonRpcClient.authenticationRequired || Engine.jsonRpcClient.initialSetupRequired) {
            if (Engine.jsonRpcClient.pushButtonAuthAvailable) {
                print("opening push button auth")
                var page = pageStack.push(Qt.resolvedUrl("PushButtonAuthPage.qml"))
                page.backPressed.connect(function() {
                    settings.lastConnectedHost = "";
                    Engine.connection.disconnect();
                    init();
                })
            } else {
                var page = pageStack.push(Qt.resolvedUrl("LoginPage.qml"));
                page.backPressed.connect(function() {
                    settings.lastConnectedHost = "";
                    Engine.connection.disconnect()
                    init();
                })
            }
        } else if (Engine.jsonRpcClient.connected) {
            pageStack.push(Qt.resolvedUrl("MainPage.qml"))
        } else {
            pageStack.push(Qt.resolvedUrl("ConnectPage.qml"))
        }
    }

    // Workaround flickering on pageStack animations when the white background shines through
    Rectangle {
        anchors.fill: parent
        color: Material.background
    }

    StackView {
        id: pageStack
        objectName: "pageStack"
        anchors.fill: parent
        initialItem: Page {}
    }

    onClosing: {
        if (Qt.platform.os == "android") {
            // If we're connected, allow going back up to MainPage
            if ((Engine.jsonRpcClient.connected && pageStack.depth > 1)
                    // if we're not connected, only allow using the back button in wizards
                    || (!Engine.jsonRpcClient.connected && pageStack.depth > 3)) {
                close.accepted = false;
                pageStack.pop();
            }
        }
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

    property var supportedInterfaces: ["light", "weather", "sensor", "media", "garagegate", "shutter", "garagegate", "button", "notifications", "inputtrigger", "outputtrigger", "gateway"]
    function interfaceToString(name) {
        switch(name) {
        case "light":
            return qsTr("Lighting")
        case "weather":
            return qsTr("Weather")
        case "sensor":
            return qsTr("Sensors")
        case "media":
            return qsTr("Media")
        case "button":
            return qsTr("Switches")
        case "gateway":
            return qsTr("Gateways")
        case "notifications":
            return qsTr("Notifications")
        case "temperaturesensor":
            return qsTr("Temperature");
        case "humiditysensor":
            return qsTr("Humidity");
        case "inputtrigger":
            return qsTr("Incoming Events");
        case "outputtrigger":
            return qsTr("Events");
        case "shutter":
            return qsTr("Shutters");
        case "blind":
            return qsTr("Blinds");
        case "garagegate":
            return qsTr("Garage gates");
        case "uncategorized":
            return qsTr("Uncategorized")
        }
    }

    function interfacesToIcon(interfaces) {
        for (var i = 0; i < interfaces.length; i++) {
            var icon = interfaceToIcon(interfaces[i]);
            if (icon !== "") {
                return icon;
            }
        }
        return Qt.resolvedUrl("images/select-none.svg")
    }

    function interfaceToIcon(name) {
        switch (name) {
        case "light":
        case "colorlight":
        case "dimmablelight":
            return Qt.resolvedUrl("images/torch-on.svg")
        case "sensor":
        case "temperaturesensor":
        case "humiditysensor":
            return Qt.resolvedUrl("images/sensors.svg")
        case "media":
        case "mediacontroller":
            return Qt.resolvedUrl("images/mediaplayer-app-symbolic.svg")
        case "button":
        case "longpressbutton":
        case "simplemultibutton":
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
        case "connectable":
            return Qt.resolvedUrl("images/stock_link.svg")
        case "inputtrigger":
            return Qt.resolvedUrl("images/mail-mark-important.svg")
        case "outputtrigger":
            return Qt.resolvedUrl("images/send.svg")
        case "shutter":
        case "blind":
            return Qt.resolvedUrl("images/sort-listitem.svg")
        case "garagegate":
            return Qt.resolvedUrl("images/shutter-10.svg")
        case "battery":
            return Qt.resolvedUrl("images/battery/battery-050.svg")
        case "uncategorized":
            return Qt.resolvedUrl("images/select-none.svg")
        }
        return "";
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

    function interfaceListToDevicePage(interfaceList) {
        var page;
        if (interfaceList.indexOf("media") >= 0) {
            page = "MediaDevicePage.qml";
        } else if (interfaceList.indexOf("button") >= 0) {
            page = "ButtonDevicePage.qml";
        } else if (interfaceList.indexOf("weather") >= 0) {
            page = "WeatherDevicePage.qml";
        } else if (interfaceList.indexOf("sensor") >= 0) {
            page = "SensorDevicePage.qml";
        } else if (interfaceList.indexOf("inputtrigger") >= 0) {
            page = "InputTriggerDevicePage.qml";
        } else if (interfaceList.indexOf("shutter") >= 0 ) {
            page = "ShutterDevicePage.qml";
        } else if (interfaceList.indexOf("garagegate") >= 0 ) {
            page = "GarageGateDevicePage.qml";
        } else if (interfaceList.indexOf("light") >= 0) {
            page = "ColorLightDevicePage.qml"
        } else {
            page = "GenericDevicePage.qml";
        }
        print("Selecting page", page, "for interface list:", interfaceList)
        return page;
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
                        Engine.connection.disconnect();
                        popup.close()
                    }
                }
            }
        }
    }
}
