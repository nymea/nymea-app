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
import "../utils"

ThingPageBase {
    id: root

    readonly property State powerState: thing.stateByName("power")
    readonly property State maxChargingCurrentState: thing.stateByName("maxChargingCurrent")
    readonly property StateType maxChargingCurrentStateType: thing.thingClass.stateTypes.findByName("maxChargingCurrent")
    readonly property State currentPowerState: thing.stateByName("currentPower")
    readonly property State pluggedInState: thing.stateByName("pluggedIn")

    ActionQueue {
        id: actionQueue
        thing: root.thing
        stateName: "power"
    }

    GridLayout {
        anchors.fill: parent
        columns: app.landscape ? 2 : 1

        CircleBackground {
            id: background
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Style.hugeMargins
    //        iconSource: "ev-charger"
            onColor: app.interfaceToColor("evcharger")
    //        on: (actionQueue.pendingValue || powerState.value) === true
            onClicked: {
                PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                actionQueue.sendValue(!root.powerState.value)
            }

            Column {
                anchors.centerIn: parent
                width: background.contentItem.width * .6
                spacing: Style.margins

                Label {
                    font: Style.largeFont
                    text: "%1 %2".arg(root.maxChargingCurrentState.value).arg(Types.toUiUnit(root.maxChargingCurrentStateType.unit))
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    text: qsTr("Maximum charging current")
                    font: Style.smallFont
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }

            Dial {
                anchors.centerIn: parent
                height: background.contentItem.height
                width: background.contentItem.width
                visible: root.maxChargingCurrentState

                thing: root.thing
                stateName: "maxChargingCurrent"
                color: app.interfaceToColor("evcharger")
                on: (actionQueue.pendingValue || powerState.value) === true
            }
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: Style.hugeMargins
            spacing: Style.bigMargins
            Label {
                Layout.fillWidth: true
                property double currentPower: root.currentPowerState.value / (root.currentPowerState.value > 1000 ? 1000 : 1)
                property string unit: root.currentPowerState.value > 1000 ? "kW" : "W"
                font: Style.smallFont
                text: root.pluggedInState.value === false
                      ? qsTr("The car is not plugged in.")
                      : root.powerState.value === true
                        ?  qsTr("Currently charging at %1.").arg('<span style="font-size:' + Style.bigFont.pixelSize + 'px">' + (currentPower.toFixed(1)) + '</span>' + ' ' + unit)
                        : ""

                textFormat: Text.RichText
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            ProgressButton {
                Layout.alignment: Qt.AlignCenter
                imageSource: "system-shutdown"
                mode: "normal"
                size: Style.bigIconSize
                busy: root.currentPowerState.value > 0
                color: (actionQueue.pendingValue || powerState.value) === true ? app.interfaceToColor("evcharger") : Style.iconColor
                onClicked: {
                    PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                    actionQueue.sendValue(!root.powerState.value)
                }
            }
        }

    }
}
