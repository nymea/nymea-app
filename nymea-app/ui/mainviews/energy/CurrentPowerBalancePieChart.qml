import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
import QtCharts 2.2
import Nymea 1.0
import "qrc:/ui/components"

Item {
    id: root

    property bool animationsEnabled: false
    property EnergyManager energyManager: null

    readonly property double fromGrid: Math.max(0, energyManager.currentPowerAcquisition)
    readonly property double fromStorage: -Math.min(0, energyManager.currentPowerStorage)
    readonly property double toStorage: -Math.min(0, -energyManager.currentPowerStorage)
    readonly property double fromProduction: energyManager.currentPowerConsumption - fromGrid - fromStorage
    readonly property double toGrid: Math.max(0, - energyManager.currentPowerAcquisition)

    QtObject {
        id: d
        function formatValue(value) {
            var ret
            if (value >= 1000) {
                ret = (value / 1000).toFixed(1) + "kW"
            } else {
                ret = value.toFixed(1) +  "W"
            }
            return ret
        }

        property double progress: 0
        onProgressChanged: canvas.requestPaint()

        property int chartSize: width / 2.5

        property point acquisitionPos: Qt.point(chartSize/2 + Style.margins, chartSize/2 + Style.margins)
        property point productionPos: Qt.point(root.width - (chartSize/2 + Style.margins), chartSize/2 + Style.margins)
        property point storagePos: Qt.point(chartSize/2 + Style.margins, root.height - (chartSize/2 + Style.margins))
        property point consumptionPos: batteries.count > 0 || producers.count === 0
                                       ? Qt.point(root.width - (chartSize/2 + Style.margins), root.height - (chartSize/2 + Style.margins))
                                       : Qt.point(root.width / 2, root.height - (chartSize/2 + Style.margins))
    }

    ThingsProxy {
        id: batteries
        engine: _engine
        shownInterfaces: ["energystorage"]
    }
    ThingsProxy {
        id: producers
        engine: _engine
        shownInterfaces: ["smartmeterproducer"]
    }

    NumberAnimation {
        id: progressAnimation
        target: d
        property: "progress"
        from: 0
        to: 1
        running: root.animationsEnabled
        loops: Animation.Infinite
        duration: 5000
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");

            var solarPos = Qt.point(d.productionPos.x - width / 2, d.productionPos.y - height / 2)
            var storagePos = Qt.point(d.storagePos.x - width / 2, d.storagePos.y - width / 2)
            var consumptionPos = Qt.point(d.consumptionPos.x - width / 2, d.consumptionPos.y - height / 2)
            var gridPos = Qt.point(d.acquisitionPos.x - width / 2, d.acquisitionPos.y - height / 2)

            ctx.save();
            ctx.reset()

            ctx.translate(width / 2, height / 2);

            ctx.strokeStyle = Style.foregroundColor
            ctx.fillStyle = Style.foregroundColor
            ctx.lineWidth = 2

            var biggest = Math.max(
                        Math.abs(energyManager.currentPowerAcquisition),
                        Math.abs(energyManager.currentPowerConsumption),
                        Math.abs(energyManager.currentPowerProduction),
                        Math.abs(energyManager.currentPowerStorage)
                        )
            var size


            if (root.toGrid > 0) {
                size = root.toGrid / biggest
                drawDottedCurve(ctx, solarPos, gridPos, size, Style.yellow)
            }

            if (energyManager.currentPowerProduction < 0 && root.fromProduction) {
                size = root.fromProduction / biggest
                drawDottedCurve(ctx, solarPos, consumptionPos, size, Style.green)
            }

            if (batteries.count > 0) {
                if (energyManager.currentPowerStorage > 0) {
                    if (energyManager.currentPowerProduction < 0) {
                        size = Math.abs(energyManager.currentPowerStorage) / biggest
                        drawDottedCurve(ctx, solarPos, storagePos, size, Style.purple)
                    } else {
                        size = Math.abs(energyManager.currentPowerStorage) / biggest
                        drawDottedCurve(ctx, gridPos, storagePos, size, Style.purple)
                    }
                }

                if (energyManager.currentPowerStorage < 0) {
                    size = Math.abs(energyManager.currentPowerStorage) / biggest
                    drawDottedCurve(ctx, storagePos, consumptionPos, size, Style.orange)
                }
            }

            if (energyManager.currentPowerAcquisition > 0) {
                size = Math.abs(energyManager.currentPowerAcquisition) / biggest
                drawDottedCurve(ctx, gridPos, consumptionPos, size, Style.red)
            }

            ctx.restore();
        }

        function bezierCurvePoint(p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y, t) {
            var x = Math.pow(1-t, 3)*p0x + 3*Math.pow(1-t, 2)*t*p1x + 3*(1-t)*Math.pow(t, 2)*p2x + Math.pow(t, 3)*p3x;
            var y = Math.pow(1-t, 3)*p0y + 3*Math.pow(1-t, 2)*t*p1y + 3*(1-t)*Math.pow(t, 2)*p2y + Math.pow(t, 3)*p3y;
            return Qt.point(x, y)
        }

        function circlePoint(center, radius, angle) {
            var x = center.x + radius * Math.cos(angle * 2 * Math.PI / 360)
            var y = center.y + radius * Math.sin(angle * 2 * Math.PI / 360)
            return Qt.point(x, y)
        }

        function drawDottedCurve(ctx, start, end, size, color) {
            var c1 = getControlPoint(start)
            var c2 = getControlPoint(end)
            ctx.fillStyle = color
            ctx.strokeStyle = color
            var count = 10;
            for (var i = 1; i <= count; i++) {
                var offset = 1 / count;
                var progress = d.progress + i * offset
                if (progress > 1)
                    progress -= 1
                var point = bezierCurvePoint(start.x, start.y, c1.x, c1.y, c2.x, c2.y, end.x, end.y, progress)
//                print("painting", d.progress, point.x, point.y)
                ctx.beginPath();
                ctx.arc(point.x, point.y, Math.max(1, size * 5), 0, 2 *Math.PI)
                ctx.stroke();
                ctx.fill();
                ctx.closePath();

            }

        }

        function getControlPoint(point) {
            return Qt.point(point.x * .1, point.y * .1)
        }

    }

    Item {
        id: acquisitionItem
        x: d.acquisitionPos.x - width / 2
        y: d.acquisitionPos.y - height / 2
        width: d.chartSize
        height: d.chartSize

        Rectangle {
            anchors.centerIn: parent
            width: acquisitionChart.plotArea.width
            height: acquisitionChart.plotArea.height
            color: Style.backgroundColor
            radius: width / 2
        }

        ColumnLayout {
            anchors.centerIn: parent
            width: acquisitionChart.plotArea.width * 0.8
            ColorIcon {
                Layout.alignment: Qt.AlignHCenter
                size: Style.bigIconSize
    //            color: Style.red
                name: "/ui/images/power-grid.svg"
            }
            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: d.formatValue(Math.abs(energyManager.currentPowerAcquisition))
//                color: energyManager.currentPowerAcquisition >= 0 ? Style.red : Style.yellow
            }
        }


        ChartView {
            id: acquisitionChart
            anchors.fill: parent
            legend.visible: false
            margins { left: 0; top: 0; right: 0; bottom: 0 }
            backgroundColor: "transparent"
            animationOptions: root.animationsEnabled ? NymeaUtils.chartsAnimationOptions : ChartView.NoAnimation

            PieSeries {
                size: 1
                holeSize: 0.8

                PieSlice {
                    color: Style.red
                    borderColor: color
                    borderWidth: 0
                    value: root.fromGrid
                }
                PieSlice {
                    color: Style.yellow
                    borderColor: color
                    borderWidth: 0
                    value: root.toGrid
                }
                PieSlice {
                    color: Style.tooltipBackgroundColor
                    borderColor: color
                    borderWidth: 0
                    value: energyManager.currentPowerAcquisition == 0 ? 1 : 0
                }
            }
        }
    }


    Item {
        id: productionItem
        x: d.productionPos.x - width / 2
        y: d.productionPos.y - height / 2
        width: d.chartSize
        height: d.chartSize
        visible: producers.count > 0

        Rectangle {
            anchors.centerIn: parent
            width: productionChart.plotArea.width
            height: productionChart.plotArea.height
            color: Style.backgroundColor
            radius: width / 2
        }

        ColumnLayout {
            anchors.centerIn: parent
            width: productionChart.plotArea.width * 0.8
            ColorIcon {
                Layout.alignment: Qt.AlignHCenter
                size: Style.bigIconSize
                //            color: Style.yellow
                name: "/ui/images/weathericons/weather-clear-day.svg"
            }
            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: d.formatValue(Math.abs(energyManager.currentPowerProduction))
                //            color: energyManager.currentPowerAcquisition >= 0 ? Style.red : Style.green
            }
        }


        ChartView {
            id: productionChart
            anchors.fill: parent
            legend.visible: false
            backgroundColor: "transparent"
            margins { left: 0; top: 0; right: 0; bottom: 0 }
            animationOptions: root.animationsEnabled ? NymeaUtils.chartsAnimationOptions : ChartView.NoAnimation

            PieSeries {
                size: 1
                holeSize: 0.8

                PieSlice {
                    color: Style.green
                    borderColor: color
                    borderWidth: 0
                    value: root.fromProduction
                }
                PieSlice {
                    color: Style.purple
                    borderColor: color
                    borderWidth: 0
                    value: root.toStorage
                }
                PieSlice {
                    color: Style.yellow
                    borderColor: color
                    borderWidth: 0
                    value: root.toGrid
                }
                PieSlice {
                    color: Style.tooltipBackgroundColor
                    borderColor: color
                    borderWidth: 0
                    value: energyManager.currentPowerProduction == 0 ? 1 : 0
                }
            }
        }
    }

    Item {
        id: consumptionItem
        x: d.consumptionPos.x - width / 2
        y: d.consumptionPos.y - height / 2
        width: d.chartSize
        height: d.chartSize

        Rectangle {
            anchors.centerIn: parent
            width: consumptionChart.plotArea.width
            height: consumptionChart.plotArea.height
            color: Style.backgroundColor
            radius: width / 2
        }

        ColumnLayout {
            anchors.centerIn: parent
            width: consumptionChart.plotArea.width * 0.8
            ColorIcon {
                Layout.alignment: Qt.AlignHCenter
                size: Style.bigIconSize
                //            color: Style.blue
                name: "/ui/images/powersocket.svg"
            }
            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: d.formatValue(energyManager.currentPowerConsumption)
    //            color: energyManager.currentPowerAcquisition >= 0 ? Style.red : Style.green
            }
        }

        ChartView {
            id: consumptionChart
            anchors.fill: parent
            margins { left: 0; top: 0; right: 0; bottom: 0 }
            legend.visible: false
            backgroundColor: "transparent"
            animationOptions: root.animationsEnabled ? NymeaUtils.chartsAnimationOptions : ChartView.NoAnimation

            PieSeries {
                size: 1
                holeSize: 0.8

                PieSlice {
                    color: Style.red
                    borderColor: color
                    borderWidth: 0
                    value: root.fromGrid
                }
                PieSlice {
                    color: Style.green
                    borderColor: color
                    borderWidth: 0
                    value: root.fromProduction
                }
                PieSlice {
                    color: Style.orange
                    borderColor: color
                    borderWidth: 0
                    value: root.fromStorage
                }
            }
        }
    }


    Item {
        id: batteryItem
        x: d.storagePos.x - width / 2
        y: d.storagePos.y - height / 2
        width: d.chartSize
        height: d.chartSize
        visible: batteries.count > 0

        Rectangle {
            anchors.centerIn: parent
            width: batteryChart.plotArea.width
            height: batteryChart.plotArea.height
            color: Style.backgroundColor
            radius: width / 2
        }

        ColumnLayout {
            anchors.centerIn: parent
            width: productionChart.plotArea.width * 0.8
            ColorIcon {
                Layout.alignment: Qt.AlignHCenter
                size: Style.bigIconSize
                //            color: Style.purple
                name: "/ui/images/battery/battery-" + NymeaUtils.pad(Math.round(batteryChart.averageLevel / 10) * 10, 3) + ".svg"
            }
            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: d.formatValue(Math.abs(energyManager.currentPowerStorage))
    //            color: energyManager.currentPowerStorage >= 0 ? Style.green : Style.red
            }
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            y: batteryChart.y + batteryChart.plotArea.height * .2
            horizontalAlignment: Text.AlignHCenter
            font: Style.smallFont
            text: batteryChart.averageLevel + "%"
//            color: energyManager.currentPowerStorage >= 0 ? Style.green : Style.red
        }

        ChartView {
            id: batteryChart
            anchors.fill: parent
            margins { left: 0; top: 0; right: 0; bottom: 0 }
            legend.visible: false
            backgroundColor: "transparent"
            animationOptions: root.animationsEnabled ? NymeaUtils.chartsAnimationOptions : ChartView.NoAnimation

            property double totalCapacity: {
                var totalCapacity = 0;
                for (var i = 0; i < batteriesRepeater.count; i++) {
                    totalCapacity += batteriesRepeater.itemAt(i).capacityState.value
                }
                return totalCapacity;
            }
            property double averageLevel: {
                if (batteriesRepeater.count == 0) {
                    return 0;
                }

                var averageLevel = 0;
                for (var i = 0; i < batteriesRepeater.count; i++) {
                    averageLevel += batteriesRepeater.itemAt(i).batteryLevelState.value
                }
                averageLevel /= batteriesRepeater.count
                return averageLevel;
            }

            Repeater {
                id: batteriesRepeater
                model: batteries
                delegate: Item {
                    property Thing thing: batteries.get(index)
                    property State batteryLevelState: thing.stateByName("batteryLevel")
                    property State capacityState: thing.stateByName("capacity")
                }
            }

            PieSeries {
                id: batterySeries
                size: 1
                holeSize: 0.8

                PieSlice {
                    color: energyManager.currentPowerStorage == 0
                           ? Style.foregroundColor
                           : root.toStorage > 0
                             ? Style.purple
                             : Style.orange
                    borderColor: color
                    borderWidth: 0
                    value: batteryChart.averageLevel
                }
                PieSlice {
                    color: Style.tooltipBackgroundColor
                    borderColor: color
                    borderWidth: 0
                    value: 100 - batteryChart.averageLevel
                }
            }
        }
    }

}

