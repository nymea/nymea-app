/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2021, nymea GmbH
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

import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "../components"
import Nymea 1.0

SettingsPageBase {
    id: root

    property ZigbeeManager zigbeeManager: null
    property ZigbeeNetwork network: null

    header: NymeaHeader {
        text: qsTr("ZigBee network")
        backButtonVisible: true
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "/ui/images/help.svg"
            text: qsTr("Network settings")
            onClicked: pageStack.push(zigbeeHelpPage)
        }

        HeaderButton {
            imageSource: "/ui/images/configure.svg"
            text: qsTr("Network settings")
            onClicked: pageStack.push(Qt.resolvedUrl("ZigbeeNetworkSettingsPage.qml"), { zigbeeManager: zigbeeManager, network: network })
        }
    }

    busy: d.pendingCommandId != -1

    QtObject {
        id: d
        property int pendingCommandId: -1
        function removeNode(networkUuid, ieeeAddress) {
            d.pendingCommandId = root.zigbeeManager.removeNode(networkUuid, ieeeAddress)
        }
    }

    Connections {
        target: root.zigbeeManager
        onRemoveNodeReply: {
            if (commandId == d.pendingCommandId) {
                d.pendingCommandId = -1
                var props = {};
                switch (error) {
                case "ZigbeeErrorNoError":
                    return;
                case "ZigbeeErrorAdapterNotAvailable":
                    props.text = qsTr("The selected adapter is not available or the selected serial port configration is incorrect.");
                    break;
                case "ZigbeeErrorAdapterAlreadyInUse":
                    props.text = qsTr("The selected adapter is already in use.");
                    break;
                default:
                    props.errorCode = error;
                }
                var comp = Qt.createComponent("../components/ErrorDialog.qml")
                var popup = comp.createObject(app, props)
                popup.open();
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Network")
    }

    ColumnLayout {
        spacing: app.margins
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins

        RowLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                text: qsTr("Network state:")
            }

            Label {
                text: {
                    switch (network.networkState) {
                    case ZigbeeNetwork.ZigbeeNetworkStateOnline:
                        return qsTr("Online")
                    case ZigbeeNetwork.ZigbeeNetworkStateOffline:
                        return qsTr("Offline")
                    case ZigbeeNetwork.ZigbeeNetworkStateStarting:
                        return qsTr("Starting")
                    case ZigbeeNetwork.ZigbeeNetworkStateUpdating:
                        return qsTr("Updating")
                    case ZigbeeNetwork.ZigbeeNetworkStateError:
                        return qsTr("Error")
                    }
                }
            }

            Led {
                Layout.preferredHeight: Style.iconSize
                Layout.preferredWidth: Style.iconSize
                state: {
                    switch (network.networkState) {
                    case ZigbeeNetwork.ZigbeeNetworkStateOnline:
                        return "on"
                    case ZigbeeNetwork.ZigbeeNetworkStateOffline:
                        return "off"
                    case ZigbeeNetwork.ZigbeeNetworkStateStarting:
                        return "orange"
                    case ZigbeeNetwork.ZigbeeNetworkStateUpdating:
                        return "orange"
                    case ZigbeeNetwork.ZigbeeNetworkStateError:
                        return "red"
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                text: qsTr("Channel")
            }

            Label {
                text: network.channel
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                text: qsTr("Permit new devices:")
            }

            Label {
                text: network.permitJoiningEnabled ? qsTr("Open for %0 s").arg(network.permitJoiningRemaining) : qsTr("Closed")
            }

            ColorIcon {
                Layout.preferredHeight: Style.iconSize
                Layout.preferredWidth: Style.iconSize
                name: network.permitJoiningEnabled ? "/ui/images/lock-open.svg" : "/ui/images/lock-closed.svg"
                visible: !network.permitJoiningEnabled
            }

            Canvas {
                id: canvas
                Layout.preferredHeight: Style.iconSize
                Layout.preferredWidth: Style.iconSize
                rotation: -90
                visible: network.permitJoiningEnabled

                property real progress: network.permitJoiningRemaining / network.permitJoiningDuration
                onProgressChanged: {
                    canvas.requestPaint()
                }

                onPaint: {
                    var ctx = canvas.getContext("2d");
                    ctx.save();
                    ctx.reset();
                    var data = [1 - progress, progress];
                    var myTotal = 0;

                    for(var e = 0; e < data.length; e++) {
                        myTotal += data[e];
                    }

                    ctx.fillStyle = Style.accentColor
                    ctx.strokeStyle = Style.accentColor
                    ctx.lineWidth = 1;

                    ctx.beginPath();
                    ctx.moveTo(canvas.width/2,canvas.height/2);
                    ctx.arc(canvas.width/2,canvas.height/2,canvas.height/2,0,(Math.PI*2*((1-progress)/myTotal)),false);
                    ctx.lineTo(canvas.width/2,canvas.height/2);
                    ctx.fill();
                    ctx.closePath();
                    ctx.beginPath();
                    ctx.arc(canvas.width/2,canvas.height/2,canvas.height/2 - 1,0,Math.PI*2,false);
                    ctx.closePath();
                    ctx.stroke();

                    ctx.restore();
                }
            }
        }

        Button {
            Layout.fillWidth: true
            text: network.permitJoiningEnabled ? qsTr("Extend open duration") : qsTr("Open for new devices")
            enabled: network.networkState === ZigbeeNetwork.ZigbeeNetworkStateOnline
            onClicked: zigbeeManager.setPermitJoin(network.networkUuid)
        }


    }

    SettingsPageSectionHeader {
        text: qsTr("Zigbee nodes")
    }

    Repeater {
        id: zigbeeNodeRepeater
        model: ZigbeeNodesProxy {
            id: zigbeeNodesProxy
            zigbeeNodes: root.network.nodes
        }

        delegate: BigTile {
            Layout.fillWidth: true
            interactive: false

            property ZigbeeNode node: zigbeeNodesProxy.get(index)

            contentItem: ColumnLayout {
                spacing: app.margins

                Loader {
                    id: nodeTypeLoader
                    Layout.fillWidth: true
                    sourceComponent: node ? (node.type === ZigbeeNode.ZigbeeNodeTypeCoordinator ? zigbeeCoordinatorComponent : zigbeeDeviceComponent) : null
                }

                Component {
                    id: zigbeeCoordinatorComponent
                    ColumnLayout {
                        RowLayout {

                            ColorIcon {
                                id: coordinatorIcon
                                Layout.preferredHeight: Style.iconSize
                                Layout.preferredWidth: Style.iconSize
                                name: "/ui/images/zigbee.svg"
                            }

                            Led {
                                Layout.preferredHeight: Style.iconSize
                                Layout.preferredWidth: Style.iconSize
                                state: {
                                    switch (network.networkState) {
                                    case ZigbeeNetwork.ZigbeeNetworkStateOnline:
                                        return "on"
                                    case ZigbeeNetwork.ZigbeeNetworkStateOffline:
                                        return "off"
                                    case ZigbeeNetwork.ZigbeeNetworkStateStarting:
                                        return "orange"
                                    case ZigbeeNetwork.ZigbeeNetworkStateUpdating:
                                        return "orange"
                                    case ZigbeeNetwork.ZigbeeNetworkStateError:
                                        return "red"
                                    }
                                }
                            }

                            Label {
                                Layout.fillWidth: true
                                text: network.backend + " " + qsTr("network coordinator")
                            }
                        }

                        Label {
                            visible: node.version !== ""
                            text: qsTr("Version") + ": " + network.firmwareVersion
                        }

                        Label {
                            text: qsTr("IEEE address") + ": " + node.ieeeAddress
                        }

                        Label {
                            text: qsTr("Network address") +  ": 0x" + (node.networkAddress + Math.pow(16, 4)).toString(16).slice(-4).toUpperCase();
                        }
                    }
                }

                Component {
                    id: zigbeeDeviceComponent

                    ColumnLayout {
                        RowLayout {
                            id: nodeHeaderRowLayout
                            ColorIcon {
                                id: deviceTypeIcon
                                Layout.preferredHeight: Style.iconSize
                                Layout.preferredWidth: Style.iconSize
                                name: node ? (node.type === ZigbeeNode.ZigbeeNodeTypeRouter ? "/ui/images/zigbee-router.svg" : "/ui/images/zigbee-enddevice.svg") : "/ui/images/zigbee-enddevice.svg"
                            }

                            Led {
                                id: reachableLed
                                Layout.preferredHeight: Style.iconSize
                                Layout.preferredWidth: Style.iconSize
                                state: {
                                    if (!node)
                                        return "off"

                                    if (node.state !== ZigbeeNode.ZigbeeNodeStateInitialized) {
                                        return "orange"
                                    }

                                    if (node.reachable) {
                                        return "on"
                                    } else {
                                        return "red"
                                    }
                                }
                            }

                            Connections {
                                target: node
                                onLastSeenChanged: {
                                    communicationIndicatorLed.state = "on"
                                    communicationIndicatorLedTimer.start()
                                }
                            }

                            Timer {
                                id: communicationIndicatorLedTimer
                                interval: 200
                                repeat: false
                                onTriggered: communicationIndicatorLed.state = "off"
                            }

                            Led {
                                id: communicationIndicatorLed
                                Layout.preferredHeight: Style.iconSize
                                Layout.preferredWidth: Style.iconSize
                                state: "off"
                            }

                            BusyIndicator {
                                Layout.preferredHeight: Style.iconSize
                                Layout.preferredWidth: Style.iconSize
                                running: visible
                                visible: node ? node.state !== ZigbeeNode.ZigbeeNodeStateInitialized : false
                            }

                            Label {
                                Layout.fillWidth: true
                                text: node ? node.model : ""
                            }

                            Label {
                                text: signalStrengthIcon.signalStrength + "%"
                            }

                            ColorIcon {
                                id: signalStrengthIcon
                                Layout.preferredHeight: Style.iconSize
                                Layout.preferredWidth: Style.iconSize

                                property int signalStrength: node ? Math.round(node.lqi * 100.0 / 255.0) : 0

                                name: {
                                    if (!node || !node.reachable)
                                        return "/ui/images/connections/nm-signal-00.svg"

                                    if (signalStrength <= 25)
                                        return "/ui/images/connections/nm-signal-25.svg"

                                    if (signalStrength <= 50)
                                        return "/ui/images/connections/nm-signal-50.svg"

                                    if (signalStrength <= 75)
                                        return "/ui/images/connections/nm-signal-75.svg"

                                    if (signalStrength <= 100)
                                        return "/ui/images/connections/nm-signal-100.svg"
                                }
                            }

                            Loader {
                                id: sleepyIconLoader
                                Layout.preferredHeight: Style.iconSize
                                Layout.preferredWidth: Style.iconSize
                                active: node ? !node.rxOnWhenIdle : false
                                visible: active
                                sourceComponent: sleepyDeviceComponent
                            }

                            Component {
                                id: sleepyDeviceComponent
                                ColorIcon {
                                    name: "/ui/images/system-suspend.svg"
                                }
                            }
                        }

                        RowLayout {
                            id: nodeDescriptionRow
                            ColumnLayout {
                                Layout.fillWidth: true

                                Label {
                                    text: node ? node.manufacturer + (node.version !== "" ? " (" +  node.version + ")" : "") : ""
                                }

                                Label {
                                    text: qsTr("IEEE address") + ": " + (node ? node.ieeeAddress : "")
                                }

                                Label {
                                    Layout.fillWidth: true
                                    text: qsTr("Network address") + (node ?  ": 0x" + (node.networkAddress + Math.pow(16, 4)).toString(16).slice(-4).toUpperCase() : "")
                                }
                            }

                            ColumnLayout {
                                Item {
                                    // Spacing item
                                    Layout.fillHeight: true
                                }

                                ProgressButton {
                                    size: Style.iconSize
                                    imageSource: "/ui/images/delete.svg"
                                    longpressEnabled: false
                                    onClicked: {
                                        var dialog = removeZigbeeNodeDialogComponent.createObject(app, {zigbeeNode: node})
                                        dialog.open()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: removeZigbeeNodeDialogComponent

        MeaDialog {
            id: removeZigbeeNodeDialog

            property ZigbeeNode zigbeeNode

            headerIcon: "/ui/images/zigbee.svg"
            title: qsTr("Remove zigbee node") + " " + (zigbeeNode ? zigbeeNode.model : "")
            text: qsTr("Are you sure you want to remove this node from the network?")
            standardButtons: Dialog.Ok | Dialog.Cancel

            Label {
                text: qsTr("Please note that if this node has been assigned to a thing, it will also be removed from the system.")
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }

            onAccepted: {
                d.removeNode(zigbeeNode.networkUuid, zigbeeNode.ieeeAddress)
            }
        }
    }

    Component {
        id: zigbeeHelpPage

        SettingsPageBase {
            id: root
            title: qsTr("ZigBee network help")

            header: NymeaHeader {
                text: qsTr("ZigBee network help")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 2 * app.margins
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins


                RowLayout {
                    spacing: app.margins
                    ColorIcon {
                        Layout.preferredHeight: Style.iconSize
                        Layout.preferredWidth: Style.iconSize
                        name: "/ui/images/zigbee.svg"
                    }

                    Label {
                        text: qsTr("Zigbee network coordinator")
                    }
                }


                RowLayout {
                    spacing: app.margins
                    ColorIcon {
                        Layout.preferredHeight: Style.iconSize
                        Layout.preferredWidth: Style.iconSize
                        name: "/ui/images/zigbee-router.svg"
                    }

                    Label {
                        text: qsTr("Zigbee router")
                    }
                }

                RowLayout {
                    spacing: app.margins
                    ColorIcon {
                        Layout.preferredHeight: Style.iconSize
                        Layout.preferredWidth: Style.iconSize
                        name: "/ui/images/zigbee-enddevice.svg"
                    }

                    Label {
                        text: qsTr("Zigbee end device")
                    }
                }

                RowLayout {
                    spacing: app.margins
                    ColorIcon {
                        Layout.preferredHeight: Style.iconSize
                        Layout.preferredWidth: Style.iconSize
                        name: "/ui/images/system-suspend.svg"
                    }

                    Label {
                        text: qsTr("Sleepy device")
                    }
                }
            }
        }
    }
}
