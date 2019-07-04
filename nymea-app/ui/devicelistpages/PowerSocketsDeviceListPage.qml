import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../delegates"
import QtQuick.Controls.Material 2.1

DeviceListPageBase {
    id: root

    header: NymeaHeader {
        text: qsTr("My %1").arg(app.interfaceToString("powersocket"))

        onBackPressed: {
            pageStack.pop()
        }
    }

    ListView {
        anchors.fill: parent
        model: devicesProxy
        spacing: app.margins

        delegate: Pane {
            id: itemDelegate
            width: parent.width

            property var device: devicesProxy.get(index);
            property var deviceClass: engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);

            property var connectedStateType: deviceClass.stateTypes.findByName("connected");
            property var connectedState: connectedStateType ? device.states.getState(connectedStateType.id) : null

            property var powerStateType: deviceClass.stateTypes.findByName("power");
            property var powerActionType: deviceClass.actionTypes.findByName("power");
            property var powerState: device.states.getState(powerStateType.id)

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
                                color: itemDelegate.connectedState !== null && itemDelegate.connectedState.value === false
                                       ? "red"
                                       : itemDelegate.powerState.value === true ? app.accentColor : keyColor
                                name: itemDelegate.connectedState !== null && itemDelegate.connectedState.value === false ?
                                          "../images/dialog-warning-symbolic.svg"
                                        : app.interfaceToIcon("powersocket")
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            text: model.name
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
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
                }
                onClicked: {
                    enterPage(index, false)
                }
            }
        }
    }
}
