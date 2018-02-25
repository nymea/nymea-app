import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import Guh 1.0
import "components"

GridView {
    id: interfacesGridView

    property alias shownInterfaces: interfacesModel.shownInterfaces

    model: InterfacesModel {
        id: interfacesModel
        devices: Engine.deviceManager.devices
    }

    property int tilesPerRow: Math.ceil(Math.sqrt(interfacesGridView.count))
    cellWidth: width / tilesPerRow
    cellHeight: height / tilesPerRow
    delegate: Item {
        width: interfacesGridView.cellWidth
        height: interfacesGridView.cellHeight
        Pane {
            anchors.fill: parent
            anchors.margins: app.margins
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
