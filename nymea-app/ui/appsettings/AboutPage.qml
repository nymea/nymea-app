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

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("About %1").arg(app.appName)
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: imprint.implicitHeight

        Imprint {
            id: imprint
            width: parent.width
            title: app.appName
            additionalLicenses: ListModel {
                ListElement { license: "CC-BY-SA-3.0"; component: "Suru icons"; infoText: qsTr("Suru icons by Ubuntu"); platforms: "*" }
                ListElement { license: "CC-BY-SA-3.0"; component: "Ubuntu font"; infoText: qsTr("Ubuntu font by Ubuntu"); platforms: "*" }
                ListElement { license: "LGPL3"; component: "QtZeroConf"; infoText: qsTr("QtZeroConf library by Jonathan Bagg"); platforms: "android,ios,linux,osx" }
                ListElement { license: "OpenSSL"; component: "OpenSSL"; infoText: qsTr("OpenSSL libraries by Eric Young"); platforms: "android,windows" }
                ListElement { license: "OFL"; component: "Oswald font"; infoText: qsTr("Oswald font by The Oswald Project"); platforms: "*" }
            }

            githubLink: "https://github.com/nymea/nymea-app"

            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("App version:")
                subText: appVersion
                progressive: false
                prominentSubText: false
            }
            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("Qt version:")
                subText: qtVersion + (qtBuildVersion !== qtVersion ? " (" + qsTr("Built with %1").arg(qtBuildVersion) + ")" : "")
                progressive: false
                prominentSubText: false
            }
        }
    }
}
