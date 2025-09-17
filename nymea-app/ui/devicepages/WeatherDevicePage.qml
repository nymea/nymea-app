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
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

import "../components"
import "../customviews"

ThingPageBase {
    id: root

    Flickable {
        anchors.fill: parent
        clip: true
        contentHeight: contentColumn.implicitHeight

        ColumnLayout {
            id: contentColumn
            width: parent.width

            WeatherView {
                Layout.fillWidth: true
                thing: root.thing
            }

            GridLayout {
                id: content
                Layout.fillWidth: true
                columns: Math.min(width / 300, 4)

                Loader {
                    Layout.fillWidth: true
                    sourceComponent: {
                        if (engine.jsonRpcClient.ensureServerVersion("8.0")) {
                            return tempComponent
                        }
                        return tempComponentPre18
                    }
                }

                Component {
                    id: tempComponent
                    StateChart {
                        thing: root.thing
                        stateType: root.thing.thingClass.stateTypes.findByName("temperature")
                        color: app.interfaceToColor("temperaturesensor")
                    }
                }

                Component {
                    id: tempComponentPre18

                    GenericTypeGraph {
                        Layout.fillWidth: true
                        thing: root.thing
                        stateType: root.thing.thingClass.stateTypes.findByName("temperature")
                        iconSource: app.interfaceToIcon("temperaturesensor")
                        color: app.interfaceToColor("temperaturesensor")
                    }
                }

                Loader {
                    Layout.fillWidth: true
                    sourceComponent: {
                        if (engine.jsonRpcClient.ensureServerVersion("8.0")) {
                            return humidityComponent
                        }
                        return humidityComponentPre18
                    }
                }

                Component {
                    id: humidityComponent
                    StateChart {
                        thing: root.thing
                        stateType: root.thing.thingClass.stateTypes.findByName("humidity")
                        color: app.interfaceToColor("humiditysensor")
                    }
                }

                Component {
                    id: humidityComponentPre18
                    GenericTypeGraph {
                        Layout.fillWidth: true
                        thing: root.thing
                        stateType: root.thing.thingClass.stateTypes.findByName("humidity")
                        iconSource: app.interfaceToIcon("humiditysensor")
                        color: app.interfaceToColor("humiditysensor")
                    }
                }

                Loader {
                    Layout.fillWidth: true
                    sourceComponent: {
                        if (engine.jsonRpcClient.ensureServerVersion("8.0")) {
                            return pressureComponent
                        }
                        return pressureComponentPre18
                    }
                }

                Component {
                    id: pressureComponent
                    StateChart {
                        thing: root.thing
                        stateType: root.thing.thingClass.stateTypes.findByName("pressure")
                        color: app.interfaceToColor("pressuresensor")
                    }
                }

                Component {
                    id: pressureComponentPre18
                    GenericTypeGraph {
                        Layout.fillWidth: true
                        thing: root.thing
                        stateType: root.thing.thingClass.stateTypes.findByName("pressure")
                        iconSource: app.interfaceToIcon("pressuresensor")
                        color: app.interfaceToColor("pressuresensor")
                    }
                }

                Loader {
                    Layout.fillWidth: true
                    sourceComponent: {
                        if (engine.jsonRpcClient.ensureServerVersion("8.0")) {
                            return windSpeedComponent
                        }
                        return windSpeedComponentPre18
                    }
                }

                Component {
                    id: windSpeedComponent
                    StateChart {
                        thing: root.thing
                        stateType: root.thing.thingClass.stateTypes.findByName("windSpeed")
                        color: app.interfaceToColor("windspeedsensor")
                    }
                }

                Component {
                    id: windSpeedComponentPre18
                    GenericTypeGraph {
                        Layout.fillWidth: true
                        thing: root.thing
                        stateType: root.thing.thingClass.stateTypes.findByName("windSpeed")
                        iconSource: app.interfaceToIcon("windspeedsensor")
                        color: app.interfaceToColor("windspeedsensor")
                    }
                }
            }
        }
    }
}
