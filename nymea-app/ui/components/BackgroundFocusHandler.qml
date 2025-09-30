import QtQuick

MouseArea {
    onClicked: {
        forceActiveFocus()
        Qt.inputMethod.hide()
    }
}
