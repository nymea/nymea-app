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
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import Nymea 1.0
import "../components"

DeviceListPageBase {
    id: root

    property string iconBasename: "../images/garage/garage"

    header: NymeaHeader {
        id: header
        onBackPressed: pageStack.pop()
        text: root.title
    }

    ListView {
        anchors.fill: parent
        model: devicesProxy
        spacing: app.margins

        delegate: Pane {
            id: itemDelegate
            width: parent.width


            property bool inline: width > 500

            property Device device: devicesProxy.getDevice(model.id)
            property Device thing: device
            property DeviceClass deviceClass: device.deviceClass

            readonly property bool isImpulseBased: device.deviceClass.interfaces.indexOf("impulsegaragedoor") >= 0
            readonly property bool isStateful: device.deviceClass.interfaces.indexOf("statefulgaragedoor") >= 0
                                               || device.deviceClass.interfaces.indexOf("garagegate") >= 0 // garagegate did not inherit garagedoor before 0.23
            readonly property bool isExtended: device.deviceClass.interfaces.indexOf("extendedstatefulgaragedoor") >= 0

            property var connectedStateType: deviceClass.stateTypes.findByName("connected");
            property var connectedState: connectedStateType ? device.states.getState(connectedStateType.id) : null


            property StateType movingStateType: deviceClass.stateTypes.findByName("moving");
            property ActionType movingActionType: deviceClass.actionTypes.findByName("moving");
            property State movingState: movingStateType ? device.states.getState(movingStateType.id) : null

            Material.elevation: 1
            topPadding: 0
            bottomPadding: 0
            leftPadding: 0
            rightPadding: 0
            contentItem: ItemDelegate {
                id: contentItem
                implicitHeight: contentLoader.item.implicitHeight

                topPadding: 0

                contentItem: Loader {
                    id: contentLoader
                    enabled: itemDelegate.connectedState === null || itemDelegate.connectedState.value === true
                    sourceComponent: isImpulseBased ? impulseGaragedoor
                                                    : isExtended ? extendedStatefulGaragedoor
                                                                 : isStateful ? garagedoor
                                                                              : simpleGaragedoor
                    Binding { target: contentLoader.item; property: "device"; value: itemDelegate.device }
                }
                onClicked: {
                    enterPage(index)
                }
            }
        }
    }

    Component {
        id: impulseGaragedoor

        RowLayout {
            id: contentItem
            property Device device: null

            spacing: app.margins
            Item {
                Layout.preferredHeight: app.iconSize
                Layout.preferredWidth: height
                Layout.alignment: Qt.AlignVCenter

                ColorIcon {
                    id: icon
                    anchors.fill: parent
                    name: root.iconBasename + "-100.svg"
                }
            }

            Label {
                Layout.fillWidth: true
                text: contentItem.device.name
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            ItemDelegate {
                Layout.preferredHeight: app.iconSize * 2
                Layout.preferredWidth: height
                ColorIcon {
                    anchors.centerIn: parent
                    height: app.iconSize
                    width: height
                    name: "../images/closable-move.svg"
                }
                onClicked: {
                    var actionTypeId = device.thingClass.actionTypes.findByName("triggerImpulse").id
                    print("Triggering impulse", actionTypeId)
                    engine.thingManager.executeAction(device.id, actionTypeId)
                }
            }
        }
    }

    Component {
        id: simpleGaragedoor

        RowLayout {
            id: contentItem
            spacing: app.margins
            property Device device: null

            Item {
                Layout.preferredHeight: app.iconSize
                Layout.preferredWidth: height
                Layout.alignment: Qt.AlignVCenter

                ColorIcon {
                    id: icon
                    anchors.fill: parent
                    color: keyColor
                    name: root.iconBasename + "-100.svg"
                }
            }

            Label {
                Layout.fillWidth: true
                text: contentItem.device.name
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            Item {
                Layout.preferredWidth: shutterControls.implicitWidth
                Layout.preferredHeight: app.iconSize * 2
                ShutterControls {
                    id: shutterControls
                    height: parent.height
                    device: contentItem.device
                }
            }
        }
    }


    Component {
        id: garagedoor

        RowLayout {
            id: contentItem
            spacing: app.margins
            property Device device: null

            property StateType stateStateType: device.deviceClass.stateTypes.findByName("state")
            property State stateState: stateStateType ? device.states.getState(stateStateType.id) : null
            Item {
                Layout.preferredHeight: app.iconSize
                Layout.preferredWidth: height
                Layout.alignment: Qt.AlignVCenter

                ColorIcon {
                    id: icon
                    anchors.fill: parent
                    color: ["opening", "closing"].indexOf(contentItem.stateState.value) >= 0
                    ? app.accentColor
                    : keyColor
                    name: root.iconBasename + "-100.svg"
                }
            }

            Label {
                Layout.fillWidth: true
                text: contentItem.device.name
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            Item {
                Layout.preferredWidth: shutterControls.implicitWidth
                Layout.preferredHeight: app.iconSize * 2
                ShutterControls {
                    id: shutterControls
                    height: parent.height
                    device: contentItem.device
                }
            }
        }
    }


    Component {
        id: extendedStatefulGaragedoor

        RowLayout {
            id: contentItem
            spacing: app.margins
            property Device device: null

            property StateType stateStateType: device.deviceClass.stateTypes.findByName("state")
            property State stateState: stateStateType ? device.states.getState(stateStateType.id) : null
            
            property StateType percentageStateType: device.deviceClass.stateTypes.findByName("percentage");
            property ActionType percentageActionType: device.deviceClass.actionTypes.findByName("percentage");
            property State percentageState: percentageStateType ? device.states.getState(percentageStateType.id) : null

            Item {
                Layout.preferredHeight: app.iconSize
                Layout.preferredWidth: height
                Layout.alignment: Qt.AlignVCenter

                ColorIcon {
                    id: icon
                    anchors.fill: parent
                    color: ["opening", "closing"].indexOf(contentItem.stateState.value) >= 0
                                    ? app.accentColor
                                    : keyColor
                    name: contentItem.percentageStateType
                          ? root.iconBasename + "-" + app.pad(Math.round(contentItem.percentageState.value / 10) * 10, 3) + ".svg"
                          : root.iconBasename + "-050.svg"
                }
            }

            Label {
                Layout.fillWidth: true
                text: contentItem.device.name
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            Item {
                Layout.preferredWidth: shutterControls.implicitWidth
                Layout.preferredHeight: app.iconSize * 2
                ShutterControls {
                    id: shutterControls
                    height: parent.height
                    device: contentItem.device
                }
            }
        }
    }
}
