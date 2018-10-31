import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

DeviceListPageBase {
    id: root

    header: GuhHeader {
        text: qsTr("Smart meters")
        onBackPressed: pageStack.pop()
    }

    ListView {
        anchors.fill: parent
        model: root.devicesProxy

        delegate: ItemDelegate {
            id: itemDelegate
            width: parent.width

            property bool inline: width > 500

            property var device: devicesProxy.get(index);
            property var deviceClass: engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);

            bottomPadding: index === ListView.view.count - 1 ? topPadding : 0
            contentItem: Pane {
                id: contentItem
                Material.elevation: 2
                leftPadding: 0
                rightPadding: 0
                topPadding: 0
                bottomPadding: 0

                contentItem: ItemDelegate {
                    leftPadding: 0
                    rightPadding: 0
                    topPadding: 0
                    bottomPadding: 0
                    contentItem: ColumnLayout {
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: app.mediumFont + app.margins
                            color: Qt.rgba(app.foregroundColor.r, app.foregroundColor.g, app.foregroundColor.b, .05)
                            RowLayout {
                                anchors { verticalCenter: parent.verticalCenter; left: parent.left; right: parent.right; margins: app.margins }
                                Label {
                                    Layout.fillWidth: true
                                    text: model.name
                                    elide: Text.ElideRight
                                }
                                ColorIcon {
                                    Layout.preferredHeight: app.iconSize * .5
                                    Layout.preferredWidth: height
                                    name: "../images/battery/battery-020.svg"
                                    visible: itemDelegate.deviceClass.interfaces.indexOf("battery") >= 0 && itemDelegate.device.states.getState(itemDelegate.deviceClass.stateTypes.findByName("batteryCritical").id).value === true
                                }
                                ColorIcon {
                                    Layout.preferredHeight: app.iconSize * .5
                                    Layout.preferredWidth: height
                                    name: "../images/dialog-warning-symbolic.svg"
                                    visible: itemDelegate.deviceClass.interfaces.indexOf("connectable") >= 0 && itemDelegate.device.states.getState(itemDelegate.deviceClass.stateTypes.findByName("connected").id).value === false
                                    color: "red"
                                }
                            }

                        }
                        GridLayout {
                            id: dataGrid
                            columns: Math.floor(contentItem.width / 120)
                            Layout.margins: app.margins
                            Repeater {
                                model: ListModel {
                                    ListElement { interfaceName: "smartmeterproducer"; stateName: "totalEnergyProduced" }
                                    ListElement { interfaceName: "smartmeterconsumer"; stateName: "totalEnergyConsumed" }
                                    ListElement { interfaceName: "extendedsmartmeterproducer"; stateName: "currentPower" }
                                }

                                delegate: RowLayout {
                                    id: sensorValueDelegate
                                    visible: itemDelegate.deviceClass.interfaces.indexOf(model.interfaceName) >= 0
                                    Layout.preferredWidth: contentItem.width / dataGrid.columns

                                    property var stateType: itemDelegate.deviceClass.stateTypes.findByName(model.stateName)
                                    property var stateValue: stateType ? itemDelegate.device.states.getState(stateType.id) : null

                                    ColorIcon {
                                        Layout.preferredHeight: app.iconSize * .8
                                        Layout.preferredWidth: height
                                        Layout.alignment: Qt.AlignVCenter
                                        color: app.interfaceToColor(model.interfaceName)
                                        name: app.interfaceToIcon(model.interfaceName)
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: sensorValueDelegate.stateValue
                                              ? "%1 %2".arg(sensorValueDelegate.stateValue.value).arg(sensorValueDelegate.stateType.unitString)
                                              : ""
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: app.smallFont
                                    }
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
}
