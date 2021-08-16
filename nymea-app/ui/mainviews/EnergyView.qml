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

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Qt5Compat.GraphicalEffects
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
            iconSource: "qrc:/icons/configure.svg",
            color: Style.iconColor,
            trigger: function() {
                pageStack.push("energy/EnergySettingsPage.qml", {energyManager: energyManager});
            },
            visible: energyMeters.count > 1 || allConsumers.count - Math.min(energyMeters.count, 1) > 0
        }
    ]

    EnergyManager {
        id: energyManager
        engine: _engine
    }


    ThingsProxy {
        id: energyMeters
        engine: _engine
        shownInterfaces: ["energymeter"]
    }
    readonly property Thing rootMeter: engine.thingManager.fetchingData ? null : engine.thingManager.things.getThing(energyManager.rootMeterId)

    ThingsProxy {
        id: allConsumers
        engine: _engine
        shownInterfaces: ["smartmeterconsumer", "energymeter"]
    }

    ThingsProxy {
        id: consumers
        engine: _engine
        parentProxy: allConsumers
        hideTagId: "hiddenInEnergyView"
        hiddenThingIds: [energyManager.rootMeterId]
    }

    ThingsProxy {
        id: producers
        engine: _engine
        shownInterfaces: ["smartmeterproducer"]
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: app.margins / 2
        contentHeight: energyGrid.childrenRect.height
        visible: !engine.thingManager.fetchingData && engine.jsonRpcClient.experiences.hasOwnProperty("Energy") && engine.jsonRpcClient.experiences["Energy"] >= "0.2"
        topMargin: root.topMargin
        bottomMargin: root.bottomMargin

//        onContentYChanged: print("contentY", contentY)

        // GridLayout directly in a flickable causes problems at initialisation
        Item {
            width: flickable.width
            height: energyGrid.implicitHeight

            GridLayout {
                id: energyGrid
                width: parent.width
                property int rawColumns: Math.floor(flickable.width / 300)
                columns: Math.min(3, Math.max(1, rawColumns /*- (rawColumns % 2)*/))
                rowSpacing: 0
                columnSpacing: 0

                CurrentPowerBalancePieChart {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: energyManager
                    visible: rootMeter != null || producers.count > 0
                    animationsEnabled: Qt.application.active && root.isCurrentItem && flickable.contentY < height
//                    onAnimationsEnabledChanged: print("animations for power balance chart", animationsEnabled ? "enabled" : "disabled")
                }

                PowerBalanceHistory {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    visible: rootMeter != null || producers.count > 0
                }

                PowerBalanceStats {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: energyManager
                    visible: rootMeter != null || producers.count > 0
                    producers: producers
                }

                ConsumersPieChart {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: energyManager
                    visible: consumers.count > 0
                    consumers: consumers
                    animationsEnabled: Qt.application.active && root.isCurrentItem && flickable.contentY < y + height && flickable.contentY + flickable.height > y
                    onAnimationsEnabledChanged: print("animations for consumer balance chart", animationsEnabled ? "enabled" : "disabled")

                }

                ConsumersHistory {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    visible: consumers.count > 0
                    energyManager: energyManager
                    consumers: consumers
                }

                ConsumerStats {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: energyManager
                    visible: consumers.count > 0
                    consumers: consumers
                }
            }
        }
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        visible: !engine.thingManager.fetchingData && (!engine.jsonRpcClient.experiences.hasOwnProperty("Energy") || engine.jsonRpcClient.experiences["Energy"] <= "0.1")
        title: qsTr("Energy plugin not installed.")
        text: qsTr("To get an overview of your current energy usage, install the energy plugin.")
        imageSource: "qrc:/icons/smartmeter.svg"
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
        visible: engine.jsonRpcClient.experiences["Energy"] >= "0.2" && !engine.thingManager.fetchingData && energyMeters.count == 0 && consumers.count == 0 && producers.count == 0
        title: qsTr("There are no energy meters installed.")
        text: qsTr("To get an overview of your current energy usage, set up an energy meter.")
        imageSource: "qrc:/icons/smartmeter.svg"
        buttonText: qsTr("Add things")
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../thingconfiguration/NewThingPage.qml"))
    }
}
