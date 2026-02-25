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
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtCharts
import Nymea

import "../../components"
import "../../customviews"

DashboardDelegateBase {
    id: root
    property DashboardGraphItem item: null

    readonly property Thing thing: engine.thingManager.fetchingData ? null : engine.thingManager.things.getThing(item.thingId)
    readonly property StateType stateType: thing ? thing.thingClass.stateTypes.getStateType(item.stateTypeId) : null
    readonly property State state: thing ? thing.states.getState(item.stateTypeId) : null

    contentItem: Loader {
        width: root.width
        height: root.height
        sourceComponent: {
            if (engine.jsonRpcClient.ensureServerVersion("8.0")) {
                return stateChartComponent
            } else {
                return graphComponent
            }
        }
    }

    Component {
        id: stateChartComponent

        StateChart {
            id: graph
            title: {
                if (!root.state || !root.stateType) {
                    return ""
                }

                var ret = root.thing.name + ", " + root.stateType.displayName
                if (["int", "uint", "double"].indexOf(root.stateType.type.toLowerCase()) >= 0) {
                    ret += ": " + Types.toUiValue(root.state.value, root.stateType.unit).toFixed(0) + Types.toUiUnit(root.stateType.unit)
                }
                return ret
            }

            thing: root.thing
            color: root.thing ? app.interfaceToColor(root.thing.thingClass.interfaces[0]) : Style.accentColor
    //        iconSource: ""// app.interfaceToIcon(interfaceName)
            implicitHeight: width * .6
    //        property string interfaceName: parent.interfaceName
            stateType: root.stateType
    //        property State state: root.state
        }
    }


    Component {
        id: graphComponent

        GenericTypeGraph {
            id: graph
            title: root.state && root.stateType ? root.thing.name + " " + Types.toUiValue(root.state.value, root.stateType.unit) + Types.toUiUnit(root.stateType.unit) : ""

            thing: root.thing
            color: "blue"//app.interfaceToColor(interfaceName)
            iconSource: ""// app.interfaceToIcon(interfaceName)
            implicitHeight: width * .6
    //        property string interfaceName: parent.interfaceName
            stateType: root.stateType
            property State state: root.state
        }
    }

}

