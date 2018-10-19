import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import Nymea 1.0
import "../components"

DeviceListPageBase {

    header: GuhHeader {
        text: qsTr("Lights")
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/system-shutdown.svg"
            onClicked: {
                for (var i = 0; i < devicesProxy.count; i++) {
                    var device = devicesProxy.get(i);
                    var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                    var actionType = deviceClass.actionTypes.findByName("power");

                    var params = [];
                    var param1 = {};
                    param1["paramTypeId"] = actionType.paramTypes.get(0).id;
                    param1["value"] = false;
                    params.push(param1)
                    engine.deviceManager.executeAction(device.id, actionType.id, params)
                }
            }
        }
    }

    ListView {
        anchors.fill: parent
        model: devicesProxy
        spacing: app.margins

        delegate: Pane {
            id: itemDelegate
            width: parent.width

            property bool inline: width > 500

            property var device: devicesProxy.get(index);
            property var deviceClass: engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);

            property var connectedStateType: deviceClass.stateTypes.findByName("connected");
            property var connectedState: device.states.getState(connectedStateType.id)

            property var powerStateType: deviceClass.stateTypes.findByName("power");
            property var powerActionType: deviceClass.actionTypes.findByName("power");
            property var powerState: device.states.getState(powerStateType.id)

            property var brightnessStateType: deviceClass.stateTypes.findByName("brightness");
            property var brightnessActionType: deviceClass.actionTypes.findByName("brightness");
            property var brightnessState: brightnessStateType ? device.states.getState(brightnessStateType.id) : null

            property var colorStateType: deviceClass.stateTypes.findByName("color");
            property var colorState: colorStateType ? device.states.getState(colorStateType.id) : null

            Material.elevation: 1
            topPadding: 0
            bottomPadding: 0
            leftPadding: 0
            rightPadding: 0
            contentItem: ItemDelegate {
                id: contentItem
                implicitHeight: itemDelegate.brightnessStateType && !itemDelegate.inline && nameRow.enabled ? nameRow.implicitHeight + sliderRow.implicitHeight : nameRow.implicitHeight
                //                gradient: Gradient {
                //                    GradientStop { position: 0.0; color: "transparent" }
                //                    GradientStop { position: 1.0; color: Qt.rgba(app.foregroundColor.r, app.foregroundColor.g, app.foregroundColor.b, 0.05) }
                //                }


                topPadding: 0

                contentItem: ColumnLayout {
                    spacing: 0
                    RowLayout {
                        enabled: itemDelegate.connectedState === null || itemDelegate.connectedState.value === true
                        id: nameRow
                        z: 2 // make sure the switch in here is on top of the slider, given we cheated a bit and made them overlap
                        spacing: app.margins
                        Item {
                            Layout.preferredHeight: app.iconSize
                            Layout.preferredWidth: height
                            Layout.alignment: Qt.AlignVCenter

//                            DropShadow {
//                                anchors.fill: icon
//                                horizontalOffset: 0
//                                verticalOffset: 0
//                                radius: 2.0
//                                samples: 17
//                                color: app.foregroundColor
//                                source: icon
//                            }

                            Glow {
                                anchors.fill: icon
                                radius: 1
                                samples: 17
                                color: app.foregroundColor
                                source: icon
                            }

                            ColorIcon {
                                id: icon
                                anchors.fill: parent
                                color: itemDelegate.connectedState !== null && itemDelegate.connectedState.value === false ?
                                           "red"
                                         : itemDelegate.colorStateType ? itemDelegate.colorState.value : "#00000000"
                                name: itemDelegate.connectedState !== null && itemDelegate.connectedState.value === false ?
                                          "../images/dialog-warning-symbolic.svg"
                                        : itemDelegate.powerState.value === true ? "../images/light-on.svg" : "../images/light-off.svg"
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            text: model.name
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                        ThrottledSlider {
                            id: inlineSlider
                            visible: contentItem.enabled && itemDelegate.brightnessStateType && itemDelegate.inline
                            from: 0; to: 100
                            value: itemDelegate.brightnessState ?  itemDelegate.brightnessState.value : 0
                            onMoved: {
                                var params = [];
                                var param1 = {};
                                param1["paramTypeId"] = itemDelegate.brightnessActionType.paramTypes.get(0).id;
                                param1["value"] = value;
                                params.push(param1)
                                engine.deviceManager.executeAction(itemDelegate.device.id, itemDelegate.brightnessActionType.id, params)
                            }
                        }
                        Switch {
                            checked: itemDelegate.powerState.value === true
                            onClicked: {
                                var params = [];
                                var param1 = {};
                                param1["paramTypeId"] = itemDelegate.powerActionType.paramTypes.get(0).id;
                                param1["value"] = checked;
                                params.push(param1)
                                engine.deviceManager.executeAction(device.id, itemDelegate.powerActionType.id, params)
                            }
                        }
                    }
                    Item {
                        id: sliderRow
                        Layout.fillWidth: true
                        implicitHeight: outlineSlider.implicitHeight * .6
                        Layout.preferredHeight: implicitHeight

                        ThrottledSlider {
                            id: outlineSlider
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                            visible: nameRow.enabled && itemDelegate.brightnessStateType && !inlineSlider.visible
                            from: 0; to: 100
                            value: itemDelegate.brightnessState ? itemDelegate.brightnessState.value : 0
                            onMoved: {
                                var params = [];
                                var param1 = {};
                                param1["paramTypeId"] = itemDelegate.brightnessActionType.paramTypes.get(0).id;
                                param1["value"] = value;
                                params.push(param1)
                                engine.deviceManager.executeAction(itemDelegate.device.id, itemDelegate.brightnessActionType.id, params)
                            }
                        }
                    }
                }
                onClicked: {
                    enterPage(index, false)
                }
            }
        }
    }
}
