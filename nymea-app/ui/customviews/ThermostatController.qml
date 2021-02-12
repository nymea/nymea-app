import QtQuick 2.9
import Nymea 1.0
import "../utils"
import "../components"

Item {
    id: root

    property Thing thing: null

    property double precision: 0.5

    readonly property StateType targetTemperatureStateType: thing.thingClass.stateTypes.findByName("targetTemperature")
    readonly property State targetTemperatureState: thing.stateByName("targetTemperature")
    readonly property StateType temperatureStateType: thing.thingClass.stateTypes.findByName("temperature")
    readonly property State temperatureState: thing.stateByName("temperature")
    readonly property State heatingOnState: thing.stateByName("heatingOn")
    readonly property State coolingOnState: thing.stateByName("coolingOn")

    Connections {
        target: targetTemperatureState
        onValueChanged: canvas.requestPaint()
    }
    Connections {
        target: temperatureState
        onValueChanged: canvas.requestPaint()
    }
    ActionQueue {
        id: actionQueue
        thing: root.thing
        stateType: targetTemperatureStateType
        onPendingValueChanged: canvas.requestPaint();
    }

    Canvas {
        id: canvas
        width: Math.min(parent.width, parent.height)
        height: width
        anchors.centerIn: parent

        property int startAngle: 135
        property int maxAngle: 270
        property int steps: roundToPrecision(root.targetTemperatureStateType.maxValue - root.targetTemperatureStateType.minValue) * (1/root.precision)
        property double stepSize: (root.targetTemperatureStateType.maxValue - root.targetTemperatureStateType.minValue) / steps
        property double anglePerStep: maxAngle / steps


        function angleToValue(angle) {
            var from = root.targetTemperatureStateType.minValue
            var to = root.targetTemperatureStateType.maxValue
            return (to - from) * angle / maxAngle + from
        }

        onPaint: {
            var ctx = canvas.getContext('2d');
            ctx.save();
            ctx.reset()


            var center = { x: canvas.width / 2, y: canvas.height / 2 };
            var rotation = 135;

            // Background arc
            ctx.beginPath()
//            ctx.strokeStyle = Style.tileBackgroundColor;
            ctx.lineWidth = 0;
            ctx.fillStyle = Style.tileBackgroundColor
            var innerRadius = canvas.width * 0.4
            var outerRadius = canvas.width * 0.5
            var endAngle = (maxAngle + startAngle) % 360
            var radStart = startAngle * Math.PI/180;
            var radEnd = endAngle * Math.PI/180;
            ctx.arc(center.x, center.y, outerRadius, radStart, radEnd)
            ctx.arc(center.x, center.y, innerRadius, radEnd, radStart, true)
            ctx.fill();
            ctx.closePath();

            // Step lines
            var currentValue = actionQueue.pendingValue || root.targetTemperatureState.value
            var targetTempStep = roundToPrecision(currentValue - root.targetTemperatureStateType.minValue) * (1/root.precision)
            var currentTempStep;
            if (root.temperatureState) {
                currentTempStep = roundToPrecision(root.temperatureState.value - root.targetTemperatureStateType.minValue) * (1/root.precision)
            }

            for(var step = 0; step < steps; step += root.precision) {
                var angle = step * anglePerStep + startAngle;
                var innerRadius = canvas.width * 0.4
                var outerRadius = canvas.width * 0.5

                if (targetTempStep === step) {
                    if (currentTempStep && currentTempStep < targetTempStep) {
                        ctx.strokeStyle = "red";
                    } else if (currentTempStep && currentTempStep > targetTempStep) {
                        ctx.strokeStyle = "dodgerblue";
                    } else {
                        ctx.strokeStyle = Style.accentColor;
                    }
                    innerRadius = canvas.width * 0.38
                    ctx.lineWidth = 4;
                } else if (currentTempStep && currentTempStep === step) {
                    if (currentTempStep < targetTempStep) {
                        ctx.strokeStyle = "red";
                    } else {
                        ctx.strokeStyle = "dodgerblue";
                    }
                    ctx.lineWidth = 3;
                } else  if (currentTempStep && currentTempStep < step && step < targetTempStep) {
                    ctx.strokeStyle = "red";
                    ctx.lineWidth = 2;
                } else  if (currentTempStep && currentTempStep > step && step > targetTempStep) {
                    ctx.strokeStyle = "dodgerblue";
                    ctx.lineWidth = 2;
                } else {
                    ctx.strokeStyle = Style.tileOverlayColor;
                    ctx.lineWidth = 1;
                }

                ctx.beginPath();
                // rotate
                //convert to radians
                var rad = angle * Math.PI/180;
                var c = Math.cos(rad);
                var s = Math.sin(rad);
                var innerPointX = center.x + (innerRadius * c);
                var innerPointY = center.y + (innerRadius * s);
                var outerPointX = center.x + (outerRadius * c);
                var outerPointY = center.x + (outerRadius * s);

                context.moveTo(innerPointX, innerPointY);
                context.lineTo(outerPointX, outerPointY);
                ctx.stroke();
                ctx.closePath();
            }

            ctx.beginPath();
            ctx.font = "" + app.hugeFont + "px " + Style.fontFamily;
            ctx.fillStyle = Style.foregroundColor;
            var roundedTargetTemp = Types.toUiValue(currentValue, root.targetTemperatureStateType.unit)
            roundedTargetTemp = roundToPrecision(roundedTargetTemp).toFixed(1) + "°"
            var size = ctx.measureText(roundedTargetTemp)
            ctx.text(roundedTargetTemp, center.x - size.width / 2, center.y + app.hugeFont / 2);
            ctx.fill();
            ctx.closePath();

            if (root.temperatureState) {
                ctx.beginPath();
                ctx.font = "" + app.largeFont + "px " + Style.fontFamily;
                var roundedTemp = Types.toUiValue(root.temperatureState.value, root.temperatureStateType.unit)
                roundedTemp = roundToPrecision(roundedTemp) + "°"
                size = ctx.measureText(roundedTemp)
                ctx.text(roundedTemp, center.x - size.width / 2, center.y + app.hugeFont + app.margins);
                ctx.fill();
                ctx.closePath();
            }

            ctx.restore();
        }

        function roundToPrecision(value) {
            var tmp = Math.round(value / root.precision) * root.precision;
            return tmp;
        }
    }

    ColorIcon {
        width: app.largeIconSize
        height: width
        anchors { bottom: canvas.bottom; horizontalCenter: canvas.horizontalCenter }
        name: root.heatingOnState && root.heatingOnState.value === true
              ? "../images/thermostat/heating.svg"
              : root.coolingOnState && root.coolingOnState.value === true
                ? "../images/thermostat/cooling.svg"
                : ""
        color: root.heatingOnState && root.heatingOnState.value === true
              ? "red"
              : root.coolingOnState && root.coolingOnState.value === true
                ? "dodgerblue"
                : Style.iconColor
    }

    MouseArea {
        anchors.fill: canvas

        property bool dragging: false
        property double lastAngle
        property double angleDiff

        onPressed: {
            lastAngle = calculateAngle(mouseX, mouseY)
        }

        onPositionChanged: {
            var angle = calculateAngle(mouseX, mouseY)
            var tmpDiff = angle - lastAngle
            if (tmpDiff > 300) {
                tmpDiff -= 360
            }
            if (tmpDiff < -300) {
                tmpDiff += 360
            }

            lastAngle = angle;

            angleDiff += tmpDiff

            var valueDiff = angleDiff / canvas.anglePerStep * canvas.stepSize
            valueDiff = canvas.roundToPrecision(valueDiff)
            if (Math.abs(valueDiff) > 0) {
                var currentValue = actionQueue.pendingValue || root.targetTemperatureState.value
                var newValue = currentValue + valueDiff
                newValue = Math.min(root.targetTemperatureStateType.maxValue, Math.max(root.targetTemperatureStateType.minValue, newValue))
                if (currentValue !== newValue) {
                    actionQueue.sendValue(newValue)
                }
                var steps = Math.floor(valueDiff / canvas.stepSize)
                angleDiff -= steps * canvas.anglePerStep
            }
        }

        function calculateAngle(mouseX, mouseY) {
            // transform coords to center of dial
            mouseX -= canvas.width / 2
            mouseY -= canvas.height / 2

            var rad = Math.atan(mouseY / mouseX);
            var angle = rad * 180 / Math.PI

            angle += 90;

            if (mouseX < 0 && mouseY >= 0) angle = 180 + angle;
            if (mouseX < 0 && mouseY < 0) angle = 180 + angle;

            return angle;
        }
    }
}
