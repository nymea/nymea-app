import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0

Item {
    id: root
    property Device device: null

    readonly property StateType artworkStateType: device ? device.deviceClass.stateTypes.findByName("artwork") : null
    readonly property State artworkState: artworkStateType ? device.states.getState(artworkStateType.id) : null

    readonly property StateType playerTypeStateType: device ? device.deviceClass.stateTypes.findByName("playerType") : null
    readonly property State playerTypeState: playerTypeStateType ? device.states.getState(playerTypeStateType.id) : null

    Pane {
        Material.elevation: 2
        anchors.centerIn: parent
        height: fallback.visible ? Math.min(parent.height, parent.width) : artworkImage.paintedHeight - 1
        width: fallback.visible ? Math.min(parent.height, parent.width) : artworkImage.paintedWidth - 1
        padding: 0
        contentItem: Rectangle {
            color: "black"
        }
    }

    Image {
        id: artworkImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        source: root.artworkState.value
        visible: source !== ""
    }

    ColorIcon {
        id: fallback
        anchors.centerIn: parent
        width: Math.min(parent.height, parent.width) - app.margins * 2
        height: Math.min(parent.height, parent.width) - app.margins * 2

        name: root.playerTypeState.value === "video" ? "../images/stock_video.svg" : "../images/stock_music.svg"
        visible: artworkImage.status !== Image.Ready || artworkImage.source === ""
//        color: app.primaryColor
        color: "white"
    }
}
