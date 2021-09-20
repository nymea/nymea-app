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
import "../utils"

ThingPageBase {
    id: root

    readonly property State powerState: thing.stateByName("power")
    readonly property State flowRateState: thing.stateByName("flowRate")
    readonly property StateType flowRateStateType: thing.thingClass.stateTypes.findByName("flowRate")

    ActionQueue {
        id: actionQueue
        thing: root.thing
        stateName: "power"
    }

    CircleBackground {
        id: background
        anchors.fill: parent
        anchors.margins: Style.hugeMargins
        iconSource: "ventilation"
        onColor: app.interfaceToColor("ventilation")
        on: (actionQueue.pendingValue || powerState.value) === true
        onClicked: {
            PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
            actionQueue.sendValue(!root.powerState.value)
        }
        PropertyAnimation on rotation {
            running: root.powerState.value === true
            duration: 2000
            from: 0
            to: 360
            loops: Animation.Infinite
            onDurationChanged: {
                running = false;
                running = true;
            }
        }
    }

    Dial {
        anchors.centerIn: parent
        height: background.contentItem.height
        width: background.contentItem.width
        visible: root.flowRateState

        thing: root.thing
        stateName: "flowRate"
        color: app.interfaceToColor("ventilation")
    }
}
