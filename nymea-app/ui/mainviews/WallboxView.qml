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
        currentIndex: pageIndicator.currentIndex
        visible: wallboxDevices.count != 0

        Repeater {
            model: wallboxDevices
            delegate: Item {
                id: wallboxDelegate
                height: swipeView.height
                width: swipeView.width

                property Thing thing: wallboxDevices.get(index)
                property State maxChargingCurrentState: thing.stateByName("maxChargingCurrent")
                property StateType maxChargingCurrentStateType: thing.thingClass.stateTypes.findByName("maxChargingCurrent")

                GridLayout {
                    id: gridLayout
                    rows: app.landscape ? 1 : 3
                    columns: app.landscape ? 3 : 1
                    flow: GridLayout.TopToBottom
                    anchors.fill: parent

                    Rectangle {                        
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"

                        Rectangle {
                            id: nameCointainer
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#E3E3E3" // TODO: VK template
                            radius: 20

                            Text {
                                id: thingName
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                text: thing.name
                                color: app.accentColor
                                font.pixelSize: 22

                                Component.onCompleted: {
                                    nameCointainer.width = width * 1.3
                                    nameCointainer.height = height * 2
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"

                        CircularSlider {
                            anchors.fill: parent
                            anchors.centerIn: parent
                            device: thing
                            stateType: maxChargingCurrentStateType
                            showValueLabel: false
                            backgroundImage: "../images/dial_stripes.svg"
                            innerBackgroundImage: "../images/dial_ellipse.svg"
                            handleVisible: true
                            steps: 360
                            maxAngle: 360
                            showMinLabel: false
                            showMaxLabel: false
                            units: qsTr("Ampere")
                            unitLabelColor: "white" // TODO: VK template
                            centerValueLabelColor: "white" // TODO: VK template
                            roundValue: true
                            color: "#78CDC6" // TODO: VK template
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"

                        Image {
                            anchors.centerIn: parent
                            fillMode: Image.PreserveAspectFit
                            source: "../images/audi_e-tron.png"
                            width: app.landscape ? parent.width * .6 : parent.width * .5
                            opacity: .9
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
        title: qsTr("There are no wallboxes set up.")
        text: qsTr("Connect your wallboxes in order to control them from here.")
        imageSource: "../images/ev-charger.svg"
        buttonText: qsTr("Add things")
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../thingconfiguration/NewThingPage.qml"))
    }
}
