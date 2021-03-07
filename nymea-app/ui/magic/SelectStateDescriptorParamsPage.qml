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

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "../components"
import "../delegates"
import Nymea 1.0

Page {
    id: root
    // Needs to be set and filled in with thingId and eventTypeId
    property var stateDescriptor: null

    readonly property Thing thing: stateDescriptor && stateDescriptor.thingId ? engine.thingManager.things.getThing(stateDescriptor.thingId) : null
    readonly property var iface: stateDescriptor && stateDescriptor.interfaceName ? Interfaces.findByName(stateDescriptor.interfaceName) : null
    readonly property var stateType: thing ? thing.thingClass.stateTypes.getStateType(stateDescriptor.stateTypeId)
                                              : iface ? iface.stateTypes.findByName(stateDescriptor.interfaceState) : null

    signal backPressed();
    signal completed();

    header: NymeaHeader {
        text: qsTr("Options")
        onBackPressed: root.backPressed();
    }

    ColumnLayout {
        anchors.fill: parent
        ParamDescriptorDelegate {
            id: paramDelegate
            Layout.fillWidth: true
            paramType: root.stateType
            value: paramType.defaultValue
        }
        Button {
            text: qsTr("OK")
            Layout.fillWidth: true
            Layout.margins: app.margins
            onClicked: {
                root.stateDescriptor.valueOperator = paramDelegate.operatorType
                root.stateDescriptor.value = paramDelegate.value
                root.completed()
            }
        }
    }
}
