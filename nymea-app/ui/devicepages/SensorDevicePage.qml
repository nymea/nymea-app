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
                if (root.thing.thingClass.interfaces.indexOf(supportedInterfaces[i]) >= 0) {
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

                    delegate: SensorView {
                        width: Math.floor(flow.width / itemsInRow)
                        height: Math.min(400, flow.cellWidth)
                        property int row: Math.floor(index / flow.columns)
                        property int itemsInRow: row < flow.totalRows ? flow.columns : (flowRepeater.count % flow.columns)

                        thing: root.thing
                        interfaceName: modelData
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

                        property StateType stateType: root.thing.thingClass.stateTypes.findByName(interfaceStateMap[modelData])
                        property State state: root.thing.stateByName(interfaceStateMap[modelData])
                        property string interfaceName: modelData

                        sourceComponent: engine.jsonRpcClient.ensureServerVersion("8.0") ? stateChartComponent : graphComponent

                    }
                }
            }
        }

        Component {
            id: stateChartComponent
            StateChart {
                thing: root.thing
                stateType: parent.stateType
                color: app.interfaceToColor(interfaceName)
                iconSource: app.interfaceToIcon(interfaceName)

            }
        }

        Component {
            id: graphComponent

            GenericTypeGraph {
                id: graph
                thing: root.thing
                color: app.interfaceToColor(interfaceName)
                iconSource: {
                    if (graph.interfaceName == "closablesensor") {
                        return graph.state.value === true ? "sensors/window-closed" : "sensors/window-open"
                    }
                    return app.interfaceToIcon(interfaceName)
                }
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
    }
}

