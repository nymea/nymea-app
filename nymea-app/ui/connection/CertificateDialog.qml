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
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Dialog {
    id: certDialog
    width: Math.min(parent.width * .9, 400)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    standardButtons: Dialog.Yes | Dialog.No

    property string url
    property var fingerprint
    property var issuerInfo
    property var pem

    readonly property bool hasOldFingerprint: engine.connection.isTrusted(url)

    ColumnLayout {
        id: certLayout
        anchors.fill: parent
        //                spacing: app.margins

        RowLayout {
            Layout.fillWidth: true
            spacing: app.margins
            ColorIcon {
                Layout.preferredHeight: app.iconSize * 2
                Layout.preferredWidth: height
                name: certDialog.hasOldFingerprint ? "../images/lock-broken.svg" : "../images/info.svg"
                color: certDialog.hasOldFingerprint ? "red" : app.accentColor
            }

            Label {
                id: titleLabel
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: certDialog.hasOldFingerprint ? qsTr("Warning") : qsTr("Hi there!")
                color: certDialog.hasOldFingerprint ? "red" : app.accentColor
                font.pixelSize: app.largeFont
            }
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: certDialog.hasOldFingerprint ? qsTr("The certificate of this %1:core has changed!").arg(app.systemName) : qsTr("It seems this is the first time you connect to this %1:core.").arg(app.systemName)
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: certDialog.hasOldFingerprint ? qsTr("Did you change the system's configuration? Verify if this information is correct.") : qsTr("This is the certificate for this %1:core. Once you trust it, an encrypted connection will be established.").arg(app.systemName)
        }

        ThinDivider {}
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitHeight: certGridLayout.implicitHeight
            Flickable {
                anchors.fill: parent
                contentHeight: certGridLayout.implicitHeight
                clip: true

                ScrollBar.vertical: ScrollBar {
                    policy: contentHeight > height ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded
                }

                GridLayout {
                    id: certGridLayout
                    columns: 2
                    width: parent.width

                    Repeater {
                        model: certDialog.issuerInfo

                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            text: modelData
                        }
                    }
                    Label {
                        Layout.fillWidth: true
                        Layout.columnSpan: 2
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: qsTr("Fingerprint: ") + certDialog.fingerprint
                    }
                }
            }
        }

        ThinDivider {}

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: certDialog.hasOldFingerprint ? qsTr("Do you want to connect nevertheless?") : qsTr("Do you want to trust this device?")
            font.bold: true
        }
    }

    onAccepted: {
        engine.connection.acceptCertificate(certDialog.url, certDialog.pem)
    }
    onRejected: {
        engine.connection.disconnect();
    }
}
