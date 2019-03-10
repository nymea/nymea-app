import QtQuick 2.0
import QtQuick.Templates 2.2
import QtQuick.Controls.Material 2.2

ApplicationWindow {
    // The app style
    Material.theme: Material.Dark

    // Main background color
    Material.background: "#50514f"

    font.family: "Oswald"

    // The header background color
    property color primaryColor: Qt.darker("#50514f", 1.1)


    // Header font color
    property color headerForegroundColor: "#ebebeb"

    // The font color
    property color foregroundColor: "#ebebeb"

    // The color of selected/highlighted things
    property color accentColor: "#f45b69"

    // colors for interfaces, e.g. icons
    property var interfaceColors: {
        "temperaturesensor": "#FF0000",
        "humiditysensor": "#00BFFF",
        "moisturesensor":"#0000FF",
        "lightsensor": "#FFA500",
        "conductivitysensor": "#008000",
        "pressuresensor": "#808080"
    }
}
