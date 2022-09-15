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
    property ZigbeeNode node: null
    readonly property ZigbeeNode coordinatorNode: root.network.nodes.getNodeByNetworkAddress(0)

    header: NymeaHeader {
        text: qsTr("ZigBee node info")
        backButtonVisible: true
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "/ui/images/delete.svg"
            text: qsTr("Remove node")
            onClicked: {
                var popup = removeZigbeeNodeDialogComponent.createObject(app)
                popup.open()
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

        onPendingCommandIdChanged: {
            print("pendingCommandId changed", pendingCommandId, wakeupDialog)
            if (pendingCommandId == -1 && wakeupDialog != null) {
                wakeupDialog.close();
                wakeupDialog.destroy();
                wakeupDialog = null
            }
        }

        property var wakeupDialog: null
    }

    Connections {
        target: root.zigbeeManager
        onCreateBindingReply: {
            print("**** create binding reply", error)
            if (commandId == d.pendingCommandId) {
                d.pendingCommandId = -1
                var props = {};
                switch (error) {
                case ZigbeeManager.ZigbeeErrorNoError:
                    return;
                case ZigbeeManager.ZigbeeErrorNetworkError:
                    props.text = qsTr("An error happened in the ZigBee network when creating the binding.");
                    break;
                case ZigbeeManager.ZigbeeErrorTimeoutError:
                    props.text = qsTr("The ZigBee device did not respond. Please try again.");
                    break;
                default:
                    props.error = error;
                }
                var comp = Qt.createComponent("/ui/components/ErrorDialog.qml")
                var popup = comp.createObject(app, props)
                popup.open();
            }
        }
        onRemoveBindingReply: {
            if (commandId == d.pendingCommandId) {
                d.pendingCommandId = -1

                var props = {};
                switch (error) {
                case ZigbeeManager.ZigbeeErrorNoError:
                    return;
                case ZigbeeManager.ZigbeeErrorNetworkError:
                    props.text = qsTr("An error happened in the ZigBee network when removing the binding.");
                    break;
                case ZigbeeManager.ZigbeeErrorTimeoutError:
                    props.text = qsTr("The ZigBee device did not respond. Please try again.");
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

    ThingsProxy {
        id: nodeThings
        engine: _engine
        paramsFilter: {"ieeeAddress": root.node.ieeeAddress}
    }

    property int signalStrength: node ? Math.round(node.lqi * 100.0 / 255.0) : 0

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: root.node.model
        subText: qsTr("Model")
        prominentSubText: false
        progressive: false
    }
    NymeaItemDelegate {
        prominentSubText: false
        progressive: false
        Layout.fillWidth: true
        text: root.node.manufacturer
        subText: qsTr("Manufacturer")
    }

    NymeaItemDelegate {
        prominentSubText: false
        progressive: false
        Layout.fillWidth: true
        text: root.node.ieeeAddress
        subText: qsTr("IEEE address")
        font: Style.smallFont
    }
    NymeaItemDelegate {
        prominentSubText: false
        progressive: false
        Layout.fillWidth: true
        text: "0x" + root.node.networkAddress.toString(16)
        subText: qsTr("Network address")
    }
    NymeaItemDelegate {
        prominentSubText: false
        progressive: false
        Layout.fillWidth: true
        text: (root.node.lqi * 100 / 255).toFixed(0) + " %"
        subText: qsTr("Signal strength")
    }
    NymeaItemDelegate {
        prominentSubText: false
        progressive: false
        Layout.fillWidth: true
        text: root.node.version.length > 0 ? root.node.version : qsTr("Unknown")
        subText: qsTr("Version")
    }

//    NymeaItemDelegate {
//        Layout.fillWidth: true
//        text: qsTr("Device endpoints")
//        subText: qsTr("Show detailed information about the node")
//        onClicked: pageStack.push(endpointsPageComponent)
//    }

    SettingsPageSectionHeader {
        text: qsTr("Associated things")
    }

    Repeater {
        model: nodeThings
        delegate: NymeaItemDelegate {
            Layout.fillWidth: true
            property Thing thing: nodeThings.get(index)
            iconName: app.interfacesToIcon(thing.thingClass.interfaces)
            text: thing.name
            onClicked: pageStack.push("/ui/thingconfiguration/ConfigureThingPage.qml", {thing: thing})
        }

//        delegate: RowLayout {
//            id: thingDelegate
//            Layout.leftMargin: Style.margins
//            Layout.rightMargin: Style.margins
//            property Thing thing: nodeThings.get(index)
//            Layout.fillWidth: true
//            ColorIcon {
//                size: Style.iconSize
//                source: app.interfacesToIcon(thing.thingClass.interfaces)
//                color: Style.accentColor
//            }
//            TextField {
//                text: thingDelegate.thing.name
//                Layout.fillWidth: true
//                onEditingFinished: engine.thingManager.editThing(thingDelegate.thing.id, text)
//            }
//        }
    }


    ColumnLayout {
        visible: engine.jsonRpcClient.ensureServerVersion("6.2")

        SettingsPageSectionHeader {
            text: qsTr("Bindings")
        }

        Repeater {
            model: root.node.bindings
            delegate: NymeaSwipeDelegate {
                id: bindingDelegate
                Layout.fillWidth: true
                property ZigbeeNodeBinding binding: root.node.bindings[index]
                property ZigbeeNode destinationNode: root.network.nodes.getNode(binding.destinationAddress)
                property ZigbeeNodeEndpoint endpoint: root.node.getEndpoint(binding.sourceEndpointId);
                property ZigbeeCluster inputCluster: endpoint ? endpoint.getInputCluster(binding.clusterId) : null
                property ZigbeeCluster outputCluster: endpoint ? endpoint.getOutputCluster(binding.clusterId) : null
                property ZigbeeCluster usedCluster: inputCluster ? inputCluster : outputCluster
                property Thing destinationThing: destinationThings.count > 0 ? destinationThings.get(0) : null
                ThingsProxy {
                    id: destinationThings
                    engine: _engine
                    paramsFilter: {"ieeeAddress": bindingDelegate.binding.destinationAddress}
                }

                iconName: destinationNode && destinationNode == root.coordinatorNode
                          ? "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
                          : destinationThing
                            ? app.interfacesToIcon(destinationThing.thingClass.interfaces)
                            : "/ui/images/zigbee.svg"
                canDelete: true
                progressive: false
                text: {
                    if (binding.destinationAddress == "") {
                        return qsTr("Group: 0x%1").arg(NymeaUtils.pad(binding.groupAddress.toString(16), 4))
                    }
                    var ret = ""
                    if (destinationNode) {
                        if (destinationNode == root.coordinatorNode) {
                            ret += Configuration.systemName
                        } else {
                            ret += destinationNode.model
                        }
                    } else {
                        ret += binding.destinationAddress
                    }

                    if (destinationThings.count == 1) {
                        ret += " (" + destinationThings.get(0).name + ")"
                    } else if (destinationThings.count > 1) {
                        ret += " (" + destinationThing.count + " things)"
                    }

                    return ret
                }
                subText: {
                    var ret = usedCluster.clusterName();
                    if (binding.destinationAddress != "") {
                        ret += " (" + binding.sourceEndpointId + " -> " + binding.destinationEndpointId + ")"
                    }
                    return ret;
                }
                onDeleteClicked: {
                    if (!node.rxOnWhenIdle) {
                        d.wakeupDialog = wakeupDialogComponent.createObject(root)
                        d.wakeupDialog.open()
                    }
                    d.pendingCommandId = zigbeeManager.removeBinding(network.networkUuid, binding)
                }
            }
        }

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: Style.margins
            Layout.rightMargin: Style.margins
            text: qsTr("Add binding")
            onClicked: {
                var dialog = addBindingComponent.createObject(root)
                dialog.open()

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
        id: endpointsPageComponent
        SettingsPageBase {
            title: qsTr("Device endpoints")

            Repeater {
                model: root.node.endpoints
                delegate: ColumnLayout {
                    id: endpointDelegate
                    property ZigbeeNodeEndpoint endpoint: root.node.endpoints[index]
                    Label {
                        Layout.fillWidth: true
                        text: "- " + qsTr("Endpoint %1").arg(endpointDelegate.endpoint.endpointId)
                    }
                    Label {
                        Layout.fillWidth: true
                        text: "    " + qsTr("Input clusters")
                    }

                    Repeater {
                        model: endpointDelegate.endpoint.inputClusters
                        delegate: Label {
                            Layout.fillWidth: true
                            property ZigbeeCluster cluster: endpointDelegate.endpoint.inputClusters[index]
                            text: "      - " + cluster.clusterName() + " (" + (cluster.direction == ZigbeeCluster.ZigbeeClusterDirectionClient ? qsTr("Client") : qsTr("Server")) + ")"
                        }
                    }
                    Label {
                        Layout.fillWidth: true
                        text: "    " + qsTr("Output clusters")
                    }

                    Repeater {
                        model: endpointDelegate.endpoint.outputClusters
                        delegate: Label {
                            Layout.fillWidth: true
                            property ZigbeeCluster cluster: endpointDelegate.endpoint.outputClusters[index]
                            text: "     - " + cluster.clusterName() + " (" + (cluster.direction == ZigbeeCluster.ZigbeeClusterDirectionClient ? qsTr("Client") : qsTr("Server")) + ")"
                        }
                    }
                }
            }
        }
    }


    Component {
        id: addBindingComponent
        MeaDialog {
            title: qsTr("Add binding")

            Label {
                text: qsTr("Source endpoint")
                Layout.fillWidth: true
            }
            ComboBox {
                Layout.fillWidth: true
                id: sourceEndpointComboBox
                model: root.node.endpoints
                textRole: "endpointId"
                displayText: currentEndpoint.endpointId
                property ZigbeeNodeEndpoint currentEndpoint: root.node.endpoints[currentIndex]
                onCurrentEndpointChanged: print("source endpoint changed", currentEndpoint.endpointId)
            }
            Label {
                text: qsTr("Target node")
                Layout.fillWidth: true
            }
            ComboBox {
                id: destinationNodeComboBox
                Layout.fillWidth: true
                Layout.preferredHeight: Style.delegateHeight
                model: network.nodes
                property ZigbeeNode currentNode: network.nodes.get(currentIndex)
                property Thing currentNodeThing: currentNode && currentDestinationNodeThings.count > 0 ? currentDestinationNodeThings.get(0) : null
                ThingsProxy {
                    id: currentDestinationNodeThings
                    engine: _engine
                    paramsFilter: destinationNodeComboBox.currentNode ? {"ieeeAddress": destinationNodeComboBox.currentNode.ieeeAddress} : {}
                }

                contentItem: RowLayout {
                    id: destinationNodeContentItem
                    width: parent.width - destinationNodeComboBox.indicator.width - Style.smallMargins
                    height: Style.delegateHeight
                    spacing: Style.smallMargins

                    ColorIcon {
                        Layout.leftMargin: Style.smallMargins
                        size: Style.iconSize
                        name: destinationNodeComboBox.currentNode == root.coordinatorNode
                              ? "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
                              : destinationNodeComboBox.currentNodeThing
                                ? app.interfacesToIcon(destinationNodeComboBox.currentNodeThing.thingClass.interfaces)
                                : "/ui/images/zigbee.svg"
                        color: Style.accentColor
                    }

                    ColumnLayout {
                        Label {
                            Layout.fillWidth: true
                            text: destinationNodeComboBox.currentNode == root.coordinatorNode
                                  ? Configuration.systemName
                                  : destinationNodeComboBox.currentNode.model + " - " + destinationNodeComboBox.currentNode.manufacturer
                            elide: Text.ElideRight
                        }
                        Label {
                            Layout.fillWidth: true
                            text: destinationNodeComboBox.currentNode == root.coordinatorNode
                                  ? qsTr("Coordinator")
                                  : currentDestinationNodeThings.count == 1
                                    ? destinationNodeComboBox.currentNodeThing.name
                                    : currentDestinationNodeThings.count > 1
                                      ? qsTr("%1 things").arg(currentDestinationNodeThings.count)
                                      : qsTr("Unrecognized device")
                            font: Style.smallFont
                            elide: Text.ElideRight
                        }
                    }
                }
//                displayText: currentDestinationNodeThings.count > 0
//                             ? currentDestinationNodeThings.get(0).name
//                             : currentNode == root.coordinatorNode
//                               ? Configuration.systemName
//                               : currentNode.model
//                ThingsProxy {
//                    id: currentDestinationNodeThings
//                    engine: _engine
//                    paramsFilter: {"ieeeAddress": destinationNodeComboBox.currentNode.ieeeAddress}
//                }
                delegate: NymeaItemDelegate {
                    id: destinationNodeDelegate
                    property ZigbeeNode node: network.nodes.get(index)
                    property Thing nodeThing: destinationNodeThings.count > 0 ? destinationNodeThings.get(0) : null
                    iconName: node == coordinatorNode
                              ? "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
                              : nodeThing ? app.interfacesToIcon(nodeThing.thingClass.interfaces) : "/ui/images/zigbee.svg"
                    width: parent.width
                    text: node == root.coordinatorNode
                          ? Configuration.systemName
                          : node.model + " - " + node.manufacturer
                    subText: node == root.coordinatorNode
                             ? qsTr("Coordinator")
                             : destinationNodeThings.count == 1
                               ? nodeThing.name
                               : nodeThings.count > 1
                                 ? qsTr("%1 things").arg(nodeThings.count)
                                 : qsTr("Unrecognized device")
                    progressive: false

                    ThingsProxy {
                        id: destinationNodeThings
                        engine: _engine
                        paramsFilter: {"ieeeAddress": destinationNodeDelegate.node.ieeeAddress}
                    }
                }
            }
            Label {
                text: qsTr("Destination endpoint")
                Layout.fillWidth: true
            }
            ComboBox {
                id: destinationEndpointComboBox
                Layout.fillWidth: true
                model: destinationNodeComboBox.currentNode.endpoints
                textRole: "endpointId"
                displayText: currentEndpoint.endpointId
                property ZigbeeNodeEndpoint currentEndpoint: destinationNodeComboBox.currentNode.endpoints[currentIndex]
            }

            Label {
                text: qsTr("Cluster")
                Layout.fillWidth: true
            }

            ComboBox {
                id: clusterComboBox
                Layout.fillWidth: true
                delegate: ItemDelegate {
                    width: parent.width
                    text: modelData.clusterName()
                }
                model: {
                    var ret = []
                    print("updating clusters", sourceEndpointComboBox.currentEndpoint, destinationNodeComboBox.currentNode, destinationEndpointComboBox.currentEndpoint)
                    if (!sourceEndpointComboBox.currentEndpoint || !destinationNodeComboBox.currentNode || !destinationEndpointComboBox.currentEndpoint) {
                        return ret;
                    }

                    for (var i = 0; i < sourceEndpointComboBox.currentEndpoint.outputClusters.length; i++) {
                        var outputCluster = sourceEndpointComboBox.currentEndpoint.outputClusters[i]
                        print("source has cluster", outputCluster.clusterId)
                        for (var j = 0; j < destinationEndpointComboBox.currentEndpoint.inputClusters.length; j++) {
                            var inputCluster = destinationEndpointComboBox.currentEndpoint.inputClusters[j]
                            print("destination has cluster", inputCluster.clusterId)
                            if (inputCluster.clusterId === outputCluster.clusterId && inputCluster.direction !== outputCluster.direction) {
                                ret.push(outputCluster);
                                break;
                            }
                        }
                    }
                    for (var i = 0; i < sourceEndpointComboBox.currentEndpoint.inputClusters.length; i++) {
                        var inputCluster = sourceEndpointComboBox.currentEndpoint.inputClusters[i]
                        print("source has cluster", inputCluster.clusterId)
                        for (var j = 0; j < destinationEndpointComboBox.currentEndpoint.outputClusters.length; j++) {
                            var outputCluster = destinationEndpointComboBox.currentEndpoint.outputClusters[j]
                            print("destination has cluster", outputCluster.clusterId)
                            if (inputCluster.clusterId === outputCluster.clusterId && inputCluster.direction !== outputCluster.direction) {
                                ret.push(inputCluster);
                                break;
                            }
                        }
                    }

                    return ret
                }
                property ZigbeeCluster currentCluster: currentValue
                displayText: currentValue.clusterName()
            }


            onAccepted: {
                d.pendingCommandId = root.zigbeeManager.createBinding(
                            root.network.networkUuid,
                            root.node.ieeeAddress,
                            sourceEndpointComboBox.currentEndpoint.endpointId,
                            clusterComboBox.currentCluster.clusterId,
                            destinationNodeComboBox.currentNode.ieeeAddress,
                            destinationEndpointComboBox.currentEndpoint.endpointId)

                if (!root.node.rxOnWhenIdle) {
                    d.wakeupDialog = wakeupDialogComponent.createObject(root)
                    d.wakeupDialog.open()
                }
            }
        }
    }

    Component {
        id: wakeupDialogComponent
        MeaDialog {
            id: wakeupDialog
            title: qsTr("Wake up %1").arg(root.node.model)
            text: qsTr("The selected node is a sleepy device. Please wake up the device by pressing a button.")
        }
    }
}
