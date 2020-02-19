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
    readonly property string title: qsTr("Wheel of fortune")
    readonly property string icon: Qt.resolvedUrl("qrc:/ui/images/ventilation.svg")

    readonly property Device motorDevice: motors.count > 0 ? motors.get(0) : null

    readonly property State powerState: motorDevice ? motorDevice.states.getState(motorDevice.deviceClass.stateTypes.findByName("power").id) : null
    readonly property State stateState: motorDevice ? motorDevice.states.getState(motorDevice.deviceClass.stateTypes.findByName("state").id) : null
    readonly property State driveVoltageState: motorDevice ? motorDevice.states.getState(motorDevice.deviceClass.stateTypes.findByName("driveVoltage").id) : null
    readonly property State driveCurrentState: motorDevice ? motorDevice.states.getState(motorDevice.deviceClass.stateTypes.findByName("driveCurrent").id) : null
    readonly property State bemfState: motorDevice ? motorDevice.states.getState(motorDevice.deviceClass.stateTypes.findByName("bemf").id) : null
    readonly property State psiState: motorDevice ? motorDevice.states.getState(motorDevice.deviceClass.stateTypes.findByName("psi").id) : null
    readonly property State voltageState: motorDevice ? motorDevice.states.getState(motorDevice.deviceClass.stateTypes.findByName("voltage").id) : null
    readonly property State currentState: motorDevice ? motorDevice.states.getState(motorDevice.deviceClass.stateTypes.findByName("current").id) : null
    readonly property State torqueState: motorDevice ? motorDevice.states.getState(motorDevice.deviceClass.stateTypes.findByName("torque").id) : null
    readonly property State omegaState: motorDevice ? motorDevice.states.getState(motorDevice.deviceClass.stateTypes.findByName("omega").id) : null
    readonly property State speedState: motorDevice ? motorDevice.states.getState(motorDevice.deviceClass.stateTypes.findByName("speed").id) : null


    //    Connections {
    //        target: engine.deviceManager
    //        onExecuteActionReply: {
    //            print("executeActionReply:", params["id"])
    //            if (params["id"] === d.pendingCallId) {
    //                d.pendingCallId = -1;

    //                // React on action executed here. example:

    ////                if (d.setTempPending) {
    ////                    setTargetTemp(d.queuedTargetTemp)
    ////                }
    //            }
    //        }
    //    }

    //    QtObject {
    //        id: d
    //        property int pendingCallId: -1
    //        property bool setTempPending: false
    //        property real queuedTargetTemp: 0
    //    }

    DevicesProxy {
        id: motors
        engine: _engine
        filterDeviceClassId: "2bbf85fd-9da8-4292-ac06-e131709ea6b6"
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        text: qsTr("There is no motor set up yet.")
        imageSource: "qrc:/ui/images/ventilation.svg"
        buttonVisible: false
        buttonText: qsTr("Set up now")
        visible: motors.count === 0 && !engine.deviceManager.fetchingData
    }

    Item {
        id: mainView
        anchors.fill: parent
        visible: root.motorDevice !== null

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: app.margins

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: app.delegateHeight
                text: qsTr("Play")
                onClicked: {
                    if (!motorDevice)
                        return

                    var deviceId = root.motorDevice.id
                    var actionTypeId = root.motorDevice.deviceClass.actionTypes.findByName("trigger").id
                    print("Execute play", deviceId, actionTypeId)
                    // Maybe check reply
                    engine.deviceManager.executeAction(root.motorDevice.id, actionTypeId)
                }
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: {
                    if (stateState.value === "Idle") {
                        return qsTr("Uninitialized")
                    } else if (stateState.value === "Spinning") {
                        return qsTr("Spinning...")
                    } else if (stateState.value === "You won") {
                        return qsTr("Congratulations! You won!")
                    } else if (stateState.value === "You lost") {
                        return qsTr("Too bad. You lost.")
                    } else {
                        stateImage.rotation = 0
                        return "qrc:/ui/images/ventilation.svg"
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: app.delegateHeight * 5


                RotationAnimation {
                    id: rotate
                    target: stateImage
                    running: stateState.value === "Spinning"
                    duration: 2000
                    loops: RotationAnimation.Infinite
                    from: 0
                    to: 360
                }

                Image {
                    id: stateImage
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: stateImage.width
                    sourceSize.height: stateImage.height
                    source: {
                        if (stateState.value === "Idle") {
                            stateImage.rotation = 0
                            return "qrc:/ui/images/ventilation.svg"
                        } else if (stateState.value === "Spinning") {
                            return "qrc:/ui/images/refresh.svg"
                        } else if (stateState.value === "You won") {
                            stateImage.rotation = 0
                            return "qrc:/ui/experiences/wheeloffortune/1f389.png"
                        } else if (stateState.value === "You lost") {
                            stateImage.rotation = 0
                            return "qrc:/ui/experiences/wheeloffortune/lost.png"
                        } else {
                            stateImage.rotation = 0
                            return "qrc:/ui/images/ventilation.svg"
                        }
                    }
                }
            }

            Label {
                id: torqueStateValue
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Torque") + " " + torqueState.value + " [Nm]"
            }

            Label {
                id: speedStateValue
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Speed") + " " + speedState.value + " [rpm]"
            }
        }
    }
}
