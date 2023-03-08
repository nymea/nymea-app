import QtQuick 2.0

Item {
    property color backgroundColor: "#fafafa"
    property color foregroundColor: "#202020"
    property color unobtrusiveForegroundColor: Qt.tint(foregroundColor, Qt.rgba(backgroundColor.r, backgroundColor.g, backgroundColor.b, 0.4))

    property color accentColor: "#57baae"
    property color iconColor: "#808080"
    property color generationBaseColor: blue

    property color tileBackgroundColor: Qt.tint(backgroundColor, Qt.rgba(foregroundColor.r, foregroundColor.g, foregroundColor.b, 0.05))
    property color tileForegroundColor: foregroundColor
    property color tileOverlayColor: Qt.tint(backgroundColor, Qt.rgba(foregroundColor.r, foregroundColor.g, foregroundColor.b, 0.1))
    property color tileOverlayForegroundColor: foregroundColor
    property color tileOverlayIconColor: iconColor

    property color tooltipBackgroundColor: tileOverlayColor

    property int cornerRadius: 10
    property int smallCornerRadius: 6

    readonly property int extraSmallMargins: 4
    readonly property int smallMargins: 8
    readonly property int margins: 16
    readonly property int bigMargins: 32
    readonly property int hugeMargins: 64

    readonly property int smallDelegateHeight: 50
    readonly property int delegateHeight: 60
    readonly property int largeDelegateHeight: 80

    readonly property int smallIconSize: 16
    readonly property int iconSize: 24
    readonly property int bigIconSize: 32
    readonly property int largeIconSize: 40
    readonly property int hugeIconSize: 64

    // Note: Font files need to be provided in a "fonts" folder in the style
    property string fontFamily: "Ubuntu"


    // Fonts
    readonly property font extraSmallFont: Qt.font({
        family: "Ubuntu",
        pixelSize: 10
    })
    readonly property font smallFont: Qt.font({
        family: "Ubuntu",
        pixelSize: 13
    })
    readonly property font font: Qt.font({
        family: "Ubuntu",
        pixelSize: 16
    })
    readonly property font bigFont: Qt.font({
        family: "Ubuntu",
        pixelSize: 20
    })
    readonly property font largeFont: Qt.font({
        family: "Ubuntu",
        pixelSize: 32
    })
    readonly property font hugeFont: Qt.font({
        family: "Ubuntu",
        pixelSize: 46
    })


    // Color definitions
    property color white: "white"
    property color gray: "gray"
    property color darkGray: "darkgray"
    property color lightGray: "lightGray"

    property color red: "indianred"
    property color yellow: "#cdcd5c"
    property color green: "#5ccd5c"
    property color lightBlue: "#5ccdcd"
    property color darkBlue: "#5c5ccd"
    property color pink: "#cd5ccd"
    property color orange: "#cd955c"
    property color lime: "#95cd5c"
    property color turquoise: "#5ccd95"
    property color blue: "#5c95cd"
    property color purple: "#955ccd"
    property color rose: "#cd5c95"
    property color darkGreen: "#5ccd5e"

    property color powerAcquisitionColor: red
    property color powerReturnColor: yellow
    property color powerConsumptionColor: blue
    property color powerSelfProductionConsumptionColor: green
    property color powerBatteryChargingColor: purple
    property color powerBatteryDischargingColor: orange
    property color powerBatteryIdleColor: lime

    // Icon/graph colors for various interfaces
    property var interfaceColors: {
        "temperaturesensor": red,
        "humiditysensor": lightBlue,
        "moisturesensor": blue,
        "lightsensor": yellow,
        "conductivitysensor": green,
        "pressuresensor": gray,
        "noisesensor": purple,
        "cosensor": darkGray,
        "co2sensor": turquoise,
        "pm10sensor": lightGray,
        "pm25sensor": gray,
        "gassensor": orange,
        "daylightsensor": yellow,
        "presencesensor": darkBlue,
        "vibrationsensor": orange,
        "closablesensor": green,
        "smartmeterconsumer": orange,
        "smartmeterproducer": lime,
        "energymeter": darkBlue,
        "heating" : red,
        "cooling": blue,
        "thermostat": blue,
        "irrigation": blue,
        "windspeedsensor": blue,
        "ventilation": lightBlue,
        "watersensor": lightBlue,
        "waterlevelsensor": lightBlue,
        "firesensor": red,
        "phsensor": green,
        "o2sensor": lightBlue,
        "orpsensor": yellow,
        "powersocket": lime,
        "evcharger": lime,
        "energystorage": lime,
        "vocsensor": green,
        "o3sensor": blue,
        "no2sensor": purple
    }

    property var stateColors: {
        "totalEnergyConsumed": red,
        "totalEnergyProduced": yellow,
        "currentPower": blue,
    }


    // Animations
    readonly property int fastAnimationDuration: 100
    readonly property int animationDuration: 150
    readonly property int slowAnimationDuration: 300
    readonly property int sleepyAnimationDuration: 2000
}
