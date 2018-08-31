import QtQuick 2.4
import QtQuick.Controls 2.1
import Nymea 1.0
import QtQuick.Controls.Material 2.2

Item {
    id: root

    property var model: null

    property color color: "grey"
    property string mode: "bezier" // "bezier" or "bars"

    Connections {
        target: model
        onCountChanged: canvas.requestPaint()
    }
    onModelChanged: canvas.requestPaint()

    readonly property var device: root.model ? engine.deviceManager.devices.getDevice(root.model.deviceId) : null
    readonly property var deviceClass: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
    readonly property var stateType: deviceClass ? deviceClass.stateTypes.getStateType(root.model.typeIds[0]) : null

    Label {
        anchors.centerIn: parent
        width: parent.width - 2 * app.margins
        wrapMode: Text.WordWrap
        text: qsTr("Sorry, there isn't enough data to display a graph here yet!")
        visible: !root.model.busy && root.model.count <= 2
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: app.largeFont
    }

    BusyIndicator {
        anchors.centerIn: parent
        visible: model.busy
    }

    Canvas {
        id: canvas
        visible: root.model.count > 2

        anchors.fill: parent

        property int minTemp: {
            var lower = Math.floor(root.model.minimumValue - 2);
            var upper = Math.ceil(root.model.maximumValue + 2);
            if (isNaN(lower) || isNaN(upper) || lower == undefined || upper == undefined) {
                return 0
            }

            while ((upper - lower) % 10 != 0) {
                lower -= 1;
                if ((upper - lower) % 10 != 0) {
                    upper += 1;
                }
            }
            return lower;
        }

        property int maxTemp: {
            var lower = Math.floor(root.model.minimumValue - 2);
            var upper = Math.ceil(root.model.maximumValue + 2);
            if (isNaN(lower) || isNaN(upper) || lower == undefined || upper == undefined) {
                return 0
            }
            while ((upper - lower) % 10 != 0) {
                lower -= 1;
                if ((upper - lower) % 10 != 0) {
                    upper += 1;
                }
            }
            return upper;
        }

        property int topMargins: app.margins
        property int bottomMargins: app.margins
        property int leftMargins: app.margins
        property int rightMargins: app.margins

        property color gridColor: "#d0d0d0"

        property int contentWidth: canvas.width - leftMargins - rightMargins
        property int contentHeight: canvas.height - topMargins - bottomMargins

        property int totalSections: Math.round((maxTemp - minTemp) / 10) * 10
        property int sections: {
            var tmp = totalSections;
            while (tmp >= 10) {
                tmp /= 2;
            }
            return tmp;
        }

        onPaint: {
//            print("painting graph")
            var ctx = canvas.getContext('2d');
            ctx.save();

            ctx.reset()

            ctx.font = "" + app.smallFont + "px Ubuntu";
            ctx.globalAlpha = 1//canvas.alpha;
            //ctx.fillStyle = canvas.fillStyle;

            var textSize = ctx.measureText(maxTemp);
            var leftTextWidth = textSize.width + app.margins;
            var bottomTextHeight = app.smallFont * 2 + app.margins;
            var topTextHeight = app.smallFont + app.margins;
            ctx.translate(leftMargins + leftTextWidth, topMargins);
            var gridWidth = contentWidth - leftTextWidth;
            var gridHeight = contentHeight - bottomTextHeight;


            paintGrid(ctx, gridWidth, gridHeight)
            enumerate(ctx, gridWidth, gridHeight)

            if (root.mode == "bezier") {
                paintGraph(ctx, gridWidth, gridHeight)
            } else {
                paintBars(ctx, gridWidth, gridHeight)
            }

            ctx.restore();

        }

        function paintGrid(ctx, width, height) {
            ctx.strokeStyle = canvas.gridColor;
            ctx.fillStyle = Material.foreground
            ctx.lineWidth = 1;

            ctx.beginPath();
            ctx.rect(0, 0, width, height)
            ctx.stroke();
            ctx.closePath();

            // Horizontal lines
            var tempInterval = (maxTemp - minTemp) / sections;
            var pps = (height / sections);

            for (var i = 0; i <= sections; i++) {
                ctx.beginPath();
                ctx.lineWidth = 1;
                ctx.strokeStyle = canvas.gridColor
                ctx.moveTo(0, i * pps);
                ctx.lineTo(width, i * pps)
                ctx.stroke();
                ctx.closePath();

                ctx.beginPath();
                var label = maxTemp - (tempInterval * i).toFixed(0)
                var textSize = ctx.measureText(label)
                ctx.strokeStyle = Material.foreground
                ctx.fillStyle = Material.foreground
                ctx.lineWidth = 0;
                ctx.text(label, -textSize.width - app.margins, i * pps + 5)
//                ctx.stroke();
                ctx.fill()
                ctx.closePath()
            }

            ctx.beginPath();
            ctx.strokeStyle = Material.foreground
            ctx.fillStyle = Material.foreground
            ctx.lineWidth = 0;
            var label = root.stateType ? root.stateType.unitString : ""
            var textSize = ctx.measureText(label)
            ctx.text(label, -textSize.width - app.margins, height + app.margins + app.smallFont)
//            ctx.stroke();
            ctx.fill()
            ctx.closePath()

        }

        function enumerate(ctx, width, height) {
            // enumate x axis
            ctx.beginPath();
            ctx.globalAlpha = 1;
            ctx.strokeStyle = Material.foreground
            ctx.fillStyle = Material.foreground
            ctx.lineWidth = 0;
            // enumerate Y axis

            var lastTextX = -1;
            for (var i = 0; i < model.count; i++) {
                var x = width / (model.count) * i;
                if (x < lastTextX) continue;

                var label = model.get(i).dayString
                var textSize = ctx.measureText(label)
                ctx.text(label.slice(0,2).concat("."), x, height + app.smallFont + app.margins / 2)

                switch (model.average) {
                case ValueLogsProxyModel.AverageQuarterHour:
                case ValueLogsProxyModel.AverageHourly:
                case ValueLogsProxyModel.AverageDayTime:
                    label = model.get(i).timeString
                    break;
                default:
                    label = model.get(i).dateString
                }

                textSize = ctx.measureText(label)
                ctx.text(label, x, height + app.smallFont * 2 + app.margins)
                lastTextX = x + textSize.width;
            }

//            ctx.stroke();
            ctx.fill()
            ctx.closePath();
        }

        function paintGraph(ctx, width, height) {
            if (model.count <= 1) {
                return;
            }

            var tempInterval = (maxTemp - minTemp) / sections;
            var pps = (height / sections)

            ctx.beginPath();
            ctx.globalAlpha = 1;
            ctx.lineWidth = 2;
            var graphStroke = root.color;
            var grapFill = Qt.rgba(root.color.r, root.color.g, root.color.b, .4);

            ctx.strokeStyle = graphStroke;
            ctx.fillStyle = grapFill;

            var points = new Array();
            for (var i = 0; i < model.count; i++) {
                var value = model.get(i).value;
                var point = new Object();
//                print("painting value", value)
                point.x = (i == 0) ? 0 : (width / (model.count - 2) * i);
                point.y = height - (value - minTemp) / tempInterval * pps;
                points.push(point);
            }

            paintBezier(ctx, points);
            ctx.stroke();
            ctx.closePath();

            ctx.beginPath();
            paintBezier(ctx, points)
            ctx.lineTo(width, height);
            ctx.lineTo(0, height);
            ctx.fill();
            ctx.closePath();


            ctx.beginPath();
            ctx.globalAlpha = 1;
            ctx.lineWidth = 2;
            ctx.strokeStyle = "green"
            ctx.fillStyle = "green"

            points = new Array();
            for (var i = 0; i < model.count; i++) {
                var dayMaxTemp = model.get(i).maxTemp;
                var point = new Object();
                point.x = (i == 0) ? 0 : (width / (model.count - 1) * i);
                point.y = - (dayMaxTemp - maxTemp) / tempInterval * pps;
                points.push(point);
            }

            paintBezier(ctx, points);

            ctx.stroke();
            ctx.closePath();
        }

        function paintBezier(ctx, points) {

            if (points.length == 2) {
                ctx.moveTo(points[0].x, points[0].y)
                ctx.lineTo(points[1].x, points[1].y)
            } else {
                var n = points.length - 1;
                points[0].rhsx = points[0].x + 2 * points[1].x;
                points[0].rhsy = points[0].y + 2 * points[1].y;
                for (var i = 1; i < n - 1; i++) {
                    points[i].rhsx = 4 * points[i].x + 2 * points[i+1].x;
                    points[i].rhsy = 4 * points[i].y + 2 * points[i+1].y;
                }
                points[n - 1].rhsx = (8 * points[n - 1].x + points[n].x) / 2;
                points[n - 1].rhsy = (8 * points[n - 1].y + points[n].y) / 2;

                var b = 2.0;
                n = points.length - 1;
                points[0].firstcontrolx = points[0].rhsx / b;
                points[0].firstcontroly = points[0].rhsy / b;

                for (var i = 1; i < n; i++) {
                    points[i].tmp = 1 / b;
                    b = (i < n - 1 ? 4.0 : 3.5) - points[i].tmp;
                    points[i].firstcontrolx = (points[i].rhsx - points[i - 1].firstcontrolx) / b;
                    points[i].firstcontroly = (points[i].rhsy - points[i - 1].firstcontroly) / b;
                }
                for (var i = 1; i < n; i++) {
                    points[n - i - 1].firstcontrolx -= points[n - i].tmp * points[n - i].firstcontrolx;
                    points[n - i - 1].firstcontroly -= points[n - i].tmp * points[n - i].firstcontroly;
                }

                n = points.length - 1;
                for (var i = 0; i < n; i++) {
                    points[i].secondcontrolx = 2 * points[i + 1].x - points[i + 1].firstcontrolx;
                    points[i].secondcontroly = 2 * points[i + 1].y - points[i + 1].firstcontroly;
                }
                points[n - 1].secondcontrolx = (points[n].x + points[n - 1].firstcontrolx) / 2;
                points[n - 1].secondcontroly = (points[n].x + points[n - 1].firstcontroly) / 2;

                ctx.moveTo(points[0].x, points[0].y);
                for (var i = 0; i < n - 1; i++) {
//                    ctx.lineTo(points[i].firstcontrolx, points[i].firstcontroly)
//                    ctx.lineTo(points[i].secondcontrolx, points[i].secondcontroly)
//                    ctx.lineTo(points[i+1].x, points[i+1].y)

                    ctx.bezierCurveTo(points[i].firstcontrolx, points[i].firstcontroly,
                                      points[i].secondcontrolx, points[i].secondcontroly,
                                      points[i + 1].x, points[i + 1].y)
                }
            }
        }

        function paintBars(ctx, width, height) {
            if (model.count <= 1) {
                return;
            }

            var tempInterval = (maxTemp - minTemp) / sections;
            var pps = (height / sections)

            ctx.globalAlpha = 1;
            ctx.lineWidth = 2;
            var graphStroke = root.color;
            var grapFill = Qt.rgba(root.color.r, root.color.g, root.color.b, .2);

            ctx.strokeStyle = graphStroke;
            ctx.fillStyle = grapFill;


            for (var i = 0; i < model.count; i++) {
                ctx.beginPath();
                var value = model.get(i).value;
                var x = width / (model.count) * i;
                var y = height - (value - minTemp) / tempInterval * pps;

                var slotWidth = width / model.count
                ctx.rect(x,y, slotWidth - 5, height - y)
                ctx.fillRect(x,y, slotWidth - 5, height - y);
                ctx.stroke();
                ctx.fill();
                ctx.closePath();
            }
        }

        function hourToX(hour, width) {
            var entries = root.day.count;
            return canvas.width / entries * hour
        }
    }
}
