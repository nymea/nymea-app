// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Nymea
import NymeaApp.Utils

import "qrc:/ui/components"

Item {
    id: root

    property Thing thing: null
    property string interfaceName: ""


    CircleBackground {
        id: background
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) - Style.margins
        height: width

        readonly property StateType sensorStateType: root.thing ? root.thing.thingClass.stateTypes.findByName(NymeaUtils.sensorInterfaceStateMap[root.interfaceName]) : null
        readonly property State sensorState: root.thing ? root.thing.stateByName(NymeaUtils.sensorInterfaceStateMap[interfaceName]) : null

        onColor: {
            if (root.interfaceName == "closablesensor") {
                return sensorState.value === true ? Style.green : Style.red
            }
            return app.interfaceToColor(root.interfaceName)
        }
        on: {
            if (root.interfaceName == "closablesensor") {
                return true
            }
            return sensorStateType && sensorStateType.type.toLowerCase() == "bool" && sensorState.value === true
        }
        iconSource: {
            if (root.interfaceName == "closablesensor") {
                return sensorState.value === true ? "sensors/window-closed" : "sensors/window-open"
            }
            var map = [
                "presencesensor",
                "daylightsensor",
                "firesensor",
                "watersensor"
            ]
            return map.indexOf(root.interfaceName) >= 0 ? app.interfaceToIcon(root.interfaceName) : ""
        }

        Loader {
            anchors.centerIn: parent
            width: background.contentItem.width
            height: background.contentItem.height
            property StateType stateType: root.thing.thingClass.stateTypes.findByName(NymeaUtils.sensorInterfaceStateMap[root.interfaceName])
            property State state: root.thing.stateByName(NymeaUtils.sensorInterfaceStateMap[root.interfaceName])
            property string interfaceName: root.interfaceName
            property var minValue: {
                if (["temperaturesensor"].indexOf(root.interfaceName) >= 0) {
                    return Types.toUiValue(-50, Types.UnitDegreeCelsius)
                }
                if (["pressuresensor"].indexOf(root.interfaceName) >= 0) {
                    return Types.toUiValue(state.minValue, Types.UnitMilliBar)
                }

                return state.minValue
            }
            property var maxValue: {
                if (["temperaturesensor"].indexOf(root.interfaceName) >= 0) {
                    return Types.toUiValue(50, Types.UnitDegreeCelsius)
                }
                if (["pressuresensor"].indexOf(root.interfaceName) >= 0) {
                    return Types.toUiValue(state.maxValue, Types.UnitMilliBar)
                }
                return state.maxValue
            }

            sourceComponent: {
                if (stateType.type.toLowerCase() == "bool") {
                    return boolComponent;
                }

                var progressInterfaces = [
                            "humiditysensor",
                            "o2sensor",
                            "temperaturesensor",
                            "moisturesensor",
                            "conductivitysensor",
                            "gassensor",
                            "lightsensor",
                            "orpsensor",
                            "co2sensor",
                            "phsensor",
                            "pressuresensor",
                            "waterlevelsensor",
                            "windspeedsensor",
                            "noisesensor"
                        ]
                if (progressInterfaces.indexOf(root.interfaceName) >= 0) {
                    return progressComponent
                }
                var scaleInterfaces = [
                            "vocsensor",
                            "cosensor",
                            "o3sensor",
                            "pm10sensor",
                            "pm25sensor",
                            "no2sensor"
                        ]
                if (scaleInterfaces.indexOf(root.interfaceName) >= 0) {
                    return scaleComponent
                }
            }
        }
    }

    Component {
        id: boolComponent
        Rectangle {
            property State state: parent.state

            radius: width / 2
            color: "transparent"
            border.color: {
                if (root.interfaceName == "closablesensor") {
                    return state.value === true ? Style.green : Style.red
                }
                return app.interfaceToColor(root.interfaceName)
            }
            border.width: width * .1
            visible: {
                if (root.interfaceName == "closablesensor") {
                    return true
                }

                return state.value === true
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
