pragma Singleton
import QtQuick 2.9
import Nymea 1.0
import QtCharts 2.2

Item {
    id: root

    function pad(num, size) {
        var trimmedNum = Math.floor(num)
        var decimals = num - trimmedNum
        var trimmedStr = "" + trimmedNum
        var str = "000000000" + trimmedNum;
        str = str.substr(str.length - Math.max(size, trimmedStr.length));
        if (decimals !== 0) {
            str += "." + (num - trimmedNum);
        }
        return str;
    }

    function interfaceListToDevicePage(interfaceList) {
        print("**** getting page for interfaces", interfaceList)
        var page;
        if (interfaceList.indexOf("media") >= 0) {
            page = "MediaThingPage.qml";
        } else if (interfaceList.indexOf("button") >= 0) {
            page = "ButtonThingPage.qml";
        } else if (interfaceList.indexOf("powerswitch") >= 0) {
            page = "ButtonThingPage.qml";
        } else if (interfaceList.indexOf("weather") >= 0) {
            page = "WeatherDevicePage.qml";
        } else if (interfaceList.indexOf("heating") >= 0) {
            page = "HeatingDevicePage.qml";
        } else if (interfaceList.indexOf("cooling") >= 0) {
            page = "CoolingThingPage.qml";
        } else if (interfaceList.indexOf("thermostat") >= 0) {
            page = "ThermostatDevicePage.qml";
        } else if (interfaceList.indexOf("sensor") >= 0) {
            page = "SensorDevicePage.qml";
        } else if (interfaceList.indexOf("inputtrigger") >= 0) {
            page = "InputTriggerDevicePage.qml";
        } else if (interfaceList.indexOf("garagedoor") >= 0 ) {
            page = "GarageThingPage.qml";
        } else if (interfaceList.indexOf("light") >= 0) {
            page = "LightThingPage.qml";
        } else if (interfaceList.indexOf("shutter") >= 0  || interfaceList.indexOf("blind") >= 0) {
            page = "ShutterDevicePage.qml";
        } else if (interfaceList.indexOf("awning") >= 0) {
            page = "AwningThingPage.qml";
        } else if (interfaceList.indexOf("notifications") >= 0) {
            page = "NotificationsDevicePage.qml";
        } else if (interfaceList.indexOf("fingerprintreader") >= 0) {
            page = "FingerprintReaderDevicePage.qml";
        } else if (interfaceList.indexOf("evcharger") >= 0) {
            page = "EvChargerThingPage.qml"
        } else if (interfaceList.indexOf("smartmeter") >= 0) {
            page = "SmartMeterDevicePage.qml"
        } else if (interfaceList.indexOf("powersocket") >= 0) {
            page = "PowersocketDevicePage.qml";
        } else if (interfaceList.indexOf("doorbell") >= 0) {
            page = "DoorbellDevicePage.qml";
        } else if (interfaceList.indexOf("irrigation") >= 0) {
            page = "IrrigationDevicePage.qml";
        } else if (interfaceList.indexOf("ventilation") >= 0) {
            page = "VentilationThingPage.qml";
        } else if (interfaceList.indexOf("barcodescanner") >= 0) {
            page = "BarcodeScannerThingPage.qml";
        } else if (interfaceList.indexOf("cleaningrobot") >= 0) {
            page = "CleaningRobotThingPage.qml";
        } else {
            page = "GenericDevicePage.qml";
        }
        print("Selecting page", page, "for interface list:", interfaceList)
        return page;
    }

    function isDark(color) {
        var r, g, b;
        if (color.constructor.name === "Object") {
            r = color.r * 255;
            g = color.g * 255;
            b = color.b * 255;
        } else if (color.constructor.name === "String") {
            var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(color);
            r = parseInt(result[1], 16)
            g = parseInt(result[2], 16)
            b = parseInt(result[3], 16)
        }

        return ((r * 299 + g * 587 + b * 114) / 1000) < 128
    }

    property var namedIcons: {
        "dashboard": "/ui/images/dashboard.svg",
        "group": "/ui/images/groups.svg",
        "folder": "/ui/images/folder.svg",
        "star": "/ui/images/starred.svg",
        "heart": "/ui/images/like.svg",
        "wrench": "/ui/images/configure.svg",
        "light": "/ui/images/light-on.svg",
        "sensor": "/ui/images/sensors.svg",
        "media": "/ui/images/media.svg",
        "powersocket": "/ui/images/powersocket.svg",
        "power": "/ui/images/system-shutdown.svg",
        "weather": "/ui/images/weather-app-symbolic.svg",
        "attention": "/ui/images/attention.svg",
        "shutter": "/ui/images/shutter/shutter-040.svg",
        "garage": "/ui/images/garage/garage-100.svg",
        "awning": "/ui/images/awning/awning-100.svg",
        "uncategorized": "/ui/images/select-none.svg",
        "closable": "/ui/images/closable-move.svg",
        "smartmeter": "/ui/images/smartmeter.svg",
        "heating": "/ui/images/thermostat/heating.svg",
        "cooling": "/ui/images/thermostat/cooling.svg",
        "meter": "/ui/images/dial.svg",
        "ev-charger": "/ui/images/ev-charger.svg",
        "battery": "/ui/images/battery/battery-100.svg",
        "message": "/ui/images/notification.svg",
        "irrigation": "/ui/images/irrigation.svg",
        "ventilation": "/ui/images/ventilation.svg",
        "lock": "/ui/images/smartlock.svg",
        "qrcode": "/ui/images/qrcode.svg",
        "cleaningrobot": "/ui/images/cleaning-robot.svg",
        "plant": "/ui/images/sensors/conductivity.svg",
        "water": "/ui/images/sensors/water.svg",
        "wind": "/ui/images/sensors/windspeed.svg",
        "cloud": "/ui/images/weathericons/weather-clouds.svg",
        "send": "/ui/images/send.svg",
    }
    function namedIcon(name) {
        if (!namedIcons.hasOwnProperty(name)) {
            console.error("No such named icon:", name)
            return
        }
        return namedIcons[name]
    }

    property ListModel scopesModel: ListModel {
        ListElement { text: qsTr("Admin"); scope: UserInfo.PermissionScopeAdmin; resetOnUnset: UserInfo.PermissionScopeNone }
        ListElement { text: qsTr("Control things"); scope: UserInfo.PermissionScopeControlThings; resetOnUnset: UserInfo.PermissionScopeNone }
        ListElement { text: qsTr("Configure things"); scope: UserInfo.PermissionScopeConfigureThings; resetOnUnset: UserInfo.PermissionScopeControlThings }
        ListElement { text: qsTr("Execute magic"); scope: UserInfo.PermissionScopeExecuteRules; resetOnUnset: UserInfo.PermissionScopeNone  }
        ListElement { text: qsTr("Configure magic"); scope: UserInfo.PermissionScopeConfigureRules; resetOnUnset: UserInfo.PermissionScopeExecuteRules }
    }

    function hasPermissionScope(permissions, requestedScope) {
        return (permissions & requestedScope) === requestedScope;
    }

    property bool inhibitChartsAnimation: PlatformHelper.deviceModel.startsWith("SM-G950") // Samsung S8 has a buggy GPU driver :(
    property int chartsAnimationOptions: !inhibitChartsAnimation ? ChartView.SeriesAnimations : ChartView.NoAnimation
}
