pragma Singleton
import QtQuick 2.0
import "../../ui"

StyleBase {
    backgroundColor: "#ffffff"
    foregroundColor: "#638B87"

    headerBackgroundColor: "#ffffff"
    headerForegroundColor: "#79a79f"

    accentColor: "#8cc1b6"

    interfaceColors: {
        "temperaturesensor": "#FF0000",
        "humiditysensor": "#00BFFF",
        "moisturesensor":"#0000FF",
        "lightsensor": "#FFA500",
        "conductivitysensor": "#008000",
        "pressuresensor": "#808080"
    }
}
