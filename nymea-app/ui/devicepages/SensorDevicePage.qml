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

DevicePageBase {
    id: root

    Flickable {
        id: listView
        anchors { fill: parent }
        topMargin: app.margins / 2
        interactive: contentHeight > height
        contentHeight: contentGrid.implicitHeight

        GridLayout {
            id: contentGrid
            width: parent.width - app.margins
            anchors.horizontalCenter: parent.horizontalCenter
            columns: Math.ceil(width / 600)
            rowSpacing: 0
            columnSpacing: 0

            Repeater {
                model: ListModel {
                    Component.onCompleted: {
                        var supportedInterfaces = ["temperaturesensor", "humiditysensor", "pressuresensor", "moisturesensor", "lightsensor", "conductivitysensor", "noisesensor", "co2sensor", "presencesensor", "daylightsensor", "closablesensor", "watersensor"]
                        for (var i = 0; i < supportedInterfaces.length; i++) {
                            if (root.deviceClass.interfaces.indexOf(supportedInterfaces[i]) >= 0) {
                                append({name: supportedInterfaces[i]});
                            }
                        }
                    }
                }

                delegate: Loader {
                    id: loader
                    Layout.fillWidth: true
                    Layout.preferredHeight: item.implicitHeight

                    property StateType stateType: root.deviceClass.stateTypes.findByName(interfaceStateMap[modelData])
                    property State state: root.thing.stateByName(interfaceStateMap[modelData])
                    property string interfaceName: modelData

    //                sourceComponent: stateType && stateType.type.toLowerCase() === "bool" ? boolComponent : graphComponent
                    sourceComponent: graphComponent

                    property var interfaceStateMap: {
                        "temperaturesensor": "temperature",
                        "humiditysensor": "humidity",
                        "pressuresensor": "pressure",
                        "moisturesensor": "moisture",
                        "lightsensor": "lightIntensity",
                        "conductivitysensor": "conductivity",
                        "noisesensor": "noise",
                        "co2sensor": "co2",
                        "presencesensor": "isPresent",
                        "daylightsensor": "daylight",
                        "closablesensor": "closed",
                        "watersensor": "waterDetected"
                    }
                }

            }
        }



        Component {
            id: graphComponent

            GenericTypeGraph {
                id: graph
                device: root.device
                color: app.interfaceToColor(interfaceName)
                iconSource: app.interfaceToIcon(interfaceName)
                implicitHeight: width * .6
                property string interfaceName: parent.interfaceName
                stateType: parent.stateType
                property State state: parent.state

                Binding {
                    target: graph
                    property: "title"
                    when: ["presencesensor", "daylightsensor", "closablesensor", "watersensor"].indexOf(graph.interfaceName) >= 0
                    value: {
                        switch (graph.interfaceName) {
                        case "presencesensor":
                            return graph.state.value === true ? qsTr("Presence") : qsTr("Vacant")
                        case "daylightsensor":
                            return graph.state.value === true ? qsTr("Daytimet") : qsTr("Nighttime")
                        case "closablesensor":
                            return graph.state.value === true ? qsTr("Closed") : qsTr("Open")
                        case "watersensor":
                            return graph.state.value === true ? qsTr("Wet") : qsTr("Dry")
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
                    Layout.minimumWidth: app.iconSize * 5
                    Layout.rowSpan: app.landscape ? 5 : 1
                    ColorIcon {
                        anchors.centerIn: parent
                        height: app.iconSize * 4
                        width: height
                        name: {
                            switch (boolView.interfaceName) {
                            case "closablesensor":
                                return device.states.getState(boolView.stateType.id).value === true ? Qt.resolvedUrl("../images/lock-closed.svg") : Qt.resolvedUrl("../images/lock-open.svg")
                            default:
                                return app.interfaceToIcon(boolView.interfaceName)
                            }
                        }
                        color: {
                            switch (boolView.interfaceName) {
                            case "closablesensor":
                                return device.states.getState(boolView.stateType.id).value === true ? "green" : "red"
                            default:
                                device.states.getState(boolView.stateType.id).value === true ? app.interfaceToColor(boolView.interfaceName) : Style.iconColor
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
                    property StateType lastSeenStateType: root.deviceClass.stateTypes.findByName("lastSeenTime")
                    property State lastSeenState: lastSeenStateType ? root.device.states.getState(lastSeenStateType.id) : null
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
                    property StateType sunriseStateType: root.deviceClass.stateTypes.findByName("sunriseTime")
                    property State sunriseState: sunriseStateType ? root.device.states.getState(sunriseStateType.id) : null
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
                    property StateType sunsetStateType: root.deviceClass.stateTypes.findByName("sunsetTime")
                    property State sunsetState: sunsetStateType ? root.device.states.getState(sunsetStateType.id) : null
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
}

