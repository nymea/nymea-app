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
import "../components"
import Nymea 1.0

MainViewBase {
    id: root

    readonly property bool landscape: width > height

    DevicesProxy {
        id: garagesFilterModel
        engine: _engine
        shownInterfaces: ["garagedoor", "garagegate"]
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        text: qsTr("There are no garage doors set up yet.")
        imageSource: "qrc:/ui/images/garage/garage-100.svg"
        buttonText: qsTr("Set up now")
        visible: garagesFilterModel.count === 0 && !engine.thingManager.fetchingData
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../thingconfiguration/NewThingPage.qml"))
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent

        Repeater {
            model: garagesFilterModel

            Item {
                id: garageGateView
                width: swipeView.width
                height: swipeView.height

                readonly property Device thing: garagesFilterModel.get(index)


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

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: app.margins
                    anchors.bottomMargin: app.margins

                    Label {
                        Layout.fillWidth: true
                        font.pixelSize: app.largeFont
                        text: garageGateView.thing.name
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }

                    GridLayout {
                        columns: root.landscape ? 2 : 1

                        ColorIcon {
                            id: shutterImage
                            Layout.preferredWidth: root.landscape ?
                                                       Math.min(parent.width - shutterControlsContainer.minimumWidth, parent.height) - app.margins
                                                     : Math.min(Math.min(parent.width, 500), parent.height - shutterControlsContainer.minimumHeight)
                            Layout.preferredHeight: width
                            Layout.alignment: Qt.AlignHCenter
                            property string currentImage: {
                                if (garageGateView.isExtended) {
                                    return app.pad(Math.round(garageGateView.percentageState.value / 10), 2) + "0"
                                }
                                if (garageGateView.intermediatePositionStateType) {
                                    return garageGateView.stateState.value === "closed" ? "100"
                                            : garageGateView.intermediatePositionState.value === false ? "000" : "050"
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
                                visible: garageGateView.stateStateType && (garageGateView.stateState.value === "opening" || garageGateView.stateState.value === "closing")
                                property bool up: garageGateView.stateState && garageGateView.stateState.value === "opening"

                                // NumberAnimation doesn't reload to/from while it's running. If we switch from closing to opening or vice versa
                                // we need to somehow stop and start the animation
                                property bool animationHack: true
                                onAnimationHackChanged: {
                                    if (!animationHack) hackTimer.start();
                                }
                                Timer { id: hackTimer; interval: 1; onTriggered: arrows.animationHack = true }
                                Connections { target: garageGateView.stateState; onValueChanged: arrows.animationHack = false }

                                NumberAnimation {
                                    target: arrowColumn
                                    property: "y"
                                    duration: 500
                                    easing.type: Easing.Linear
                                    from: arrows.up ? app.iconSize : -app.iconSize
                                    to: arrows.up ? -app.iconSize : app.iconSize
                                    loops: Animation.Infinite
                                    running: arrows.animationHack && garageGateView.stateState && (garageGateView.stateState.value === "opening" || garageGateView.stateState.value === "closing")
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
                            property int minimumWidth: app.iconSize * 2.5 * (garageGateView.lightState ? 4 : 3)
                            property int minimumHeight: app.iconSize * 2.5

                            ItemDelegate {
                                height: app.iconSize * 2
                                width: height
                                anchors.centerIn: parent
                                visible: garageGateView.isImpulseBased
                                ColorIcon {
                                    anchors.fill: parent
                                    name: "../images/closable-move.svg"
                                    anchors.margins: app.margins
                                }
                                onClicked: {
                                    var actionTypeId = garageGateView.thing.thingClass.actionTypes.findByName("triggerImpulse").id
                                    print("Triggering impulse", actionTypeId)
                                    engine.thingManager.executeAction(garageGateView.thing.id, actionTypeId)
                                }
                            }

                            ShutterControls {
                                id: shutterControls
                                device: garageGateView.thing
                                anchors.centerIn: parent
                                spacing: (parent.width - app.iconSize*2*children.length) / (children.length - 1)
                                visible: !garageGateView.isImpulseBased

                                ItemDelegate {
                                    width: app.iconSize * 2
                                    height: width
                                    visible: garageGateView.lightStateType !== null

                                    ColorIcon {
                                        anchors.fill: parent
                                        anchors.margins: app.margins
                                        name: "../images/light-" + (garageGateView.lightState && garageGateView.lightState.value === true ? "on" : "off") + ".svg"
                                        color: garageGateView.lightState && garageGateView.lightState.value === true ? Material.accent : keyColor
                                    }
                                    onClicked: {
                                        var params = [];
                                        var param = {};
                                        param["paramTypeId"] = garageGateView.lightStateType.id;
                                        param["value"] = !garageGateView.lightState.value;
                                        params.push(param)
                                        engine.deviceManager.executeAction(garageGateView.device.id, garageGateView.lightStateType.id, params)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    PageIndicator {
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        count: garagesFilterModel.count
        currentIndex: swipeView.currentIndex
    }
}
