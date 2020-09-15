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
    readonly property string title: qsTr("Celsi°s")
    readonly property string icon: Qt.resolvedUrl("qrc:/ui/images/radiator.svg")

    readonly property Device duwWpDevice: duwWpFilterModel.count > 0 ? duwWpFilterModel.get(0) : null
    readonly property Device duwLuDevice: duwLuFilterModel.count > 0 ? duwLuFilterModel.get(0) : null

    readonly property State temperatureState: duwWpDevice ? duwWpDevice.states.getState(duwWpDevice.deviceClass.stateTypes.findByName("temperature").id) : null
    readonly property State targetTemperatureState: duwWpDevice ? duwWpDevice.states.getState(duwWpDevice.deviceClass.stateTypes.findByName("targetTemperature").id) : null
    readonly property State co2LevelState: duwLuDevice ? duwLuDevice.states.getState(duwLuDevice.deviceClass.stateTypes.findByName("co2").id) : null
    readonly property State ventilationModeState: duwLuDevice ? duwLuDevice.states.getState(duwLuDevice.deviceClass.stateTypes.findByName("ventilationMode").id) : null
    readonly property State ventilationLevelState: duwLuDevice ? duwLuDevice.states.getState(duwLuDevice.deviceClass.stateTypes.findByName("activeVentilationLevel").id) : null

    function ventilationModeToSliderValue(ventilationMode) {
        switch (ventilationMode) {
        case "Automatic":
        case "Party":
            return 0
        case "Manual level 0":
            return 0;
        case "Manual level 1":
            return 1;
        case "Manual level 2":
            return 2;
        case "Manual level 3":
            return 3;
        }
        return 0;
    }
    function ventilationModeToUiMode(ventilationMode) {
        switch (ventilationMode) {
        case "Automatic":
            return 0
        case "Party":
            return 1;
        case "Manual level 0":
        case "Manual level 1":
        case "Manual level 2":
        case "Manual level 3":
            return 2;
        }
    }

    function uiModeToVentilationMode(uiMode, sliderValue) {
        switch (uiMode) {
        case 0:
            return "Automatic";
        case 1:
            return "Party";
        case 2:
            return "Manual level " + Math.floor(sliderValue)
        }
    }

    function setVentilationMode(uiModeIndex, sliderIndex) {
        var params =[];
        var param = {};
        param["paramTypeId"] = root.ventilationModeState.stateTypeId
        param["value"] = root.uiModeToVentilationMode(uiModeIndex, sliderIndex)
        params.push(param)
        engine.deviceManager.executeAction(root.duwLuDevice.id, root.ventilationModeState.stateTypeId, params)
    }

    function setTargetTemp(targetTemp) {
        // We don't want to spam with set value calls so we're going to queue them up and only send one at a time
        d.queuedTargetTemp = targetTemp;
        if (d.pendingCallId != -1) {
            d.setTempPending = true;
            return;
        }
        var params = []
        var param = {}
        param["paramTypeId"] = root.targetTemperatureState.stateTypeId
        param["value"] = targetTemp
        params.push(param)
        d.pendingCallId = engine.deviceManager.executeAction(root.duwWpDevice.id, root.targetTemperatureState.stateTypeId, params)
        d.setTempPending = false;
    }

    Connections {
        target: engine.deviceManager
        onExecuteActionReply: {
            print("executeActionReply:", commandId)
            if (commandId === d.pendingCallId) {
                d.pendingCallId = -1;
                if (d.setTempPending) {
                    setTargetTemp(d.queuedTargetTemp)
                }
            }
        }
    }

    QtObject {
        id: d
        property int pendingCallId: -1
        property bool setTempPending: false
        property real queuedTargetTemp: 0
    }

    DevicesProxy {
        id: duwWpFilterModel
        engine: _engine
        filterDeviceClassId: "e548f962-92db-4110-8279-10fbcde35f93"
    }

    DevicesProxy {
        id: duwLuFilterModel
        engine: _engine
        filterDeviceClassId: "0de8e21e-392a-4790-a78a-b1a7eaa7571b"
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        text: qsTr("There is no drexel und weiss heating system set up yet.")
        imageSource: "qrc:/ui/images/radiator.svg"
        buttonVisible: false
        buttonText: qsTr("Set up now")
        visible: duwWpFilterModel.count === 0 && !engine.deviceManager.fetchingData
    }


    Item {
        id: mainView
        anchors.fill: parent
        visible: root.duwWpDevice !== null

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: app.margins

            ColumnLayout {

                Label {
                    text: qsTr("Current air quality")
                    font.pixelSize: app.smallFont
                }

                RowLayout {
                    spacing: app.margins
                    ColorIcon {
                        Layout.preferredHeight: app.iconSize
                        Layout.preferredWidth: app.iconSize
                        name: "qrc:/ui/images/weathericons/wind.svg"
                        color: app.accentColor
                    }
                    Led {
                        state: {
                            if (!root.co2LevelState) {
                                return "off"
                            }
                            if (root.co2LevelState.value < 600) {
                                return "green"
                            }
                            if (root.co2LevelState.value < 1200) {
                                return "orange"
                            }
                            return "red"
                        }
                    }
                }

                Label {
                    text: qsTr("Current temperature")
                    font.pixelSize: app.smallFont
                }

                RowLayout {
                    ColorIcon {
                        Layout.preferredHeight: app.iconSize
                        Layout.preferredWidth: app.iconSize
                        name: "qrc:/ui/images/sensors/temperature.svg"
                        color: app.accentColor
                    }
                    Label {
                        text: root.temperatureState ? root.temperatureState.value.toFixed(1) + "°C" : "N/A"
                        Layout.fillWidth: true
                        font.pixelSize: app.largeFont * 1.5
                    }
                }
            }

            ColumnLayout {

                Label {
                    text: qsTr("Temperature, °C")
                    font.pixelSize: app.largeFont
                }
                Label {
                    text: (d.pendingCallId !== -1 || d.setTempPending) ? d.queuedTargetTemp.toFixed(1) :
                        root.targetTemperatureState ? root.targetTemperatureState.value.toFixed(1) : "N/A"
                    font.pixelSize: app.largeFont * 3
                }
            }


            ColumnLayout {
                Layout.fillWidth: false
                Layout.bottomMargin: app.margins
                ColorIcon {
                    Layout.preferredHeight: app.iconSize //* 1.5
                    Layout.preferredWidth: height
                    Layout.alignment: Qt.AlignHCenter
                    color: app.accentColor
                    name: "qrc:/ui/images/magic.svg"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: pageStack.push("qrc:/ui/magic/DeviceRulesPage.qml", {device: root.duwWpDevice})
                    }
                }
                Label {
                    text: qsTr("Automate this thing")
                    color: app.accentColor
                    font.pixelSize: app.smallFont
                }
            }

            ColumnLayout {

                RowLayout {
                    Layout.leftMargin: parent.width * .05
                    Layout.rightMargin: parent.width * .2
                    spacing: app.margins
                    ColorIcon {
                        Layout.preferredHeight: app.iconSize
                        Layout.preferredWidth: app.iconSize
                        color: app.accentColor
                        name: "qrc:/ui/images/ventilation.svg"
                        PropertyAnimation on rotation {
                            running: root.ventilationLevelState !== null
                            duration: root.ventilationLevelState !== null && root.ventilationLevelState.value > 0
                                      ? 2000 / root.ventilationLevelState.value
                                      : 0
                            from: 0
                            to: 360
                            loops: Animation.Infinite
                            onDurationChanged: {
                                running = false;
                                running = true;
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.maximumHeight: app.iconSize
                        spacing: 0

                        Repeater {
                            model: ListModel {
                                ListElement { text: qsTr("Auto") }
                                ListElement { text: qsTr("Party") }
                                ListElement { text: qsTr("Manual") }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                border.width: 1
                                border.color: app.accentColor
                                color: root.ventilationModeState && root.ventilationModeToUiMode(root.ventilationModeState.value) === index ? app.accentColor : "transparent"
                                Label {
                                    anchors.centerIn: parent
                                    text: model.text
                                    font.pixelSize: app.smallFont
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        root.setVentilationMode(index, ventilationSlider.value)
                                    }
                                }
                            }
                        }
                    }
                }

                Slider {
                    id: ventilationSlider
                    Layout.fillWidth: true
                    Layout.leftMargin: parent.width * .05
                    Layout.rightMargin: parent.width * .05
                    from: 0
                    to: 3
                    stepSize: 1
                    live: false
                    snapMode: Slider.SnapAlways
                    enabled: root.ventilationModeState && root.ventilationModeToUiMode(root.ventilationModeState.value) === 2
                    opacity: enabled ? 1 : .2
                    value: root.ventilationModeState ? root.ventilationModeToSliderValue(root.ventilationModeState.value) : 0
                    onMoved: root.setVentilationMode(2, valueAt(visualPosition))
                }
            }


//            ProgressButton {
//                imageSource: "qrc:/ui/images/system-shutdown.svg"
//                Layout.preferredHeight: app.iconSize * 1.5
//                Layout.preferredWidth: height
//                Layout.alignment: Qt.AlignHCenter
//            }

//            Label {
//                text: qsTr("Hold to turn off")
//                font.pixelSize: app.smallFont
//                Layout.fillWidth: true
//                horizontalAlignment: Text.AlignHCenter
//            }
        }

        Item {
            height: parent.height * .85
            width: height
            anchors.left: parent.right
            anchors.leftMargin: -width * .25
            anchors.top: parent.top
            anchors.topMargin: -height * .05
            z: -1

            Rectangle {
                id: outerRadius
                anchors.fill: parent
                radius: width / 2
                border.width: 3
                color: "transparent"
                border.color: app.accentColor
            }

            Glow {
                anchors.fill: parent
                source: outerRadius
//                color: "#f45b69"
                color: Qt.rgba(app.accentColor.r, app.accentColor.g, app.accentColor.b, .5)
                radius: 8
                samples: 17
                spread: 0.5
            }

            Rectangle {
                id: innerRadius
                anchors.fill: parent
                anchors.margins: parent.width * .02
                radius: width / 2
                border.width: 2
                color: "transparent"
                border.color: app.accentColor

                Repeater {
                    id: ticksRepeater
                    model: 180

                    Item {
                        height: isBold ? 3 : 2
                        width: parent.width - 2
                        anchors.centerIn: parent
                        rotation: index * 360 / ticksRepeater.count
                        readonly property int isBold: index % 10 === 0
//                        Rectangle  { anchors.fill: parent; color: "blue" }

                        Rectangle { height: parent.height; width: parent.isBold ? 20 : 10; color: app.accentColor }

                    }
                }

            }

            MouseArea {
                anchors.fill: parent
                preventStealing: true

                property real startAnglePress
                property real startAngleDial
                property real startTemp

                property real lastValue

                onPressed: {
                    startAnglePress = calculateAngle(mouseX, mouseY)
                    startAngleDial = innerRadius.rotation
                    startTemp = root.targetTemperatureState.value
                    lastValue = startTemp

                    print("angle:", calculateAngle(mouseX, mouseY))
                }

                onPositionChanged: {
                    var currentAngle = calculateAngle(mouseX, mouseY)
                    var angleDiff = currentAngle - startAnglePress

                    var tempDiff = Math.round(angleDiff / 2) / 10
                    var newTemp = startTemp + tempDiff

                    innerRadius.rotation = startAngleDial + angleDiff

                    if (lastValue.toFixed(1) === newTemp.toFixed(1)) {
                        return;
                    }
                    lastValue = newTemp

                    print("degree value changed", newTemp, lastValue)
                    PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                    root.setTargetTemp(newTemp);
                }

                function calculateAngle(mouseX, mouseY) {
                    // transform coords to center of dial
                    mouseX -= width / 2
                    mouseY -= height / 2

                    var rad = Math.atan(mouseY / mouseX);
                    var angle = rad * 180 / Math.PI

                    angle += 90;

                    if (mouseX < 0 && mouseY >= 0) angle = 180 + angle;
                    if (mouseX < 0 && mouseY < 0) angle = 180 + angle;

                    return angle;
                }
            }
        }
    }
}
