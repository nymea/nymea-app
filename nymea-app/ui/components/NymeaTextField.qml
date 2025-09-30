import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import Nymea

TextField {
    id: control

    property bool error: false

    onEditingFinished: {
        parent.forceActiveFocus()
    }

    background: Rectangle {
        y: control.height - height - control.bottomPadding + 8
        implicitWidth: 120
        height: control.activeFocus || control.hovered ? 2 : 1
        color: control.error ? Style.red : control.activeFocus ? Style.accentColor
                                   : (control.hovered ? control.Material.primaryTextColor : control.Material.hintTextColor)
    }
}

