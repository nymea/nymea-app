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
        text: qsTr("App Settings")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: layout.implicitHeight
        clip: true

        GridLayout {
            id: layout
            property bool isGrid: columns > 1
            anchors { left: parent.left; top: parent.top; right: parent.right; margins: isGrid ? app.margins : 0 }
            columns: Math.max(1, Math.floor(parent.width / 300))
            rowSpacing: isGrid ? app.margins : 0
            columnSpacing: isGrid ? app.margins : 0

            Pane {
                Layout.fillWidth: true
                Material.elevation: layout.isGrid ? 1 : 0
                padding: 0
                NymeaSwipeDelegate {
                    width: parent.width
                    text: qsTr("Look & feel")
                    subText: qsTr("Customize the app's look and behavior")
                    iconName: "../images/preferences-look-and-feel.svg"
                    prominentSubText: false
                    wrapTexts: false
                    onClicked: pageStack.push(Qt.resolvedUrl("LookAndFeelSettingsPage.qml"))
                }
            }

            Pane {
                Layout.fillWidth: true
                Material.elevation: layout.isGrid ? 1 : 0
                padding: 0
                NymeaSwipeDelegate {
                    width: parent.width
                    text: qsTr("Cloud login")
                    subText: qsTr("Log into %1:cloud and manage connected %1 systems").arg(Configuration.systemName)
                    iconName: "../images/connections/cloud.svg"
                    prominentSubText: false
                    wrapTexts: false
                    onClicked: pageStack.push(Qt.resolvedUrl("CloudLoginPage.qml"))
                }
            }
            Pane {
                Layout.fillWidth: true
                Material.elevation: layout.isGrid ? 1 : 0
                padding: 0
                NymeaSwipeDelegate {
                    width: parent.width
                    text: qsTr("Developer options")
                    subText: qsTr("Access tools for debugging and error reporting")
                    iconName: "../images/sdk.svg"
                    prominentSubText: false
                    wrapTexts: false
                    onClicked: pageStack.push(Qt.resolvedUrl("DeveloperOptionsPage.qml"))
                }
            }
            Pane {
                Layout.fillWidth: true
                Material.elevation: layout.isGrid ? 1 : 0
                padding: 0
                NymeaSwipeDelegate {
                    width: parent.width
                    text: qsTr("About %1").arg(Configuration.appName)
                    subText: qsTr("Find app versions and licence information")
                    iconName: "../images/info.svg"
                    prominentSubText: false
                    wrapTexts: false
                    onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                }
            }
        }
    }
}
