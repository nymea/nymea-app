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
import Qt.labs.settings 1.0
import "../components"
import "dashboard"

MainViewBase {
    id: root

    contentY: dashboard.contentY

    headerButtons: [
        {
            iconSource: "qrc:/icons/configure.svg",
            color: dashboard.editMode ? Style.accentColor : Style.iconColor,
            trigger: function() {
                dashboard.editMode = !dashboard.editMode;
            },
            visible: true
        }
    ]

    DashboardModel {
        id: dashboardModel

        Component.onCompleted: {
            print("loading dashboard:", dashboardSettings.dashboardConfig)
            loadFromJson(dashboardSettings.dashboardConfig)
        }

        onSave: {
            print("saving dashboard");
            dashboardSettings.dashboardConfig = dashboardModel.toJson()
        }
    }

    AppData {
        id: dashboardSettings
        engine: _engine
        group: "dashboard-1"
        property string dashboardConfig: ""
        onDashboardConfigChanged: {
            print("dashboard changed on server! Reloading...")
            dashboardModel.loadFromJson(dashboardConfig)
        }
    }

    Settings {
        category: engine.jsonRpcClient.currentHost.uuid
        property string dashboardConfig
    }

    Dashboard {
        id: dashboard
        anchors.fill: parent
        anchors.topMargin: root.topMargin

        model: dashboardModel
        dashboardVisible: root.isCurrentItem
    }
}
