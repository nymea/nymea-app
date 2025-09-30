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

import "../components"

Dialog {
    id: certDialog
    width: Math.min(parent.width * .9, 400)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    standardButtons: Dialog.Ok

    property string serverUuid
    property var issuerInfo

    ColumnLayout {
        id: certLayout
        anchors.fill: parent
        //                spacing: app.margins

        RowLayout {
            Layout.fillWidth: true
            spacing: app.margins
            ColorIcon {
                Layout.preferredHeight: Style.iconSize * 2
                Layout.preferredWidth: height
                name: "qrc:/icons/lock-closed.svg"
                color: Style.accentColor
            }

            Label {
                id: titleLabel
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: qsTr("Certificate information")
                color: Style.accentColor
                font.pixelSize: app.largeFont
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: app.margins
        }

        Label {
            text: qsTr("nymea UUID:")
            Layout.fillWidth: true
        }
        Label {
            text: certDialog.serverUuid
            Layout.fillWidth: true
        }
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: app.margins
        }
        GridLayout {
            columns: 2
            Label {
                text: qsTr("Organisation:")
                Layout.fillWidth: true
            }
            Label {
                text: certDialog.issuerInfo["O"]
                Layout.fillWidth: true
            }
            Label {
                text: qsTr("Common name:")
                Layout.fillWidth: true
            }
            Label {
                text: certDialog.issuerInfo["CN"]
                Layout.fillWidth: true
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: app.margins
        }
        Label {
            text: qsTr("Fingerprint:")
            Layout.fillWidth: true
        }
        Label {
            text: certDialog.issuerInfo["fingerprint"]
            Layout.fillWidth: true
            wrapMode: Text.WrapAnywhere
        }
    }
}
