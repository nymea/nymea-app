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
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtCharts 2.2
import Nymea 1.0
import "../components"
import "../delegates"

MainViewBase {
    id: root

    ThingsProxy {
        id: consumers
        engine: _engine
        shownInterfaces: ["smartmeterconsumer"]
    }
    ThingsProxy {
        id: producers
        engine: _engine
        shownInterfaces: ["smartmeterproducer"]
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        visible: !engine.thingManager.fetchingData && consumers.count == 0
        title: qsTr("There are no energy meters installed.")
        text: qsTr("To get an overview of your current energy usage, install some energy meters.")
        imageSource: "../images/smartmeter.svg"
        buttonText: qsTr("Add things")
    }

    Flickable {
        anchors.fill: parent
        contentHeight: energyGrid.childrenRect.height

        GridLayout {
            id: energyGrid
            width: parent.width
            visible: consumers.count > 0
            columns: Math.floor(root.width / 300)

            SmartMeterChart {
                Layout.fillWidth: true
                Layout.preferredHeight: width * .7
                meters: consumers
                title: qsTr("Total consumed energy")
                visible: consumers.count > 0
            }
            SmartMeterChart {
                Layout.fillWidth: true
                Layout.preferredHeight: width * .7
                meters: producers
                title: qsTr("Total produced energy")
                visible: producers.count > 0
                multiplier: -1
            }
        }
    }
}
