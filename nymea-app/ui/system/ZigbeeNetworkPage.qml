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
                    pageStack.pop(root, StackView.Immediate)
                    pageStack.pop()
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
        text: qsTr("Connected devices")
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
            readonly property Thing nodeThing: nodeThings.count === 1 ? nodeThings.get(0) : null
            property int signalStrength: node ? Math.round(node.lqi * 100.0 / 255.0) : 0

            Layout.fillWidth: true
            text: nodeThing ? nodeThing.name : node.model
            subText: node.manufacturer || node.ieeeAddress
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


            tertiaryIconColor: node.reachable ? Style.iconColor : "red"

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
                name: node.type === ZigbeeNode.ZigbeeNodeTypeRouter
                  ? "/ui/images/zigbee-router.svg"
                  : "/ui/images/zigbee-enddevice.svg"
                color: communicationIndicatorLedTimer.running ? Style.accentColor : Style.iconColor
                Component.onCompleted: print("************+ node type", node.type)
            }

            onClicked: {
                var popup = nodeInfoComponent.createObject(app, {node: node, nodeThing: nodeThing})
                popup.open()
            }
        }
    }

    Component {
        id: nodeInfoComponent
        MeaDialog {
            id: nodeInfoDialog
            property ZigbeeNode node: null
            property Thing nodeThing: null
            header: Item {
                implicitHeight: headerRow.height + Style.margins
                implicitWidth: parent.width
                RowLayout {
                    id: headerRow
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: Style.margins }
                    spacing: Style.margins
                    ColorIcon {
                        id: headerColorIcon
                        Layout.preferredHeight: Style.hugeIconSize
                        Layout.preferredWidth: height
                        color: Style.accentColor
                        name: nodeThing ? app.interfacesToIcon(nodeThing.thingClass.interfaces) : "/ui/images/zigbee.svg"
                        visible: name.length > 0
                    }

                    TextField {
                        id: titleLabel
                        Layout.fillWidth: true
                        Layout.margins: Style.margins
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: nodeThing ? nodeThing.name : node.model
                        color: Style.accentColor
                        font.pixelSize: app.largeFont
                        readOnly: nodeInfoDialog.nodeThing == null
                        onEditingFinished: engine.thingManager.editThing(nodeInfoDialog.nodeThing.id, text)
                    }
                }
            }

            standardButtons: Dialog.NoButton

            NymeaItemDelegate {
                text: qsTr("Model")
                Layout.fillWidth: true
                progressive: false
                subText: nodeInfoDialog.node.model
            }
            NymeaItemDelegate {
                text: qsTr("Manufacturer")
                Layout.fillWidth: true
                progressive: false
                subText: nodeInfoDialog.node.manufacturer
            }
            NymeaItemDelegate {
                text: qsTr("IEEE address")
                Layout.fillWidth: true
                progressive: false
                subText: nodeInfoDialog.node.ieeeAddress
            }
            NymeaItemDelegate {
                text: qsTr("Network address")
                Layout.fillWidth: true
                progressive: false
                subText: "0x" + nodeInfoDialog.node.networkAddress.toString(16)
            }
            NymeaItemDelegate {
                text: qsTr("Signal strength")
                Layout.fillWidth: true
                progressive: false
                subText: (nodeInfoDialog.node.lqi * 100 / 255).toFixed(0) + " %"
            }
            NymeaItemDelegate {
                text: qsTr("Version")
                Layout.fillWidth: true
                progressive: false
                subText: nodeInfoDialog.node.version
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
                    name: "/ui/images/zigbee-router.svg"
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
                    name: "/ui/images/zigbee-enddevice.svg"
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
