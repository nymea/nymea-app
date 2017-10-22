import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.1
import Guh 1.0
import "components"

Page {
    id: root

    header: GuhHeader {
        text: "My things"
        backButtonVisible: false

        HeaderButton {
            imageSource: "images/add.svg"
            onClicked: pageStack.push(Qt.resolvedUrl("NewDeviceWizard.qml"))
        }
    }

    function interfaceToString(name) {
        switch(name) {
        case "light":
            return "Lighting"
        case "weather":
            return "Weather"
        case "sensor":
            return "Sensor"
        case "media":
            return "Media"
        }
    }

    SwipeView {
        anchors.fill: parent
        clip: true

        Item {
            GridView {
                id: interfacesGridView
                anchors.fill: parent
                anchors.margins: app.margins

                model: InterfacesModel {
                    id: interfacesModel
                    devices: Engine.deviceManager.devices
                    shownInterfaces: ["light", "weather", "sensor", "media"]
                }

                cellWidth: {
                    if (count < 6) {
                        return (interfacesGridView.width - spacing) / 2
                    }
                    return (interfacesGridView.width - spacing * 2) / 3
                }
                cellHeight: cellWidth
                delegate: Item {
                    width: interfacesGridView.cellWidth
                    height: interfacesGridView.cellHeight
                    Pane {
                        anchors.fill: parent
                        anchors.margins: app.margins
//                        color: "#22000000"
                        Material.elevation: 2
                        Label {
                            anchors.centerIn: parent
                            text: root.interfaceToString(model.name)
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                print("kkkkklick", model.name)
                                var page;
                                switch (model.name) {
                                case "light":
                                    page = lightsPageComponent;
                                    break;
                                default:
                                    page = subPageComponent
                                }

                                pageStack.push(page, {filterInterface: model.name})
                            }
                        }
                    }
                }
            }
        }

        Item {
            GridView {
                id: gridView
                anchors.fill: parent
                anchors.margins: app.margins

                model: DevicesBasicTagsModel {
                    id: devicesBasicTagsModel
                    devices: Engine.deviceManager.devices
                    hideSystemTags: true
                }

                cellWidth: {
                    if (count < 6) {
                        return (gridView.width - spacing) / 2
                    }
                    return (gridView.width - spacing * 2) / 3
                }
                cellHeight: cellWidth
                delegate: Item {
                    width: gridView.cellWidth
                    height: gridView.cellHeight
                    Pane {
                        anchors.fill: parent
                        anchors.margins: app.margins
//                        color: "#22000000"
                        Material.elevation: 2
                        Label {
                            anchors.centerIn: parent
                            text: model.tagLabel

                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                pageStack.push(subPageComponent, {filterTag: model.tag})
                            }
                        }
                    }
                }
            }
        }
        ListView {
            model: Engine.deviceManager.devices
            delegate: ItemDelegate {
                width: parent.width
                Label {
                    anchors { fill: parent; leftMargin: app.margins; rightMargin: app.margins }
                    text: model.name
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    Component {
        id: lightsPageComponent


        Page {
            property alias filterInterface: devicesProxy.filterInterface
            header: GuhHeader {
                text: "Lights"
                onBackPressed: pageStack.pop()
            }
            ColumnLayout {
                anchors.fill: parent
                RowLayout {
                    Layout.fillWidth: true
                    Layout.margins: 10
                    Label {
                        text: "All"
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "off"
                        onClicked: {
                            for (var i = 0; i < devicesProxy.count; i++) {
                                var device = devicesProxy.get(i);
                                var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                                var actionType = deviceClass.actionTypes.findByName("power");

                                var params = [];
                                var param1 = {};
                                param1["paramTypeId"] = actionType.paramTypes.get(0).id;
                                param1["value"] = checked;
                                params.push(param1)
                                Engine.jsonRpcClient.executeAction(device.id, actionType.id, params)


                            }
                        }
                    }
                }

                ListView {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    model: DevicesProxy {
                        id: devicesProxy
                        devices: Engine.deviceManager.devices
                    }

                    delegate: ItemDelegate {
                        width: parent.width
                        height: childrenRect.height
                        property var device: devicesProxy.get(index);
                        property var deviceClass: Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);

                        ColumnLayout {
                            anchors { left: parent.left; right: parent.right; top: parent.top }
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.margins: 10
                                Label {
                                    Layout.fillWidth: true
                                    text: model.name
                                    verticalAlignment: Text.AlignVCenter
                                }
                                Slider {
                                    visible: model.interfaces.indexOf("dimmablelight") >= 0
                                    property var stateType: deviceClass.stateTypes.findByName("brightnes");
                                    property var actionType: deviceClass.actionTypes.findByName("brightness");
                                    from: 0; to: 100
                                    value: device.stateValue(stateType.id)
                                    onValueChanged: {
                                        if (pressed) {
                                            var params = [];
                                            var param1 = {};
                                            param1["paramTypeId"] = actionType.paramTypes.get(0).id;
                                            param1["value"] = value;
                                            params.push(param1)
                                            Engine.jsonRpcClient.executeAction(device.id, actionType.id, params)
                                        }
                                    }
                                }
                                Switch {
                                    property var stateType: deviceClass.stateTypes.findByName("power");
                                    property var actionType: deviceClass.actionTypes.findByName("power");
                                    checked: device.stateValue(stateType.id) === true
                                    onClicked: {
                                        var params = [];
                                        var param1 = {};
                                        param1["paramTypeId"] = actionType.paramTypes.get(0).id;
                                        param1["value"] = checked;
                                        params.push(param1)
                                        Engine.jsonRpcClient.executeAction(device.id, actionType.id, params)
                                    }

                                }
                            }
                        }


                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("DevicePage.qml"), {device: devicesProxy.get(index)})
                        }
                    }

                }
            }
        }
    }

    Component {
        id: subPageComponent
        Page {
            id: subPage
            property alias filterTag: devicesProxy.filterTag
            property alias filterInterface: devicesProxy.filterInterface

            header: GuhHeader {
                text: {
                    if (subPage.filterTag != DeviceClass.BasicTagNone) {
                        return qsTr("My %1 things").arg(devicesBasicTagsModel.basicTagToString(subPage.filterTag))
                    } else if (subPage.filterInterface.length > 0) {
                        return qsTr("My %1 things").arg(root.interfaceToString(subPage.filterInterface))
                    }
                    return qsTr("All my things")
                }

                onBackPressed: pageStack.pop()
            }

            ListView {
                anchors.fill: parent
                model: DevicesProxy {
                    id: devicesProxy
                    devices: Engine.deviceManager.devices
                }
                delegate: ItemDelegate {
                    width: parent.width
                    Label {
                        anchors { fill: parent; leftMargin: app.margins; rightMargin: app.margins }
                        text: model.name
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("DevicePage.qml"), {device: devicesProxy.get(index)})
                    }
                }
            }
        }
    }
}
