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
import QtGraphicalEffects 1.0
import QtCharts 2.2
import Nymea 1.0
import "../components"
import "../delegates"
import "energy"

MainViewBase {
    id: root

    contentY: flickable.contentY + topMargin

    headerButtons: [
        {
            iconSource: "/ui/images/configure.svg",
            color: Style.iconColor,
            trigger: function() {
                pageStack.push("energy/EnergySettingsPage.qml", {energyManager: energyManager});
            },
            visible: true
        }
    ]

    EnergyManager {
        id: energyManager
        engine: _engine
    }

    property var thingColors: [Style.blue, Style.green, Style.red, Style.yellow, Style.purple, Style.yellow, Style.lime]


    ThingsProxy {
        id: energyMeters
        engine: _engine
        shownInterfaces: ["energymeter"]
    }
    readonly property Thing rootMeter: energyMeters.count > 0 ? energyMeters.get(0) : null

    ThingsProxy {
        id: consumers
        engine: _engine
        shownInterfaces: ["smartmeterconsumer", "energymeter"]
        hideTagId: "hiddenInEnergyView"
        hiddenThingIds: [energyManager.rootMeterId]
    }

    ThingsProxy {
        id: producers
        engine: _engine
        shownInterfaces: ["smartmeterproducer"]
    }

    ThingsProxy {
        id: batteries
        engine: _engine
        shownInterfaces: ["energystorage"]
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: app.margins / 2
        contentHeight: energyGrid.childrenRect.height
        visible: !engine.thingManager.fetchingData && engine.jsonRpcClient.experiences.hasOwnProperty("Energy")
        topMargin: root.topMargin

        // GridLayout directly in a flickable causes problems at initialisation
        Item {
            width: parent.width
            height: energyGrid.implicitHeight


            GridLayout {
                id: energyGrid
                width: parent.width
                property int rawColumns: Math.floor(flickable.width / 300)
                columns: Math.max(1, rawColumns - (rawColumns % 2))
                rowSpacing: 0
                columnSpacing: 0


                CurrentConsumptionBalancePieChart {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: energyManager
                    visible: producers.count > 0
                }
                CurrentProductionBalancePieChart {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: energyManager
                    visible: producers.count > 0
                }

                PowerConsumptionBalanceHistory {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    visible: producers.count > 0
                }

                PowerProductionBalanceHistory {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    visible: producers.count > 0
                }

                ConsumersPieChart {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: energyManager
                    visible: consumers.count > 0
                    colors: root.thingColors
                    consumers: consumers
                }

//                ConsumersBarChart {
//                    Layout.fillWidth: true
//                    Layout.preferredHeight: width
//                    energyManager: energyManager
//                    visible: consumers.count > 0
//                    colors: root.thingColors
//                    consumers: consumers
//                }
                ConsumersHistory {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    visible: consumers.count > 0
                    colors: root.thingColors
                    consumers: consumers
                }

                PowerBalanceStats {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: energyManager
                }

                ConsumerStats {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: energyManager
                    visible: consumers.count > 0
                    colors: root.thingColors
                    consumers: consumers
                }
            }
        }
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        visible: !engine.thingManager.fetchingData && !engine.jsonRpcClient.experiences.hasOwnProperty("Energy")
        title: qsTr("Energy plugin not installed installed.")
        text: qsTr("This %1 system does not have the energy extensions installed.").arg(Configuration.systemName)
        imageSource: "../images/smartmeter.svg"
        buttonText: qsTr("Install energy plugin")
        buttonVisible: packagesFilterModel.count > 0
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../system/PackageListPage.qml"), {filter: "nymea-experience-plugin-energy"})
        PackagesFilterModel {
            id: packagesFilterModel
            packages: engine.systemController.packages
            nameFilter: "nymea-experience-plugin-energy"
        }
    }
    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        visible: engine.jsonRpcClient.experiences.hasOwnProperty("Energy") && !engine.thingManager.fetchingData && energyMeters.count == 0
        title: qsTr("There are no energy meters installed.")
        text: qsTr("To get an overview of your current energy usage, install an energy meter.")
        imageSource: "../images/smartmeter.svg"
        buttonText: qsTr("Add things")
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../thingconfiguration/NewThingPage.qml"))
    }
}
