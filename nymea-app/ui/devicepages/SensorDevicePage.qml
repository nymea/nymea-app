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
import Nymea 1.0
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
        "gassensor": "gas",
        "presencesensor": "isPresent",
        "daylightsensor": "daylight",
        "closablesensor": "closed",
        "watersensor": "waterDetected",
        "firesensor": "fireDetected",
        "waterlevelsensor": "waterLevel",
        "phsensor": "ph",
        "o2sensor": "o2saturation",
        "orpsensor": "orp",
        "airquality": "airQuality",
        "indoorairquality": "indoorAirQuality"
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
                                    return state.minValue
                                }
                                property var maxValue: {
                                    if (["temperaturesensor"].indexOf(modelData) >= 0) {
                                        return Types.toUiValue(50, Types.UnitDegreeCelsius)
                                    }
                                    return state.maxValue
                                }

                                sourceComponent: {
                                    var handledInterfaces = [
                                                "humiditysensor",
                                                "o2sensor",
                                                "temperaturesensor",
                                                "moisturesensor",
                                                "co2sensor",
                                                "conductivitysensor",
                                                "cosensor",
                                                "co2sensor",
                                                "gassensor",
                                                "lightsensor",
                                                "orpsensor",
                                                "phsensor",
                                                "pressuresensor",
                                                "waterlevelsensor",
                                                "windspeedsensor"
                                            ]
                                    if (handledInterfaces.indexOf(modelData) >= 0) {
                                        return progressComponent
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

            Label {
                anchors.centerIn: parent
                width: parent.width * 0.6
                text: Types.toUiValue(progressCanvas.state.value, progressCanvas.stateType.unit).toFixed(1) + " " + Types.toUiUnit(progressCanvas.stateType.unit)
                font.pixelSize: Math.min(Style.hugeFont.pixelSize, parent.height / 6)
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
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
                var progress = (progressCanvas.state.value - progressCanvas.minValue) / (progressCanvas.maxValue - progressCanvas.minValue)
                radEnd *= progress
                ctx.arc(0, 0, width / 2 - ctx.lineWidth / 2, radStart, radEnd)
                ctx.stroke()
                ctx.closePath()
            }

            ColorIcon {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: progressCanvas.height / 2 - height
                name: app.interfaceToIcon(progressCanvas.interfaceName)
                size: Math.min(Style.bigIconSize, parent.height / 5)
                color: app.interfaceToColor(progressCanvas.interfaceName)
            }
        }
    }

}

