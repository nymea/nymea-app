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
    visibility: ApplicationWindow.AutomaticVisibility
    font: Qt.application.font

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
        property alias viewMode: app.visibility
        property bool returnToHome: false
        property bool darkTheme: false
        property string graphStyle: "bars"
        property string style: "light"
        property int currentMainViewIndex: 0
        property bool showHiddenOptions: false
        property string cloudEnvironment: "community"
        property bool showConnectionTabs: false
        property int tabCount: 1
    }

    RootItem {
        id: rootItem
        anchors.fill: parent
    }

    onClosing: {
        rootItem.handleCloseEvent(close)
    }

    property var supportedInterfaces: ["light", "weather", "sensor", "media", "garagegate", "awning", "shutter", "blind", "accesscontrol", "button", "notifications", "inputtrigger", "outputtrigger", "gateway"]
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
        case "pressuresensor":
            return qsTr("Pressure");
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
            return Qt.resolvedUrl("images/sensors/temperature.svg")
        case "humiditysensor":
            return Qt.resolvedUrl("images/sensors/humidity.svg")
        case "gateway":
            return Qt.resolvedUrl("images/network-wired-symbolic.svg")
        case "notifications":
            return Qt.resolvedUrl("images/notification.svg")
        case "connectable":
            return Qt.resolvedUrl("images/stock_link.svg")
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
            return Qt.resolvedUrl("images/network-secure.svg");
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
        "pressuresensor": "grey"
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
        } else if (interfaceList.indexOf("weather") >= 0) {
            page = "WeatherDevicePage.qml";
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


    KeyboardLoader {
        id: keyboardRect
        anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
    }
}
