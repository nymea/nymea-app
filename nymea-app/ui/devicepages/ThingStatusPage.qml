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
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

Page {
    id: root

    property Thing thing: null

    header: NymeaHeader {
        text: qsTr("Status for %1").arg(root.thing.name)
        onBackPressed: pageStack.pop()
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: layout.implicitHeight
        interactive: contentHeight > height
        clip: true

        GridLayout {
            id: layout
            width: flickable.width
            columns: app.landscape ? 2 : 1

            ColumnLayout {
                id: updateStatusLayout
                readonly property State currentVersionState: thing.stateByName("currentVersion")
                readonly property State availableVersionState: thing.stateByName("availableVersion")
                readonly property State updateStatusState: thing.stateByName("updateStatus")
                readonly property State updateProgressState: thing.stateByName("updateProgress")

                visible: thing.thingClass.interfaces.indexOf("update") >= 0

                SettingsPageSectionHeader {
                    text: qsTr("Update information")
                }

                RowLayout {
                    Layout.leftMargin: Style.margins
                    Layout.rightMargin: Style.margins
                    Layout.bottomMargin: Style.margins
                    spacing: Style.margins

                    ColorIcon {
                        name: "system-update"
                        size: Style.largeIconSize
                        color: updateStatusLayout.updateStatusState != null && updateStatusLayout.updateStatusState.value == "updating" ? Style.accentColor : Style.iconColor
                        RotationAnimation on rotation {
                            from: 0; to: 360
                            duration: 2000
                            running: updateStatusLayout.updateStatusState != null && updateStatusLayout.updateStatusState.value == "updating"
                            loops: Animation.Infinite
                        }

                    }

                    ColumnLayout {

                        Label {
                            Layout.fillWidth: true
                            text: {
                                switch (updateStatusLayout.updateStatusState.value) {
                                case "idle":
                                    return qsTr("Thing is up to date")
                                case "available":
                                    return qsTr("Update available")
                                case "updating":
                                    return qsTr("Updating...")
                                }
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            text: updateStatusLayout.currentVersionState ? qsTr("Installed version: %1").arg(updateStatusLayout.currentVersionState.value) : ""
                            font: Style.smallFont
                        }
                        Label {
                            Layout.fillWidth: true
                            visible: updateStatusLayout.availableVersionState != null && updateStatusLayout.updateStatusState != null && updateStatusLayout.updateStatusState.value === "available"
                            text: updateStatusLayout.availableVersionState ?  qsTr("Available version: %1").arg(updateStatusLayout.availableVersionState.value) : ""
                            font: Style.smallFont
                        }

                        ProgressBar {
                            Layout.fillWidth: true
                            visible: updateStatusLayout.updateStatusState != null && updateStatusLayout.updateStatusState.value === "updating"
                            value: updateStatusLayout.updateProgressState ? updateStatusLayout.updateProgressState.value : 50
                            indeterminate: updateStatusLayout.updateProgressState == null
                            from: 0
                            to: 100
                        }
                    }
                }

                Button {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Update")
                    Layout.minimumWidth: parent.width / 2
                    visible: updateStatusLayout.updateStatusState && updateStatusLayout.updateStatusState.value === "available"
                    onClicked: {
                        var dialogComponent = Qt.createComponent("../components/NymeaDialog.qml")
                        var currentVersionState = root.thing.stateByName("currentVersion")
                        var availableVersionState = root.thing.stateByName("availableVersion")
                        var text = qsTr("Do you want to start the update now?")
                        if (currentVersionState) {
                            text += "\n\n" + qsTr("Current version: %1").arg(currentVersionState.value)
                        }
                        if (availableVersionState) {
                            text += "\n\n" + qsTr("Available version: %1").arg(availableVersionState.value)
                        }

                        var dialog = dialogComponent.createObject(app,
                                                                  {
                                                                      headerIcon: "system-update",
                                                                      title: qsTr("Update"),
                                                                      text: text,
                                                                      standardButtons: Dialog.Ok | Dialog.Cancel
                                                                  })
                        if (!dialog) {
                            print("Error:", dialogComponent.errorString())
                        }

                        dialog.accepted.connect(function() {
                            print("starting update")
                            root.thing.executeAction("performUpdate")
                        })
                        dialog.open();
                    }
                }

            }

            ColumnLayout {
                id: connectionStatusLayout
                Layout.fillWidth: true

                readonly property State connectedState: thing.stateByName("connected")
                readonly property State signalStrengthState: thing.stateByName("signalStrength")

                visible: thing.thingClass.interfaces.indexOf("connectable") >= 0

                SettingsPageSectionHeader {
                    text: qsTr("Connection information")
                }

                RowLayout {
                    Layout.leftMargin: Style.margins
                    Layout.rightMargin: Style.margins
                    Layout.bottomMargin: Style.margins

                    Label {
                        Layout.fillWidth: true
                        text: (connectionStatusLayout.connectedState.value === true ? qsTr("Connected") : qsTr("Disconnected"))
                    }

                    Label {
                        Layout.fillWidth: true
                        text: connectionStatusLayout.signalStrengthState != null ? connectionStatusLayout.signalStrengthState.value + " %" : ""
                        horizontalAlignment: Text.AlignRight
                    }
                    ConnectionStatusIcon {
                        Layout.preferredHeight: Style.smallIconSize
                        Layout.preferredWidth: height
                        thing: root.thing
                        visible: connectionStatusLayout.signalStrengthState != null
                    }
                }

                MultiStateChart {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width / 2
                    statesModel: [
                        {thingId: root.thing.id, stateName: "connected", color: Qt.rgba(Style.green.r, Style.green.g, Style.green.b, .2), fillArea: true, tooltipFunction: function(value) {
                                return value === true ? qsTr("Connected") : qsTr("Disconnected")
                        }},
                        {thingId: root.thing.id, stateName: "signalStrength", color: Style.orange, fillArea: true, tooltipFunction: function(value){ return qsTr("Signal strength: %1 %").arg(value)}},
                    ]
                }
            }

            ColumnLayout {
                id: batteryStatusLayout
                Layout.fillWidth: true

                readonly property State batteryCriticalState: thing.stateByName("batteryCritical")
                readonly property State batteryLevelState: thing.stateByName("batteryLevel")

                visible: thing.thingClass.interfaces.indexOf("battery") >= 0

                SettingsPageSectionHeader {
                    text: qsTr("Battery information")
                }

                RowLayout {
                    Layout.margins: Style.margins

                    Label {
                        Layout.fillWidth: true
                        text: batteryStatusLayout.batteryCriticalState.value === true ? qsTr("Battery level critical") : qsTr("Battery level ok")
                    }

                    Label {
                        Layout.fillWidth: true
                        text: batteryStatusLayout.batteryLevelState != null ? batteryStatusLayout.batteryLevelState.value + " %" : ""
                        horizontalAlignment: Text.AlignRight
                    }
                    BatteryStatusIcon {
                        Layout.preferredHeight: Style.smallIconSize
                        Layout.preferredWidth: height
                        thing: root.thing
                        visible: batteryStatusLayout.batteryLevelState != null
                    }
                }

                MultiStateChart {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width / 2
                    statesModel: [
                        {thingId: root.thing.id, stateName: "batteryCritical", color: Qt.rgba(Style.red.r, Style.red.g, Style.red.b, .2), fillArea: true, tooltipFunction(value) {
                                return value === true ? qsTr("Critical") : qsTr("OK")
                            }},
                        {thingId: root.thing.id, stateName: "batteryLevel", color: Style.orange, fillArea: true, tooltipFunction: function(value){ return qsTr("Battery level: %1 %").arg(value)}},
                    ]
                }
            }

        }
    }
}
