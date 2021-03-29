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
    title: qsTr("About %1").arg(Configuration.systemName)


    Imprint {
        id: imprint
        Layout.fillWidth: true
        title: qsTr("%1").arg(Configuration.systemName)
        githubLink: "https://github.com/nymea/nymea"

        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: qsTr("Connection:")
            subText: engine.jsonRpcClient.currentConnection.url
            progressive: false
            prominentSubText: false
        }
        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: qsTr("Server UUID:")
            subText: engine.jsonRpcClient.serverUuid
            progressive: false
            prominentSubText: false
        }
        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: qsTr("Server version:")
            subText: engine.jsonRpcClient.serverVersion
            progressive: false
            prominentSubText: false
        }
        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: qsTr("JSON-RPC version:")
            subText: engine.jsonRpcClient.jsonRpcVersion
            progressive: false
            prominentSubText: false
        }
        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: qsTr("Qt version:")
            visible: engine.jsonRpcClient.ensureServerVersion("4.1")
            subText: engine.jsonRpcClient.serverQtVersion + (engine.jsonRpcClient.serverQtVersion !== engine.jsonRpcClient.serverQtBuildVersion ? " (" + qsTr("Built with %1").arg(engine.jsonRpcClient.serverQtBuildVersion) + ")" : "")
            progressive: false
            prominentSubText: false
        }
        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: qsTr("Device serial number")
            subText: engine.systemController.deviceSerialNumber
            visible: engine.systemController.deviceSerialNumber.length > 0
            progressive: false
            prominentSubText: false
        }
    }
}
