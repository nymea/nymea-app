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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

SettingsPageBase {
    id: root
    title: qsTr("Developer options")

    SettingsPageSectionHeader {
        text: qsTr("Logging")
    }

    CheckDelegate {
        text: qsTr("Enable app logging")
        enabled: AppLogController.canWriteLogs
        checked: AppLogController.enabled
        onCheckedChanged: AppLogController.enabled = checked;
        Layout.fillWidth: true
    }

    NymeaSwipeDelegate {
        Layout.fillWidth: true
        text: qsTr("View log")
        onClicked: pageStack.push(Qt.resolvedUrl("../appsettings/AppLogPage.qml"))
        enabled: AppLogController.enabled
    }


    SettingsPageSectionHeader {
        text: qsTr("Advanced options")
        visible: settings.showHiddenOptions
    }

    RowLayout {
        Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
        visible: settings.showHiddenOptions

        Label {
            Layout.fillWidth: true
            text: qsTr("Cloud environment")
        }

        ComboBox {
            currentIndex: model.indexOf(app.settings.cloudEnvironment)
            model: AWSClient.availableConfigs
            onActivated: {
                app.settings.cloudEnvironment = model[index];
            }
        }
    }
}
