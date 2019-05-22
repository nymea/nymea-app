import QtQuick 2.4

Item {
    id: root
    implicitHeight: active ? childrenRect.height : 0
    property bool active: d.kbd && d.kbd.active

    Behavior on implicitHeight { NumberAnimation { duration: 130; easing.type: Easing.InOutQuad } }

    QtObject {
        id: d
        property var kbd: null
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
    }


    Component.onCompleted: {
        if (useVirtualKeyboard) {
            d.kbd = Qt.createQmlObject(d.virtualKeyboardString, root);
        }
    }
}
