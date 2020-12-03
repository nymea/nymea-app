import QtQuick 2.9
import QtGraphicalEffects 1.0
import Nymea 1.0
import "../utils"

Item {
    id: root

    property Thing thing: null

    ActionQueue {
        id: actionQueue
        thing: root.thing
        stateType: thing.thingClass.stateTypes.findByName("color")
    }

    ConicalGradient {
        id: gradient
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height)
        height: width
        visible: false
        gradient: Gradient{
            id: g
            GradientStop { position: 0.000; color: Qt.rgba(1, 0, 0, 1) }
            GradientStop { position: 0.167; color: Qt.rgba(1, 1, 0, 1) }
            GradientStop { position: 0.333; color: Qt.rgba(0, 1, 0, 1) }
            GradientStop { position: 0.500; color: Qt.rgba(0, 1, 1, 1) }
            GradientStop { position: 0.667; color: Qt.rgba(0, 0, 1, 1) }
            GradientStop { position: 0.833; color: Qt.rgba(1, 0, 1, 1) }
            GradientStop { position: 1.000; color: Qt.rgba(1, 0, 0, 1) }
        }
    }

    Rectangle {
        id: mask
        anchors.fill: gradient
        radius: width / 2
    }
    OpacityMask {
        anchors.fill: gradient
        source: gradient
        maskSource: mask
    }

    RadialGradient {
        anchors.fill: gradient
        gradient: Gradient{
            GradientStop { position: 0.05; color: Qt.rgba(1, 1, 1, 1) }
            GradientStop { position: 0.10; color: Qt.rgba(1, 1, 1, .9) }
            GradientStop { position: 0.20; color: Qt.rgba(1, 1, 1, .7) }
            GradientStop { position: 0.30; color: Qt.rgba(1, 1, 1, .5) }
            GradientStop { position: 0.40; color: Qt.rgba(1, 1, 1, .3) }
            GradientStop { position: 0.50; color: "transparent" }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onPositionChanged: {

            var angle = calculateAngle(mouseX, mouseY)
            var position = angle / 360;

            var stopBefore = null;
            var stopAfter = null;
            for (var i = 0; i < g.stops.length; i++) {
                var stop = g.stops[i];
                if (stop.position < position) {
                    stopBefore = stop;
                    continue
                }
                stopAfter = stop;
                break;
            }

            var colorBefore = stopBefore.color
            var colorAfter = stopAfter.color
            // p : 1 = pis : (a - b)
            var positionInStop = (position - stopBefore.position) / (stopAfter.position - stopBefore.position);

            var dr = stopAfter.color.r - stopBefore.color.r;
            var dg = stopAfter.color.g - stopBefore.color.g;
            var db = stopAfter.color.b - stopBefore.color.b;

            var distanceFromCenter = calculateDistance(mouseX, mouseY)

            // Reduce width a bit to keep outside circle for full color intensity
            var positionFromCenter = Math.min(distanceFromCenter / (width * 0.9 / 2), 1)
            // Invert it, The further we're away, the less impact this should have
            positionFromCenter = 1 - positionFromCenter;
            print("pos", positionFromCenter)

            var color = Qt.rgba((stopBefore.color.r + dr * positionInStop) + positionFromCenter,
                                (stopBefore.color.g + dg * positionInStop) + positionFromCenter,
                                (stopBefore.color.b + db * positionInStop) + positionFromCenter,
                                1)

            actionQueue.sendValue(color);
        }

        function calculateAngle(mouseX, mouseY) {
            // transform coords to center of dial
            mouseX -= mouseArea.width / 2
            mouseY -= mouseArea.height / 2

            var rad = Math.atan(mouseY / mouseX);
            var angle = rad * 180 / Math.PI

            angle += 90;

            if (mouseX < 0 && mouseY >= 0) angle = 180 + angle;
            if (mouseX < 0 && mouseY < 0) angle = 180 + angle;

            return angle;
        }

        function calculateDistance(mouseX, mouseY) {
            mouseX -= mouseArea.width / 2
            mouseY -= mouseArea.height / 2

            return Math.abs(Math.sqrt(Math.pow(mouseX, 2) + Math.pow(mouseY, 2)))
        }
    }
}
