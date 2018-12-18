import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import Nymea 1.0
import "../components"
import "../customviews"

DevicePageBase {
    id: root

    function stateValue(name) {
        var stateType = root.deviceClass.stateTypes.findByName(name);
        if (!stateType) return null
        return root.device.states.getState(stateType.id).value
    }

    function executeAction(actionName, params) {
        var actionTypeId = deviceClass.actionTypes.findByName(actionName).id;
        print("executing", device, device.id, actionTypeId, actionName, deviceClass.actionTypes, params)
        engine.deviceManager.executeAction(device.id, actionTypeId, params)
    }

    readonly property State playbackState: device.states.getState(deviceClass.stateTypes.findByName("playbackStatus").id)

    GridLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: app.margins
        columns: app.landscape ? 2 : 1
        columnSpacing: app.margins
        rowSpacing: app.margins

        Pane {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Material.elevation: 2
            padding: 0

            contentItem: Rectangle {
                color: app.foregroundColor

                Image {
                    id: artworkImage
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: root.stateValue("artwork")
                }

                ColorIcon {
                    id: fallback
                    anchors.fill: parent
                    anchors.margins: app.margins * 2
                    name: root.stateValue("playerType") === "video" ? "../images/stock_video.svg" : "../images/stock_music.svg"
                    visible: artworkImage.status !== Image.Ready || artworkImage.source === ""
                    color: app.primaryColor
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: app.margins

            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                font.pixelSize: app.largeFont
                font.bold: true
                text: root.stateValue("title")
            }
            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                text: root.stateValue("artist")
            }
            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                text: root.stateValue("collection")
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                ProgressButton {
                    Layout.preferredHeight: app.iconSize
                    Layout.preferredWidth: height
                    imageSource: "../images/media-skip-backward.svg"
                    longpressImageSource: "../images/media-seek-backward.svg"
                    repeat: true

                    onClicked: {
                        root.executeAction("skipBack")
                    }
                    onLongpressed: {
                        root.executeAction("fastRewind")
                    }
                }

                Item { Layout.fillWidth: true }

                ProgressButton {
                    Layout.preferredHeight: app.iconSize * 2
                    Layout.preferredWidth: height
                    imageSource: root.playbackState.value === "Playing" ? "../images/media-playback-pause.svg" : "../images/media-playback-start.svg"
                    longpressImageSource: "../images/media-playback-stop.svg"
                    longpressEnabled: root.playbackState.value !== "Stopped"

                    onClicked: {
                        if (root.playbackState.value === "Playing") {
                            root.executeAction("pause")
                        } else {
                            root.executeAction("play")
                        }
                    }

                    onLongpressed: {
                        root.executeAction("stop")
                    }
                }

                Item { Layout.fillWidth: true }
                ProgressButton {
                    Layout.preferredHeight: app.iconSize
                    Layout.preferredWidth: height
                    imageSource: "../images/media-skip-forward.svg"
                    longpressImageSource: "../images/media-seek-forward.svg"
                    repeat: true
                    onClicked: {
                        root.executeAction("skipNext")
                    }
                    onLongpressed: {
                        root.executeAction("fastForward")
                    }
                }
                Item { Layout.fillWidth: true }
            }
        }
    }

    Component {
        id: volumeSliderPaneComponent
        Dialog {

            leftPadding: 0
            topPadding: app.margins / 2
            rightPadding: 0
            bottomPadding: app.margins / 2

            contentItem: ColumnLayout {
                Slider {
                    Layout.fillHeight: true
                    orientation: Qt.Vertical
                    from: 0
                    to: 100
                    value: root.stateValue("volume")
                    onMoved: {
                        var params = []
                        var volParam = {}
                        volParam["paramTypeId"] = root.deviceClass.actionTypes.findByName("volume").id
                        volParam["value"] = value;
                        params.push(volParam)
                        root.executeAction("volume", params);
                    }
                }
                HeaderButton {
                    imageSource: "../images/audio-speakers-muted-symbolic.svg"
                    color: root.stateValue("mute") ? app.accentColor : keyColor
                    onClicked: {
                        var params = []
                        var muteParam = {}
                        muteParam["paramTypeId"] = root.deviceClass.actionTypes.findByName("mute").id
                        muteParam["value"] = !root.stateValue("mute");
                        params.push(muteParam)
                        root.executeAction("mute", params);
                    }
                }
            }
        }
    }

    footer: Pane {
        Material.elevation: 1
        height: 50
        padding: 0
        contentItem: RowLayout {
//            Item {
//                Layout.fillWidth: true; Layout.fillHeight: true
//                HeaderButton {
//                    anchors.centerIn: parent
//                    imageSource: "../images/media-playlist.svg"
//                }
//            }
            Item {
                Layout.fillWidth: true; Layout.fillHeight: true
                visible: root.deviceClass.interfaces.indexOf("shufflerepeat") >= 0
                HeaderButton {
                    anchors.centerIn: parent
                    imageSource: root.stateValue("repeat") === "One" ? "../images/media-playlist-repeat-one.svg" : "../images/media-playlist-repeat.svg"
                    color: root.stateValue("repeat") === "None" ? keyColor : app.accentColor
                    property var allowedValues: ["None", "All", "One"]
                    onClicked: {
                        var params = []
                        var param = {}
                        param["paramTypeId"] = root.deviceClass.actionTypes.findByName("repeat").id;
                        param["value"] = allowedValues[(allowedValues.indexOf(root.stateValue("repeat")) + 1) % 3]
                        params.push(param)
                        root.executeAction("repeat", params)
                    }
                }
            }
            Item {
                Layout.fillWidth: true; Layout.fillHeight: true
                visible: root.deviceClass.interfaces.indexOf("shufflerepeat") >= 0
                HeaderButton {
                    anchors.centerIn: parent
                    imageSource: "../images/media-playlist-shuffle.svg"
                    color: root.stateValue("shuffle") ? app.accentColor: keyColor
                    onClicked: {
                        var params = []
                        var param = {}
                        param["paramTypeId"] = root.deviceClass.actionTypes.findByName("shuffle").id;
                        param["value"] = !root.stateValue("shuffle")
                        params.push(param)
                        root.executeAction("shuffle", params)
                    }
                }
            }
            Item {
                id: volumeButtonContainer
                Layout.fillWidth: true; Layout.fillHeight: true
                HeaderButton {
                    id: volumeButton
                    anchors.centerIn: parent
                    imageSource: "../images/audio-speakers-symbolic.svg"
                    onClicked: {
                        print("...");
                        print(volumeButton.x, volumeButton.y)
                        print(Qt.point(volumeButton.x, volumeButton.y))
                        print(volumeButton.mapToItem(root, volumeButton.x,0))
                        var buttonPosition = root.mapFromItem(volumeButtonContainer, volumeButton.x, 0)
                        var sliderHeight = 200
                        var props = {}
                        props["x"] = buttonPosition.x
                        props["y"] = root.height - sliderHeight - root.footer.height
                        props["height"] = sliderHeight
                        var sliderPane = volumeSliderPaneComponent.createObject(root, props)
                        sliderPane.open()
                    }
                }
            }
        }
    }
}
