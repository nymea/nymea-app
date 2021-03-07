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
            onClicked: pageStack.push(Qt.resolvedUrl("ZigbeeAddNetworkPage.qml"), {zigbeeManager: zigbeeManager})
        }
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
                pageStack.push(Qt.resolvedUrl("ZigbeeAddNetworkPage.qml"), {zigbeeManager: zigbeeManager})
            }
        }
    }


    ColumnLayout {
        Layout.margins: app.margins / 2
        Repeater {
            model: zigbeeManager.networks
            delegate: BigTile {
                Layout.fillWidth: true
                interactive: false

                contentItem: ColumnLayout {
                    spacing: app.margins
                    RowLayout {
                        ColorIcon {
                            name: "/ui/images/zigbee/" + model.backend + ".svg"
                            Layout.preferredWidth: app.iconSize
                            Layout.preferredHeight: app.iconSize
                        }

                        Label {
                            Layout.fillWidth: true
                            text: model.backend
                            font.pixelSize: app.largeFont
                        }

                        ProgressButton {
                            Layout.preferredWidth: app.iconSize
                            Layout.preferredHeight: app.iconSize
                            imageSource: "/ui/images/configure.svg"
                            longpressEnabled: false
                            onClicked: pageStack.push(Qt.resolvedUrl("ZigbeeNetworkPage.qml"), { zigbeeManager: zigbeeManager, network: zigbeeManager.networks.get(index) })
                        }
                    }
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
                            Layout.preferredHeight: app.iconSize
                            Layout.preferredWidth: app.iconSize
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
                            Layout.fillWidth: true
                            text: qsTr("Network joining:")
                        }
                        Label {
                            text: model.permitJoiningEnabled ? qsTr("Open for %0 s").arg(model.permitJoiningRemaining) : qsTr("Closed")
                        }
                        ColorIcon {
                            Layout.preferredHeight: app.iconSize
                            Layout.preferredWidth: app.iconSize
                            name: model.permitJoiningEnabled ? "/ui/images/lock-open.svg" : "/ui/images/lock-closed.svg"
                            visible: !model.permitJoiningEnabled
                        }
                        Canvas {
                            id: canvas
                            Layout.preferredHeight: app.iconSize
                            Layout.preferredWidth: app.iconSize
                            rotation: -90
                            visible: model.permitJoiningEnabled

                            property real progress: model.permitJoiningRemaining / model.permitJoiningDuration
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
                        text: model.permitJoiningEnabled ? qsTr("Extend open duration") : qsTr("Open for new devices")
                        enabled: model.networkState === ZigbeeNetwork.ZigbeeNetworkStateOnline
                        onClicked: zigbeeManager.setPermitJoin(model.networkUuid)
                    }
                }
            }
        }
    }
}

