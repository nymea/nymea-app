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
            anchors { left: parent.left; top: parent.top; right: parent.right; margins: Style.smallMargins }
            columns: Math.max(1, Math.floor(parent.width / 300))
            rowSpacing: 0
            columnSpacing: 0

            SettingsTile {
                Layout.fillWidth: true
                text: qsTr("Look & feel")
                subText: qsTr("Customize the app's look and behavior")
                iconSource: "qrc:/icons/preferences-look-and-feel.svg"
                onClicked: pageStack.push(Qt.resolvedUrl("ConsolinnoLookAndFeelSettingsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                text: qsTr("Developer options")
                subText: qsTr("Access tools for debugging and error reporting")
                iconSource: "qrc:/icons/sdk.svg"
                onClicked: pageStack.push(Qt.resolvedUrl("DeveloperOptionsPage.qml"))
            }
            SettingsTile {
                Layout.fillWidth: true
                text: qsTr("About %1").arg(Configuration.appName)
                subText: qsTr("Find app versions and licence information")
                iconSource: "qrc:/icons/info.svg"
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        }
    }
}
