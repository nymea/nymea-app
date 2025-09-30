pragma Singleton
import QtQuick
import "../../ui"

StyleBase {
    backgroundColor: "#ffffff"
    foregroundColor: "#638B87"

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