//ChartView {
//    id: consumptionPieChart
//    backgroundColor: "transparent"
//    animationOptions: animationsEnabled ? NymeaUtils.chartsAnimationOptions : ChartView.NoAnimation
//    title: qsTr("My energy mix")
//    titleColor: Style.foregroundColor
//    legend.visible: false

//    margins.left: 0
//    margins.right: 0
//    margins.bottom: 0
//    margins.top: 0

//    property bool animationsEnabled: true
//    property EnergyManager energyManager: null

//    ThingsProxy {
//        id: batteries
//        engine: _engine
//        shownInterfaces: ["energystorage"]
//    }

//    PieSeries {
//        id: consumptionBalanceSeries
//        size: 0.88
//        holeSize: 0.7

//        property double fromGrid: Math.max(0, energyManager.currentPowerAcquisition)
//        property double fromStorage: -Math.min(0, energyManager.currentPowerStorage)
//        property double toStorage: -Math.min(0, -energyManager.currentPowerStorage)
//        property double fromProduction: energyManager.currentPowerConsumption - fromGrid - fromStorage
//        property double toGrid: Math.max(0, - energyManager.currentPowerAcquisition)

//        PieSlice {
//            color: Style.red
//            borderColor: color
//            borderWidth: 0
//            value: consumptionBalanceSeries.fromGrid
//        }
//        PieSlice {
//            color: Style.green
//            borderColor: color
//            borderWidth: 0
//            value: consumptionBalanceSeries.fromProduction
//        }
//        PieSlice {
//            color: Style.purple
//            borderColor: color
//            borderWidth: 0
//            value: consumptionBalanceSeries.fromStorage
//        }
//        PieSlice {
//            color: Style.yellow
//            borderColor: color
//            borderWidth: 0
//            value: consumptionBalanceSeries.toGrid
//        }
//        PieSlice {
//            color: Style.orange
//            borderColor: color
//            borderWidth: 0
//            value: consumptionBalanceSeries.toStorage
//        }

