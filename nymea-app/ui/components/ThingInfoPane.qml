// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
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

InfoPaneBase {
    id: root

    property Thing thing: null

    property bool hideLabel: false
    readonly property bool setupInProgress: root.thing.setupStatus == Thing.ThingSetupStatusInProgress
    readonly property bool setupFailure: root.thing.setupStatus == Thing.ThingSetupStatusFailed
    readonly property State batteryState: root.thing.stateByName("batteryLevel")
    readonly property State batteryCriticalState: root.thing.stateByName("batteryCritical")
    readonly property State connectedState: root.thing.thingClass.interfaces.indexOf("connectable") >= 0 ? root.thing.stateByName("connected") : null
    readonly property State signalStrengthState: root.thing.stateByName("signalStrength")
    readonly property State updateStatusState: root.thing.stateByName("updateStatus")
    readonly property State childLockState: root.thing.stateByName("childLock")
    readonly property bool updateAvailable: updateStatusState && updateStatusState.value === "available"
    readonly property bool updateRunning: updateStatusState && updateStatusState.value === "updating"
    readonly property bool isWireless: root.thing.thingClass.interfaces.indexOf("wirelessconnectable") >= 0
    readonly property bool alertState: setupFailure ||
                              (connectedState != null && connectedState.value === false) ||
                              (batteryCriticalState != null && batteryCriticalState.value === true)
    readonly property bool batteryCritical: batteryCriticalState && batteryCriticalState.value === true
    readonly property bool childLockEnabled: childLockState != null && childLockState.value === true
    readonly property bool highlightState: updateAvailable || updateRunning

    shown: setupInProgress || setupFailure || batteryState != null || (connectedState != null && connectedState.value === false) || signalStrengthState !== null || updateAvailable

    color: alertState ? "red"
            : highlightState ? Style.accentColor : "transparent"

    contentItem: RowLayout {
        id: contentRow
        anchors { left: parent.left; top: parent.top; right: parent.right }

        Label {
            id: textLabel
            color: root.alertState || root.highlightState ? "white" : Style.foregroundColor
            font.pixelSize: app.smallFont
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            wrapMode: Text.WordWrap
            visible: !hideLabel
            text: root.setupInProgress ?
                      qsTr("Thing is being set up...")
                    : root.setupFailure ?
                          (root.thing.setupDisplayMessage.length > 0 ? root.thing.setupDisplayMessage : qsTr("Thing setup failed!"))
                        : (root.connectedState !== null && root.connectedState.value === false) ?
                              qsTr("Thing is not connected!")
                            : root.updateAvailable ?
                                  qsTr("Update available!")
                                : root.updateRunning ?
                                      qsTr("Updating...")
                                    : root.batteryCritical ?
                                          qsTr("Thing runs out of battery!")
                                        : ""

        }

        ColorIcon {
            id: childLockIcon
            name: root.childLockEnabled ? "qrc:/icons/lock-closed.svg" : "qrc:/icons/lock-open.svg"
            color: pendingAction == -1 ? Style.iconColor : Style.tileBackgroundColor
            size: Style.smallIconSize
            visible: root.childLockState != null
            property int pendingAction: -1
            MouseArea {
                anchors.fill: parent
                anchors.margins: -app.margins / 4
                onClicked: {
                    parent.pendingAction = thing.executeAction("childLock", [{paramName: "childLock", value: !root.childLockEnabled}]);
                }
            }
            BusyIndicator {
                anchors.centerIn: parent
                width: Style.iconSize
                height: Style.iconSize
                visible: parent.pendingAction != -1
                running: visible
            }
            Connections {
                target: engine.thingManager
                onExecuteActionReply: (commandId, thingError, displayMessage) => {
                    if (commandId === childLockIcon.pendingAction) {
                        childLockIcon.pendingAction = -1
                    }
                }
            }
        }

        ThingStatusIcons {
            thing: root.thing
            color: root.alertState || root.highlightState ? "white" : Style.iconColor

        }


    }
}


