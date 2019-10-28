import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

DeviceListPageBase {
    id: root

    header: NymeaHeader {
        text: qsTr("Sensors")
        onBackPressed: pageStack.pop()
    }

    ListView {
        anchors.fill: parent
        model: root.devicesProxy

        delegate: ItemDelegate {
            id: itemDelegate
            width: parent.width

            property bool inline: width > 500

            property Device device: devicesProxy.getDevice(model.id)
            property DeviceClass deviceClass: device.deviceClass

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
                                    ListElement { interfaceName: "temperaturesensor"; stateName: "temperature" }
                                    ListElement { interfaceName: "humiditysensor"; stateName: "humidity" }
                                    ListElement { interfaceName: "moisturesensor"; stateName: "moisture" }
                                    ListElement { interfaceName: "pressuresensor"; stateName: "pressure" }
                                    ListElement { interfaceName: "lightsensor"; stateName: "lightIntensity" }
                                    ListElement { interfaceName: "conductivitysensor"; stateName: "conductivity" }
                                    ListElement { interfaceName: "noisesensor"; stateName: "noise" }
                                    ListElement { interfaceName: "co2sensor"; stateName: "co2" }
                                    ListElement { interfaceName: "daylightsensor"; stateName: "daylight" }
                                    ListElement { interfaceName: "presencesensor"; stateName: "isPresent" }
                                    ListElement { interfaceName: "closablesensor"; stateName: "closed" }
                                    ListElement { interfaceName: "heating"; stateName: "power" }
                                    ListElement { interfaceName: "thermostat"; stateName: "targetTemperature" }
                                }

                                delegate: RowLayout {
                                    id: sensorValueDelegate
                                    visible: itemDelegate.deviceClass.interfaces.indexOf(model.interfaceName) >= 0
                                    Layout.preferredWidth: contentItem.width / dataGrid.columns

                                    property StateType stateType: itemDelegate.deviceClass.stateTypes.findByName(model.stateName)
                                    property State stateValue: stateType ? itemDelegate.device.states.getState(stateType.id) : null

                                    ColorIcon {
                                        Layout.preferredHeight: app.iconSize * .8
                                        Layout.preferredWidth: height
                                        Layout.alignment: Qt.AlignVCenter
                                        color: {
                                            switch (model.interfaceName) {
                                            case "closablesensor":
                                                return sensorValueDelegate.stateValue.value === true ? "green" : "red";
                                            default:
                                                return app.interfaceToColor(model.interfaceName)
                                            }
                                        }
                                        name: {
                                            switch (model.interfaceName) {
                                            case "closablesensor":
                                                return sensorValueDelegate.stateValue.value === true ? Qt.resolvedUrl("../images/lock-closed.svg") : Qt.resolvedUrl("../images/lock-open.svg");
                                            default:
                                                return app.interfaceToIcon(model.interfaceName)
                                            }
                                        }
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: {
                                            switch (model.interfaceName) {
                                            case "closablesensor":
                                                return sensorValueDelegate.stateValue.value === true ? qsTr("is closed") : qsTr("is open");
                                            default:
                                                return sensorValueDelegate.stateType && sensorValueDelegate.stateType.type.toLowerCase() === "bool"
                                                  ? sensorValueDelegate.stateType.displayName
                                                  : sensorValueDelegate.stateValue
                                                    ? "%1 %2".arg(Math.round(sensorValueDelegate.stateValue.value * 100) / 100).arg(sensorValueDelegate.stateType.unitString)
                                                    : ""
                                            }
                                        }
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: app.smallFont
                                    }
                                    Led {
                                        id: led
                                        visible: ["presencesensor", "daylightsensor"].indexOf(model.interfaceName) >= 0
                                        state: visible && sensorValueDelegate.stateValue.value === true ? "on" : "off"
                                    }
                                    Item {
                                        Layout.preferredWidth: led.width
                                        visible: led.visible
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
