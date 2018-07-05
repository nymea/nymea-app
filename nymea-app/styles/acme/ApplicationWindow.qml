import QtQuick 2.0
import QtQuick.Templates 2.2
import QtQuick.Controls.Material 2.2

ApplicationWindow {
    property string systemName: "ACME"
    property string appName: "ACME Inc."

    Material.theme: Material.Light
    Material.accent: Material.Red
    Material.primary: Material.background
}
