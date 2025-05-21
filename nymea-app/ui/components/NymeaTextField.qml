import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import Nymea 1.0

TextField {
    id: control

    property bool error: false

    onEditingFinished: {
        activeFocus = false
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

