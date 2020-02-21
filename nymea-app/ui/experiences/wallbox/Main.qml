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

import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import "qrc:/ui/components"
import Nymea 1.0
import QtGraphicalEffects 1.0

Item {
    id: root
    readonly property string title: qsTr("Wallbox")
    readonly property string icon: Qt.resolvedUrl("qrc:/ui/images/battery/battery-050.svg")

    readonly property Device wallboxDevice: wallboxModel.count > 0 ? wallboxModel.get(0) : null

    readonly property StateType powerStateType: wallboxDevice ? wallboxDevice.deviceClass.stateTypes.findByName("power") : null
    readonly property State powerState: powerStateType ? wallboxDevice.states.getState(powerStateType.id) : null

    readonly property StateType plugStateType: wallboxDevice ? wallboxDevice.deviceClass.stateTypes.findByName("plugState") : null
    readonly property State plugState: plugStateType ? wallboxDevice.states.getState(plugStateType.id) : null

    readonly property StateType currentStateType: wallboxDevice ? wallboxDevice.deviceClass.stateTypes.findByName("current") : null
    readonly property State currentState: currentStateType ? wallboxDevice.states.getState(currentStateType.id) : null

    readonly property StateType powerConsumptionStateType: wallboxDevice ? wallboxDevice.deviceClass.stateTypes.findByName("powerConsumption") : null
    readonly property State powerConsumptionState: powerConsumptionStateType ? wallboxDevice.states.getState(powerConsumptionStateType.id) : null

    readonly property StateType presentEnergyStateType: wallboxDevice ? wallboxDevice.deviceClass.stateTypes.findByName("EP") : null
    readonly property State presentEnergyState: presentEnergyStateType ? wallboxDevice.states.getState(presentEnergyStateType.id) : null

    readonly property StateType sessionTimeStateType: wallboxDevice ? wallboxDevice.deviceClass.stateTypes.findByName("sessionTime") : null
    readonly property State sessionTimeState: sessionTimeStateType ? wallboxDevice.states.getState(sessionTimeStateType.id) : null

    readonly property bool isCharging: powerConsumptionState && powerConsumptionState.value > 0

    DevicesProxy {
        id: wallboxModel
        engine: _engine
        filterDeviceClassId: "900dacec-cae7-4a37-95ba-501846368ea2"
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        text: qsTr("There is no drexel und weiss heating system set up yet.")
        imageSource: "qrc:/ui/images/radiator.svg"
        buttonVisible: false
        buttonText: qsTr("Set up now")
        visible: wallboxModel.count === 0 && !engine.deviceManager.fetchingData
    }


    Item {
        id: mainView
        anchors.fill: parent
        visible: root.wallboxDevice !== null

        GridLayout {
            anchors.fill: parent
            anchors.margins: app.margins
            columns: app.landscape ? 2 : 1

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Rectangle {
                    height: Math.min(parent.height * .5, parent.width * .5)
                    width: height
                    radius: height / 2
                    color: root.powerState && root.powerState.value === true ? app.accentColor : app.foregroundColor
                    anchors.centerIn: parent

                    Label {
                        anchors.centerIn: parent
                        font.pixelSize: app.largeFont
                        text: root.powerState && root.powerState.value === true ? "STOP" : "START"
                        color: root.powerState && root.powerState.value === true ? app.foregroundColor : app.accentColor
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            print("executing power action with param", !root.powerState.value)
                            var params = []
                            var param = {}
                            param["paramTypeId"] = root.powerStateType.id;
                            param["value"] = !root.powerState.value;
                            params.push(param)
                            engine.deviceManager.executeAction(wallboxDevice.id, root.powerStateType.id, params)
                        }
                    }
                }
            }

            Item {
                id: batteryContainer
                Layout.fillHeight: true
                Layout.fillWidth: true

                Column {
                    anchors.centerIn: parent
                    spacing: app.margins

                    ColorIcon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: Math.min(batteryContainer.height / 2, batteryContainer.width / 2)
                        width: height
                        name: "../images/battery/battery-" + app.pad(progress, 2) + "0.svg"
                        rotation: -90
                        color: keyColor

                        property int progress: 0
                        Timer {
                            id: chargingAnimationTimer
                            interval: 1000
                            repeat: true
                            running: root.isCharging
                            onTriggered: {
                                if (parent.progress == 10) {
                                    parent.progress = 1;
                                } else {
                                    parent.progress++;
                                }
                            }
                        }

                        ColorIcon {
                            anchors.centerIn: parent
                            name: "../images/dialog-error-symbolic.svg"
                            visible: root.plugState.value === "Unplugged"
                            height: parent.height / 2
                            width: height
                            color: "red"
                        }
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.sessionTimeState ?
                                  (root.sessionTimeState.value / 60 / 60) + ":" + app.pad((root.sessionTimeState.value / 60) % 60, 2) + ":" + app.pad(root.sessionTimeState.value % 60, 2) : ""
                        font.pixelSize: app.largeFont
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: (root.presentEnergyState ? root.presentEnergyState.value : "0") + " kW/h"
                    }
                }
            }
        }
    }
}
