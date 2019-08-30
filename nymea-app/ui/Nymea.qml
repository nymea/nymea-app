import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Qt.labs.settings 1.0
import QtQuick.Window 2.3
import Nymea 1.0

ApplicationWindow {
    id: app
    visible: true
    width: 360
    height: 580
    minimumWidth: 360
    minimumHeight: 480
    visibility: kioskMode ? ApplicationWindow.FullScreen : settings.viewMode

    // Those variables must be present in the Style
    title: appName
    Material.primary: primaryColor
    Material.accent: accentColor
    Material.foreground: foregroundColor

    property int margins: 16
    property int bigMargins: 20
    property int extraSmallFont: 10
    property int smallFont: 13
    property int mediumFont: 16
    property int largeFont: 20
    property int iconSize: 30
    property int delegateHeight: 60

    readonly property bool landscape: app.width > app.height

    readonly property var settings: Settings {
        property int viewMode: ApplicationWindow.AutomaticVisibility
        property alias windowWidth: app.width
        property alias windowHeight: app.height
        property bool returnToHome: false
        property string graphStyle: "bars"
        property string style: "light"
        property bool showHiddenOptions: false
        property string cloudEnvironment: "Community"
        property bool showConnectionTabs: false
        property int tabCount: 1
    }

    property string privacyPolicyUrl: "https://nymea.io/privacy-statement/en/nymea_privacy.html"

    Component.onCompleted: {
        styleController.setSystemFont(app.font)
    }

    RootItem {
        id: rootItem
        anchors.fill: parent
        anchors.bottomMargin: keyboardRect.height
    }

    NymeaDiscovery {
        id: discovery
        objectName: "discovery"
        awsClient: AWSClient
//        discovering: pageStack.currentItem.objectName === "discoveryPage"
    }
    property alias _discovery: discovery

    property var supportedInterfaces: ["light", "weather", "media", "garagegate", "awning", "shutter", "blind", "powersocket", "heating", "doorbell", "sensor", "smartmeter", "evcharger", "accesscontrol", "button", "notifications", "inputtrigger", "outputtrigger", "gateway"]
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
        case "powerswitch":
            return qsTr("Switches")
        case "gateway":
            return qsTr("Gateways")
        case "notifications":
            return qsTr("Notifications")
        case "temperaturesensor":
            return qsTr("Temperature");
        case "humiditysensor":
            return qsTr("Humidity");
        case "pressuresensor":
            return qsTr("Pressure");
        case "noisesensor":
            return qsTr("Noise level");
        case "co2sensor":
            return qsTr("CO2 level")
        case "inputtrigger":
            return qsTr("Incoming Events");
        case "outputtrigger":
            return qsTr("Events");
        case "shutter":
        case "extendedshutter":
            return qsTr("Shutters");
        case "blind":
        case "extendedblind":
            return qsTr("Blinds");
        case "awning":
        case "extendedawning":
            return qsTr("Awnings");
        case "garagegate":
            return qsTr("Garage gates");
        case "accesscontrol":
            return qsTr("Access control");
        case "smartmeter":
        case "smartmeterproducer":
        case "smartmeterconsumer":
        case "extendedsmartmeterproducer":
        case "extendedsmartmeterconsumer":
            return qsTr("Smart meters");
        case "heating":
            return qsTr("Heatings");
        case "evcharger":
            return qsTr("EV-chargers");
        case "powersocket":
            return qsTr("Power sockets")
        case "doorbell":
            return qsTr("Doorbells");
        case "uncategorized":
            return qsTr("Uncategorized")
        default:
            console.warn("interfaceToString unhandled interface:", name)
        }
        return ""
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
        case "colortemperaturelight":
            return Qt.resolvedUrl("images/light-on.svg")
        case "sensor":
            return Qt.resolvedUrl("images/sensors.svg")
        case "temperaturesensor":
            return Qt.resolvedUrl("images/sensors/temperature.svg")
        case "humiditysensor":
            return Qt.resolvedUrl("images/sensors/humidity.svg")
        case "moisturesensor":
            return Qt.resolvedUrl("images/sensors/moisture.svg")
        case "lightsensor":
            return Qt.resolvedUrl("images/sensors/light.svg")
        case "conductivitysensor":
            return Qt.resolvedUrl("images/sensors/conductivity.svg")
        case "pressuresensor":
            return Qt.resolvedUrl("images/sensors/pressure.svg")
        case "noisesensor":
            return Qt.resolvedUrl("images/sensors/noise.svg");
        case "co2sensor":
            return Qt.resolvedUrl("images/sensors/co2.svg")
        case "daylightsensor":
            return Qt.resolvedUrl("images/sensors/light.svg")
        case "presencesensor":
            return Qt.resolvedUrl("images/sensors/presence.svg")
        case "closablesensor":
            return Qt.resolvedUrl("images/sensors/closable.svg")
        case "media":
        case "mediacontroller":
            return Qt.resolvedUrl("images/mediaplayer-app-symbolic.svg")
        case "powersocket":
            return Qt.resolvedUrl("images/powersocket.svg")
        case "button":
        case "longpressbutton":
        case "simplemultibutton":
        case "longpressmultibutton":
        case "powerswitch":
            return Qt.resolvedUrl("images/system-shutdown.svg")
        case "weather":
            return Qt.resolvedUrl("images/weather-app-symbolic.svg")
        case "gateway":
            return Qt.resolvedUrl("images/network-wired.svg")
        case "notifications":
            return Qt.resolvedUrl("images/messaging-app-symbolic.svg")
        case "inputtrigger":
            return Qt.resolvedUrl("images/attention.svg")
        case "outputtrigger":
            return Qt.resolvedUrl("images/send.svg")
        case "shutter":
        case "extendedshutter":
            return Qt.resolvedUrl("images/DeviceIconRollerShutter.svg")
        case "blind":
        case "extendedblind":
            return Qt.resolvedUrl("images/DeviceIconBlind.svg")
        case "garagegate":
            return Qt.resolvedUrl("images/shutter/shutter-100.svg")
        case "awning":
        case "extendedawning":
            return Qt.resolvedUrl("images/awning/awning-100.svg")
        case "battery":
            return Qt.resolvedUrl("images/battery/battery-050.svg")
        case "uncategorized":
            return Qt.resolvedUrl("images/select-none.svg")
        case "simpleclosable":
            return Qt.resolvedUrl("images/sort-listitem.svg")
        case "fingerprintreader":
            return Qt.resolvedUrl("images/fingerprint.svg")
        case "accesscontrol":
            return Qt.resolvedUrl("images/lock-closed.svg");
        case "smartmeter":
        case "smartmeterconsumer":
        case "smartmeterproducer":
        case "extendedsmartmeterconsumer":
        case "extendedsmartmeterproducer":
            return Qt.resolvedUrl("images/smartmeter.svg")
        case "heating":
        case "extendedheating":
            return Qt.resolvedUrl("images/radiator.svg")
        case "thermostat":
            return Qt.resolvedUrl("images/dial.svg")
        case "evcharger":
        case "extendedevcharger":
            return Qt.resolvedUrl("images/ev-charger.svg")
        case "doorbell":
            return Qt.resolvedUrl("images/notification.svg")
        case "connectable":
            return Qt.resolvedUrl("images/stock_link.svg")
        case "power":
            return Qt.resolvedUrl("images/system-shutdown.svg")
        default:
            console.warn("InterfaceToIcon: Unhandled interface", name)
        }
        return "";
    }

    property var fallbackColors: {
        "temperaturesensor": "red",
        "humiditysensor": "deepskyblue",
        "moisturesensor":"blue",
        "lightsensor": "orange",
        "conductivitysensor": "green",
        "pressuresensor": "grey",
        "noisesensor": "darkviolet",
        "co2sensor": "turquoise",
        "daylightsensor": "gold",
        "presencesensor": "darkblue",
        "closablesensor": "green",
        "smartmeterproducer": "lightgreen",
        "smartmeterconsumer": "orange",
        "extendedsmartmeterproducer": "blue",
        "extendedsmartmeterconsumer": "blue",
        "heating" : "gainsboro",
        "thermostat": "dodgerblue"
    }

    function interfaceToColor(name) {
        // Try to load color map from style
        if (interfaceColors[name]) {
            return interfaceColors[name];
        }

        if (fallbackColors[name]) {
            return fallbackColors[name];
        }

        return "grey";
    }

    function interfaceToDisplayName(name) {
        switch (name) {
        case "light":
            return qsTr("light")
        case "button":
            return "button";
        case "sensor":
            return qsTr("sensor")
        case "battery":
            return qsTr("battery powered thing")
        case "connectable":
            return qsTr("connectable thing")
        case "power":
            return qsTr("switchable thing")
        case "daylightsensor":
            return qsTr("daylight sensor")
        case "presencesensor":
            return qsTr("presence sensor")
        case "doorbell":
            return qsTr("doorbell")
        case "alert":
            return qsTr("alert")
        case "simplemultibutton":
        case "simplebutton":
            return qsTr("button")
        case "accesscotrol":
            return qsTr("access control")
        case "smartmeter":
        case "smartmeterproducer":
        case "smartmeterconsumer":
        case "extendedsmartmeterproducer":
        case "extendedsmartmeterconsumer":
            return qsTr("smart meter");
        default:
            console.warn("Unhandled interfaceToDisplayName:", name)
        }
    }

    function interfaceListToDevicePage(interfaceList) {
        var page;
        if (interfaceList.indexOf("media") >= 0) {
            page = "MediaDevicePage.qml";
        } else if (interfaceList.indexOf("button") >= 0) {
            page = "ButtonDevicePage.qml";
        } else if (interfaceList.indexOf("powerswitch") >= 0) {
            page = "ButtonDevicePage.qml";
        } else if (interfaceList.indexOf("weather") >= 0) {
            page = "WeatherDevicePage.qml";
        } else if (interfaceList.indexOf("heating") >= 0 || interfaceList.indexOf("thermostat") >= 0) {
            page = "HeatingDevicePage.qml";
        } else if (interfaceList.indexOf("sensor") >= 0) {
            page = "SensorDevicePage.qml";
        } else if (interfaceList.indexOf("inputtrigger") >= 0) {
            page = "InputTriggerDevicePage.qml";
        } else if (interfaceList.indexOf("garagegate") >= 0 ) {
            page = "GarageGateDevicePage.qml";
        } else if (interfaceList.indexOf("light") >= 0) {
            page = "LightDevicePage.qml";
        } else if (interfaceList.indexOf("shutter") >= 0  || interfaceList.indexOf("blind") >= 0) {
            page = "ShutterDevicePage.qml";
        } else if (interfaceList.indexOf("awning") >= 0) {
            page = "AwningDevicePage.qml";
        } else if (interfaceList.indexOf("notifications") >= 0) {
            page = "NotificationsDevicePage.qml";
        } else if (interfaceList.indexOf("fingerprintreader") >= 0) {
            page = "FingerprintReaderDevicePage.qml";
        } else if (interfaceList.indexOf("smartmeter") >= 0) {
            page = "SmartMeterDevicePage.qml"
        } else if (interfaceList.indexOf("powersocket") >= 0) {
            page = "PowersocketDevicePage.qml";
        } else if (interfaceList.indexOf("doorbell") >= 0) {
            page = "DoorbellDevicePage.qml";
        } else {
            page = "GenericDevicePage.qml";
        }
        print("Selecting page", page, "for interface list:", interfaceList)
        return page;
    }

    function pad(num, size) {
        var s = "000000000" + num;
        return s.substr(s.length-size);
    }

    // Handle the Android close event that happens when the back button is pressed
    // It's hard to handle the key press, because we might not have focus all the time
    // So let's handle the window's onClosing signal instad.
    // The problem is, we cannot distinguish between the back button being pressed
    // or the bottom swipe gesture is being used to switch apps. Let's try to figure that out
    // by checking if the app becomes inactive right after the event. If not, it's probably a back
    // button press and we close ourselves.
    onClosing: {
        if (Qt.platform.os == "android") {
            var handled = rootItem.handleAndroidBackButton();
            if (!handled) {
                closeTimer.start()
            }
            close.accepted = false;
        }
    }
    Timer {
        id: closeTimer
        interval: 300
        onTriggered: Qt.quit();
    }
    Connections {
        target: Qt.application
        onStateChanged: closeTimer.stop()
    }


    KeyboardLoader {
        id: keyboardRect
        anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
    }
}