//        PieSlice {
//            color: Style.tooltipBackgroundColor
//            borderColor: color
//            borderWidth: 0
//            value: consumptionBalanceSeries.fromGrid == 0 && consumptionBalanceSeries.fromProduction == 0 && consumptionBalanceSeries.fromStorage == 0 ? 1 : 0
//        }
//    }

//    Item {
//        id: centerItem

//        x: consumptionPieChart.plotArea.x + (consumptionPieChart.plotArea.width - width) / 2
//        y: consumptionPieChart.plotArea.y + (consumptionPieChart.plotArea.height - height) / 2
//        width: consumptionPieChart.plotArea.width * 0.65
//        height: width

////        Rectangle {
////            anchors.fill: parent
////            color: "white"
////        }

//        QtObject {
//            id: d
//            property double progress: 0
//            onProgressChanged: canvas.requestPaint()
//        }

//        NumberAnimation {
//            id: progressAnimation
//            target: d
//            property: "progress"
//            from: 0
//            to: 1
//            running: true
//            loops: Animation.Infinite
//            duration: 5000
//        }


//        Canvas {
//            id: canvas
//            anchors.fill: parent

//            property int itemCount: batteries.count > 0 ? 4 : 3

//            ColorIcon {
//                property var point: canvas.circlePoint(Qt.point(canvas.width / 2, canvas.height / 2), canvas.height / 2, -90)
//                x: point.x - width / 2
//                y: point.y - height / 2
//                name: "weathericons/weather-clear-day"
//            }
//            ColorIcon {
//                property var point: canvas.circlePoint(Qt.point(canvas.width / 2, canvas.height / 2), canvas.height / 2, -90 + 360 / canvas.itemCount)
//                x: point.x - width / 2
//                y: point.y - height / 2
//                name: "battery/battery-080"
//                visible: batteries.count > 0
//            }
//            ColorIcon {
//                property var point: canvas.circlePoint(Qt.point(canvas.width / 2, canvas.height / 2), canvas.height / 2, -90 + 360 / canvas.itemCount * (batteries.count > 0 ? 2 : 1))
//                x: point.x - width / 2
//                y: point.y - height / 2
//                name: "things"
//            }
//            ColorIcon {
//                property var point: canvas.circlePoint(Qt.point(canvas.width / 2, canvas.height / 2), canvas.height / 2, -90 + 360 / canvas.itemCount * (batteries.count > 0 ? 3 : 2))
//                x: point.x - width / 2
//                y: point.y - height / 2
//                name: "energy"
//            }

