import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../../components"

ComboBox {
    property var value
    property var possibleValues

    signal changed(var value)
    model: possibleValues
    currentIndex: possibleValues.indexOf(value)
    onActivated: changed(model[index])
    Component.onCompleted: print("completed. values", possibleValues, "value", value)
}
