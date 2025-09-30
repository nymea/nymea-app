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

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Nymea

Rectangle {
    anchors.fill: parent
    color: Material.background
    visible: engine.systemController.updateRunning

    // Event eater
    MouseArea {
        anchors.fill: parent
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width

        ColorIcon {
            height: Style.iconSize * 3
            width: height
            Layout.alignment: Qt.AlignHCenter
            name: Qt.resolvedUrl("qrc:/icons/system-update.svg")
            color: Style.accentColor
            PropertyAnimation on rotation {
                from: 0; to: 360;
                duration: 2000
                loops: Animation.Infinite
//                onStopped: start(); // No clue why loops won't work
            }
        }

        Label {
            Layout.fillWidth: true
            Layout.margins: app.margins * 2
            text: qsTr("System update in progress...")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: app.largeFont
        }
        Label {
            Layout.fillWidth: true
            Layout.margins: app.margins * 2
            text: qsTr("Please wait")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
        Label {
            Layout.fillWidth: true
            Layout.margins: app.margins * 2
            text: qsTr("The system may restart in order to complete the update. %1:app will reconnect automatically after the update.").arg(Configuration.systemName)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: app.smallFont
        }
    }
}
