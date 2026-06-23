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
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Nymea
import Nymea.DynamicLoadManager

import "qrc:/ui/components"
import "qrc:/ui/system/dynamicloadmanager"

MainViewBase {
    id: root

    contentY: graph.contentY + topMargin

    headerButtons: [
        {
            iconSource: "qrc:/icons/configure.svg",
            color: Style.iconColor,
            visible: true,
            trigger: function() {
                pageStack.push(Qt.resolvedUrl("../system/DynamicLoadManagerSettingsPage.qml"));
            }
        }
    ]

    DynamicLoadManagerManager {
        id: dynamicLoadManager
        engine: _engine
    }

    TopologyGraph {
        id: graph
        anchors.fill: parent
        manager: dynamicLoadManager
        editable: true
        animationsEnabled: root.isCurrentItem && Qt.application.active
        contentTopMargin: root.topMargin
        contentBottomMargin: root.bottomMargin
        visible: engine.jsonRpcClient.experiences.hasOwnProperty("DynamicLoadManager") && graph.layout.nodes.length > 0
        onNodeClicked: (node) => {
            var dialog = nodeInfoDialog.createObject(app, { "manager": dynamicLoadManager, "node": node })
            dialog.open()
        }
    }

    Component {
        id: nodeInfoDialog
        NodeInfoDialog { }
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        visible: !engine.jsonRpcClient.experiences.hasOwnProperty("DynamicLoadManager")
        title: qsTr("Dynamic load management plugin not installed.")
        text: qsTr("To show the load topology, install the dynamic load management plugin.")
        imageSource: "qrc:/icons/energy.svg"
        buttonText: qsTr("Install plugin")
        buttonVisible: packagesFilterModel.count > 0
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../system/PackageListPage.qml"), {filter: "nymea-experience-plugin-dynamicloadmanager"})

        PackagesFilterModel {
            id: packagesFilterModel
            packages: engine.systemController.packages
            nameFilter: "nymea-experience-plugin-dynamicloadmanager"
        }
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        visible: engine.jsonRpcClient.experiences.hasOwnProperty("DynamicLoadManager") && graph.layout.nodes.length === 0
        title: qsTr("No load topology configured.")
        text: qsTr("Configure fuses and chargers in the dynamic load management settings.")
        imageSource: "qrc:/icons/energy.svg"
        buttonText: qsTr("Open settings")
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../system/DynamicLoadManagerSettingsPage.qml"))
    }
}
