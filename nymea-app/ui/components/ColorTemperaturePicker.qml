import QtQuick 2.9
import QtGraphicalEffects 1.0
import Nymea 1.0
import "../utils"

Item {
    id: root
    implicitWidth: orientation == Qt.Horizontal ? 300 : app.hugeIconSize
    implicitHeight: orientation == Qt.Horizontal ? app.hugeIconSize : 300

    property Thing thing: null

    property int orientation: Qt.Horizontal

    readonly property StateType colorTemperatureStateType: root.thing.thingClass.stateTypes.findByName("colorTemperature")

    property int value: thing.stateByName("colorTemperature").value

    ActionQueue {
        id: actionQueue
        thing: root.thing
        stateType: root.colorTemperatureStateType
    }

    Rectangle {
        id: clipRect
        anchors.fill: parent
        radius: Style.tileRadius
    }

    LinearGradient {
        anchors.fill: parent
        start: root.orientation == Qt.Horizontal ? Qt.point(0, 0) : Qt.point(0, height)
        end: root.orientation == Qt.Horizontal ? Qt.point(width, 0) : Qt.point(0, 0)
        source: clipRect
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#dfffff" }
            GradientStop { position: 0.5; color: "#ffffea" }
            GradientStop { position: 1.0; color: "#ffd649" }
        }
    }

    Rectangle {
        id: dragHandle
        property double valuePercentage: ((actionQueue.pendingValue || root.value) - root.colorTemperatureStateType.minValue) / (root.colorTemperatureStateType.maxValue - root.colorTemperatureStateType.minValue)
        x: orientation == Qt.Horizontal ? valuePercentage * (root.width - dragHandle.width) : 0
        y: root.orientation === Qt.Vertical ? root.height - dragHandle.height - (valuePercentage * (root.height - dragHandle.height)) : 0
        height: root.orientation == Qt.Horizontal ? parent.height : 8
        width: root.orientation == Qt.Horizontal ? 8 : parent.width
        radius: 4
        color: Qt.tint(Style.backgroundColor, Qt.rgba(Style.foregroundColor.r, Style.foregroundColor.g, Style.foregroundColor.b, 0.5))
    }

    MouseArea {
        anchors.fill: parent
        onPositionChanged: {
            var minCt = root.colorTemperatureStateType.minValue;
            var maxCt = root.colorTemperatureStateType.maxValue
            var ct;
            if (root.orientation == Qt.Horizontal) {
                ct = Math.min(maxCt, Math.max(minCt, (mouseX * (maxCt - minCt) / (width - dragHandle.width)) + minCt))
            } else {
                ct = Math.min(maxCt, Math.max(minCt, ((height - mouseY) * (maxCt - minCt) / (height - dragHandle.height)) + minCt))
            }
            actionQueue.sendValue(ct);
        }
    }
}

