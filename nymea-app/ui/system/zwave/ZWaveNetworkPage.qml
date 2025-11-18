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

import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "qrc:/ui/components"
import Nymea 1.0

SettingsPageBase {
    id: root

    property ZWaveManager zwaveManager: null
    property ZWaveNetwork network: null

    header: NymeaHeader {
        text: qsTr("Z-Wave network")
        backButtonVisible: true
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "qrc:/icons/help.svg"
            text: qsTr("Help")
            onClicked: {
                var popup = zigbeeHelpDialog.createObject(app)
                popup.open()
            }
        }

        HeaderButton {
            imageSource: "qrc:/icons/configure.svg"
            text: qsTr("Network settings")
            onClicked: {
                var page = pageStack.push(Qt.resolvedUrl("ZWaveNetworkSettingsPage.qml"), { zwaveManager: zwaveManager, network: network })
                page.exit.connect(function() {
                    pageStack.pop(root, StackView.Immediate)
                    pageStack.pop()
                })
            }
        }
    }

    busy: d.pendingCommandId != -1

    QtObject {
        id: d
        property var addRemoveNodeDialog: null
        property int pendingCommandId: -1
        function removeFailedNode(networkUuid, nodeId) {
            d.pendingCommandId = root.zwaveManager.removeFailedNode(networkUuid, nodeId)
        }
    }

    Connections {
        target: root.zwaveManager
        onAddNodeReply: {
            if (commandId == d.pendingCommandId) {
                d.pendingCommandId = -1
                processStatusCode(error)
            }
        }
        onRemoveNodeReply: {
            if (commandId == d.pendingCommandId) {
                d.pendingCommandId = -1
                processStatusCode(error)
            }
        }
        onRemoveFailedNodeReply: {
            if (commandId == d.pendingCommandId) {
                d.pendingCommandId = -1
                processStatusCode(error)
            }
        }
        function processStatusCode(error) {
            var props = {};
            switch (error) {
            case ZWaveManager.ZWaveErrorNoError:
                return;
            case ZWaveManager.ZWaveErrorBackendError:
                props.text = qsTr("Un unexpected error happened in the Z-Wave backend.");
                break;
            case ZWaveManager.ZWaveErrorInUse:
                props.text = qsTr("The operation could not be started because the Z-Wave network is busy. Please try again later.");
                break;
            default:
                props.text = qsTr("An unexpected error happened. Status code: %1").arg(error);
                props.errorCode = error;
            }
            var comp = Qt.createComponent("/ui/components/ErrorDialog.qml")
            var popup = comp.createObject(app, props)
            popup.open();
        }
    }

    Connections {
        target: root.network
        onWaitingForNodeAdditionChanged: {
            if (root.network.waitingForNodeAddition) {
                var props = {
                    title: qsTr("Include Z-Wave device"),
                    text: qsTr("The Z-Wave network is now accepting new devices for inclusion. Please start the pairing procedure from the Z-Wave device you want to add to the network. Check the device manual for further details.")
                }
                d.addRemoveNodeDialog = addRemoveNodeDialogComponent.createObject(app, props)
                d.addRemoveNodeDialog.open();
            } else {
                if (d.addRemoveNodeDialog) {
                    d.addRemoveNodeDialog.close()
                }
            }
        }
        onWaitingForNodeRemovalChanged: {
            if (root.network.waitingForNodeRemoval) {
                var props = {
                    title: qsTr("Exclude Z-Wave device"),
                    text: qsTr("The Z-Wave network is now accepting devices for exclusion. Please start the pairing procedure from the Z-Wave device you want to remove from the network. Check the device manual for further details.")
                }
                d.addRemoveNodeDialog = addRemoveNodeDialogComponent.createObject(app, props)
                d.addRemoveNodeDialog.open();
            } else {
                if (d.addRemoveNodeDialog) {
                    d.addRemoveNodeDialog.close()
                }
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Network")
    }

    ColumnLayout {
        spacing: Style.margins
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins

        RowLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                text: qsTr("Network state:")
            }

            Label {
                text: {
                    switch (network.networkState) {
                    case ZWaveNetwork.ZWaveNetworkStateOnline:
                        return qsTr("Online")
                    case ZWaveNetwork.ZWaveNetworkStateOffline:
                        return qsTr("Offline")
                    case ZWaveNetwork.ZWaveNetworkStateStarting:
                        return qsTr("Starting")
                    case ZWaveNetwork.ZWaveNetworkStateError:
                        return qsTr("Error")
                    }
                }
            }

            Led {
                Layout.preferredHeight: Style.iconSize
                Layout.preferredWidth: Style.iconSize
                state: {
                    switch (network.networkState) {
                    case ZWaveNetwork.ZWaveNetworkStateOnline:
                        return "on"
                    case ZWaveNetwork.ZWaveNetworkStateOffline:
                        return "off"
                    case ZWaveNetwork.ZWaveNetworkStateStarting:
                        return "orange"
                    case ZWaveNetwork.ZWaveNetworkStateError:
                        return "red"
                    }
                }
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Device management")
        visible: network.isPrimaryController
    }

    ColumnLayout {
        spacing: Style.margins
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        visible: network.isPrimaryController

        Button {
            Layout.fillWidth: true
            text: qsTr("Add a new device")
            enabled: network.networkState === ZWaveNetwork.ZWaveNetworkStateOnline
            onClicked: {
                zwaveManager.cancelPendingOperation(network.networkUuid)
                d.pendingCommandId = zwaveManager.addNode(network.networkUuid)
            }
        }
        Button {
            Layout.fillWidth: true
            text: qsTr("Remove a device")
            enabled: network.networkState === ZWaveNetwork.ZWaveNetworkStateOnline
            onClicked: {
                zwaveManager.cancelPendingOperation(network.networkUuid)
                d.pendingCommandId = zwaveManager.removeNode(network.networkUuid)
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Connected devices")
    }

    Label {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("There are no Z-Wave devices connected yet. Open the network for new devices to join and start the pairing procedure from the Z-Wave device. Please refer to the devices manual for more information on how to start the pairing.")
        wrapMode: Text.WordWrap
        visible: nodesModel.count === 0
    }

    Repeater {
        model: ZWaveNodesProxy {
            id: nodesModel
            zwaveNodes: root.network.nodes
            showController: false
            newOnTop: true
        }
        delegate: NymeaSwipeDelegate {
            id: nodeDelegate
            readonly property ZWaveNode node: nodesModel.get(index)

            ThingsProxy {
                id: nodeThings
                engine: _engine
                paramsFilter: {"networkUuid": nodeDelegate.node.networkUuid, "nodeId": nodeDelegate.node.nodeId}
            }
            readonly property Thing nodeThing: nodeThings.count >= 1 ? nodeThings.get(0) : null

            Layout.fillWidth: true
            text: node.productName + " - " + node.manufacturerName// nodeThing ? nodeThing.name : node.model
            subText: node.state == ZigbeeNode.ZigbeeNodeStateInitializing ?
                         qsTr("Initializing...")
                       : nodeThings.count == 1 ? nodeThing.name :
                                                 nodeThings.count > 1 ? qsTr("%1 things").arg(nodeThings.count)
                                                                      : node.nodeType == ZWaveNode.ZWaveNodeTypeStaticController || node.nodeType == ZWaveNode.ZWaveNodeTypeController
                                                                        ? qsTr("Network controller") : qsTr("Unrecognized device")
            iconName: nodeThing ? app.interfacesToIcon(nodeThing.thingClass.interfaces) : "qrc:/icons/z-wave.svg"
            iconColor: busy
                       ? Style.tileOverlayColor
                       : node.nodeType == ZWaveNode.ZWaveNodeTypeController || node.nodeType == ZWaveNode.ZWaveNodeTypeStaticController
                         ? Style.green
                         : node.failed
                           ? Style.red
                           : nodeThing != null
                             ? Style.accentColor
                             : Style.iconColor
            progressive: false

            busy: !node.initialized

            canDelete: node.failed
//            canDelete: true
            onDeleteClicked: {
                var dialog = removeZWaveNodeDialogComponent.createObject(app, {zwaveNode: node})
                dialog.open()
            }

            secondaryIconName: node && node.sleeping ? "qrc:/icons/system-suspend.svg" : ""

            tertiaryIconName: {
                var signalStrength = "00";

                if (!node || !node.reachable) {
                    signalStrength = "00";
                } else if (node.linkQuality <= 25) {
                    signalStrength = "25"
                } else if (node.linkQuality <= 50) {
                    signalStrength = "50"
                } else if (node.linkQuality <= 75) {
                    signalStrength = "75"
                } else {
                    signalStrength = "100"
                }
                return "qrc:/icons/connections/nm-signal-" + signalStrength + (node.isSecure ? "-secure" : "") +".svg"
            }

            tertiaryIconColor: node.reachable ? Style.iconColor : Style.red

            Timer {
                id: communicationIndicatorLedTimer
                interval: 200
            }
            additionalItem: ColorIcon {
                size: Style.smallIconSize
                anchors.verticalCenter: parent.verticalCenter
                name: {
                    print("node type:", node.nodeType)
                    switch (node.nodeType) {
                    case ZWaveNode.ZWaveNodeTypeController:
                    case ZWaveNode.ZWaveNodeTypeStaticController:
                        return "qrc:/icons/z-wave.svg"
                    case ZWaveNode.ZWaveNodeTypeRoutingSlave:
                        return "qrc:/icons/zigbee/zigbee-router.svg"
                    case ZWaveNode.ZWaveNodeTypeSlave:
                        return "qrc:/icons/zigbee/zigbee-enddevice.svg"
                    }
                }
                color: communicationIndicatorLedTimer.running ? Style.accentColor : Style.iconColor
            }

            onClicked: {
                var popup = nodeInfoComponent.createObject(app, {node: node, nodeThings: nodeThings})
                popup.open()
            }
        }
    }

    Component {
        id: nodeInfoComponent
        NymeaDialog {
            id: nodeInfoDialog
            property ZWaveNode node: null
            property ThingsProxy nodeThings: null
            readonly property Thing nodeThing: nodeThings.count > 0 ? nodeThings.get(0) : null
            header: Item {
                implicitHeight: headerRow.height
                implicitWidth: parent.width
                RowLayout {
                    id: headerRow
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: Style.margins }
                    ColorIcon {
                        id: headerColorIcon
                        Layout.preferredHeight: Style.bigIconSize
                        Layout.preferredWidth: Style.bigIconSize * 1.5
                        color: Style.accentColor
                        name: nodeInfoDialog.node.isZWavePlus ? "qrc:/icons/zwave/z-wave-plus-wide.svg" : "qrc:/icons/zwave/z-wave-wide.svg"
                    }
                    ColumnLayout {
                        Layout.margins: Style.margins
                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: nodeInfoDialog.node.productName
                        }
                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: nodeInfoDialog.node.manufacturerName
                        }
                    }
                }
            }

            standardButtons: Dialog.NoButton

            GridLayout {
                columns: 2
                Label {
                    text: qsTr("Node ID:")
                    font: Style.smallFont
                }
                Label {
                    Layout.fillWidth: true
                    text: nodeInfoDialog.node.nodeId
                    font: Style.smallFont
                    horizontalAlignment: Text.AlignRight
                }
                Label {
                    text: qsTr("Device type:")
                    font: Style.smallFont
                }
                Label {
                    Layout.fillWidth: true
                    text: nodeInfoDialog.node.deviceTypeString
                    font: Style.smallFont
                    horizontalAlignment: Text.AlignRight
                }
                Label {
                    text: qsTr("Node type:")
                    font: Style.smallFont
                }
                Label {
                    Layout.fillWidth: true
                    text: nodeInfoDialog.node.nodeTypeString
                    font: Style.smallFont
                    horizontalAlignment: Text.AlignRight
                }
                Label {
                    text: qsTr("Role:")
                    font: Style.smallFont
                }
                Label {
                    Layout.fillWidth: true
                    text: nodeInfoDialog.node.roleString
                    font: Style.smallFont
                    horizontalAlignment: Text.AlignRight
                }
                Label {
                    text: qsTr("Security mode:")
                    font: Style.smallFont
                }
                Label {
                    Layout.fillWidth: true
                    text: nodeInfoDialog.node.securityMode
                    font: Style.smallFont
                    horizontalAlignment: Text.AlignRight
                }

                Label {
                    text: qsTr("Z-Wave plus:")
                    font: Style.smallFont
                }
                Label {
                    Layout.fillWidth: true
                    text: nodeInfoDialog.node.isZWavePlusDevice ? qsTr("Yes") : qsTr("No")
                    font: Style.smallFont
                    horizontalAlignment: Text.AlignRight
                }
                Label {
                    text: qsTr("Security device:")
                    font: Style.smallFont
                }
                Label {
                    Layout.fillWidth: true
                    text: nodeInfoDialog.node.isSecurityDevice ? qsTr("Yes") : qsTr("No")
                    font: Style.smallFont
                    horizontalAlignment: Text.AlignRight
                }
                Label {
                    text: qsTr("Beaming supported:")
                    font: Style.smallFont
                }
                Label {
                    Layout.fillWidth: true
                    text: nodeInfoDialog.node.isBeamingDevice ? qsTr("Yes") : qsTr("No")
                    font: Style.smallFont
                    horizontalAlignment: Text.AlignRight
                }
                Label {
                    text: qsTr("Signal strength:")
                    font: Style.smallFont
                }
                Label {
                    Layout.fillWidth: true
                    text: nodeInfoDialog.node.linkQuality + " %"
                    font: Style.smallFont
                    horizontalAlignment: Text.AlignRight
                }
                Label {
                    text: qsTr("Version:")
                    font: Style.smallFont
                }
                Label {
                    Layout.fillWidth: true
                    text: nodeInfoDialog.node.version
                    font: Style.smallFont
                    horizontalAlignment: Text.AlignRight
                }
            }

            SettingsPageSectionHeader {
                text: qsTr("Associated things")
                Layout.leftMargin: 0
                Layout.rightMargin: 0
            }

            Repeater {
                model: nodeInfoDialog.nodeThings
                delegate: RowLayout {
                    id: thingDelegate
                    property Thing thing: nodeInfoDialog.nodeThings.get(index)
                    Layout.fillWidth: true
                    ColorIcon {
                        size: Style.iconSize
                        source: app.interfacesToIcon(thing.thingClass.interfaces)
                        color: Style.accentColor
                    }
                    TextField {
                        text: thingDelegate.thing.name
                        Layout.fillWidth: true
                        onEditingFinished: engine.thingManager.editThing(thingDelegate.thing.id, text)
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Button {
                    visible: node && node.nodeType !== ZWaveNode.ZWaveNodeTypeController && node.failed
                    text: qsTr("Remove")
                    Layout.alignment: Qt.AlignLeft
                    onClicked: {
                        var dialog = removeZWaveNodeDialogComponent.createObject(app, {zwaveNode: node})
                        dialog.open()
                        nodeInfoDialog.close()
                    }
                }
                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: qsTr("OK")
                    onClicked: nodeInfoDialog.close()
                    Layout.alignment: Qt.AlignRight
                }
            }
        }
    }

    Component {
        id: removeZWaveNodeDialogComponent

        NymeaDialog {
            id: removeZWaveNodeDialog

            property ZWaveNode zwaveNode

            headerIcon: "qrc:/icons/zigbee.svg"
            title: qsTr("Remove Z-Wave node") + " " + (zwaveNode ? zwaveNode.name != "" ? zwaveNode.name : zwaveNode.productName : "")
            text: qsTr("Are you sure you want to remove this node from the network?")
            standardButtons: Dialog.Ok | Dialog.Cancel

            Label {
                text: qsTr("Please note that if this node has been assigned to a thing, it will also be removed from the system.")
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }

            onAccepted: {
                zwaveManager.cancelPendingOperation(network.networkUuid)
                d.removeFailedNode(zwaveNode.networkUuid, zwaveNode.nodeId)
            }
        }
    }

    Component {
        id: zigbeeHelpDialog

        NymeaDialog {
            id: dialog
            title: qsTr("Z-Wave network help")

            RowLayout {
                spacing: Style.margins
                ColorIcon {
                    Layout.preferredHeight: Style.iconSize
                    Layout.preferredWidth: Style.iconSize
                    name: "qrc:/icons/zigbee/zigbee-router.svg"
                }

                Label {
                    text: qsTr("Z-Wave router")
                }
            }

            RowLayout {
                spacing: Style.margins
                ColorIcon {
                    Layout.preferredHeight: Style.iconSize
                    Layout.preferredWidth: Style.iconSize
                    name: "qrc:/icons/zigbee-enddevice.svg"
                }

                Label {
                    text: qsTr("Z-Wave end device")
                }
            }

            RowLayout {
                spacing: Style.margins
                ColorIcon {
                    Layout.preferredHeight: Style.iconSize
                    Layout.preferredWidth: Style.iconSize
                    name: "qrc:/icons/system-suspend.svg"
                }

                Label {
                    text: qsTr("Sleepy device")
                }
            }
        }
    }

    Component {
        id: addRemoveNodeDialogComponent
        NymeaDialog {
            standardButtons: Dialog.Cancel
            onRejected: {
                zwaveManager.cancelPendingOperation(network.networkUuid)
            }
        }
    }
}
