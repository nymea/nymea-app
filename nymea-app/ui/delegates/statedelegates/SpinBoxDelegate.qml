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
    editable: true
    onValueModified: {
        changed(value)
    }
}
