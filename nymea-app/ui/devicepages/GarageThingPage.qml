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
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

DevicePageBase {
    id: root

    readonly property bool landscape: width > height

    readonly property bool isImpulseBased: thing.thingClass.interfaces.indexOf("impulsegaragedoor") >= 0
    readonly property bool isStateful: thing.thingClass.interfaces.indexOf("statefulgaragedoor") >= 0
    readonly property bool isExtended: thing.thingClass.interfaces.indexOf("extendedstatefulgaragedoor") >= 0

    // Stateful garagedoor
    readonly property StateType stateStateType: thing.thingClass.stateTypes.findByName("state")
    readonly property State stateState: stateStateType ? thing.states.getState(stateStateType.id) : null

    // Extended stateful garagedoor
    readonly property StateType percentageStateType: thing.thingClass.stateTypes.findByName("percentage")
    readonly property State percentageState: percentageStateType ? thing.states.getState(percentageStateType.id) : null


    // Backward compatiblity with old garagegate interface
    readonly property StateType intermediatePositionStateType: thing.thingClass.stateTypes.findByName("intermediatePosition")
    readonly property var intermediatePositionState: intermediatePositionStateType ? device.states.getState(intermediatePositionStateType.id) : null

    // Some garages may also implement the light interface
    readonly property var lightStateType: thing.thingClass.stateTypes.findByName("power")
    readonly property var lightState: lightStateType ? thing.states.getState(lightStateType.id) : null

    Component.onCompleted: {
        print("Creating garage page. Impulse based:", isImpulseBased, "stateful:", isStateful, "extended:", isExtended, "legacy:", intermediatePositionState !== null)
    }

    GridLayout {
        anchors.fill: parent
        columns: root.landscape ? 2 : 1

        ColorIcon {
            id: shutterImage
            Layout.preferredWidth: root.landscape ?
                                       Math.min(parent.width - shutterControlsContainer.minimumWidth, parent.height) - app.margins
                                     : Math.min(Math.min(parent.width, 500), parent.height - shutterControlsContainer.minimumHeight)
            Layout.preferredHeight: width
            Layout.alignment: Qt.AlignHCenter
            property string currentImage: {
                if (root.isExtended) {
                    return NymeaUtils.pad(Math.round(root.percentageState.value / 10), 2) + "0"
                }
                if (root.intermediatePositionStateType) {
                    return root.stateState.value === "closed" ? "100"
                            : root.intermediatePositionState.value === false ? "000" : "050"
                }
                return "100"
            }
            name: "../images/garage/garage-" + currentImage + ".svg"

            Item {
                id: arrows
                anchors.centerIn: parent
                width: app.iconSize * 2
                height: parent.height * .6
                clip: true
                visible: root.stateStateType && (root.stateState.value === "opening" || root.stateState.value === "closing")
                property bool up: root.stateState && root.stateState.value === "opening"

                // NumberAnimation doesn't reload to/from while it's running. If we switch from closing to opening or vice versa
                // we need to somehow stop and start the animation
                property bool animationHack: true
                onAnimationHackChanged: {
                    if (!animationHack) hackTimer.start();
                }
                Timer { id: hackTimer; interval: 1; onTriggered: arrows.animationHack = true }
                Connections { target: root.stateState; onValueChanged: arrows.animationHack = false }

                NumberAnimation {
                    target: arrowColumn
                    property: "y"
                    duration: 500
                    easing.type: Easing.Linear
                    from: arrows.up ? app.iconSize : -app.iconSize
                    to: arrows.up ? -app.iconSize : app.iconSize
                    loops: Animation.Infinite
                    running: arrows.animationHack && root.stateState && (root.stateState.value === "opening" || root.stateState.value === "closing")
                }

                Column {
                    id: arrowColumn
                    width: parent.width

                    Repeater {
                        model: arrows.height / app.iconSize + 1
                        ColorIcon {
                            name: arrows.up ? "../images/up.svg" : "../images/down.svg"
                            width: parent.width
                            height: width
                            color: app.accentColor
                        }
                    }
                }
            }
        }

        Item {
            id: shutterControlsContainer
            Layout.fillWidth: true
            Layout.margins: app.margins * 2
            Layout.fillHeight: true
            property int minimumWidth: app.iconSize * 2.5 * (root.lightState ? 4 : 3)
            property int minimumHeight: app.iconSize * 2.5

            ItemDelegate {
                height: app.iconSize * 2
                width: height
                anchors.centerIn: parent
                visible: root.isImpulseBased
                ColorIcon {
                    anchors.fill: parent
                    name: "../images/closable-move.svg"
                    anchors.margins: app.margins
                }
                onClicked: {
                    var actionTypeId = root.thing.thingClass.actionTypes.findByName("triggerImpulse").id
                    print("Triggering impulse", actionTypeId)
                    engine.thingManager.executeAction(root.thing.id, actionTypeId)
                }
            }

            ShutterControls {
                id: shutterControls
                device: root.device
                anchors.centerIn: parent
                spacing: (parent.width - app.iconSize*2*children.length) / (children.length - 1)
                visible: !root.isImpulseBased

                ItemDelegate {
                    width: app.iconSize * 2
                    height: width
                    visible: root.lightStateType !== null

                    ColorIcon {
                        anchors.fill: parent
                        anchors.margins: app.margins
                        name: "../images/light-" + (root.lightState && root.lightState.value === true ? "on" : "off") + ".svg"
                        color: root.lightState && root.lightState.value === true ? Material.accent : keyColor
                    }
                    onClicked: {
                        print("blabla", root.lightState, root.lightState.value, root.lightStateType.name, root.lightState.stateTypeId, root.lightStateType.id)
                        var params = [];
                        var param = {};
                        param["paramTypeId"] = root.lightStateType.id;
                        param["value"] = !root.lightState.value;
                        params.push(param)
                        engine.deviceManager.executeAction(root.device.id, root.lightStateType.id, params)
                    }
                }
            }
        }
    }
}
