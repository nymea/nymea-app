import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../../components"

SpinBox {
    width: 150
    signal changed(var value)
    stepSize: Math.min(10, (to - from) / 10)
    property var unit: Types.UnitNone
    editable: true
    onValueModified: {
        changed(value)
    }
    textFromValue: function(value) {
        return Types.toUiValue(value, unit)
    }
}
