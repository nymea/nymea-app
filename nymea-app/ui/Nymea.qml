// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick.Controls.Material
import QtQuick.Controls
import QtQuick
import QtQuick.Layouts
import QtCore
import Qt.labs.folderlistmodel
import QtQuick.Window

import Nymea
import NymeaApp.Utils

ApplicationWindow {
    id: app
    visible: true
    width: Qt.platform.os === "ios" ? Screen.width : 360
    height: Qt.platform.os === "ios" ? Screen.height : 580
    minimumWidth: 350
    minimumHeight: 480
    visibility: kioskMode ? ApplicationWindow.FullScreen : settings.viewMode
    color: Material.background
    title: Configuration.appName

    Material.theme: NymeaUtils.isDark(Style.backgroundColor) ? Material.Dark : Material.Light
    Material.background: Style.backgroundColor
    Material.accent: Style.accentColor
    Material.foreground: Style.foregroundColor

    font.pixelSize: mediumFont
    font.weight: Font.Normal
    font.capitalization: Font.MixedCase
    font.family: Style.fontFamily

    Binding {
        target: PlatformHelper
        property: "topPanelColor"
        value: app.color
    }

    Binding {
        target: PlatformHelper
        property: "bottomPanelColor"
        value: app.color
    }

    property int margins: 16
    property int bigMargins: 20

    property int extraSmallFont: 10
    property int smallFont: 13
    property int mediumFont: 16
    property int largeFont: 20
    property int hugeFont: 40

    property int delegateHeight: 60

    readonly property bool landscape: app.width > app.height

    readonly property var settings: Settings {
        property int viewMode: ApplicationWindow.AutomaticVisibility
        property alias windowWidth: app.width
        property alias windowHeight: app.height
        property bool returnToHome: false
        property string graphStyle: "bars"
        property bool showHiddenOptions: false
        property string cloudEnvironment: "Community"
        // FIXME: This shouldn't be needed... we should probably only use the system locale and not even provide a setting
        // However, the topic is more complex, and in the long run we'd probably want to allow the user selecting the
        // desired unit for particular interfaces/things/views. See https://github.com/nymea/nymea/issues/386
        property string units: Qt.locale().measurementSystem === Locale.MetricSystem ? "metric" : "imperial"
    }

    property string privacyPolicyUrl: "https://nymea.io/privacy-statement/en/nymea_privacy.html"

    Component.onCompleted: {
        styleController.setSystemFont(app.font)
    }

    Binding {
        target: Types
        property: "unitSystem"
        value: settings.units === "metric" ? Types.UnitSystemMetric : Types.UnitSystemImperial
    }

    Binding {
        target: PushNotifications
        property: "enabled"
        value: PlatformPermissions.notificationsPermission === PlatformPermissions.PermissionStatusGranted
    }

    ConfiguredHostsModel {
        id: configuredHostsModel
    }

    property alias mainMenu: m
    MainMenu {
        id: m
        height: app.height
        width: Math.min(300, app.width)
        configuredHosts: configuredHostsModel
        onOpenThingSettings: rootItem.openThingSettings();
        onOpenMagicSettings: rootItem.openMagicSettings();
        onOpenAppSettings: rootItem.openAppSettings();
        onOpenSystemSettings: rootItem.openSystemSettings();
        onOpenCustomPage: rootItem.openCustomPage(page);
        onConfigureMainView: rootItem.configureMainView();
        onStartManualConnection: rootItem.startManualConnection();
        onStartWirelessSetup: rootItem.startWirelessSetup();
    }

    RootItem {
        id: rootItem
        anchors.fill: parent
        anchors.bottomMargin: keyboardRect.height
    }

    property NymeaDiscovery nymeaDiscovery: NymeaDiscovery {
        objectName: "discovery"
        bluetoothDiscoveryEnabled: false// PlatformPermissions.bluetoothPermission === PlatformPermissions.PermissionStatusGranted
    }

    property var supportedInterfaces: [
        "light",
        "media",
        "awning",
        "shutter",
        "blind",
        "cleaningrobot",
        "garagedoor",
        "powersocket",
        "thermostat",
        "heating",
        "cooling",
        "smartlock",
        "doorbell",
        "irrigation",
        "ventilation",
        "sensor",
        "weather",
        "evcharger",
        "smartmeter",
        "fingerprintreader",
        "notifications",
        "barcodescanner",
        "button",
        "inputtrigger",
        "outputtrigger",
        "gateway",
        "account"
    ]

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
        case "cosensor":
            return qsTr("CO level")
        case "co2sensor":
            return qsTr("CO2 level")
        case "no2sensor":
            return qsTr("Nitrogen dioxide level")
        case "gassensor":
            return qsTr("Flammable gas level")
        case "vocsensor":
            return qsTr("VOC level")
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
        case "garagedoor":
            return qsTr("Garage doors");
        case "accesscontrol":
            return qsTr("Access control");
        case "fingerprintreader":
            return qsTr("Fingerprint reader");
        case "smartmeter":
        case "smartmeterproducer":
        case "smartmeterconsumer":
        case "extendedsmartmeterproducer":
        case "extendedsmartmeterconsumer":
            return qsTr("Smart meters");
        case "heating":
            return qsTr("Heating");
        case "cooling":
            return qsTr("Cooling");
        case "thermostat":
            return qsTr("Thermostats");
        case "evcharger":
            return qsTr("EV-chargers");
        case "powersocket":
            return qsTr("Power sockets")
        case "doorbell":
            return qsTr("Doorbells");
        case "account":
            return qsTr("Accounts");
        case "smartlock":
            return qsTr("Smartlocks")
        case "irrigation":
            return qsTr("Irrigation");
        case "ventilation":
            return qsTr("Ventilation")
        case "barcodescanner":
            return qsTr("Barcode scanners");
        case "cleaningrobot":
            return qsTr("Cleaning robots")
        case "electricvehicle":
            return qsTr("Electric cars");
        case "closablesensor":
            return qsTr("Door/Window sensors");
        case "o3sensor":
            return qsTr("Ozone sensors");
        case "uncategorized":
            return qsTr("Uncategorized")
        default:
            console.warn("interfaceToString unhandled interface:", name)
        }
        return ""
    }

    function interfacesToIcon(interfaces) {
//        print("finding icon for interfaces:", interfaces)
        for (var i = 0; i < interfaces.length; i++) {
            var icon = interfaceToIcon(interfaces[i]);
            if (icon !== "") {
                return icon;
            }
        }
        return Qt.resolvedUrl("qrc:/icons/select-none.svg")
    }

    function interfaceToIcon(name) {
//        print("finding icon for interface:", name)
        switch (name) {
        case "light":
        case "colorlight":
        case "dimmablelight":
        case "colortemperaturelight":
            return Qt.resolvedUrl("qrc:/icons/light-on.svg")
        case "sensor":
            return Qt.resolvedUrl("qrc:/icons/sensors.svg")
        case "temperaturesensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/temperature.svg")
        case "humiditysensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/humidity.svg")
        case "moisturesensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/moisture.svg")
        case "lightsensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/light.svg")
        case "conductivitysensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/conductivity.svg")
        case "pressuresensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/pressure.svg")
        case "noisesensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/noise.svg");
        case "cosensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/co.svg")
        case "co2sensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/co2.svg")
        case "no2sensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/no2.svg")
        case "o3sensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/o3.svg")
        case "vocsensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/voc.svg")
        case "pm10sensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/pm10.svg")
        case "pm25sensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/pm25.svg")
        case "gassensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/gas.svg")
        case "daylightsensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/light.svg")
        case "presencesensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/presence.svg")
        case "closablesensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/window-closed.svg")
        case "windspeedsensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/windspeed.svg")
        case "watersensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/water.svg")
        case "vibrationsensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/vibration.svg")
        case "waterlevelsensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/water.svg")
        case "firesensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/fire.svg")
        case "o2sensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/o2.svg")
        case "phsensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/ph.svg")
        case "orpsensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/orp.svg")
        case "media":
        case "mediacontroller":
        case "mediaplayer":
            return Qt.resolvedUrl("qrc:/icons/media.svg")
        case "powersocket":
            return Qt.resolvedUrl("qrc:/icons/powersocket.svg")
        case "button":
        case "longpressbutton":
        case "simplemultibutton":
        case "longpressmultibutton":
        case "powerswitch":
            return Qt.resolvedUrl("qrc:/icons/system-shutdown.svg")
        case "weather":
            return Qt.resolvedUrl("qrc:/icons/weather-app-symbolic.svg")
        case "gateway":
            return Qt.resolvedUrl("qrc:/icons/connections/network-wired.svg")
        case "notifications":
            return Qt.resolvedUrl("qrc:/icons/messaging-app-symbolic.svg")
        case "inputtrigger":
            return Qt.resolvedUrl("qrc:/icons/attention.svg")
        case "outputtrigger":
            return Qt.resolvedUrl("qrc:/icons/send.svg")
        case "shutter":
        case "extendedshutter":
            return Qt.resolvedUrl("qrc:/icons/shutter/shutter-040.svg")
        case "blind":
        case "extendedblind":
            return Qt.resolvedUrl("qrc:/icons/shutter/shutter-060.svg")
        case "garagedoor":
        case "impulsegaragedoor":
        case "statefulgaragedoor":
        case "extendedstatefulgaragedoor":
        case "garagegate":
            return Qt.resolvedUrl("qrc:/icons/garage/garage-100.svg")
        case "awning":
        case "extendedawning":
            return Qt.resolvedUrl("qrc:/icons/awning/awning-100.svg")
        case "battery":
            return Qt.resolvedUrl("qrc:/icons/battery/battery-050.svg")
        case "uncategorized":
            return Qt.resolvedUrl("qrc:/icons/select-none.svg")
        case "simpleclosable":
            return Qt.resolvedUrl("qrc:/icons/closable-move.svg")
        case "fingerprintreader":
            return Qt.resolvedUrl("qrc:/icons/fingerprint.svg")
        case "accesscontrol":
            return Qt.resolvedUrl("qrc:/icons/lock-closed.svg");
        case "solarinverter":
            return Qt.resolvedUrl("qrc:/icons/weathericons/weather-clear-day.svg")
        case "smartmeter":
        case "smartmeterconsumer":
        case "smartmeterproducer":
        case "energymeter":
            return Qt.resolvedUrl("qrc:/icons/smartmeter.svg")
