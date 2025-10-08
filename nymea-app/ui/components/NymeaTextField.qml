import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl
import Nymea

TextField {
    id: control

    property bool error: false

    color: enabled ? ( control.error ? Style.red : Material.foreground) : Material.hintTextColor
}

