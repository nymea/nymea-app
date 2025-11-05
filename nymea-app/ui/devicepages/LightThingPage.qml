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
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.1
import Nymea 1.0
import QtGraphicalEffects 1.0
import "../components"
import "../utils"

ThingPageBase {
    id: root

    readonly property State powerState: thing.stateByName("power")

    readonly property State brightnessState: thing.stateByName("brightness")
    readonly property ActionType brightnessActionType: thing.thingClass.actionTypes.findByName("brightness");

    readonly property State colorState: thing.stateByName("color")

    readonly property StateType ctStateType: thing.thingClass.stateTypes.findByName("colorTemperature")
    readonly property State ctState: thing.stateByName("colorTemperature")
    readonly property ActionType ctActionType: thing.thingClass.actionTypes.findByName("colorTemperature")

    readonly property int statesCount: (powerState !== null ? 1 : 0) +
                                       (brightnessState !== null ? 1 : 0) +
                                       (ctState !== null ? 1 : 0) +
                                       (colorState !== null ? 1 : 0)

    GridLayout {
        anchors.fill: parent
        anchors.margins: Style.bigMargins
        columns: app.landscape ? root.statesCount : 1
        rowSpacing: Style.bigMargins
        columnSpacing: Style.bigMargins
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
                delegate: ProgressButton {
                    Layout.preferredHeight: Style.hugeIconSize
                    Layout.preferredWidth: Style.hugeIconSize
                    imageSource: "qrc:/icons/lighting/" + model.name + ".svg"
                    longpressEnabled: false
//                    mode: "normal"
//                    backgroundColor: model.color


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

        ColumnLayout {
            spacing: Style.hugeMargins

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: width
                currentIndex: selectionTabs.currentIndex

                Repeater {
                    model: modeModel
                    delegate: Loader {
                        sourceComponent: model.comp
                    }
                }

                Component {
                    id: colorPickerComponent
                    ColorPicker {
                        anchors.fill: parent
                        thing: root.thing
                    }
                }

                Component {
                    id: colorTemperatureComponent
                    ColorTemperaturePicker {
                        anchors.fill: parent
                        thing: root.thing
                        orientation: app.landscape ? Qt.Vertical : Qt.Horizontal
                    }
                }

                Component {
                    id: brightnessComponent
                    Item {
                        id: brightnessController
                        property Thing thing: root.thing
                        readonly property State brightnessState: thing ? thing.stateByName("brightness") : null
                        readonly property State colorState: thing ? thing.stateByName("color") : null
                        readonly property State powerState: thing ? thing.stateByName("power") : null

                        ActionQueue {
                            id: actionQueue
                            thing: brightnessController.thing
                            stateType: thing.thingClass.stateTypes.findByName("brightness")
                        }

                        Rectangle {
                            id: brightnessCircle
                            anchors.centerIn: parent
                            width: Math.min(400, Math.min(parent.width, parent.height))
                            height: width
                            radius: width / 2
                            color: Style.tileBackgroundColor

                        }

                        ShaderEffect {
                            anchors.fill: brightnessCircle
                            property Item source: ShaderEffectSource {
                                id: shaderSource
                                anchors.fill: parent
                                sourceItem: brightnessCircle
                                hideSource: true
                            }
                            property color inColor: Style.tileBackgroundColor
                            property color outColor: powerState.value === true
                                                     ? colorState ? colorState.value :  "#ffd649"
                                                     : Style.tileOverlayColor
                            Behavior on outColor { ColorAnimation { duration: Style.animationDuration } }

                            property real threshold: 0.1
                            property real brightness: 1 - (actionQueue.pendingValue || brightnessState.value) / 100

                            fragmentShader: "
                                varying highp vec2 qt_TexCoord0;
                                uniform sampler2D source;
                                uniform highp vec4 outColor;
                                uniform highp vec4 inColor;
                                uniform lowp float threshold;
                                uniform lowp float qt_Opacity;
                                uniform lowp float brightness;
                                void main() {
                                    bool isOn = qt_TexCoord0.y > brightness;
                                    lowp vec4 sourceColor = texture2D(source, qt_TexCoord0);
                                    if (isOn) {
                                        gl_FragColor = mix(vec4(outColor.rgb, 1.0) * sourceColor.a, sourceColor, step(threshold, distance(sourceColor.rgb / sourceColor.a, inColor.rgb))) * qt_Opacity;
                                    } else {
                                        gl_FragColor = sourceColor;
                                    }
                                }"

                        }

                        MouseArea {
                            anchors.fill: brightnessCircle
                            onMouseYChanged: {
                                var progress = 1 - mouseY / height
                                actionQueue.sendValue(progress * 100);
                            }
                        }
                    }
                }

                Component {
                    id: powerComponent
                    Item {
                        id: powerController
                        property Thing thing: root.thing
                        readonly property State powerState: thing ? thing.stateByName("power") : null


                        ActionQueue {
                            id: actionQueue
                            thing: powerController.thing
                            stateType: thing.thingClass.stateTypes.findByName("power")
                        }

                        CircleBackground {
                            anchors.fill: parent
                            anchors.margins: Style.bigMargins
                            onColor: "#ffd649"
                            iconSource: (actionQueue.pendingValue || powerState.value) === true ? "light-on" : "light-off"
                            on: (actionQueue.pendingValue || powerState.value) === true ? 1 : 0
                            onClicked: {
                                actionQueue.sendValue(!powerState.value)
                            }
                        }
                    }
                }
            }

            ListModel {
                id: modeModel
                Component.onCompleted: {
                    if (root.colorState) {
                        append({modelData: qsTr("Color"), comp: colorPickerComponent})
                    }
                    if (root.ctState) {
                        append({modelData: qsTr("Temperature"), comp: colorTemperatureComponent})
                    }
                    if (root.brightnessState && !root.ctState && !root.colorState) {
                        append({modelData: qsTr("Brightness"), comp: brightnessComponent})
                    }
                    if (!root.colorState && !root.ctState && !root.brightnessState) {
                        append({modelData: qsTr("Power"), comp: powerComponent})
                    }
                }
            }

            SelectionTabs {
                id: selectionTabs
                Layout.fillWidth: true
                model: modeModel
                visible: modeModel.count > 1
            }
        }



        GridLayout {
            id: basicItems
            Layout.fillWidth: !app.landscape
            Layout.fillHeight: app.landscape && (powerButton.visible || brightnessSlider.visible)
            Layout.alignment: Qt.AlignHCenter
            columnSpacing: app.margins
            rowSpacing: app.margins
            columns: app.landscape ? 1 : 2

            ProgressButton {
                id: powerButton
                imageSource: root.powerState.value === true ? "qrc:/icons/light-on.svg" : "qrc:/icons/light-off.svg"
                mode: "normal"
                size: Style.bigIconSize
                longpressEnabled: false
                visible: root.brightnessState || root.ctState || root.colorState
                onClicked: {
                    root.thing.executeAction("power", [{paramName: "power", value: !root.powerState.value}])
                }
            }

            BrightnessSlider {
                id: brightnessSlider
                Layout.fillWidth: orientation == Qt.Horizontal
                Layout.fillHeight: orientation == Qt.Vertical
                Layout.alignment: Qt.AlignHCenter
                thing: root.thing
                orientation: basicItems.columns === 1 ? Qt.Vertical : Qt.Horizontal
                visible: root.brightnessState && (root.ctState || root.colorState)
            }
        }
    }
}
