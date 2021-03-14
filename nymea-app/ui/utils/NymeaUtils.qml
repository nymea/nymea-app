pragma Singleton
import QtQuick 2.9

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
        } else if (interfaceList.indexOf("thermostat") >= 0) {
            page = "ThermostatDevicePage.qml";
        } else if (interfaceList.indexOf("sensor") >= 0) {
            page = "SensorDevicePage.qml";
        } else if (interfaceList.indexOf("inputtrigger") >= 0) {
            page = "InputTriggerDevicePage.qml";
        } else if (interfaceList.indexOf("garagedoor") >= 0 ) {
            page = "GarageThingPage.qml";
        } else if (interfaceList.indexOf("light") >= 0) {
            page = "LightDevicePage.qml";
        } else if (interfaceList.indexOf("shutter") >= 0  || interfaceList.indexOf("blind") >= 0) {
            page = "ShutterDevicePage.qml";
        } else if (interfaceList.indexOf("awning") >= 0) {
            page = "AwningThingPage.qml";
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
        } else if (interfaceList.indexOf("irrigation") >= 0) {
            page = "IrrigationDevicePage.qml";
        } else if (interfaceList.indexOf("ventilation") >= 0) {
            page = "VentilationDevicePage.qml";
        } else if (interfaceList.indexOf("barcodescanner") >= 0) {
            page = "BarcodeScannerThingPage.qml";
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

}
