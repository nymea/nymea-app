import QtQuick 2.0
import QtQuick.Templates 2.2
import QtQuick.Controls.Material 2.2

ApplicationWindow {
    property color guhAccent: "#ff57baae"
    property string systemName: "nymea"
    property string appName: "nymea:app"

    Material.theme: Material.Light
    Material.accent: guhAccent
    Material.primary: "white"

}