//            return Qt.resolvedUrl("qrc:/icons/energy.svg")
        case "heating":
            return Qt.resolvedUrl("qrc:/icons/thermostat/heating.svg")
        case "cooling":
            return Qt.resolvedUrl("qrc:/icons/thermostat/cooling.svg")
        case "thermostat":
            return Qt.resolvedUrl("qrc:/icons/dial.svg")
        case "evcharger":
            return Qt.resolvedUrl("qrc:/icons/ev-charger.svg")
        case "doorbell":
            return Qt.resolvedUrl("qrc:/icons/notification.svg")
        case "irrigation":
            return Qt.resolvedUrl("qrc:/icons/irrigation.svg")
        case "ventilation":
            return Qt.resolvedUrl("qrc:/icons/ventilation.svg")
        case "power":
            return Qt.resolvedUrl("qrc:/icons/system-shutdown.svg")
        case "smartlock":
            return Qt.resolvedUrl("qrc:/icons/smartlock.svg")
        case "navigationpad":
        case "extendednavigationpad":
            return Qt.resolvedUrl("qrc:/icons/navigationpad.svg")
        case "volumecontroller":
            return Qt.resolvedUrl("qrc:/icons/audio-speakers-symbolic.svg")
        case "shufflerepeat":
            return Qt.resolvedUrl("qrc:/icons/media-playlist-shuffle.svg")
        case "alert":
            return Qt.resolvedUrl("qrc:/icons/notification.svg")
        case "barcodescanner":
            return Qt.resolvedUrl("qrc:/icons/qrcode.svg")
        case "cleaningrobot":
            return Qt.resolvedUrl("qrc:/icons/cleaning-robot.svg")
        case "account":
            return Qt.resolvedUrl("qrc:/icons/account.svg")
        case "wirelessconnectable":
            return Qt.resolvedUrl("qrc:/icons/connections/network-wifi.svg")
        case "connectable":
            return Qt.resolvedUrl("qrc:/icons/stock_link.svg")
        case "electricvehicle":
            return Qt.resolvedUrl("qrc:/icons/car.svg")
        case "update":
            return Qt.resolvedUrl("qrc:/icons/system-update.svg")
        default:
            console.warn("InterfaceToIcon: Unhandled interface", name)
        }
        return "";
    }



    StyleBase {
        id: styleBase
    }

    function stateColor(stateName) {
        // Try to load color map from style
        if (Style.stateColors[stateName]) {
            return Style.stateColors[stateName];
        }

        if (styleBase.stateColors[stateName]) {
            return styleBase.stateColors[stateName];
        }
        console.warn("stateColor(): Color not set for state", stateName)
        return "grey";
    }

    function stateIcon(stateName) {
        var iconMap = {
            "currentPower": "energy.svg",
            "totalEnergyConsumed": "smartmeter.svg",
            "totalEnergyProduced": "smartmeter.svg",
        }
        if (!iconMap[stateName]) {
            console.warn("stateIcon(): Icon not set for state", stateName)
        }
        return Qt.resolvedUrl("qrc:/icons/" + iconMap[stateName]);
    }

    function interfaceToColor(name) {
        // Try to load color map from style
        if (Style.interfaceColors[name]) {
            return Style.interfaceColors[name];
        }

        if (styleBase.interfaceColors[name]) {
            return styleBase.interfaceColors[name];
        }

        return "grey";
    }

    function interfaceToDisplayName(name) {
        switch (name) {
        case "light":
        case "dimmablelight":
        case "colorlight":
        case "colortemperaturelight":
            //: Select ...
            return qsTr("light")
        case "sensor":
            //: Select ...
            return qsTr("sensor")
        case "battery":
            //: Select ...
            return qsTr("battery powered thing")
        case "connectable":
            //: Select ...
            return qsTr("connectable thing")
        case "irrigation":
            //: Select ...
            return qsTr("irrigation");
        case "ventilation":
            //: Select ...
            return qsTr("ventilation");
        case "power":
            //: Select ...
            return qsTr("switchable thing")
        case "daylightsensor":
            //: Select ...
            return qsTr("daylight sensor")
        case "presencesensor":
            //: Select ...
            return qsTr("presence sensor")
        case "vibrationsensor":
            //: Select ...
            return qsTr("vibration sensor");
        case "doorbell":
            //: Select ...
            return qsTr("doorbell")
        case "alert":
            //: Select ...
            return qsTr("alert")
        case "simplemultibutton":
        case "simplebutton":
        case "button":
            //: Select ...
            return qsTr("button")
        case "accesscotrol":
            //: Select ...
            return qsTr("access control")
        case "smartmeter":
        case "smartmeterproducer":
        case "smartmeterconsumer":
        case "extendedsmartmeterproducer":
        case "extendedsmartmeterconsumer":
            //: Select ...
            return qsTr("smart meter");
        case "media":
        case "mediaplayer":
        case "mediacontroller":
            //: Select ...
            return qsTr("media player");
        case "moisturesensor":
            //: Select ...
            return qsTr("moisture sensor");
        case "notifications":
            //: Select ...
            return qsTr("thing to notify")
        case "smartlock":
            //: Select ...
            return qsTr("smartlock");
        default:
            console.warn("Unhandled interfaceToDisplayName:", name)
        }
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
        if (Qt.platform.os === "android") {
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

    FolderListModel {
        id: availableMainViews
        folder: "mainviews"
        showFiles: false
    }

    // // NOTE: If using a Dialog, make sure closePolicy does not contain Dialog.CloseOnPressOutside
    // // or the virtual keyboard will close when pressing it...

    // // https://bugreports.qt.io/browse/QTBUG-56918
    KeyboardLoader {
        id: keyboardRect
        // parent: app.overlay
        z: 1
        anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
    }

    Image {
        id: splashScreen
        // parent: overlay
        source: "/ui/images/nymea-splash.svg"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        opacity: PlatformHelper.splashVisible ? 1 : 0
        Behavior on opacity { NumberAnimation {duration: 300 }}
        visible: showSplash && opacity > 0
        antialiasing: true
        smooth: true
        sourceSize.width: Math.max(width, height)
        sourceSize.height: Math.max(width, height)
    }
}
