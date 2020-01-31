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

    ListView {
        anchors { fill: parent }
        model: ListModel {
            Component.onCompleted: {
                if (root.deviceClass.interfaces.indexOf("extendedsmartmeterproducer") >= 0
                        || root.deviceClass.interfaces.indexOf("extendedsmartmeterconsumer") >= 0) {
                    append( {interface: "extendedsmartmeterproducer", stateTypeName: "currentPower" })
                }
                if (root.deviceClass.interfaces.indexOf("smartmeterproducer") >= 0) {
                    append( {interface: "smartmeterproducer", stateTypeName: "totalEnergyProduced" })
                }
                if (root.deviceClass.interfaces.indexOf("smartmeterconsumer") >= 0) {
                    append( {interface: "smartmeterconsumer", stateTypeName: "totalEnergyConsumed" })
                }
                print("shown graphs are", count)
            }
        }
        delegate: ColumnLayout {
            width: parent.width
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.topMargin: app.margins; Layout.rightMargin: app.rightMargins;
                text: root.deviceClass.stateTypes.findByName(model.stateTypeName).displayName
            }
            GenericTypeGraph {
                Layout.fillWidth: true
                device: root.device
                stateType: root.deviceClass.stateTypes.findByName(model.stateTypeName)
                color: app.interfaceToColor(model.interface)
                iconSource: app.interfaceToIcon(model.interface)
                roundTo: 5
            }
        }
    }
}
