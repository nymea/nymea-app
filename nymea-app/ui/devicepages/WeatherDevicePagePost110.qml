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

Flickable {
    anchors.fill: parent
    clip: true
    contentHeight: contentColumn.implicitHeight

    property var device
    property var deviceClass

    ColumnLayout {
        id: contentColumn
        width: parent.width

        WeatherView {
            Layout.fillWidth: true
            device: root.device
            deviceClass: root.deviceClass
        }

        GridLayout {
            id: content
            Layout.fillWidth: true
            columns: Math.min(width / 300, 4)

            GenericTypeGraph {
                Layout.fillWidth: true
                device: root.device
                stateType: root.deviceClass.stateTypes.findByName("temperature")
                iconSource: app.interfaceToIcon("temperaturesensor")
                color: app.interfaceToColor("temperaturesensor")
            }
            GenericTypeGraph {
                Layout.fillWidth: true
                device: root.device
                stateType: root.deviceClass.stateTypes.findByName("humidity")
                iconSource: app.interfaceToIcon("humiditysensor")
                color: app.interfaceToColor("humiditysensor")
            }
            GenericTypeGraph {
                Layout.fillWidth: true
                device: root.device
                stateType: root.deviceClass.stateTypes.findByName("pressure")
                iconSource: app.interfaceToIcon("pressuresensor")
                color: app.interfaceToColor("pressuresensor")
            }
            GenericTypeGraph {
                Layout.fillWidth: true
                device: root.device
                stateType: root.deviceClass.stateTypes.findByName("windSpeed")
                iconSource: app.interfaceToIcon("windspeedsensor")
                color: app.interfaceToColor("windspeedsensor")
            }
        }
    }

}
