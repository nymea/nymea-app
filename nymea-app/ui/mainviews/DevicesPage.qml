import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"

Item {
    id: root
    property alias count: interfacesGridView.count
    property alias model: interfacesGridView.model

    GridView {
        id: interfacesGridView
        anchors.fill: parent
        anchors.margins: app.margins / 2

        readonly property int minTileWidth: 180
        readonly property int minTileHeight: 240
        readonly property int tilesPerRow: root.width / minTileWidth

        model: InterfacesModel {
            id: interfacesModel
            devices: Engine.deviceManager.devices
        }
        cellWidth: width / tilesPerRow
        cellHeight: cellWidth
        delegate: DevicesPageDelegate {
            width: interfacesGridView.cellWidth
            height: interfacesGridView.cellHeight
        }
    }
}
