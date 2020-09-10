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

    Rectangle {
        anchors.fill: parent
        color: app.foregroundColor

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

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            Layout.alignment: Qt.AlignCenter
                            Layout.preferredWidth: thingName.width * 1.5
                            Layout.preferredHeight: thingName.height * 2
                            Layout.topMargin: app.margins * 4
                            Layout.bottomMargin: app.margins
                            radius: 20
                            color: app.accentColor

                            Text {
                                id: thingName
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                text: thing.name
                            }
                        }

                        Rectangle {
                            Layout.alignment: Qt.AlignCenter
                            Layout.preferredWidth: parent.width
                            Layout.preferredHeight: swipeView.height * 0.6

                            CircularSlider {
                                id: maxChargingCurrentStateDial
                                width: parent.width * 0.8
                                height: parent.height * 0.8
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                Layout.alignment: Qt.AlignCenter
                                Layout.rowSpan: app.landscape ? 3 : 1
                                device: thing
                                stateType: maxChargingCurrentStateType
                                showValueLabel: false

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    id: maxChargingCurrentStateText
                                    text: Math.round(maxChargingCurrentState.value / 1000) + " " + qsTr("Ampere")
                                    font: app.font
                                }
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
        title: qsTr("There are no wallboxes set up.")
        text: qsTr("Connect your wallboxes in order to control them from here.")
        imageSource: "../images/ev-charger.svg"
        buttonText: qsTr("Add things")
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../thingconfiguration/NewThingPage.qml"))
    }
}
