import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1
import Nymea 1.0

BigTile {
    id: root

    property Thing thing: null

    readonly property State connectedState: thing.thingClass.interfaces.indexOf("connectable") >= 0 ? thing.stateByName("connected") : null
    readonly property bool isConnected: connectedState === null || connectedState.value === true
    readonly property bool isEnabled: thing.setupStatus == Thing.ThingSetupStatusComplete && isConnected

    onPressAndHold: {
        var contextMenuComponent = Qt.createComponent("../components/ThingContextMenu.qml");
        var contextMenu = contextMenuComponent.createObject(root, { thing: root.thing })
        contextMenu.x = Qt.binding(function() { return (root.width - contextMenu.width) / 2 })
        contextMenu.open()
    }    

    header: RowLayout {
        id: headerRow
        visible: root.showHeader
        width: parent.width
        Layout.margins: Style.margins / 2
        Label {
            Layout.fillWidth: true
            text: root.thing.name
            elide: Text.ElideRight
        }
        ThingStatusIcons {
            thing: root.thing
        }
    }
}
