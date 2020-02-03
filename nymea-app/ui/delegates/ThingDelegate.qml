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

import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "../components"
import Nymea 1.0

NymeaListItemDelegate {
    id: root
    width: parent.width
    iconName: device && device.deviceClass ? app.interfacesToIcon(device.deviceClass.interfaces) : ""
    text: device ? device.name : ""
    progressive: true
    secondaryIconName: batteryCritical ? "../images/battery/battery-010.svg" : ""
    tertiaryIconName: disconnected ? "../images/dialog-warning-symbolic.svg" : ""
    tertiaryIconColor: "red"

    property Device device: null

    readonly property bool hasBatteryInterface: device && device.deviceClass.interfaces.indexOf("battery") > 0
    readonly property StateType batteryCriticalStateType: hasBatteryInterface ? device.deviceClass.stateTypes.findByName("batteryCritical") : null
    readonly property State batteryCriticalState: batteryCriticalStateType ? device.states.getState(batteryCriticalStateType.id) : null
    readonly property bool batteryCritical: batteryCriticalState && batteryCriticalState.value === true

    readonly property bool hasConnectableInterface: device && device.deviceClass.interfaces.indexOf("connectable") > 0
    readonly property StateType connectedStateType: hasConnectableInterface ? device.deviceClass.stateTypes.findByName("connected") : null
    readonly property State connectedState: connectedStateType ? device.states.getState(connectedStateType.id) : null
    readonly property bool disconnected: connectedState && connectedState.value === false ? true : false
}
