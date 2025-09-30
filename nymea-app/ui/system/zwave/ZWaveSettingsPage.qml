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

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Nymea

import "qrc:/ui/components"

SettingsPageBase {
    id: root
    header: NymeaHeader {
        text: qsTr("Z-Wave")
        backButtonVisible: true
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "qrc:/icons/add.svg"
            text: qsTr("Add Z-Wave network")
            onClicked: {
                addNetwork()
            }
        }
    }

    function addNetwork() {
        var addPage = pageStack.push(Qt.resolvedUrl("ZWaveAddNetworkPage.qml"), {zwaveManager: zwaveManager})
        addPage.done.connect(function() {pageStack.pop(root)})
    }

    ZWaveManager {
        id: zwaveManager
        engine: _engine
    }


    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: root.height - root.header.height - Style.margins
        visible: !zwaveManager.fetchingData && (!zwaveManager.zwaveAvailable || zwaveManager.networks.count == 0)

        BusyIndicator {
            anchors.centerIn: parent
            visible: zwaveManager.fetchingData
            running: visible
        }

        EmptyViewPlaceholder {
            visible: !zwaveManager.fetchingData
            width: parent.width - app.margins * 2
            anchors.centerIn: parent
            title: qsTr("Z-Wave")
            text: zwaveManager.zwaveAvailable
                  ? qsTr("There are no Z-Wave networks set up yet. In order to use Z-Wave, create a Z-Wave network.")
                  : qsTr("Z-Wave is not available on this system as no Z-Wave backend is installed.")
            imageSource: "qrc:/icons/z-wave.svg"
            buttonVisible: zwaveManager.zwaveAvailable
            buttonText: qsTr("Add network")
            onButtonClicked: {
                addNetwork()
            }
        }
    }


    ColumnLayout {
        Layout.margins: app.margins / 2
        visible: !zwaveManager.fetchingData && zwaveManager.zwaveAvailable && zwaveManager.networks.count > 0
        Repeater {
            model: zwaveManager.networks
            delegate: BigTile {
                id: networkDelegate
                Layout.fillWidth: true
                interactive: false
                property ZWaveNetwork network: zwaveManager.networks.get(index)

                onClicked: pageStack.push(Qt.resolvedUrl("ZWaveNetworkPage.qml"), { zwaveManager: zwaveManager, network: networkDelegate.network })

                header: RowLayout {
                    Image {
                        source: "qrc:/icons/zwave/z-wave" + (network.isZWavePlus ? "-plus" : "") + "-wide.svg"
                        Layout.preferredHeight: Style.iconSize
                        // ssw : w = ssh : h
                        Layout.preferredWidth: sourceSize.width * height / sourceSize.height
                    }

                    Label {
                        Layout.fillWidth: true
                        text: model.isZWavePlus ? qsTr("Z-Wave Plus network") : qsTr("Z-Wave network")
//                        font: Style.largeFont
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
                                switch (model.networkState) {
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

                    RowLayout {
                        Label {
                            text: qsTr("Adapter:")
                        }

                        Label {
                            Layout.fillWidth: true
                            text: adaptersProxy.count > 0 ? adaptersProxy.get(0).description : ""
                            elide: Text.ElideRight

                            SerialPortsProxy {
                                id: adaptersProxy
                                serialPorts: zwaveManager.serialPorts
                                systemLocationFilter: networkDelegate.network.serialPort
                            }
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        text: offlineNodes.count == 0
                              ? qsTr("%n device(s)", "", Math.max(0, networkDelegate.network.nodes.count - 1)) // -1 for coordinator node
                              : qsTr("%n device(s) (%1 disconnected)", "", Math.max(networkDelegate.network.nodes.count - 1)).arg(offlineNodes.count)

                        ZWaveNodesProxy {
                            id: offlineNodes
                            zwaveNodes: networkDelegate.network.nodes
                            showController: false
                            showOnline: false
                        }
                    }
                }
            }
        }
    }
}

