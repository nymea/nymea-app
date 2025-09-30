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

