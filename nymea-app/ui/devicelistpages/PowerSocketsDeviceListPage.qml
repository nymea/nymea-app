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

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../delegates"
import QtQuick.Controls.Material 2.1

DeviceListPageBase {
    id: root

    header: NymeaHeader {
        text: qsTr("My %1").arg(app.interfaceToString("powersocket"))

        onBackPressed: {
            pageStack.pop()
        }
    }

    ListView {
        anchors.fill: parent
        model: devicesProxy
        spacing: app.margins

        delegate: Pane {
            id: itemDelegate
            width: parent.width

            property Device device: devicesProxy.getDevice(model.id)
            property DeviceClass deviceClass: device.deviceClass

            property var connectedStateType: deviceClass.stateTypes.findByName("connected");
            property var connectedState: connectedStateType ? device.states.getState(connectedStateType.id) : null

            property var powerStateType: deviceClass.stateTypes.findByName("power");
            property var powerActionType: deviceClass.actionTypes.findByName("power");
            property var powerState: device.states.getState(powerStateType.id)

            Material.elevation: 1
            topPadding: 0
            bottomPadding: 0
            leftPadding: 0
            rightPadding: 0
            contentItem: ItemDelegate {
                id: contentItem
                implicitHeight: nameRow.implicitHeight
                topPadding: 0

                contentItem: ColumnLayout {
                    spacing: 0
                    RowLayout {
                        enabled: itemDelegate.connectedState === null || itemDelegate.connectedState.value === true
                        id: nameRow
                        z: 2 // make sure the switch in here is on top of the slider, given we cheated a bit and made them overlap
                        spacing: app.margins
                        Item {
                            Layout.preferredHeight: app.iconSize
                            Layout.preferredWidth: height
                            Layout.alignment: Qt.AlignVCenter

                            ColorIcon {
                                id: icon
                                anchors.fill: parent
                                color: itemDelegate.connectedState !== null && itemDelegate.connectedState.value === false
                                       ? "red"
                                       : itemDelegate.powerState.value === true ? app.accentColor : keyColor
                                name: itemDelegate.connectedState !== null && itemDelegate.connectedState.value === false ?
                                          "../images/dialog-warning-symbolic.svg"
                                        : app.interfaceToIcon("powersocket")
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            text: model.name
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                        Switch {
                            checked: itemDelegate.powerState.value === true
                            onClicked: {
                                var params = [];
                                var param1 = {};
                                param1["paramTypeId"] = itemDelegate.powerActionType.paramTypes.get(0).id;
                                param1["value"] = checked;
                                params.push(param1)
                                engine.deviceManager.executeAction(device.id, itemDelegate.powerActionType.id, params)
                            }
                        }
                    }
                }
                onClicked: {
                    enterPage(index, false)
                }
            }
        }
    }
}
