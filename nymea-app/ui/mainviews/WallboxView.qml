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
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtCharts 2.2
import Nymea 1.0
import "../components"
import "../delegates"

MainViewBase {
    id: root

    ThingsProxy {
        id: wallboxDevices
        engine: _engine
        shownInterfaces: ["evcharger"]
    }    

    SwipeView {
        id: swipeView
        anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter
        currentIndex: pageIndicator.currentIndex
        visible: wallboxDevices.count != 0

        Repeater {
            anchors.fill: parent
            anchors.horizontalCenter: parent.horizontalCenter
            model: wallboxDevices

            delegate: Item {
                property Thing thing: wallboxDevices.get(index)
                property State powerState: thing.stateByName("power")
                property State maxChargingCurrentState: thing.stateByName("maxChargingCurrent")

                id: wallboxDelegate
                height: swipeView.height
                width: swipeView.width

                Component.onCompleted: {
                    console.log(thing.name);
                }

                Rectangle {
                    id: one
                    width: swipeView.width
                    height: swipeView.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "green"

                    gradient: Gradient {
                        GradientStop { position: 0; color: "#07203F" }
                        GradientStop { position: 1; color: "#01092A" }
                    }

                    GridLayout {
                        anchors.fill: parent
                        anchors.margins: app.margins
                        anchors.horizontalCenter: parent.horizontalCenter
                        columns: 1
                        rowSpacing: app.margins

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: thing.name
                            color: "white"
                        }

                        Switch {
                            anchors.horizontalCenter: parent.horizontalCenter
                            id: powerSwitch
                            checked: powerState.value
                            onClicked: {
                                console.log(checked)
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Math.round(maxChargingSlider.value) + " " + qsTr("Ampere")
                            color: "white"
                        }

                        Slider {
                            id: maxChargingSlider
                            anchors.horizontalCenter: parent.horizontalCenter
                            Layout.fillWidth: true
                            Layout.leftMargin: parent.width * .05
                            Layout.rightMargin: parent.width * .05
                            from: 6000 / 1000
                            to: 80000 / 1000
                            stepSize: 1
                            snapMode: Slider.SnapAlways
                            value: maxChargingCurrentState.value / 1000
                            onMoved: {
                                console.log(value)
                            }
                        }
                    }
                }
            }
        }
    }

    PageIndicator {
        id: pageIndicator
        count: swipeView.count
        currentIndex: swipeView.currentIndex
        interactive: true
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        visible: !engine.thingManager.fetchingData && wallboxDevices.count == 0
        title: qsTr("There are no wallbox devices set up.")
        text: qsTr("Connect your wallbox devices in order to control them from here.")
        imageSource: "../images/wallbox/wallbox.svg"
        buttonText: qsTr("Add things")
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../thingconfiguration/NewThingPage.qml"))
    }
}
