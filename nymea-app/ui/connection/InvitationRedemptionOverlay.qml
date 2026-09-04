// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Nymea

import "../components"

// Global overlay for InvitationRedemptionController - present once at the app root
// (RootItem.qml) rather than per tab, since a pasted or deep-linked invitation may
// target a different server than whichever tab happens to be active. Renders every
// non-Idle state; QML never infers progress/result from unrelated signals like
// authenticatedChanged, only from controller.state/result/errorMessage.
Popup {
    id: root

    property InvitationRedemptionController controller: null

    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    width: Math.min(parent.width * 0.9, 420)
    modal: true
    closePolicy: Popup.NoAutoClose
    visible: controller && controller.state !== InvitationRedemptionController.Idle

    contentItem: ColumnLayout {
        spacing: Style.margins

        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: Style.margins
            spacing: Style.margins
            visible: root.controller && (root.controller.state === InvitationRedemptionController.Validating
                                          || root.controller.state === InvitationRedemptionController.TryingCandidate
                                          || root.controller.state === InvitationRedemptionController.AwaitingHello
                                          || root.controller.state === InvitationRedemptionController.Redeeming)

            BusyIndicator {
                Layout.alignment: Qt.AlignHCenter
            }
            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: {
                    if (!root.controller) {
                        return "";
                    }
                    switch (root.controller.state) {
                    case InvitationRedemptionController.Validating:
                        return qsTr("Reading invitation link…");
                    case InvitationRedemptionController.Redeeming:
                        return qsTr("Redeeming invitation…");
                    default:
                        return qsTr("Connecting…");
                    }
                }
            }
            Button {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Cancel")
                onClicked: root.controller.cancel()
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: Style.margins
            spacing: Style.margins
            visible: root.controller && root.controller.state === InvitationRedemptionController.AwaitingConfirmation

            Label {
                Layout.fillWidth: true
                font: Style.bigFont
                wrapMode: Text.WordWrap
                text: qsTr("Connect to this system?")
            }
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                visible: text !== ""
                text: root.controller && root.controller.confirmationServerName !== ""
                      ? qsTr("Name: %1").arg(root.controller.confirmationServerName) : ""
            }
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: root.controller ? qsTr("Address: %1:%2").arg(root.controller.confirmationHost).arg(root.controller.confirmationPort) : ""
            }
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: root.controller ? qsTr("Connection: %1").arg(root.controller.confirmationTransport) : ""
            }
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: app.extraSmallFont
                color: Style.accentColor
                text: qsTr("This app cannot verify this is actually the system that created this invitation. The matching link, ID, and connection type are not proof of identity.")
            }
            RowLayout {
                Layout.fillWidth: true
                Button {
                    Layout.fillWidth: true
                    text: qsTr("Cancel")
                    onClicked: root.controller.cancel()
                }
                Button {
                    Layout.fillWidth: true
                    highlighted: true
                    text: qsTr("Connect")
                    onClicked: root.controller.confirmCandidate()
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: Style.margins
            spacing: Style.margins
            visible: root.controller && (root.controller.state === InvitationRedemptionController.Completed
                                          || root.controller.state === InvitationRedemptionController.Failed
                                          || root.controller.state === InvitationRedemptionController.Cancelled)

            ColorIcon {
                Layout.alignment: Qt.AlignHCenter
                size: Style.hugeIconSize
                name: root.controller && root.controller.state === InvitationRedemptionController.Completed
                      ? "qrc:/icons/tick.svg" : "qrc:/icons/dialog-warning-symbolic.svg"
                color: root.controller && root.controller.state === InvitationRedemptionController.Completed
                       ? Style.accentColor : "red"
            }
            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: root.controller && root.controller.state === InvitationRedemptionController.Completed
                      ? qsTr("You're connected!")
                      : (root.controller ? root.controller.errorMessage : "")
            }
            Button {
                Layout.fillWidth: true
                text: qsTr("OK")
                onClicked: root.controller.acknowledge()
            }
        }
    }
}
