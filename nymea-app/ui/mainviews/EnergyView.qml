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

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtCharts 2.2
import Nymea 1.0
import "../components"
import "../delegates"

MainViewBase {
    id: root

    contentY: flickable.contentY + topMargin

    ThingsProxy {
        id: energyMeters
        engine: _engine
        shownInterfaces: ["energymeter"]
    }
    readonly property Thing rootMeter: energyMeters.count > 0 ? energyMeters.get(0) : null

    ThingsProxy {
        id: consumers
        engine: _engine
        shownInterfaces: ["smartmeterconsumer"]
    }

    ThingsProxy {
        id: producers
        engine: _engine
        shownInterfaces: ["smartmeterproducer"]
    }


    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: app.margins / 2
        contentHeight: energyGrid.childrenRect.height
        visible: energyMeters.count > 0
        topMargin: root.topMargin


        GridLayout {
            id: energyGrid
            width: parent.width
            columns: root.width > 600 ? 2 : 1
            rowSpacing: 0
            columnSpacing: 0

            SmartMeterChart {
                Layout.fillWidth: true
//                Layout.preferredWidth: energyGrid.width / energyGrid.columns
                Layout.preferredHeight: (energyGrid.width / energyGrid.columns) * .7
                // FIXME: multiple root meters... Not exactly a use case, still possible tho
                rootMeter: root.rootMeter
                meters: consumers
                title: qsTr("Total consumed energy")
                visible: rootMeterTotalEnergyState || consumers.count > 0
            }

            SmartMeterChart {
                Layout.fillWidth: true
                Layout.preferredHeight: width * .7
                backgroundColor: Style.tileBackgroundColor
                backgroundRoundness: Style.cornerRadius
                rootMeter: root.rootMeter
                meters: producers
                title: qsTr("Total produced energy")
                stateName: "totalEnergyProduced"
                readonly property State totalProducedState: rootMeter ? rootMeter.stateByName("totalEnergyProduced") : null
                visible: (rootMeterTotalEnergyState && rootMeterTotalEnergyState.value > 0) || producers.count > 0
            }

            ChartView {
                id: chartView
                Layout.fillWidth: true
//                Layout.preferredWidth: energyGrid.width / energyGrid.columns
                Layout.columnSpan: energyGrid.columns
                Layout.preferredHeight: width * .7
                legend.alignment: Qt.AlignBottom
                legend.font.pixelSize: app.smallFont
//                legend.visible: false
                legend.labelColor: Style.foregroundColor
                backgroundColor: Style.tileBackgroundColor
                backgroundRoundness: Style.cornerRadius
                theme: ChartView.ChartThemeLight
                titleColor: Style.foregroundColor
                title: qsTr("Power usage history")

                property var startTime: xAxis.min
                property var endTime: xAxis.max

                property int sampleRate: XYSeriesAdapter.SampleRateMinute

                property int busyModels: 0

                BusyIndicator {
                    anchors.centerIn: parent
                    visible: chartView.busyModels > 0
                    running: visible
                }

                LogsModel {
                    id: rootMeterLogsModel
                    objectName: "Root meter model"
                    engine: rootMeter ? _engine : null // Don't start fetching before we know what we want
                    thingId: rootMeter ? rootMeter.id : ""
                    typeIds: rootMeter ? [rootMeter.thingClass.stateTypes.findByName("currentPower").id] : []
                    viewStartTime: xAxis.min
                    live: true
                }
                XYSeriesAdapter {
                    id: rootMeterSeriesAdapter
                    objectName: "Root meter adapter"
                    logsModel: rootMeterLogsModel
                    sampleRate: chartView.sampleRate
                    xySeries: rootMeterSeries
                    Component.onCompleted: ensureSamples(xAxis.min, xAxis.max)
                }
                Connections {
                    target: xAxis
                    onMinChanged: rootMeterSeriesAdapter.ensureSamples(xAxis.min, xAxis.max)
                    onMaxChanged: rootMeterSeriesAdapter.ensureSamples(xAxis.min, xAxis.max)
                }

                AreaSeries {
                    id: rootMeterAreaSeries
                    color: Style.accentColor
                    borderWidth: 0
                    axisX: xAxis
                    axisY: yAxis
                    name: qsTr("Unknown")
                    useOpenGL: true
                    lowerSeries: LineSeries {
                        id: rootMeterLowerSeries
                        XYPoint { x: xAxis.max.getTime(); y: 0 }
                        XYPoint { x: xAxis.min.getTime(); y: 0 }
                    }
                    // HACK: We want this to be created (added to the chart) *before* the repeater Series below...
                    // That might not be the case for a reason I don't understand. Most likely due to a mix of the declarative
                    // approach here and the imperative approach using chartView.createSeries() below.
                    // So hacking around by blocking the repeater from loading until this one is done
                    property bool ready: false
                    Component.onCompleted: ready = true

                    upperSeries: LineSeries {
                        id: rootMeterSeries

                        onPointAdded: {
                            var newPoint = rootMeterSeries.at(index)

                            if (newPoint.x > rootMeterLowerSeries.at(0).x) {
                                rootMeterLowerSeries.replace(0, newPoint.x, 0)
                            }
                            if (newPoint.x < rootMeterLowerSeries.at(1).x) {
                                rootMeterLowerSeries.replace(1, newPoint.x, 0)
                            }
                        }
                    }
                }

                Repeater {
                    id: consumersRepeater
                    model: rootMeterAreaSeries.ready && !engine.thingManager.fetchingData ? consumers : null

                    delegate: Item {
                        id: consumer
                        property Thing thing: consumers.get(index)

                        property var model: LogsModel {
                            id: logsModel
                            objectName: consumer.thing.name
                            engine: _engine
                            thingId: consumer.thing.id
                            typeIds: [consumer.thing.thingClass.stateTypes.findByName("currentPower").id]
                            viewStartTime: xAxis.min
                            live: true
                            onBusyChanged: {
                                if (busy) {
                                    chartView.busyModels++
                                } else {
                                    chartView.busyModels--
                                }
                            }
                        }
                        property XYSeriesAdapter adapter: XYSeriesAdapter {
                            id: seriesAdapter
                            objectName: consumer.thing.name +  " adapter"
                            logsModel: logsModel
                            sampleRate: chartView.sampleRate
                            xySeries: upperSeries
                        }
                        Connections {
                            target: xAxis
                            onMinChanged: seriesAdapter.ensureSamples(xAxis.min, xAxis.max)
                            onMaxChanged: seriesAdapter.ensureSamples(xAxis.min, xAxis.max)
                        }
                        property XYSeries lineSeries: LineSeries {
                            id: upperSeries
                            onPointAdded: {
                                var newPoint = upperSeries.at(index)

                                if (newPoint.x > lowerSeries.at(0).x) {
                                    lowerSeries.replace(0, newPoint.x, 0)
                                }
                                if (newPoint.x < lowerSeries.at(1).x) {
                                    lowerSeries.replace(1, newPoint.x, 0)
                                }
                            }
                        }
                        LineSeries {
                            id: lowerSeries
                            XYPoint { x: xAxis.max.getTime(); y: 0 }
                            XYPoint { x: xAxis.min.getTime(); y: 0 }
                        }

                        Component.onCompleted: {
                            var indexInModel = consumers.indexOf(consumer.thing)
                            print("creating series", consumer.thing.name, index, indexInModel)
                            seriesAdapter.ensureSamples(xAxis.min, xAxis.max)
                            var areaSeries = chartView.createSeries(ChartView.SeriesTypeArea, consumer.thing.name, xAxis, yAxis)
                            areaSeries.useOpenGL = true
                            areaSeries.upperSeries = upperSeries;
                            if (index > 0) {
                                areaSeries.lowerSeries = consumersRepeater.itemAt(index - 1).lineSeries
                                seriesAdapter.baseSeries = consumersRepeater.itemAt(index - 1).lineSeries
                            } else {
                                areaSeries.lowerSeries = lowerSeries;
                            }

                            var color = Style.accentColor
                            for (var j = 0; j <= indexInModel; j+=2) {
                                if (indexInModel % 2 == 0) {
                                    color = Qt.lighter(color, 1.2);
                                } else {
                                    color = Qt.darker(color, 1.2)
                                }
                            }
                            areaSeries.color = color;
                            areaSeries.borderColor = color;
                            areaSeries.borderWidth = 0;
                        }
                    }
                }

                ValueAxis {
                    id: yAxis
                    readonly property XYSeriesAdapter highestSeriesAdapter: consumersRepeater.count > 0 ? consumersRepeater.itemAt(consumersRepeater.count - 1).adapter : null
                    property double rawMax: rootMeter ? rootMeterSeriesAdapter.maxValue
                                                      : highestSeriesAdapter ? highestSeriesAdapter.maxValue : 1
                    property double rawMin: rootMeter ? rootMeterSeriesAdapter.minValue
                                                      : highestSeriesAdapter ? highestSeriesAdapter.minValue : 0
                    max: Math.ceil(Math.max(rawMax * 0.9, rawMax * 1.1))
                    min: Math.floor(Math.min(rawMin * 0.9, rawMin * 1.1))
                    // This seems to crash occationally
//                    onMinChanged: applyNiceNumbers();
//                    onMaxChanged: applyNiceNumbers();
                    labelsFont.pixelSize: app.smallFont
                    labelFormat: "%d"
                    labelsColor: Style.foregroundColor
                    color: Qt.rgba(Style.foregroundColor.r, Style.foregroundColor.g, Style.foregroundColor.b, .2)
                    gridLineColor: color
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
                        preventStealing = true
                    }
                    onClicked: {
                        //                        var pt = chartView.mapToValue(Qt.point(mouse.x + chartView.plotArea.x, mouse.y + chartView.plotArea.y), mainSeries)
                        //                        mainSeries.markClosestPoint(pt)
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
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        visible: !engine.thingManager.fetchingData && energyMeters.count == 0
        title: qsTr("There are no energy meters installed.")
        text: qsTr("To get an overview of your current energy usage, install an energy meter.")
        imageSource: "../images/smartmeter.svg"
        buttonText: qsTr("Add things")
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../thingconfiguration/NewThingPage.qml"))
    }
}
