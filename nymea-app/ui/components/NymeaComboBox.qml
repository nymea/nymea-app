import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

ComboBox {
    id: control
    background: Item {
        implicitWidth: 120
        implicitHeight: control.Material.buttonHeight

        Ripple {
            clip: control.flat
            clipRadius: control.flat ? 0 : 2
            x: control.editable && control.indicator ? control.indicator.x : 0
            width: control.editable && control.indicator ? control.indicator.width : parent.width
            height: parent.height
            pressed: control.pressed
            anchor: control.editable && control.indicator ? control.indicator : control
            active: control.pressed || control.visualFocus || control.hovered
            color: control.Material.rippleColor
        }
    }
}
