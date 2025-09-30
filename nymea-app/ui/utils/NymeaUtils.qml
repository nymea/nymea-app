pragma Singleton

import QtQuick
import Nymea
import QtCharts

Item {
    id: root

    function pad(num, size, base) {
        if (base == undefined) {
            base = 10
        }

        var trimmedNum = Math.floor(num)
        var decimals = num - trimmedNum
        var trimmedStr = "" + trimmedNum.toString(base)
        var str = "000000000" + trimmedStr
        str = str.substr(str.length - Math.max(size, trimmedStr.length));
        if (decimals !== 0) {
            str += "." + decimals.toString(base);
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
        } else if (interfaceList.indexOf("vibrationsensor") >= 0) {
            page = "InputTriggerDevicePage.qml";
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
            page = "NotificationsThingPage.qml";
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
            page = "GenericThingPage.qml";
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
        "dashboard": "qrc:/icons/dashboard.svg",
        "group": "qrc:/icons/groups.svg",
        "folder": "qrc:/icons/folder.svg",
        "star": "qrc:/icons/starred.svg",
        "heart": "qrc:/icons/like.svg",
        "wrench": "qrc:/icons/configure.svg",
        "light": "qrc:/icons/light-on.svg",
        "sensor": "qrc:/icons/sensors.svg",
        "media": "qrc:/icons/media.svg",
        "powersocket": "qrc:/icons/powersocket.svg",
        "power": "qrc:/icons/system-shutdown.svg",
        "weather": "qrc:/icons/weather-app-symbolic.svg",
        "attention": "qrc:/icons/attention.svg",
        "shutter": "qrc:/icons/shutter/shutter-040.svg",
        "garage": "qrc:/icons/garage/garage-100.svg",
        "awning": "qrc:/icons/awning/awning-100.svg",
        "uncategorized": "qrc:/icons/select-none.svg",
        "closable": "qrc:/icons/closable-move.svg",
        "smartmeter": "qrc:/icons/smartmeter.svg",
        "heating": "qrc:/icons/thermostat/heating.svg",
        "cooling": "qrc:/icons/thermostat/cooling.svg",
        "meter": "qrc:/icons/dial.svg",
        "ev-charger": "qrc:/icons/ev-charger.svg",
        "battery": "qrc:/icons/battery/battery-100.svg",
        "message": "qrc:/icons/notification.svg",
        "irrigation": "qrc:/icons/irrigation.svg",
        "ventilation": "qrc:/icons/ventilation.svg",
        "lock": "qrc:/icons/smartlock.svg",
        "qrcode": "qrc:/icons/qrcode.svg",
        "cleaningrobot": "qrc:/icons/cleaning-robot.svg",
        "plant": "qrc:/icons/sensors/conductivity.svg",
        "water": "qrc:/icons/sensors/water.svg",
        "wind": "qrc:/icons/sensors/windspeed.svg",
        "cloud": "qrc:/icons/weathericons/weather-clouds.svg",
        "send": "qrc:/icons/send.svg",
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

    function generateColor(baseColor, index, alpha) {
        var stepSize = 30
        var baseHSV = rgb2hsv(baseColor.r, baseColor.g, baseColor.b)
        var currentHue = baseHSV[0]
        var handledColors = [currentHue]
        for (var i = 0; i < index; i++) {
            while (handledColors.indexOf(currentHue) >= 0) {
                currentHue = (currentHue + 60) % 360

                if (handledColors.indexOf(currentHue) >= 0) {
                    currentHue += /*60 + */stepSize
                    stepSize = Math.max(1, stepSize / 2)
                }
            }
            handledColors.push(currentHue)
        }
        return Qt.hsva(currentHue / 360, baseHSV[1], baseHSV[2], alpha || 1);
    }

    function rgb2hsv(r,g,b) {
      var v=Math.max(r,g,b), c=v-Math.min(r,g,b);
      var h= c && ((v==r) ? (g-b)/c : ((v==g) ? 2+(b-r)/c : 4+(r-g)/c));
      return [60*(h<0?h+6:h), v&&c/v, v];
    }

    readonly property var sensorInterfaceStateMap: {
        "temperaturesensor": "temperature",
        "humiditysensor": "humidity",
        "pressuresensor": "pressure",
        "moisturesensor": "moisture",
        "lightsensor": "lightIntensity",
        "conductivitysensor": "conductivity",
        "noisesensor": "noise",
        "cosensor": "co",
        "co2sensor": "co2",
        "gassensor": "gasLevel",
        "presencesensor": "isPresent",
        "daylightsensor": "daylight",
        "closablesensor": "closed",
        "watersensor": "waterDetected",
        "firesensor": "fireDetected",
        "waterlevelsensor": "waterLevel",
        "phsensor": "ph",
        "o2sensor": "o2saturation",
        "o3sensor": "o3",
        "orpsensor": "orp",
        "vocsensor": "voc",
        "cosensor": "co",
        "pm10sensor": "pm10",
        "pm25sensor": "pm25",
        "no2sensor": "no2"
    }

}