//            onPaint: {
//                var ctx = getContext("2d");

//                var solarPos = circlePoint(Qt.point(0, 0), height / 2, -90)
//                var storagePos = circlePoint(Qt.point(0, 0), height / 2, -90 / 360 * itemCount * 1)
//                var consumptionPos = circlePoint(Qt.point(0, 0), height / 2, -90 + 360 / itemCount * (batteries.count > 0 ? 2 : 1))
//                var gridPos = circlePoint(Qt.point(0, 0), height / 2, -90 + 360 / itemCount * (batteries.count > 0 ? 3 : 2))

//                ctx.save();
//                ctx.reset()

//                ctx.translate(width / 2, height / 2);

//                ctx.strokeStyle = Style.foregroundColor
//                ctx.fillStyle = Style.foregroundColor
//                ctx.lineWidth = 2

////                ctx.beginPath();
////                ctx.moveTo(0, -height / 2);
////                ctx.bezierCurveTo(0, -height / 10, -width / 10, 0, -width / 2, 0)
////                ctx.stroke();
////                ctx.closePath();

////                ctx.beginPath();
////                ctx.moveTo(-width / 2, 0);
////                ctx.bezierCurveTo(-width / 10, 0, 0, height / 10, 0, height / 2)
////                ctx.stroke();
////                ctx.closePath();

