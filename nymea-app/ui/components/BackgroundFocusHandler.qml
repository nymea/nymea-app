import QtQuick 2.9

MouseArea {
    onClicked: {
        forceActiveFocus()
        Qt.inputMethod.hide()
    }
}
