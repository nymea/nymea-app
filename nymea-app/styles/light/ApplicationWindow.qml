import QtQuick 2.0
import QtQuick.Templates 2.2
import QtQuick.Controls.Material 2.2

ApplicationWindow {
    // The system (box) name.
    property string systemName: "nymea"

    // The app name
    property string appName: "nymea:app"

    // The header background color
    property color primaryColor: "white"

    // Header font color
    property color headerForegroundColor: Material.foreground

    // The font color
    property color foregroundColor: Material.foreground

    // The color of selected/highlighted things
    property color accentColor: "#ff57baae"

    // colors for interfaces, e.g. icons
    property var interfaceColors: {
        "temperaturesensor": "red",
        "humiditysensor": "deepskyblue",
        "moisturesensor":"blue",
        "lightsensor": "orange",
        "conductivitysensor": "green",
        "pressuresensor": "grey"
    }

    // Optional: Set this to override the cloud environment
    //property string cloudEnvironment: "Community"
}