////                ctx.beginPath();
////                ctx.moveTo(0, height / 2);
////                ctx.bezierCurveTo(0, height / 10, width / 10, 0, width / 2, 0)
////                ctx.stroke();
////                ctx.closePath();

////                ctx.beginPath();
////                ctx.moveTo(width / 2, 0);
////                ctx.bezierCurveTo(width / 10, 0, 0, -height / 10, 0, -height / 2)
////                ctx.stroke();
////                ctx.closePath();

//                var size = Math.abs(energyManager.currentPowerAcquisition) / Math.abs(energyManager.currentPowerProduction)
//                drawDottedCurve(ctx, solarPos, gridPos, size)

//                size = Math.abs(energyManager.currentPowerConsumption) / Math.abs(energyManager.currentPowerProduction)
//                drawDottedCurve(ctx, solarPos, consumptionPos, size)

//                if (batteries.count > 0) {
//                    size = Math.abs(energyManager.currentPowerStorage) / Math.abs(energyManager.currentPowerProduction)
//                    drawDottedCurve(ctx, solarPos, storagePos, size)

//                    if (energyManager.currentPowerStorage < 0) {
//                        size = Math.abs(energyManager.currentPowerStorage) / Math.abs(energyManager.currentPowerConsumption)
//                        drawDottedCurve(ctx, storagePos, consumptionPos, size)
//                    }
//                }

