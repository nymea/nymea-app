/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2022, nymea GmbH
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
import Qt5Compat.GraphicalEffects
import QtCharts
import Nymea
import NymeaApp.Utils
import Nymea.AirConditioning

import "qrc:/ui/components"
import "qrc:/ui/delegates"
import "airconditioning"

MainViewBase {
    id: root

    contentY: flickable.contentY + topMargin

    headerButtons: [
        {
            iconSource: "qrc:/icons/configure.svg",
            color: Style.iconColor,
            visible: acManager.zoneInfos.count > 0 && NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin),
            trigger: function() {
                pageStack.push("airconditioning/ACSettingsPage.qml", {acManager: acManager});
            }
        }
    ]

    LoggingCategory {
        id: category
        name: "AirConditioning"
    }


    ThingsProxy {
        id: thermostats
        engine: _engine
        shownInterfaces: ["thermostat"]
    }


    AirConditioningManager {
        id: acManager
        engine: _engine
    }

    ZonesView {
        id: flickable
        anchors.fill: parent
        topMargin: root.topMargin
        bottomMargin: root.bottomMargin
        clip: true
        acManager: acManager
    }


    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        visible: !engine.thingManager.fetchingData && (!engine.jsonRpcClient.experiences.hasOwnProperty("AirConditioning") || engine.jsonRpcClient.experiences["AirConditioning"] < "0.1")
        title: qsTr("Air conditioning plugin not installed.")
        text: qsTr("To set up air conditioning, install the air conditioning plugin.")
        imageSource: "qrc:/icons/sensors.svg"
        buttonText: qsTr("Install A/C plugin")
        buttonVisible: packagesFilterModel.count > 0
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../system/PackageListPage.qml"), {filter: "nymea-experience-plugin-airconditioning"})
        PackagesFilterModel {
            id: packagesFilterModel
            packages: engine.systemController.packages
            nameFilter: "nymea-experience-plugin-airconditioning"
        }
    }
    EmptyViewPlaceholder {
        id: noZonePlaceHolder
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        visible: engine.jsonRpcClient.experiences["AirConditioning"] >= "0.1" && acManager.zoneInfos.count == 0
        title: qsTr("No zones configured.")
        text: qsTr("Start with configuring your zones.")
        imageSource: "qrc:/icons/sensors.svg"
        buttonText: qsTr("Add zone")
        onButtonClicked: {
            pendingAddCall = acManager.addZone(qsTr("Zone %1").arg(acManager.zoneInfos.count + 1), [], [], [], [])
        }
        property int pendingAddCall: -1

        Connections {
            target: acManager
            onAddZoneReply: {
                if (commandId == noZonePlaceHolder.pendingAddCall) {
                    print("zone added", zoneId)
                    var zone = acManager.zoneInfos.getZoneInfo(zoneId)
                    pageStack.push(Qt.resolvedUrl("airconditioning/EditZonePage.qml"), {acManager: acManager, zone: zone, createNew: true})
                }
            }
        }
    }
}
