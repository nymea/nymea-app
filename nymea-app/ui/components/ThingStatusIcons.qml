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

import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0

RowLayout {
    id: root
    Layout.fillWidth: false
    spacing: app.margins / 2

    property Thing thing: null

    property color color: Style.iconColor

    UpdateStatusIcon {
        id: updateStatusIcon
        Layout.preferredHeight: Style.smallIconSize
        Layout.preferredWidth: height
        thing: root.thing
        visible: setupStatusIcon.setupStatus == Thing.ThingSetupStatusComplete && connectionStatusIcon.isConnected && (updateAvailable || updateRunning)
        Binding { target: updateStatusIcon; property: "color"; value: root.color; when: root.color !== Style.iconColor }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -app.margins / 4
            onClicked: {
                if (engine.jsonRpcClient.ensureServerVersion("8.0")) {
                    pageStack.push("../devicepages/ThingStatusPage.qml", {thing: root.thing})
                } else {
                    var dialogComponent = Qt.createComponent("NymeaDialog.qml")
                    var currentVersionState = root.thing.stateByName("currentVersion")
                    var availableVersionState = root.thing.stateByName("availableVersion")
                    var text = qsTr("An update for %1 is available. Do you want to start the update now?").arg(root.thing.name)
                    if (currentVersionState) {
                        text += "\n\n" + qsTr("Current version: %1").arg(currentVersionState.value)
                    }
                    if (availableVersionState) {
                        text += "\n\n" + qsTr("Available version: %1").arg(availableVersionState.value)
                    }

                    var dialog = dialogComponent.createObject(app,
                                                              {
                                                                  headerIcon: "qrc:/icons/system-update.svg",
                                                                  title: qsTr("Update"),
                                                                  text: text,
                                                                  standardButtons: Dialog.Ok | Dialog.Cancel
                                                              })
                    dialog.accepted.connect(function() {
                        print("starting update")
                        engine.thingManager.executeAction(root.thing.id, root.thing.thingClass.actionTypes.findByName("performUpdate").id)
                    })
                    dialog.open();
                }

            }
        }
    }
    BatteryStatusIcon {
        id: batteryStatusIcon
        Layout.preferredHeight: Style.smallIconSize
        Layout.preferredWidth: height
        thing: root.thing
        visible: root.thing.setupStatus == Thing.ThingSetupStatusComplete && (hasBatteryLevel || isCritical)
        Binding { target: batteryStatusIcon; property: "color"; value: root.color; when: root.color !== Style.iconColor }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -app.margins / 4
            onClicked: {
                if (engine.jsonRpcClient.ensureServerVersion("8.0")) {
                    pageStack.push("../devicepages/ThingStatusPage.qml", {thing: root.thing})
                } else {
                    var levelStateType = root.thing.thingClass.stateTypes.findByName("batteryLevel");
                    var criticalStateType = root.thing.thingClass.stateTypes.findByName("batteryCritical");
                    var stateTypes = []
                    if (levelStateType) {
                        stateTypes.push(levelStateType.id)
                    }
                    if (criticalStateType) {
                        stateTypes.push(criticalStateType.id)
                    }
                    pageStack.push("../devicepages/DeviceLogPage.qml",
                                   {
                                       thing: root.thing,
                                       filterTypeIds: stateTypes
                                   });
                }
            }
        }
    }
    ConnectionStatusIcon {
        id: connectionStatusIcon
        Layout.preferredHeight: Style.smallIconSize
        Layout.preferredWidth: height
        thing: root.thing
        visible: root.thing.setupStatus == Thing.ThingSetupStatusComplete && root.thing.thingClass.interfaces.indexOf("connectable") >= 0 && (hasSignalStrength || !isConnected)
        Binding { target: connectionStatusIcon; property: "color"; value: root.color; when: root.color !== Style.iconColor }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -app.margins / 4
            onClicked: {
                if (engine.jsonRpcClient.ensureServerVersion("8.0")) {
                    pageStack.push("../devicepages/ThingStatusPage.qml", {thing: root.thing})
                } else {
                    var signalStateType = root.thing.thingClass.stateTypes.findByName("signalStrength")
                    var connectedStateType = root.thing.thingClass.stateTypes.findByName("connected")
                    var stateTypes = []
                    if (signalStateType) {
                        stateTypes.push(signalStateType.id)
                    }
                    if (connectedStateType) {
                        stateTypes.push(connectedStateType.id)
                    }
                    pageStack.push("../devicepages/DeviceLogPage.qml",
                                   {
                                       thing: root.thing,
                                       filterTypeIds: stateTypes
                                   });
                }
            }
        }
    }
    SetupStatusIcon {
        id: setupStatusIcon
        Layout.preferredHeight: Style.smallIconSize
        Layout.preferredWidth: height
        thing: root.thing
        visible: setupFailed || setupInProgress
        Binding { target: setupStatusIcon; property: "color"; value: root.color; when: root.color !== Style.iconColor }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -app.margins / 4
            onClicked: {
                pageStack.push("../thingconfiguration/ConfigureThingPage.qml", { thing: root.thing });
            }
        }
    }
}
