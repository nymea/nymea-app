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
    title: qsTr("Web server")

    SettingsPageSectionHeader {
        text: qsTr("Web server interfaces")
    }

    Repeater {
        model: engine.nymeaConfiguration.webServerConfigurations
        delegate: ConnectionInterfaceDelegate {
            Layout.fillWidth: true
            canDelete: true
            onClicked: {
                var component = Qt.createComponent(Qt.resolvedUrl("WebServerConfigurationDialog.qml"));
                var popup = component.createObject(root, { serverConfiguration: engine.nymeaConfiguration.webServerConfigurations.get(index).clone() });
                popup.accepted.connect(function() {
                    engine.nymeaConfiguration.setWebServerConfiguration(popup.serverConfiguration)
                    popup.serverConfiguration.destroy();
                })
                popup.rejected.connect(function() {
                    popup.serverConfiguration.destroy();
                })
                popup.open()
            }
            onDeleteClicked: {
                print("should delete")
                engine.nymeaConfiguration.deleteWebServerConfiguration(model.id)
            }
        }
    }
    Button {
        Layout.fillWidth: true
        Layout.margins: app.margins
        text: qsTr("Add")
        onClicked: {
            var config = engine.nymeaConfiguration.createWebServerConfiguration("0.0.0.0", 80 + engine.nymeaConfiguration.webServerConfigurations.count, false, false, "/var/www/");
            var component = Qt.createComponent(Qt.resolvedUrl("WebServerConfigurationDialog.qml"));
            var popup = component.createObject(root, { serverConfiguration: config });
            popup.accepted.connect(function() {
                engine.nymeaConfiguration.setWebServerConfiguration(popup.serverConfiguration)
                popup.serverConfiguration.destroy();
            })
            popup.rejected.connect(function() {
                popup.serverConfiguration.destroy();
            })
            popup.open()
        }
    }
}
