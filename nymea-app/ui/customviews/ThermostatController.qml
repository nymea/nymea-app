import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
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
        property int steps: roundToPrecision(root.targetTemperatureState.maxValue - root.targetTemperatureState.minValue) * (1/root.precision)
        property double stepSize: (root.targetTemperatureState.maxValue - root.targetTemperatureState.minValue) / steps
        property double anglePerStep: maxAngle / steps

        readonly property double currentValue: actionQueue.pendingValue || root.targetTemperatureState.value
        readonly property double targetTempStep: roundToPrecision(currentValue - root.targetTemperatureState.minValue) * (1/root.precision)
        readonly property double currentTempStep: root.temperatureState ? roundToPrecision(root.temperatureState.value - root.targetTemperatureState.minValue) * (1/root.precision) : 0


        readonly property double targetTemperature: roundToPrecision(Types.toUiValue(currentValue, root.targetTemperatureStateType.unit))

        readonly property color currentColor: {
            if (currentTempStep && currentTempStep < targetTempStep) {
                return app.interfaceToColor("heating");
            } else if (currentTempStep && currentTempStep > targetTempStep) {
                return app.interfaceToColor("cooling");
            }
            return Style.accentColor;
        }

        function angleToValue(angle) {
            var from = root.targetTemperatureState.minValue
            var to = root.targetTemperatureState.maxValue
            return (to - from) * angle / maxAngle + from
        }

        ColumnLayout {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -Style.smallMargins
            width: parent.width * 0.6

            Label {
                Layout.fillWidth: true
                text: canvas.targetTemperature.toFixed(1) + Types.toUiUnit(Types.UnitDegreeCelsius)
                wrapMode: Text.WordWrap
                font.pixelSize: Math.min(Style.hugeFont.pixelSize, canvas.height / 8)
                maximumLineCount: 2
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                color: canvas.currentColor
            }
            Label {
                Layout.fillWidth: true
                text: Types.toUiValue(root.temperatureState.value, root.temperatureStateType.unit).toFixed(1) + Types.toUiUnit(Types.UnitDegreeCelsius)
                font.pixelSize: Math.min(Style.largeFont.pixelSize, canvas.height / 12)
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
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

            for(var step = 0; step < steps; step += root.precision) {
                var angle = step * anglePerStep + startAngle;
                var innerRadius = canvas.width * 0.4
                var outerRadius = canvas.width * 0.5

                if (canvas.targetTempStep === step) {
                    if (canvas.currentTempStep && canvas.currentTempStep < canvas.targetTempStep) {
                        ctx.strokeStyle = app.interfaceToColor("heating");
                    } else if (canvas.currentTempStep && canvas.currentTempStep > canvas.targetTempStep) {
                        ctx.strokeStyle = app.interfaceToColor("cooling");
                    } else {
                        ctx.strokeStyle = Style.accentColor;
                    }
                    innerRadius = canvas.width * 0.38
                    ctx.lineWidth = 4;
                } else if (canvas.currentTempStep && canvas.currentTempStep === step) {
                    if (canvas.currentTempStep < canvas.targetTempStep) {
                        ctx.strokeStyle = app.interfaceToColor("heating");
                    } else {
                        ctx.strokeStyle = app.interfaceToColor("cooling");
                    }
                    ctx.lineWidth = 3;
                } else  if (canvas.currentTempStep && canvas.currentTempStep < step && step < canvas.targetTempStep) {
                    ctx.strokeStyle = app.interfaceToColor("heating");
                    ctx.lineWidth = 2;
                } else  if (canvas.currentTempStep && canvas.currentTempStep > step && step > canvas.targetTempStep) {
                    ctx.strokeStyle = app.interfaceToColor("cooling");
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

                ctx.moveTo(innerPointX, innerPointY);
                ctx.lineTo(outerPointX, outerPointY);
                ctx.stroke();
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
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.smallMargins
        size: Math.min(Style.bigIconSize, parent.height / 5)
        name: root.heatingOnState && root.heatingOnState.value === true
              ? "qrc:/icons/thermostat/heating.svg"
              : root.coolingOnState && root.coolingOnState.value === true
                ? "qrc:/icons/thermostat/cooling.svg"
                : ""
        color: root.heatingOnState && root.heatingOnState.value === true
              ? app.interfaceToColor("heating")
              : root.coolingOnState && root.coolingOnState.value === true
                ? app.interfaceToColor("cooling")
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
                var currentValue = actionQueue.pendingValue ? actionQueue.pendingValue : root.targetTemperatureState.value
                var newValue = currentValue + valueDiff
                newValue = Math.min(root.targetTemperatureState.maxValue, Math.max(root.targetTemperatureState.minValue, newValue))
                print("newValue:", newValue, "current:", currentValue, "diff:", valueDiff, root.targetTemperatureState.minValue)
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