//                if (energyManager.currentPowerAcquisition > 0) {
//                    size = Math.abs(energyManager.currentPowerAcquisition) / Math.abs(energyManager.currentPowerConsumption)
//                    drawDottedCurve(ctx, gridPos, consumptionPos, size)
//                }

////                var count = 5;
////                for (var i = 1; i <= count; i++) {
////                    var offset = 1 / count;
////                    var progress = d.progress + i * offset
////                    if (progress > 1)
////                        progress -= 1
////                    var point = bezierCurvePoint(width / 2, 0, width / 10, 0, 0, -height / 10, 0, -height / 2, progress)
////    //                print("painting", d.progress, point.x, point.y)
////                    ctx.beginPath();
////                    ctx.arc(point.x, point.y, 4, 0, 2 *Math.PI)
////                    ctx.stroke();
////                    ctx.closePath();

////                }


//                ctx.restore();
//            }

//            function bezierCurvePoint(p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y, t) {
//                var x = Math.pow(1-t, 3)*p0x + 3*Math.pow(1-t, 2)*t*p1x + 3*(1-t)*Math.pow(t, 2)*p2x + Math.pow(t, 3)*p3x;
//                var y = Math.pow(1-t, 3)*p0y + 3*Math.pow(1-t, 2)*t*p1y + 3*(1-t)*Math.pow(t, 2)*p2y + Math.pow(t, 3)*p3y;
//                return Qt.point(x, y)
//            }

//            function circlePoint(center, radius, angle) {
//                var x = center.x + radius * Math.cos(angle * 2 * Math.PI / 360)
//                var y = center.y + radius * Math.sin(angle * 2 * Math.PI / 360)
//                return Qt.point(x, y)
//            }

//            function drawDottedCurve(ctx, start, end, size) {
//                var c1 = getControlPoint(start)
//                var c2 = getControlPoint(end)
//                var count = 10;
//                for (var i = 1; i <= count; i++) {
//                    var offset = 1 / count;
//                    var progress = d.progress + i * offset
//                    if (progress > 1)
//                        progress -= 1
//                    var point = bezierCurvePoint(start.x, start.y, c1.x, c1.y, c2.x, c2.y, end.x, end.y, progress)
//    //                print("painting", d.progress, point.x, point.y)
//                    ctx.beginPath();
//                    ctx.arc(point.x, point.y, size * 5, 0, 2 *Math.PI)
//                    ctx.stroke();
//                    ctx.fill();
//                    ctx.closePath();

//                }

//            }

//            function getControlPoint(point) {
//                return Qt.point(point.x * .1, point.y * .1)
//            }

//        }

//    }


