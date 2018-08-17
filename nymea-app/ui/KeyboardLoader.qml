import QtQuick 2.0

Item {
    id: root
    implicitHeight: childrenRect.height

    property string virtualKeyboardString:
        '
        import QtQuick 2.8;
        import QtQuick.VirtualKeyboard 2.1
        InputPanel {
            id: inputPanel
            y: Qt.inputMethod.visible ? parent.height - inputPanel.height : parent.height
            anchors.left: parent.left
            anchors.right: parent.right
        }
        '

    Component.onCompleted: {
        if (useVirtualKeyboard) {
            var kbd = Qt.createQmlObject(virtualKeyboardString, root);
        }
    }
}
