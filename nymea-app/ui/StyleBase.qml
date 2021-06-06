import QtQuick 2.0

Item {
    property color backgroundColor: "#fafafa"
    property color foregroundColor: "#202020"

    property color accentColor: "#57baae"
    property color iconColor: "#808080"

    property color headerBackgroundColor: "#ffffff"
    property color headerForegroundColor: "#202020"

    property color tileBackgroundColor: Qt.tint(backgroundColor, Qt.rgba(foregroundColor.r, foregroundColor.g, foregroundColor.b, 0.05))
    property color tileForegroundColor: foregroundColor
    property color tileOverlayColor: Qt.tint(backgroundColor, Qt.rgba(foregroundColor.r, foregroundColor.g, foregroundColor.b, 0.1))
    property color tileOverlayForegroundColor: foregroundColor
    property color tileOverlayIconColor: iconColor

    property int cornerRadius: 6
    property int smallCornerRadius: 4

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
    readonly property font largeFont: Qt.font({
        family: "Ubuntu",
        pixelSize: 20
    })
    readonly property font hugeFont: Qt.font({
        family: "Ubuntu",
        pixelSize: 40
    })


    // Icon/graph colors for various interfaces
    property var interfaceColors: {
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
        "extendedsmartmeterproducer": "lightgreen",
        "smartmeterconsumer": "deepskyblue",
        "extendedsmartmeterconsumer": "deepskyblue",
        "heating" : "gainsboro",
        "thermostat": "dodgerblue",
        "irrigation": "lightblue",
        "windspeedsensor": "blue",
        "ventilation": "lightblue",
        "watersensor": "aqua"
    }

    property var stateColors: {
        "totalEnergyConsumed": "orange",
        "totalEnergyProduced": "lightgreen",
        "currentPower": "deepskyblue",
    }

    readonly property color red: "#952727"
    readonly property color white: "white"
}
