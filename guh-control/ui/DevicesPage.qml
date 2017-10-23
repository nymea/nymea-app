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
                        Material.elevation: 1
                        Column {
                            anchors.centerIn: parent
                            spacing: app.margins
                            ColorIcon {
                                height: app.iconSize * 2
                                width: height
                                color: app.guhAccent
                                anchors.horizontalCenter: parent.horizontalCenter
                                name: interfaceToIcon(model.name)
                            }

                            Label {
                                text: interfaceToString(model.name).toUpperCase()
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var page;
                                switch (model.name) {
                                case "light":
                                    page = "LightsDeviceListPage.qml"
                                    break;
                                default:
                                    page = "GenericDeviceListPage.qml"
                                }

                                pageStack.push(Qt.resolvedUrl("devicelistpages/" + page), {filterInterface: model.name})
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
                                pageStack.push(Qt.resolvedUrl("devicelistpages/GenericDeviceListPage.qml"), {filterTag: model.tag})
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
}
