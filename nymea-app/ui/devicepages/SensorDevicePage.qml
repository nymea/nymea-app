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

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import Nymea 1.0
import NymeaApp.Utils 1.0
import "../components"
import "../customviews"

ThingPageBase {
    id: root

    property var interfaceStateMap: {
        "temperaturesensor": "temperature",
        "humiditysensor": "humidity",
        "pressuresensor": "pressure",
        "moisturesensor": "moisture",
        "lightsensor": "lightIntensity",
        "conductivitysensor": "conductivity",
        "noisesensor": "noise",
        "cosensor": "co",
        "co2sensor": "co2",
        "gassensor": "gasLevel",
        "presencesensor": "isPresent",
        "daylightsensor": "daylight",
        "closablesensor": "closed",
        "watersensor": "waterDetected",
        "firesensor": "fireDetected",
        "waterlevelsensor": "waterLevel",
        "phsensor": "ph",
        "o2sensor": "o2saturation",
        "o3sensor": "o3",
        "orpsensor": "orp",
        "vocsensor": "voc",
        "cosensor": "co",
        "pm10sensor": "pm10",
        "pm25sensor": "pm25",
        "no2sensor": "no2"
    }

    ListModel {
        id: sensorsModel
        Component.onCompleted: {
            var supportedInterfaces = Object.keys(interfaceStateMap)
            for (var i = 0; i < supportedInterfaces.length; i++) {
                if (root.thingClass.interfaces.indexOf(supportedInterfaces[i]) >= 0) {
                    append({name: supportedInterfaces[i]});
                }
            }
        }
    }

    Flickable {
        id: listView
        anchors { fill: parent }
        topMargin: app.margins / 2
        interactive: contentHeight > height
        contentHeight: contentGrid.implicitHeight

        ColumnLayout {
            id: contentGrid
            width: parent.width
            spacing: Style.margins

            Flow {
                id: flow
                Layout.fillWidth: true
                Layout.leftMargin: sensorsModel.count == 1 ? Style.hugeMargins : Style.bigMargins
                Layout.rightMargin: sensorsModel.count == 1 ? Style.hugeMargins : Style.bigMargins
                Layout.preferredHeight: cellWidth * Math.min(400, Math.ceil(flowRepeater.count / columns))

                property int columns: Math.min(flowRepeater.count, Math.floor(listView.width / 150))
                property int cellWidth: width / columns
                property int totalRows: flowRepeater.count / columns

//                columns: 2// Math.ceil(width / 600)
//                columnSpacing: Style.margins
//                rowSpacing: Style.margins

                Repeater {
                    id: flowRepeater
                    model: sensorsModel

                    delegate: Item {
                        width: Math.floor(flow.width / itemsInRow)
                        height: Math.min(400, flow.cellWidth)
                        property int row: Math.floor(index / flow.columns)
                        property int itemsInRow: row < flow.totalRows ? flow.columns : (flowRepeater.count % flow.columns)

                        CircleBackground {
                            id: background
                            anchors.centerIn: parent
                            width: Math.min(parent.width, parent.height) - Style.margins
                            height: width

                            readonly property StateType sensorStateType: root.thing.thingClass.stateTypes.findByName(interfaceStateMap[modelData])
                            readonly property State sensorState: root.thing.stateByName(interfaceStateMap[modelData])

                            onColor: app.interfaceToColor(modelData)
                            on: sensorStateType.type.toLowerCase() == "bool" && sensorState.value === true
                            iconSource: [
                                "closablesensor",
                                "presencesensor",
                                "daylightsensor",
                                "firesensor",
                                "watersensor"
                            ].indexOf(modelData) >= 0 ? app.interfaceToIcon(modelData) : ""

                            Loader {
                                anchors.centerIn: parent
                                width: background.contentItem.width
                                height: background.contentItem.height
                                property StateType stateType: root.thingClass.stateTypes.findByName(interfaceStateMap[modelData])
                                property State state: root.thing.stateByName(interfaceStateMap[modelData])
                                property string interfaceName: modelData
                                property var minValue: {
                                    if (["temperaturesensor"].indexOf(modelData) >= 0) {
                                        return Types.toUiValue(-50, Types.UnitDegreeCelsius)
                                    }
                                    if (["pressuresensor"].indexOf(modelData) >= 0) {
                                        return Types.toUiValue(900, Types.UnitMilliBar)
                                    }

                                    return state.minValue
                                }
                                property var maxValue: {
                                    if (["temperaturesensor"].indexOf(modelData) >= 0) {
                                        return Types.toUiValue(50, Types.UnitDegreeCelsius)
                                    }
                                    if (["pressuresensor"].indexOf(modelData) >= 0) {
                                        return Types.toUiValue(1100, Types.UnitMilliBar)
                                    }
                                    return state.maxValue
                                }

                                sourceComponent: {
                                    var progressInterfaces = [
                                                "humiditysensor",
                                                "o2sensor",
                                                "temperaturesensor",
                                                "moisturesensor",
                                                "conductivitysensor",
                                                "gassensor",
                                                "lightsensor",
                                                "orpsensor",
                                                "phsensor",
                                                "pressuresensor",
                                                "waterlevelsensor",
                                                "windspeedsensor"
                                            ]
                                    if (progressInterfaces.indexOf(modelData) >= 0) {
                                        return progressComponent
                                    }
                                    var scaleInterfaces = [
                                                "vocsensor",
                                                "cosensor",
                                                "co2sensor",
                                                "o3sensor",
                                                "pm10sensor",
                                                "pm25sensor",
                                                "no2sensor"
                                            ]
                                    if (scaleInterfaces.indexOf(modelData) >= 0) {
                                        return scaleComponent
                                    }
                                }
                            }
                        }
                    }
                }
            }


            GridLayout {
                columns: Math.ceil(width / 600)
                rowSpacing: 0
                columnSpacing: 0

                Repeater {
                    model: sensorsModel

                    delegate: Loader {
                        id: loader
                        Layout.fillWidth: true
                        Layout.preferredHeight: item.implicitHeight

                        property StateType stateType: root.thingClass.stateTypes.findByName(interfaceStateMap[modelData])
                        property State state: root.thing.stateByName(interfaceStateMap[modelData])
                        property string interfaceName: modelData

        //                sourceComponent: stateType && stateType.type.toLowerCase() === "bool" ? boolComponent : graphComponent
                        sourceComponent: graphComponent

                    }
                }
            }
        }

        Component {
            id: graphComponent

            GenericTypeGraph {
                id: graph
                thing: root.thing
                color: app.interfaceToColor(interfaceName)
                iconSource: app.interfaceToIcon(interfaceName)
                implicitHeight: width * .6
                property string interfaceName: parent.interfaceName
                stateType: parent.stateType
                property State state: parent.state

                Binding {
                    target: graph
                    property: "title"
                    when: ["presencesensor", "daylightsensor", "closablesensor", "watersensor", "firesensor"].indexOf(graph.interfaceName) >= 0
                    value: {
                        switch (graph.interfaceName) {
                        case "presencesensor":
                            return graph.state.value === true ? qsTr("Presence") : qsTr("Vacant")
                        case "daylightsensor":
                            return graph.state.value === true ? qsTr("Daytime") : qsTr("Nighttime")
                        case "closablesensor":
                            return graph.state.value === true ? qsTr("Closed") : qsTr("Open")
                        case "watersensor":
                            return graph.state.value === true ? qsTr("Wet") : qsTr("Dry")
                        case "firesensor":
                            return graph.state.value === true ? qsTr("Fire") : qsTr("No fire")
                        }
                    }
                }
            }
        }

        Component {
            id: boolComponent
            GridLayout {
                id: boolView
                property string interfaceName: parent.interfaceName
                property StateType stateType: parent.stateType
                height: listView.height
                columns: app.landscape ? 2 : 1
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: Style.iconSize * 5
                    Layout.rowSpan: app.landscape ? 5 : 1
                    ColorIcon {
                        anchors.centerIn: parent
                        height: Style.iconSize * 4
                        width: height
                        name: {
                            switch (boolView.interfaceName) {
                            case "closablesensor":
                                return thing.states.getState(boolView.stateType.id).value === true ? Qt.resolvedUrl("../images/lock-closed.svg") : Qt.resolvedUrl("../images/lock-open.svg")
                            default:
                                return app.interfaceToIcon(boolView.interfaceName)
                            }
                        }
                        color: {
                            switch (boolView.interfaceName) {
                            case "closablesensor":
                                return thing.states.getState(boolView.stateType.id).value === true ? "green" : "red"
                            default:
                                thing.states.getState(boolView.stateType.id).value === true ? app.interfaceToColor(boolView.interfaceName) : Style.iconColor
                            }
                        }
                    }
                }
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
                RowLayout {
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignHCenter
                    property StateType lastSeenStateType: root.thingClass.stateTypes.findByName("lastSeenTime")
                    property State lastSeenState: lastSeenStateType ? root.thing.states.getState(lastSeenStateType.id) : null
                    visible: lastSeenStateType !== null
                    Label {
                        text: qsTr("Last seen:")
                        font.bold: true
                    }
                    Label {
                        text: parent.lastSeenState ? Qt.formatDateTime(new Date(parent.lastSeenState.value * 1000)) : ""
                    }
                }
                RowLayout {
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignHCenter
                    property StateType sunriseStateType: root.thingClass.stateTypes.findByName("sunriseTime")
                    property State sunriseState: sunriseStateType ? root.thing.states.getState(sunriseStateType.id) : null
                    visible: sunriseStateType !== null
                    Label {
                        text: qsTr("Sunrise:")
                        font.bold: true
                    }
                    Label {
                        text: parent.sunriseStateType ? Qt.formatDateTime(new Date(parent.sunriseState.value * 1000)) : ""
                    }
                }
                RowLayout {
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignHCenter
                    property StateType sunsetStateType: root.thingClass.stateTypes.findByName("sunsetTime")
                    property State sunsetState: sunsetStateType ? root.thing.states.getState(sunsetStateType.id) : null
                    visible: sunsetStateType !== null
                    Label {
                        text: qsTr("Sunset:")
                        font.bold: true
                    }
                    Label {
                        text: parent.sunsetStateType ? Qt.formatDateTime(new Date(parent.sunsetState.value * 1000)) : ""
                    }
                }
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }
        }
    }

    Component {
        id: progressComponent
        Canvas {
            id: progressCanvas
            property string interfaceName: parent.interfaceName
            property StateType stateType: parent.stateType
            property State state: parent.state
            property var minValue: parent.minValue
            property var maxValue: parent.maxValue

            property double progress: (progressCanvas.state.value - progressCanvas.minValue) / (progressCanvas.maxValue - progressCanvas.minValue)
            Behavior on progress { NumberAnimation { duration: Style.slowAnimationDuration; easing.type: Easing.InOutQuad } }
            onProgressChanged: requestPaint();

            ColumnLayout {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -Style.smallMargins
                width: parent.width * 0.6

                Label {
                    Layout.fillWidth: true
                    text: Types.toUiValue(progressCanvas.state.value, progressCanvas.stateType.unit).toFixed(1)
                    wrapMode: Text.WordWrap
                    font.pixelSize: Math.min(Style.hugeFont.pixelSize, progressCanvas.height / 8)
                    maximumLineCount: 2
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }
                Label {
                    Layout.fillWidth: true
                    text: Types.toUiUnit(progressCanvas.stateType.unit)
                    font.pixelSize: Math.min(Style.largeFont.pixelSize, progressCanvas.height / 12)
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }
            }


            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();

                ctx.beginPath()
                ctx.fillStyle = Style.foregroundColor

                ctx.translate(width / 2, height / 2)
                ctx.rotate(135 * Math.PI / 180)

                ctx.lineCap = "round"
                ctx.lineWidth = width * .1

                ctx.beginPath()
                ctx.strokeStyle = Style.tileOverlayColor
                var startAngle = 0
                var endAngle = 270
                var radStart = startAngle * Math.PI/180;
                var radEnd = endAngle * Math.PI/180;
                ctx.arc(0, 0, width / 2 - ctx.lineWidth / 2, radStart, radEnd)
                ctx.stroke()
                ctx.closePath()

                ctx.beginPath()
                ctx.strokeStyle = app.interfaceToColor(progressCanvas.interfaceName)
                radEnd *= progressCanvas.progress
                ctx.arc(0, 0, width / 2 - ctx.lineWidth / 2, radStart, radEnd)
                ctx.stroke()
                ctx.closePath()
            }

            ColorIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Style.smallMargins
                name: app.interfaceToIcon(progressCanvas.interfaceName)
                size: Math.min(Style.bigIconSize, parent.height / 5)
                color: app.interfaceToColor(progressCanvas.interfaceName)
            }
        }
    }

    Component {
        id: scaleComponent
        Item {
            id: scaleCanvas
            property string interfaceName: parent.interfaceName
            property StateType stateType: parent.stateType
            property State state: parent.state
            property var minValue: parent.minValue
            property var maxValue: parent.maxValue

            property int scaleWidth: width * .1

            property var scale: {
                switch (interfaceName) {
                case "vocsensor":
                    return AirQualityIndex.iaqVoc
                case "cosensor":
                    return AirQualityIndex.caqiCo
                case "o3sensor":
                    return AirQualityIndex.caqiO3
                case "pm10sensor":
                    return AirQualityIndex.caqiPm10
                case "pm25sensor":
                    return AirQualityIndex.caqiPm25
                case "no2sensor":
                    return AirQualityIndex.caqiNo2
                }
                return baseScale
            }
            property var baseScale: [
                {
                    "value": maxValue,
                    "angle": 270,
                    "color": Style.tileOverlayColor
                }
            ]

            property var currentIndex: {
                for (var i = 0; i < scale.length; i++) {
                    if (state.value <= scale[i].value) {
                        return i;
                    }
                }
                log.warn("Value out of scale!")
                return -1
            }

            property double angle: {
                var baseAngle = 0
                var baseValue = 0;
                if (currentIndex > 0) {
                    baseAngle = scale[currentIndex-1].angle
                    baseValue = scale[currentIndex-1].value
                }
                var valueRange = scale[currentIndex].value - baseValue
                var angleRange = scale[currentIndex].angle - baseAngle
                var progress = (state.value - baseValue) / (scale[currentIndex].value - baseValue)
                return baseAngle + angleRange * progress
            }
            Behavior on angle { NumberAnimation { duration: Style.slowAnimationDuration; easing.type: Easing.InOutQuad } }
            onAngleChanged: maskCanvas.requestPaint();

            Canvas {
                id: baseCanvas
                anchors.fill: parent
                visible: false
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();

                    ctx.beginPath()
                    ctx.fillStyle = Style.foregroundColor

                    ctx.translate(width / 2, height / 2)
                    ctx.rotate(135 * Math.PI / 180)

                    ctx.lineCap = "round"
                    ctx.lineWidth = scaleCanvas.scaleWidth

                    // paint first rounded
                    ctx.beginPath()
                    ctx.strokeStyle = scaleCanvas.scale[0].color
                    var startAngle = 0
                    var endAngle = scaleCanvas.scale[0].angle * Math.PI/180
                    ctx.arc(0, 0, width / 2 - ctx.lineWidth / 2, startAngle, endAngle)
                    ctx.stroke()
                    ctx.closePath()

                    // paint last rounded
                    ctx.beginPath()
                    ctx.strokeStyle = scaleCanvas.scale[scaleCanvas.scale.length - 1].color
                    startAngle = scaleCanvas.scale[scaleCanvas.scale.length - 2].angle * Math.PI/180
                    endAngle = scaleCanvas.scale[scaleCanvas.scale.length - 1].angle * Math.PI/180
                    ctx.arc(0, 0, width / 2 - ctx.lineWidth / 2, startAngle, endAngle)
                    ctx.stroke()
                    ctx.closePath()

                    // paint inner parts
                    ctx.lineCap = "butt"
                    for (var i = 1; i < scaleCanvas.scale.length - 1; i++) {
                        ctx.beginPath()
                        ctx.strokeStyle = scaleCanvas.scale[i].color
                        startAngle = scaleCanvas.scale[i - 1].angle * Math.PI/180
                        endAngle = scaleCanvas.scale[i].angle * Math.PI/180
                        ctx.arc(0, 0, width / 2 - ctx.lineWidth / 2, startAngle, endAngle)
                        ctx.stroke()
                        ctx.closePath()
                    }
                }
            }
            Canvas {
                id: maskCanvas
                anchors.fill: parent
                visible: false
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();

                    ctx.beginPath()
                    ctx.fillStyle = Style.foregroundColor

                    ctx.translate(width / 2, height / 2)
                    ctx.rotate(135 * Math.PI / 180)

                    ctx.lineCap = "round"
                    ctx.lineWidth = width * .1

                    ctx.beginPath()
                    ctx.strokeStyle = "#55ffffff"
                    var startAngle = 0
                    var endAngle = 270
                    var radStart = startAngle * Math.PI/180;
                    var radEnd = endAngle * Math.PI/180;
                    ctx.arc(0, 0, width / 2 - ctx.lineWidth / 2, radStart, radEnd)
                    ctx.stroke()
                    ctx.closePath()

                    ctx.beginPath()
                    ctx.strokeStyle = "#000000"
                    radEnd = scaleCanvas.angle * Math.PI/180
                    ctx.arc(0, 0, width / 2 - ctx.lineWidth / 2, radStart, radEnd)
                    ctx.stroke()
                    ctx.closePath()
                }
            }

            OpacityMask {
                anchors.fill: parent
                source: baseCanvas
                maskSource: maskCanvas
            }


            ColumnLayout {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -Style.smallMargins
                width: parent.width * 0.6

                Label {
                    Layout.fillWidth: true
                    text: scaleCanvas.scale[scaleCanvas.currentIndex].text
                    font.pixelSize: Math.min(Style.hugeFont.pixelSize, scaleCanvas.height / 8)
                    wrapMode: Text.WordWrap
    //                    color: scaleCanvas.scale[scaleCanvas.currentIndex].color
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    maximumLineCount: 2
                }
                Label {
                    Layout.fillWidth: true
                    text: Types.toUiValue(scaleCanvas.state.value, scaleCanvas.stateType.unit).toFixed(1) + " " + Types.toUiUnit(scaleCanvas.stateType.unit)
                    font.pixelSize: Math.min(Style.largeFont.pixelSize, scaleCanvas.height / 12)
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }
            }


            ColorIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Style.smallMargins
    //                anchors.verticalCenterOffset: scaleCanvas.height / 2 - height
                name: app.interfaceToIcon(scaleCanvas.interfaceName)
                size: Math.min(Style.bigIconSize, parent.height / 5)
                color: app.interfaceToColor(scaleCanvas.interfaceName)
            }
        }
    }
}

