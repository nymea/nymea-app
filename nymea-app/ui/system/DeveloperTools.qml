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
    title: qsTr("Developer tools")

    property WebServerConfiguration usedConfig: {
        var config = null
        for (var i = 0; i < engine.nymeaConfiguration.webServerConfigurations.count; i++) {
            var tmp = engine.nymeaConfiguration.webServerConfigurations.get(i)
            print("checking config:", tmp.id, tmp.address, tmp.port, tmp.sslEnabled)
            if (tmp.address === engine.jsonRpcClient.currentConnection.hostAddress || tmp.address === "0.0.0.0") {

                // This one prefers https over http...
                //                if (config === null || (!config.sslEnabled && tmp.sslEnabled)) {

                // ...but for now, prefer http because self signed certs cause trouble and this is meant for local debugging only anyways...
                if (config === null || (config.sslEnabled && !tmp.sslEnabled)) {
                    config = tmp;
                }
                continue;
            }
        }
        return config;
    }


    SettingsPageSectionHeader {
        text: qsTr("Debug server")
    }

    SwitchDelegate {
        id: debugServerEnabledSwitch
        Layout.fillWidth: true
        text: qsTr("Debug server enabled")
        checked: engine.nymeaConfiguration.debugServerEnabled
        onToggled: engine.nymeaConfiguration.debugServerEnabled = checked
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        text: qsTr("In order to access the debug interface, please enable the web server.")
        font.pixelSize: app.smallFont
        color: "red"
        wrapMode: Text.WordWrap
        visible: engine.nymeaConfiguration.webServerConfigurations.count === 0
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        text: qsTr("The web server cannot be reached on %1.").arg(engine.jsonRpcClient.currentConnection.hostAddress)
        wrapMode: Text.WordWrap
        font.pixelSize: app.smallFont
        color: "red"
        visible: engine.nymeaConfiguration.webServerConfigurations.count > 0 && root.usedConfig === null
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        text: qsTr("Please enable the web server to be accessed on this address.")
        wrapMode: Text.WordWrap
        font.pixelSize: app.smallFont
        visible: engine.nymeaConfiguration.webServerConfigurations.count > 0 && root.usedConfig == null
    }

    Label {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        wrapMode: Text.WordWrap
        visible: debugServerEnabledSwitch.checked && root.usedConfig != null
        text: {
            var proto = "http" + (root.usedConfig.sslEnabled ? "s" : "") + "://"
            var path = engine.jsonRpcClient.currentConnection.hostAddress + ":" + root.usedConfig.port + "/debug"
            return qsTr("Debug interface active at %1.").arg('<a href="' + proto + path + '">' + proto + path + '</a>')
        }
        onLinkActivated: Qt.openUrlExternally(link)
    }
}
