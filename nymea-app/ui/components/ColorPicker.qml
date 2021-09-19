import QtQuick 2.9
import QtGraphicalEffects 1.0
import Nymea 1.0
import "../utils"

Item {
    id: root

    property Thing thing: null

    readonly property State colorState: thing ? thing.stateByName("color") : null
    readonly property State powerState: thing ? thing.stateByName("power") : null

    Connections {
        target: colorState
        onValueChanged: {
            if (actionQueue.pendingValue === null) {
                actionQueue.useStoredPoint = false
            }
        }
    }

    ActionQueue {
        id: actionQueue
        thing: root.thing
        stateType: thing.thingClass.stateTypes.findByName("color")

        property bool useStoredPoint: false
        property point storedPoint: Qt.point(0, 0)
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
        onWidthChanged: dragHandle.updatePoint()
        onHeightChanged: dragHandle.updatePoint()

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
    }

    Desaturate {
        id: colorizer
        anchors.fill: gradient
        source: gradient
        desaturation: root.powerState.value === true ? 0 : 1
        Behavior on desaturation { NumberAnimation { duration: Style.animationDuration } }
        visible: false
    }

    Rectangle {
        id: mask
        anchors.fill: gradient
        radius: width / 2
    }
    OpacityMask {
        anchors.fill: gradient
        source: colorizer
        maskSource: mask
    }


    Rectangle {
        id: dragHandle
        width: 20
        height: 20
        radius: height / 2
        color: Style.backgroundColor
        border.color: Style.foregroundColor
        border.width: 2

        x: point.x + gradient.width / 2 + gradient.x - width / 2
        y: point.y + gradient.height / 2 + gradient.y - height / 2

        property color shownColor: root.colorState ? actionQueue.pendingValue || root.colorState.value : "white`"
        onShownColorChanged: updatePoint()
//        Component.onCompleted: updatePoint()

        property point point: Qt.point(0,0);
        function updatePoint() {

            if (actionQueue.useStoredPoint) {
                point = actionQueue.storedPoint
                return
            }

            print("current color:", shownColor.r, shownColor.g, shownColor.b)

            var whitePart = Math.min(Math.min(shownColor.r, shownColor.g), shownColor.b)

            var stopIndex = 0
            var progressInStop = 0
            if (shownColor.r === 1) {
                if (shownColor.g > shownColor.b) {
                    stopIndex = 0
                    progressInStop = shownColor.g - whitePart
                } else {
                    stopIndex = 5
                    progressInStop = 1 - shownColor.b + whitePart
                }
            }
            if (shownColor.g === 1) {
                if (shownColor.r > shownColor.b) {
                    stopIndex = 1
                    progressInStop = 1 - shownColor.r + whitePart
                } else {
                    stopIndex = 2
                    progressInStop = shownColor.b - whitePart
                }
            }
            if (shownColor.b === 1) {
                if (shownColor.r > shownColor.g) {
                    stopIndex = 4
                    progressInStop = shownColor.r - whitePart
                } else {
                    stopIndex = 3
                    progressInStop = 1-shownColor.g + whitePart
                }
            }

            var stopBefore = g.stops[stopIndex]
            var stopAfter = g.stops[stopIndex+1]

            print("stopIndex", stopIndex)
            print("stopBefore:", stopBefore.color.r, stopBefore.color.g, stopBefore.color.b)
            print("stopAfter:", stopAfter.color.r, stopAfter.color.g, stopAfter.color.b)
            print("progressInStop", progressInStop)


            print("beforePosition", stopBefore.position)

            var positionInGradient = stopBefore.position + (stopAfter.position - stopBefore.position) * progressInStop

            print("positionInGradient", positionInGradient)

            var degrees = 360 * positionInGradient;
            degrees -= 90;

            var radian = degrees * 0.0174532925

            var radius = gradient.height * 0.9 / 2 * (1-whitePart)


            var x = radius * Math.cos(radian)
            var y = radius * Math.sin(radian)

            print("degrees", degrees)
            print("radius", radius)

            print("Setting point to", x, y)
            point = Qt.point(x, y)
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

            // Store the coordinates (limited to the circle) as the above calculation is lossy so we can't precicely
            // calcuate the position from the color but we don't want the drag handle jumping while dragging.
            var rad = (angle - 90) / 180 * Math.PI
            var radius = Math.min(distanceFromCenter, width * 0.9 / 2)
            actionQueue.storedPoint = Qt.point(radius * Math.cos(rad), radius * Math.sin(rad))
            actionQueue.useStoredPoint = true
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
