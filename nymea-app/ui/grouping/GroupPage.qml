import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root
    header: NymeaHeader {
        text: root.groupTag.substring(6)
        onBackPressed: pageStack.pop()
    }

    property string groupTag


    DevicesProxy {
        id: devicesInGroup
        engine: _engine
        filterTagId: root.groupTag
    }

    InterfacesProxy {
        id: interfacesInGroup
        devicesProxyFilter: devicesInGroup
        showStates: true
    }

    GridView {
        id: gridView
        anchors.fill: parent
        anchors.margins: app.margins / 2

        model: devicesInGroup

        readonly property int minTileWidth: 180
        readonly property int minTileHeight: 240
        readonly property int tilesPerRow: root.width / minTileWidth

        cellWidth: gridView.width / tilesPerRow
        cellHeight: cellWidth

        delegate: ThingTile {
            width: gridView.cellWidth
            height: gridView.cellHeight

            device: devicesInGroup.get(index)

            onClicked: pageStack.push(Qt.resolvedUrl("../devicepages/" + app.interfaceListToDevicePage(deviceClass.interfaces)), {device: device})

        }
    }

}
