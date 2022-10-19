/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2022, nymea GmbH
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
import "qrc:/ui/components"
import Nymea 1.0

SettingsPageBase {
    id: root

    property ZigbeeManager zigbeeManager: null
    property ZigbeeNetwork network: null

    signal exit()

    header: NymeaHeader {
        text: qsTr("ZigBee network")
        backButtonVisible: true
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "/ui/images/help.svg"
            text: qsTr("Help")
            onClicked: {
                var popup = zigbeeHelpDialog.createObject(app)
                popup.open()
            }
        }

        HeaderButton {
            imageSource: "/ui/images/configure.svg"
            text: qsTr("Network settings")
            onClicked: {
                var page = pageStack.push(Qt.resolvedUrl("ZigbeeNetworkSettingsPage.qml"), { zigbeeManager: zigbeeManager, network: network })
                page.exit.connect(function() {
                    root.exit()
                })
            }
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
                case ZigbeeManager.ZigbeeErrorNoError:
                    return;
                case ZigbeeManager.ZigbeeErrorAdapterNotAvailable:
                    props.text = qsTr("The selected adapter is not available or the selected serial port configration is incorrect.");
                    break;
                case ZigbeeManager.ZigbeeErrorAdapterAlreadyInUse:
                    props.text = qsTr("The selected adapter is already in use.");
                    break;
                default:
                    props.error = error;
                }
                var comp = Qt.createComponent("/ui/components/ErrorDialog.qml")
                var popup = comp.createObject(app, props)
                popup.open();
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Network state")
    }

    ColumnLayout {
        spacing: Style.margins
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: Style.margins
            columnSpacing: Style.margins

            RowLayout {
                Layout.preferredWidth: (parent.width - parent.columnSpacing) / 2
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

            }

            RowLayout {
                Layout.preferredWidth: (parent.width - parent.columnSpacing) / 2

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

                        ctx.fillStyle = Style.foregroundColor
                        ctx.strokeStyle = Style.foregroundColor
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


                ColorIcon {
                    Layout.preferredHeight: Style.iconSize
                    Layout.preferredWidth: Style.iconSize
                    name: network.permitJoiningEnabled ? "/ui/images/lock-open.svg" : "/ui/images/lock-closed.svg"
                    visible: !network.permitJoiningEnabled
                }
                Label {
                    Layout.fillWidth: true
                    text: network.permitJoiningEnabled ? qsTr("Open for %0 s").arg(network.permitJoiningRemaining) : qsTr("Closed")
                }

            }

            Button {
                Layout.fillWidth: true
                Layout.columnSpan: 2
                text: qsTr("Open for new devices")
                enabled: network.networkState === ZigbeeNetwork.ZigbeeNetworkStateOnline
                visible: !network.permitJoiningEnabled
                onClicked: zigbeeManager.setPermitJoin(network.networkUuid)
            }

            Button {
                Layout.fillWidth: true
                text: qsTr("Extend")
                enabled: network.networkState === ZigbeeNetwork.ZigbeeNetworkStateOnline
                visible: network.permitJoiningEnabled
                onClicked: zigbeeManager.setPermitJoin(network.networkUuid, 254)
            }


            Button {
                Layout.fillWidth: true
                enabled: network.networkState == ZigbeeNetwork.ZigbeeNetworkStateOnline
                visible: network.permitJoiningEnabled
                text: qsTr("Close")
                onClicked: {
                    zigbeeManager.setPermitJoin(network.networkUuid, 0)
                }
            }

        }


    }

    SettingsPageSectionHeader {
        text: offlineNodes.count == 0
              ? qsTr("%n device(s)", "", Math.max(0, root.network.nodes.count - 1)) // -1 for coordinator node
              : qsTr("%n device(s) (%1 disconnected)", "", Math.max(root.network.nodes.count - 1)).arg(offlineNodes.count)

        ZigbeeNodesProxy {
            id: offlineNodes
            zigbeeNodes: root.network.nodes
            showCoordinator: false
            showOnline: false
        }
    }

    Label {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("There are no ZigBee devices connected yet. Open the network for new devices to join and start the pairing procedure from the ZigBee device. Please refer to the devices manual for more information on how to start the pairing.")
        wrapMode: Text.WordWrap
        visible: nodesModel.count === 0
    }

    Repeater {
        model: ZigbeeNodesProxy {
            id: nodesModel
            zigbeeNodes: root.network.nodes
            showCoordinator: false
            newOnTop: true
        }
        delegate: NymeaSwipeDelegate {
            id: nodeDelegate
            readonly property ZigbeeNode node: nodesModel.get(index)

            ThingsProxy {
                id: nodeThings
                engine: _engine
                paramsFilter: {"ieeeAddress": nodeDelegate.node.ieeeAddress}
            }
            readonly property Thing nodeThing: nodeThings.count >= 1 ? nodeThings.get(0) : null
            property int signalStrength: node ? Math.round(node.lqi * 100.0 / 255.0) : 0

            Layout.fillWidth: true
            text: node.model + " - " + node.manufacturer// nodeThing ? nodeThing.name : node.model
            subText: node.state == ZigbeeNode.ZigbeeNodeStateInitializing ?
                         qsTr("Initializing...")
                       : nodeThings.count == 1 ? nodeThing.name :
                                                 nodeThings.count > 1 ? qsTr("%1 things").arg(nodeThings.count) : qsTr("Unrecognized device")
            iconName: nodeThing ? app.interfacesToIcon(nodeThing.thingClass.interfaces) : "/ui/images/zigbee.svg"
            iconColor: busy
                       ? Style.tileOverlayColor
                       : nodeThing != null ? Style.accentColor : Style.iconColor
            progressive: false

            busy: node.state !== ZigbeeNode.ZigbeeNodeStateInitialized

            canDelete: true
            onDeleteClicked: {
                var dialog = removeZigbeeNodeDialogComponent.createObject(app, {zigbeeNode: node})
                dialog.open()
            }

            secondaryIconName: node && !node.rxOnWhenIdle ? "/ui/images/system-suspend.svg" : ""

            tertiaryIconName: {
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


            tertiaryIconColor: node.reachable ? Style.iconColor : Style.red

            Connections {
                target: node
                onLastSeenChanged: communicationIndicatorLedTimer.start()
            }

            Timer {
                id: communicationIndicatorLedTimer
                interval: 200
            }
            additionalItem: ColorIcon {
                size: Style.smallIconSize
                anchors.verticalCenter: parent.verticalCenter
                name: node.type === ZigbeeNode.ZigbeeNodeTypeCoordinator
                      ? "/ui/images/zigbee/zigbee-coordinator.svg"
                      : node.type === ZigbeeNode.ZigbeeNodeTypeRouter
                        ? "/ui/images/zigbee/zigbee-router.svg"
                        : "/ui/images/zigbee/zigbee-enddevice.svg"
                color: communicationIndicatorLedTimer.running ? Style.accentColor : Style.iconColor
            }

            onClicked: {
                pageStack.push("ZigbeeNodePage.qml", {zigbeeManager: zigbeeManager, network: network, node: node})
//                var popup = nodeInfoComponent.createObject(app, {node: node, nodeThings: nodeThings})
//                popup.open()
            }
        }
    }

    Component {
        id: nodeInfoComponent
        MeaDialog {
            id: nodeInfoDialog
            property ZigbeeNode node: null
            property ThingsProxy nodeThings: null
            readonly property Thing nodeThing: nodeThings.count > 0 ? nodeThings.get(0) : null
            header: Item {
                implicitHeight: headerRow.height
                implicitWidth: parent.width
                RowLayout {
                    id: headerRow
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: Style.margins }
                    spacing: Style.margins
                    ColorIcon {
                        id: headerColorIcon
                        Layout.preferredHeight: Style.bigIconSize
                        Layout.preferredWidth: height
                        color: Style.accentColor
                        name: "/ui/images/zigbee.svg"
                    }
                    ColumnLayout {
                        Layout.margins: Style.margins
                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: nodeInfoDialog.node.model
                        }
                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: nodeInfoDialog.node.manufacturer
                        }
                    }
                }
            }

            standardButtons: Dialog.NoButton

            GridLayout {
                columns: 2
                Label {
                    text: qsTr("IEEE address:")
                    font: Style.smallFont
                }
                Label {
                    Layout.fillWidth: true
                    text: nodeInfoDialog.node.ieeeAddress
                    font: Style.smallFont
                    horizontalAlignment: Text.AlignRight
                }
                Label {
                    text: qsTr("Network address:")
                    font: Style.smallFont
                }
                Label {
                    Layout.fillWidth: true
                    text: "0x" + nodeInfoDialog.node.networkAddress.toString(16)
                    font: Style.smallFont
                    horizontalAlignment: Text.AlignRight
                }
                Label {
                    text: qsTr("Signal strength:")
                    font: Style.smallFont
                }
                Label {
                    Layout.fillWidth: true
                    text: (nodeInfoDialog.node.lqi * 100 / 255).toFixed(0) + " %"
                    font: Style.smallFont
                    horizontalAlignment: Text.AlignRight
                }
                Label {
                    text: qsTr("Version:")
                    font: Style.smallFont
                }
                Label {
                    Layout.fillWidth: true
                    text: nodeInfoDialog.node.version.length > 0 ? nodeInfoDialog.node.version : qsTr("Unknown")
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
    //                    size: Style.iconSize
                    visible: node && node.type !== ZigbeeNode.ZigbeeNodeTypeCoordinator
    //                    imageSource: "/ui/images/delete.svg"
                    text: qsTr("Remove")
                    Layout.alignment: Qt.AlignLeft
                    onClicked: {
                        var dialog = removeZigbeeNodeDialogComponent.createObject(app, {zigbeeNode: node})
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
        id: removeZigbeeNodeDialogComponent

        MeaDialog {
            id: removeZigbeeNodeDialog

            property ZigbeeNode zigbeeNode

            headerIcon: "/ui/images/zigbee.svg"
            title: qsTr("Remove ZigBee node") + " " + (zigbeeNode ? zigbeeNode.model : "")
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
        id: zigbeeHelpDialog

        MeaDialog {
            id: dialog
            title: qsTr("ZigBee network help")

            RowLayout {
                spacing: Style.margins
                ColorIcon {
                    Layout.preferredHeight: Style.iconSize
                    Layout.preferredWidth: Style.iconSize
                    name: "/ui/images/zigbee/zigbee-router.svg"
                }

                Label {
                    text: qsTr("ZigBee router")
                }
            }

            RowLayout {
                spacing: Style.margins
                ColorIcon {
                    Layout.preferredHeight: Style.iconSize
                    Layout.preferredWidth: Style.iconSize
                    name: "/ui/images/zigbee/zigbee-enddevice.svg"
                }

                Label {
                    text: qsTr("ZigBee end device")
                }
            }

            RowLayout {
                spacing: Style.margins
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
