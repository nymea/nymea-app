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

import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "../components"
import Nymea 1.0

SettingsPageBase {
    id: root
    header: NymeaHeader {
        text: qsTr("ZigBee")
        backButtonVisible: true
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/add.svg"
            text: qsTr("Add ZigBee network")
            onClicked: {
                addNetwork()
            }
        }
    }

    function addNetwork() {
        var addPage = pageStack.push(Qt.resolvedUrl("ZigbeeAddNetworkPage.qml"), {zigbeeManager: zigbeeManager})
        addPage.done.connect(function() {pageStack.pop(root)})
    }

    ZigbeeManager {
        id: zigbeeManager
        engine: _engine
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: root.height
        visible: zigbeeManager.networks.count == 0

        EmptyViewPlaceholder {
            width: parent.width - app.margins * 2
            anchors.centerIn: parent
            title: qsTr("ZigBee")
            text: qsTr("There are no ZigBee networks set up yet. In order to use ZigBee, create a ZigBee network.")
            imageSource: "/ui/images/zigbee.svg"
            buttonText: qsTr("Add network")
            onButtonClicked: {
                addNetwork()
            }
        }
    }


    ColumnLayout {
        Layout.margins: app.margins / 2
        Repeater {
            model: zigbeeManager.networks
            delegate: BigTile {
                id: networkDelegate
                Layout.fillWidth: true
                interactive: false
                property ZigbeeNetwork network: zigbeeManager.networks.get(index)

                onClicked: pageStack.push(Qt.resolvedUrl("ZigbeeNetworkPage.qml"), { zigbeeManager: zigbeeManager, network: networkDelegate.network })

                header: RowLayout {
                    ColorIcon {
                        name: "/ui/images/zigbee/" + model.backend + ".svg"
                        Layout.preferredWidth: Style.iconSize
                        Layout.preferredHeight: Style.iconSize
                    }

                    Label {
                        Layout.fillWidth: true
                        text: model.backend
                        font.pixelSize: app.largeFont
                    }
                }

                contentItem: ColumnLayout {
                    spacing: app.margins


                    RowLayout {
                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Network state:")
                        }
                        Label {
                            text: {
                                switch (model.networkState) {
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
                                switch (model.networkState) {
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
                        Label {
                            text: qsTr("Adapter:")
                        }

                        Label {
                            Layout.fillWidth: true
                            text: adaptersProxy.count > 0 ? adaptersProxy.get(0).description : ""
                            elide: Text.ElideRight

                            ZigbeeAdaptersProxy {
                                id: adaptersProxy
                                manager: zigbeeManager
                                serialPortFilter: networkDelegate.network.serialPort
                            }
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        text: offlineNodes.count == 0
                              ? qsTr("%n device(s)", "", Math.max(0, networkDelegate.network.nodes.count - 1)) // -1 for coordinator node
                              : qsTr("%n device(s) (%1 disconnected)", "", Math.max(networkDelegate.network.nodes.count - 1)).arg(offlineNodes.count)

                        ZigbeeNodesProxy {
                            id: offlineNodes
                            zigbeeNodes: networkDelegate.network.nodes
                            showCoordinator: false
                            showOnline: false
                        }
                    }
                }
            }
        }
    }
}

