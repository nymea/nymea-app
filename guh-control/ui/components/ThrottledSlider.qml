import QtQuick 2.8
import QtQuick.Controls 2.1

Item {
    id: root
    implicitHeight: slider.implicitHeight

    property real value: 0
    property alias from: slider.from
    property alias to: slider.to
    signal moved(real value);

    Slider {
        id: slider
        anchors.left: parent.left; anchors.right: parent.right
        from: 0
        to: 100
        property var lastSentTime: new Date()
        onValueChanged: {
            var currentTime = new Date();
            if (pressed && currentTime - lastSentTime > 200) {
                root.moved(slider.value)
                lastSentTime = currentTime
            }
        }
        onPressedChanged: {
            if (!pressed) {
                root.moved(slider.value)
            }
        }
    }

    Binding {
        target: slider
        property: "value"
        value: root.value
        when: !slider.pressed
    }
}

