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
    title: qsTr("Connection settings")

    SettingsPageSectionHeader {
        text: qsTr("Remote connection")
    }
    Label {
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        text: qsTr("Enabling the remote connection will allow connecting to this %1 system from anywhere.").arg(Configuration.systemName)
        wrapMode: Text.WordWrap
    }

    SwitchDelegate {
        Layout.fillWidth: true
        text: checked ? qsTr("Enabled") : qsTr("Disabled")
        checked: engine.nymeaConfiguration.tunnelProxyServerConfigurations.count > 0
        onClicked: {
            if (!checked) {
                for (var i = 0; i < engine.nymeaConfiguration.tunnelProxyServerConfigurations.count; i++) {
                    var config = engine.nymeaConfiguration.tunnelProxyServerConfigurations.get(i);
                    engine.nymeaConfiguration.deleteTunnelProxyServerConfiguration(config.id)
                }
            } else {
                var config = engine.nymeaConfiguration.createTunnelProxyServerConfiguration("remoteproxy.nymea.io", 2213, true, true, false);
                engine.nymeaConfiguration.setTunnelProxyServerConfiguration(config)
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Advanced")
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Connection interfaces")
        onClicked: pageStack.push("AdvancedConnectionInterfacesPage.qml")
    }
}