//    Column {
//        id: centerLayout
//        x: consumptionPieChart.plotArea.x + (consumptionPieChart.plotArea.width - width) / 2
//        y: consumptionPieChart.plotArea.y + (consumptionPieChart.plotArea.height - height) / 2
//        width: consumptionPieChart.plotArea.width * 0.65
////                    height: consumptionPieChart.plotArea.height * 0.65
//        height: childrenRect.height
//        spacing: Style.smallMargins

//        visible: false

//        ColumnLayout {
//            width: parent.width
//            spacing: 0
//            Label {
//                text: qsTr("Consumption")
//                font: Style.smallFont
//                Layout.fillWidth: true
//                horizontalAlignment: Text.AlignHCenter
//            }

//            Label {
//                text: "%1 %2"
//                .arg((energyManager.currentPowerConsumption / (energyManager.currentPowerConsumption > 1000 ? 1000 : 1)).toFixed(1))
//                .arg(energyManager.currentPowerConsumption > 1000 ? "kW" : "W")
//                Layout.fillWidth: true
//                horizontalAlignment: Text.AlignHCenter
////                font: Style.smallFont
//                color: Style.blue
//            }
//        }
//        ColumnLayout {
//            width: parent.width
//            spacing: 0
//            Label {
//                text: qsTr("Production")
//                font: Style.smallFont
//                Layout.fillWidth: true
//                horizontalAlignment: Text.AlignHCenter
//            }

//            Label {
//                property double absValue: Math.abs(energyManager.currentPowerProduction)
//                text: "%1 %2"
//                .arg((absValue / (absValue > 1000 ? 1000 : 1)).toFixed(1))
//                .arg(absValue > 1000 ? "kW" : "W")
//                Layout.fillWidth: true
//                horizontalAlignment: Text.AlignHCenter
////                font: Style.bigFont
//                color: Style.yellow

//            }
//        }


//        ColumnLayout {
//            width: parent.width
//            spacing: 0
//            Label {
//                text: qsTr("From grid")
//                Layout.fillWidth: true
//                horizontalAlignment: Text.AlignHCenter
//                font: Style.extraSmallFont
//            }
//            Label {
//                property double absValue: consumptionBalanceSeries.fromGrid
//                color: Style.red
//                text: "%1 %2"
//                .arg((absValue / (absValue > 1000 ? 1000 : 1)).toFixed(1))
//                .arg(absValue > 1000 ? "kW" : "W")
//                Layout.fillWidth: true
//                horizontalAlignment: Text.AlignHCenter
//                font: Style.smallFont
//            }
//        }


//        ColumnLayout {
//            width: parent.width
//            spacing: 0
//            Label {
//                text: qsTr("From self production")
//                Layout.fillWidth: true
//                horizontalAlignment: Text.AlignHCenter
//                font: Style.extraSmallFont
//            }
//            Label {
//                color: Style.green
//                property double absValue: consumptionBalanceSeries.fromProduction
//                text: "%1 %2".arg((absValue / (absValue > 1000 ? 1000 : 1)).toFixed(1))
//                .arg(absValue > 1000 ? "kW" : "W")
//                Layout.fillWidth: true
//                horizontalAlignment: Text.AlignHCenter
//                font: Style.smallFont
//            }
//        }
//        ColumnLayout {
//            width: parent.width
//            spacing: 0
//            visible: batteries.count > 0
//            Label {
//                text: energyManager.currentPowerStorage < 0 ? qsTr("From battery") : qsTr("To battery")
//                Layout.fillWidth: true
//                horizontalAlignment: Text.AlignHCenter
//                font: Style.extraSmallFont
//            }
//            Label {
//                color: value < 0 ? Style.purple : Style.orange
//                property double value: energyManager.currentPowerStorage
//                property double absValue: Math.abs(energyManager.currentPowerStorage)
//                text: "%1 %2".arg((absValue / (absValue > 1000 ? 1000 : 1)).toFixed(1))
//                .arg(absValue > 1000 ? "kW" : "W")
//                Layout.fillWidth: true
//                horizontalAlignment: Text.AlignHCenter
//                font: Style.smallFont
//            }
//        }
//    }
//}
