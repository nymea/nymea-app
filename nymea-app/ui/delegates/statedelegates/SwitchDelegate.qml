import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../../components"

Switch {
    property var value
    signal changed(var value)
    checked: value === true
    onClicked: {
        changed(checked)
    }
}
