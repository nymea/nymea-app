import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import Nymea 1.0
import "../components"

DeviceListPageBase {
    id: root

    property string iconBasename

    property bool invertControls: false

    header: NymeaHeader {
        id: header
        onBackPressed: pageStack.pop()
        text: root.title

        HeaderButton {
            imageSource: root.invertControls ? "../images/down.svg" : "../images/up.svg"
            onClicked: {
                for (var i = 0; i < devicesProxy.count; i++) {
                    var device = devicesProxy.get(i);
                    var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                    var actionType = deviceClass.actionTypes.findByName("open");
                    engine.deviceManager.executeAction(device.id, actionType.id)
                }
            }
        }
        HeaderButton {
            imageSource: "../images/media-playback-stop.svg"
            onClicked: {
                for (var i = 0; i < devicesProxy.count; i++) {
                    var device = devicesProxy.get(i);
                    var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                    var actionType = deviceClass.actionTypes.findByName("stop");
                    engine.deviceManager.executeAction(device.id, actionType.id)
                }
            }
        }
        HeaderButton {
            imageSource: root.invertControls ? "../images/up.svg" : "../images/down.svg"
            onClicked: {
                for (var i = 0; i < devicesProxy.count; i++) {
                    var device = devicesProxy.get(i);
                    var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                    var actionType = deviceClass.actionTypes.findByName("close");
                    engine.deviceManager.executeAction(device.id, actionType.id)
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

            property Device device: devicesProxy.get(index);
            property DeviceClass deviceClass: engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);

            property var connectedStateType: deviceClass.stateTypes.findByName("connected");
            property var connectedState: connectedStateType ? device.states.getState(connectedStateType.id) : null

            property StateType percentageStateType: deviceClass.stateTypes.findByName("percentage");
            property ActionType percentageActionType: deviceClass.actionTypes.findByName("percentage");
            property State percentageState: percentageStateType ? device.states.getState(percentageStateType.id) : null

            property StateType movingStateType: deviceClass.stateTypes.findByName("moving");
            property ActionType movingActionType: deviceClass.actionTypes.findByName("moving");
            property State movingState: movingStateType ? device.states.getState(movingStateType.id) : null

            Material.elevation: 1
            topPadding: 0
            bottomPadding: 0
            leftPadding: 0
            rightPadding: 0
            contentItem: ItemDelegate {
                id: contentItem
                implicitHeight: nameRow.implicitHeight

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

                            ColorIcon {
                                id: icon
                                anchors.fill: parent
                                color: itemDelegate.movingStateType && itemDelegate.movingState.value === true
                                       ? app.accentColor
                                       : keyColor
                                name: itemDelegate.percentageStateType
                                      ? root.iconBasename + "-" + app.pad(Math.round(itemDelegate.percentageState.value / 10) * 10, 3) + ".svg"
                                      : root.iconBasename + "-050.svg"
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            text: itemDelegate.device.name
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        Item {
                            Layout.preferredWidth: shutterControls.implicitWidth
                            Layout.preferredHeight: app.iconSize * 2
                            ShutterControls {
                                id: shutterControls
                                height: parent.height
                                device: itemDelegate.device
                                invert: root.invertControls
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
