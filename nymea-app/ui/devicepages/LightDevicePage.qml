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

import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.1
import Nymea 1.0
import QtGraphicalEffects 1.0
import "../components"

ThingPageBase {
    id: root

    readonly property State powerState: thing.stateByName("power")

    readonly property State brightnessState: thing.stateByName("brightness")
    readonly property ActionType brightnessActionType: thingClass.actionTypes.findByName("brightness");

    readonly property State colorState: thing.stateByName("color")

    readonly property StateType ctStateType: thingClass.stateTypes.findByName("colorTemperature")
    readonly property State ctState: thing.stateByName("colorTemperature")
    readonly property ActionType ctActionType: thingClass.actionTypes.findByName("colorTemperature")

    readonly property int statesCount: (powerState !== null ? 1 : 0) +
                                       (brightnessState !== null ? 1 : 0) +
                                       (ctState !== null ? 1 : 0) +
                                       (colorState !== null ? 1 : 0)

    GridLayout {
        anchors.fill: parent
        anchors.margins: app.margins
        columns: app.landscape ? root.statesCount : 1
        rowSpacing: app.margins
        columnSpacing: app.margins
        Layout.alignment: Qt.AlignCenter

        GridLayout {
            Layout.fillHeight: true
            Layout.fillWidth: !app.landscape
            columnSpacing: app.margins
            rowSpacing: app.margins
            Layout.alignment: Qt.AlignHCenter
            visible: root.ctStateType !== null
            columns: app.landscape ? 1 : 4

            Repeater {
                model: ListModel {
                    ListElement { name: "activate"; ct: "0"; bri: 100; color: "#00c5ff" }
                    ListElement { name: "concentrate"; ct: "23"; bri: 100; color: "#3dddff" }
                    ListElement { name: "reading"; ct: "57"; bri: 100; color: "#f4de00" }
                    ListElement { name: "relax"; ct: "95" ; bri: 55; color: "#ffaf2a"}
                }
                delegate: Item {
                    Layout.preferredWidth: app.hugeIconSize
                    Layout.preferredHeight: app.hugeIconSize
                    Layout.fillWidth: true
                    Layout.fillHeight: app.landscape
                    ItemDelegate {
                        height: app.hugeIconSize
                        width: height
                        anchors.centerIn: parent

                        leftPadding: 0
                        rightPadding: 0
                        topPadding: 0
                        bottomPadding: 0

                        contentItem: Rectangle {
                            color: model.color
                            radius: Style.tileRadius

                            ColorIcon {
                                anchors.fill: parent
                                name: "../images/lighting/" + model.name + ".svg"
                                color: "white"
                            }
                        }


                        onClicked: {
                            // Translate from % to absolute value in min/max
                            // % : 100 = abs : (max - min)
                            print("min,max", root.ctStateType, root.ctStateType.minValue, root.ctStateType.maxValue)
                            var absoluteCtValue = (model.ct * (root.ctStateType.maxValue - root.ctStateType.minValue) / 100) + root.ctStateType.minValue
                            var params = [];
                            var param1 = {};
                            param1["paramName"] = root.ctActionType.paramTypes.get(0).name;
                            param1["value"] = absoluteCtValue;
                            params.push(param1)
                            root.thing.executeAction(root.ctActionType.name, params)
                            params = [];
                            param1 = {};
                            param1["paramName"] = root.brightnessActionType.paramTypes.get(0).name;
                            param1["value"] = model.bri;
                            params.push(param1)
                            root.thing.executeAction(root.brightnessActionType.name, params)
                        }
                    }
                }
            }
        }

        ColorPicker {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: width
            thing: root.thing
            visible: root.thing.thingClass.stateTypes.findByName("color") !== null
        }

        ColorTemperaturePicker {
            Layout.fillWidth: !app.landscape
            Layout.fillHeight: app.landscape
            thing: root.thing
            orientation: app.landscape ? Qt.Vertical : Qt.Horizontal
            visible: root.thing.thingClass.stateTypes.findByName("colorTemperature") !== null
        }

        GridLayout {
            id: basicItems
            Layout.fillWidth: !app.landscape
            Layout.fillHeight: app.landscape
            Layout.alignment: Qt.AlignHCenter
            columnSpacing: app.margins
            rowSpacing: app.margins
            columns: (app.landscape && (root.colorState !== null && root.ctState !== null))
                     || (!app.landscape && (root.colorState === null && root.ctState === null)) ? 1 : 2
            Rectangle {
                Layout.preferredWidth: app.hugeIconSize
                Layout.preferredHeight: width
                radius: Style.tileRadius
                color: root.colorState ? root.colorState.value : "red"
//                color: Qt.tint(Style.backgroundColor, Qt.rgba(Style.foregroundColor.r, Style.foregroundColor.g, Style.foregroundColor.b, 0.1))
                ColorIcon {
                    anchors.centerIn: parent
                    height: app.largeIconSize
                    width: height
                    name: root.powerState.value === true ? "../images/light-on.svg" : "../images/light-off.svg"
                    color: root.colorState ?
                               NymeaUtils.isDark(root.colorState.value) ? "white" : "black" : "white"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.thing.executeAction("power", [{paramName: "power", value: !root.powerState.value}])
                    }
                }
            }

            BrightnessSlider {
                Layout.fillWidth: orientation == Qt.Horizontal
                Layout.fillHeight: orientation == Qt.Vertical
                thing: root.thing
                orientation: basicItems.columns === 1 ? Qt.Vertical : Qt.Horizontal
                visible: root.thing.stateByName("brightness") !== null
            }
        }
    }
}
