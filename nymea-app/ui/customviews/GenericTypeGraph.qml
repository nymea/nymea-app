/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"
import QtCharts 2.2

Item {
    id: root
    implicitHeight: width * .6

    property Thing thing: null
    property StateType stateType: null
    property int roundTo: 2
    property color color: Style.accentColor
    property string iconSource: ""
    property alias title: titleLabel.text

    readonly property var valueState: thing.states.getState(stateType.id)
    readonly property bool hasConnectable: thing.thingClass.interfaces.indexOf("connectable") >= 0
    readonly property StateType connectedStateType: hasConnectable ? thing.thingClass.stateTypes.findByName("connected") : null


    LogsModelNg {
        id: logsModelNg
        engine: _engine
        thingId: root.thing.id
        typeIds: [root.stateType.id]
        live: true
        graphSeries: lineSeries1
        viewStartTime: xAxis.min
    }

    LogsModelNg {
        id: connectedLogsModel
        engine: root.hasConnectable ? _engine : null // don't even try to poll if we don't have a connectable interface
        thingId: root.thing.id
        typeIds: root.hasConnectable ? [root.connectedStateType.id] : []
        live: true
        graphSeries: connectedLineSeries
        viewStartTime: xAxis.min
    }

    ChartView {
        id: chartView
        anchors.fill: parent
        margins.top: Style.iconSize + app.margins
        margins.bottom: app.margins / 2
        margins.left: 0
        margins.right: 0
        backgroundColor: Style.tileBackgroundColor
        backgroundRoundness: Style.tileRadius
        legend.visible: false
        legend.labelColor: Style.foregroundColor

        titleColor: Style.foregroundColor
        titleFont.pixelSize: app.largeFont

        animationDuration: 300
        animationOptions: ChartView.SeriesAnimations

        RowLayout {
            anchors { left: parent.left; top: parent.top; right: parent.right; topMargin: app.margins / 2; leftMargin: app.margins * 1.5; rightMargin: app.margins }

            ColorIcon {
                Layout.preferredHeight: Style.iconSize
                Layout.preferredWidth: Style.iconSize
                name: root.iconSource
                visible: root.iconSource.length > 0
                color: root.color
            }
            Label {
                id: titleLabel
                Layout.fillWidth: true
                text: root.stateType.type.toLowerCase() === "bool"
                       ? root.stateType.displayName
                       : 1.0 * Math.round(Types.toUiValue(root.valueState.value, root.stateType.unit) * Math.pow(10, root.roundTo)) / Math.pow(10, root.roundTo) + " " + Types.toUiUnit(root.stateType.unit)
                font.pixelSize: app.largeFont
            }
            HeaderButton {
                imageSource: "../images/zoom-out.svg"
                onClicked: {
                    var newTime = new Date(xAxis.min.getTime() - (xAxis.timeDiff * 1000 / 4))
                    xAxis.min = newTime;
                }
            }
            HeaderButton {
                imageSource: "../images/zoom-in.svg"
                enabled: xAxis.timeDiff > (60 * 30)
                onClicked: {
                    var newTime = new Date(Math.min(xAxis.min.getTime() + (xAxis.timeDiff * 1000 / 4), xAxis.max.getTime() - (1000 * 60 * 30)))
                    xAxis.min = newTime;
                }
            }
        }

        ValueAxis {
            id: yAxis
            max: {
                switch (root.stateType.type.toLowerCase()) {
                case "bool":
                    return 1;
                default:
                    Math.ceil(logsModelNg.maxValue + Math.abs(logsModelNg.maxValue * .05))
                }
            }
            min: Math.floor(logsModelNg.minValue - Math.abs(logsModelNg.minValue * .05))
            //                onMinChanged: applyNiceNumbers();
            //                onMaxChanged: applyNiceNumbers();
            labelsFont.pixelSize: app.smallFont
            labelFormat: {
                switch (root.stateType.type.toLowerCase()) {
                case "bool":
                    return "x";
                default:
                    return "%d";
                }
            }
            labelsColor: Style.foregroundColor
            tickCount: root.stateType.type.toLowerCase() === "bool" ? 2 : chartView.height / 40
            color: Qt.rgba(Style.foregroundColor.r, Style.foregroundColor.g, Style.foregroundColor.b, .2)
            gridLineColor: color
        }

        ValueAxis {
            id: connectedAxis
            min: 0
            max: 1
            visible: false
        }

        DateTimeAxis {
            id: xAxis
            gridVisible: false
            color: Qt.rgba(Style.foregroundColor.r, Style.foregroundColor.g, Style.foregroundColor.b, .2)
            tickCount: chartView.width / 70
            labelsFont.pixelSize: app.smallFont
            labelsColor: Style.foregroundColor
            property int timeDiff: (xAxis.max.getTime() - xAxis.min.getTime()) / 1000

            function getTimeSpanString() {
                var td = Math.round(timeDiff)
                if (td < 60) {
                    return qsTr("%n seconds", "", td);
                }
                td = Math.round(td / 60)
                if (td < 60) {
                    return qsTr("%n minutes", "", td);
                }
                td = Math.round(td / 60)
                if (td < 48) {
                    return qsTr("%n hours", "", td);
                }
                td = Math.round(td / 24);
                if (td < 14) {
                    return qsTr("%n days", "", td);
                }
                td = Math.round(td / 7)
                if (td < 9) {
                    return qsTr("%n weeks", "", td);
                }
                td = Math.round(td * 7 / 30)
                if (td < 24) {
                    return qsTr("%n months", "", td);
                }
                td = Math.round(td * 30 / 356)
                return qsTr("%n years", "", td)
            }

            titleText: {
                if (xAxis.min.getYear() === xAxis.max.getYear()
                        && xAxis.min.getMonth() === xAxis.max.getMonth()
                        && xAxis.min.getDate() === xAxis.max.getDate()) {
                    return Qt.formatDate(xAxis.min) + " (" + getTimeSpanString() + ")"
                }
                return Qt.formatDate(xAxis.min) + " - " + Qt.formatDate(xAxis.max) + " (" + getTimeSpanString() + ")"
            }
            titleBrush: Style.foregroundColor
            format: {
                if (timeDiff < 60) { // one minute
                    return "mm:ss"
                }
                if (timeDiff < 60 * 60) { // one hour
                    return "hh:mm"
                }
                if (timeDiff < 60 * 60 * 24 * 2) { // two day
                    return "hh:mm"
                }
                if (timeDiff < 60 * 60 * 24 * 7) { // one week
                    return "ddd hh:mm"
                }
                if (timeDiff < 60 * 60 * 24 * 7 * 30) { // one month
                    return "dd.MM."
                }
                return "MMM yy"
            }

            min: {
                var date = new Date();
                date.setTime(date.getTime() - (1000 * 60 * 60 * 6) + 2000);
                return date;
            }
            max: {
                var date = new Date();
                date.setTime(date.getTime() + 2000)
                return date;
            }
        }

        AreaSeries {
            axisX: xAxis
            axisY: connectedAxis
            name: qsTr("Not connected")
            visible: root.hasConnectable
            upperSeries: LineSeries {
                XYPoint {x: xAxis.min.getTime(); y: 1}
                XYPoint {x: xAxis.max.getTime(); y: 1}
            }

            lowerSeries: LineSeries {
                id: connectedLineSeries
                onPointAdded: {
                    var newPoint = connectedLineSeries.at(index)
                    //                        print("pointadded", newPoint.x, newPoint.y)
                }

            }
            color: "#55ff0000"
            borderWidth: 0
        }

        AreaSeries {
            id: mainSeries
            axisX: xAxis
            axisY: yAxis
            name: root.stateType.displayName
            borderColor: root.color
            borderWidth: 4
            lowerSeries: LineSeries {
                id: lineSeries0
                XYPoint { x: xAxis.max.getTime(); y: 0 }
                XYPoint { x: xAxis.min.getTime(); y: 0 }
            }

            upperSeries: LineSeries {
                id: lineSeries1
                onPointAdded: {
                    var newPoint = lineSeries1.at(index)
                    //                        print("pointadded", newPoint.x, newPoint.y)

                    if (newPoint.x > lineSeries0.at(0).x) {
                        lineSeries0.replace(0, newPoint.x, 0)
                    }
                    if (newPoint.x < lineSeries0.at(1).x) {
                        lineSeries0.replace(1, newPoint.x, 0)
                    }

                    if (newPoint.x <= xAxis.max.getTime() || logsModelNg.busy) {
                        return;
                    }

                    var diffMaxToNew = newPoint.x - xAxis.max.getTime();
                    if (diffMaxToNew < 1000 * 60 * 5) {
                        chartView.animationOptions = ChartView.NoAnimation
                        var newMin = xAxis.min.getTime()  + diffMaxToNew;
                        xAxis.max = new Date(newPoint.x);
                        xAxis.min = new Date(newMin)
                        chartView.animationOptions = ChartView.SeriesAnimations
                    }

                }
            }
            color: Qt.rgba(root.color.r, root.color.g, root.color.b, .3)
            onHovered: {
                markClosestPoint(point)
            }

            function markClosestPoint(point) {
                if (lineSeries1.count == 0) {
                    return;
                }

                if (lineSeries1.count == 1) {
                    selectedHighlights.removePoints(0, selectedHighlights.count)
                    selectedHighlights.append(lineSeries1.at(0).x, lineSeries1.at(1).y)
                    return;
                }

                var searchIndex = Math.floor(lineSeries1.count / 2)
                var previousIndex = 0;
                var nextIndex = lineSeries1.count - 1;

                while (previousIndex + 1 != nextIndex) {
                    if (point.x < lineSeries1.at(searchIndex).x) {
                        previousIndex = searchIndex;
                    } else if (point.x > lineSeries1.at(searchIndex).x) {
                        nextIndex = searchIndex;
                    }
                    searchIndex = previousIndex + Math.floor((nextIndex - previousIndex) / 2);
                }
                var diffToPrevious = Math.abs(point.x - lineSeries1.at(previousIndex).x)
                var diffToNext = Math.abs(point.x - lineSeries1.at(nextIndex).x)
                var closestPoint = diffToPrevious < diffToNext ? lineSeries1.at(previousIndex) : lineSeries1.at(nextIndex);

                selectedHighlights.removePoints(0, selectedHighlights.count)
                selectedHighlights.append(closestPoint.x, closestPoint.y)
            }
        }

        ScatterSeries {
            id: selectedHighlights
            color: root.color
            markerSize: 10
            borderWidth: 2
            borderColor: root.color
            axisX: xAxis
            axisY: yAxis
            pointLabelsVisible: root.stateType.type.toLowerCase() !== "bool"
            pointLabelsColor: Style.foregroundColor
            pointLabelsFont.pixelSize: app.smallFont
            pointLabelsFormat: "@yPoint"
            pointLabelsClipping: false
        }

        BusyIndicator {
            anchors.centerIn: parent
            visible: logsModelNg.busy
        }


        MouseArea {
            id: scrollMouseArea
            x: chartView.plotArea.x
            y: chartView.plotArea.y
            width: chartView.plotArea.width
            height: chartView.plotArea.height
            property int lastX: 0
            property int startX: 0
            preventStealing: false

            property bool autoScroll: true

            function scrollRightLimited(dx) {
                chartView.animationOptions = ChartView.NoAnimation
                var now = new Date()
                // if we're already at the limit, don't even start scrolling
                if (dx < 0 || xAxis.max < now) {
                    chartView.scrollRight(dx)
                }
                // figure out if we scrolled too far
                var overshoot = xAxis.max.getTime() - now.getTime()
                //                    print("overshoot is:", overshoot, "oldMax", xAxis.max, "newMax", now, "oldMin", xAxis.min, "newMin", new Date(xAxis.min.getTime() - overshoot))
                if (overshoot > 0) {
                    var range = xAxis.max - xAxis.min
                    xAxis.max = now
                    xAxis.min = new Date(xAxis.max.getTime() - range)
                }
                // If the user scrolled closer than 5 pixels to the right edge, enable autoscroll
                autoScroll = overshoot > -5;

                chartView.animationOptions = ChartView.SeriesAnimations
            }

            function zoomInLimited(dy) {
                chartView.animationOptions = ChartView.NoAnimation
                var oldMax = xAxis.max;
                chartView.scrollRight(dy);
                xAxis.min = new Date(xAxis.min.getTime() - xAxis.timeDiff * 1000 * 2)
                chartView.animationOptions = ChartView.SeriesAnimations
            }

            onPressed: {
                lastX = mouse.x
                startX = mouse.x
            }
            onClicked: {
                var pt = chartView.mapToValue(Qt.point(mouse.x + chartView.plotArea.x, mouse.y + chartView.plotArea.y), mainSeries)
                mainSeries.markClosestPoint(pt)
            }

            onWheel: {
                scrollRightLimited(-wheel.pixelDelta.x)
                //                    zoomInLimited(wheel.pixelDelta.y)
            }

            onPositionChanged: {
                if (lastX !== mouse.x) {
                    scrollRightLimited(lastX - mouseX)
                    lastX = mouse.x
                }

                if (Math.abs(startX - mouse.x) > 10) {
                    preventStealing = true;
                }
            }

            onReleased: preventStealing = false;


            Timer {
                running: scrollMouseArea.autoScroll
                interval: 1000
                repeat: true
                onTriggered: {
                    scrollMouseArea.scrollRightLimited(10)
                }
            }
        }
    }
}

