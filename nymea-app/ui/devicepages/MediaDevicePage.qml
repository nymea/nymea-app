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
    popStackOnBackButton: false
    showBrowserButton: false

    onBackPressed: {
        if (swipeView.currentIndex > 0) {
            if (internalPageStack.depth > 1) {
                internalPageStack.pop();
            } else {
                swipeView.currentIndex = 0;
            }
        } else {
            pageStack.pop();
        }
    }

    Component.onCompleted: {
        if (root.deviceClass.browsable && playbackState.value === "Stopped") {
            swipeView.currentIndex = 1;
        }
    }

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

    function executeBrowserItem(itemId) {
        d.pendingItemId = itemId
        d.pendingBrowserItemId = engine.deviceManager.executeBrowserItem(device.id, itemId);
    }

    readonly property State playbackState: device.states.getState(deviceClass.stateTypes.findByName("playbackStatus").id)

    QtObject {
        id: d
        property int pendingBrowserItemId: -1
        property string pendingItemId: ""
    }

    Connections {
        target: engine.deviceManager
        onExecuteBrowserItemReply: {
            print("Execute reply:", params, params.id, params["id"], d.pendingBrowserItemId)
            if (params.id === d.pendingBrowserItemId) {
                d.pendingBrowserItemId = -1;
                d.pendingItemId = ""
                print("yep finished")
                if (params.params.deviceError === "DeviceErrorNoError") {
                    swipeView.currentIndex = 0;
                } else {
                    header.showInfo(qsTr("Error: %").arg(params.params.deviceError), true)
                }
            }
        }
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        interactive: root.deviceClass.browsable

        Item {
            GridLayout {
                id: contentColumn
                anchors.fill: parent
                anchors.margins: app.margins
                columns: app.landscape ? 2 : 1
                columnSpacing: app.margins
                rowSpacing: app.margins

                MediaArtworkImage {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / parent.columns
                    device: root.device
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

                    MediaControls {
                        device: root.device
                        iconSize: app.iconSize * 2
                    }
                }
            }
        }

        Item {

            StackView {
                id: internalPageStack
                anchors.fill: parent
                initialItem: internalBrowserPage

                Component {
                    id: internalBrowserPage
                    ListView {
                        id: listView
                        anchors.fill: parent
                        model: browserItems
                        ScrollBar.vertical: ScrollBar {}

                        property string nodeId: ""

                        // Need to keep a explicit property here or the GC will eat it too early
                        property BrowserItems browserItems: null
                        Component.onCompleted: {
                            browserItems = engine.deviceManager.browseDevice(root.device.id, nodeId);
                        }

                        delegate: NymeaListItemDelegate {
                            width: parent.width
                            text: model.displayName
                            progressive: model.browsable
                            subText: model.description
                            prominentSubText: false
                            iconName: model.thumbnail
                            fallbackIcon: "../images/browser/" + (model.mediaIcon && model.mediaIcon !== "MediaBrowserIconNone" ? model.mediaIcon : model.icon) + ".svg"
                            enabled: model.browsable || model.executable

                            onClicked: {
                                print("clicked:", model.id)
                                if (model.executable) {
                                    root.executeBrowserItem(model.id)
                                } else if (model.browsable) {
                                    internalPageStack.push(internalBrowserPage, {device: root.device, nodeId: model.id})
                                }
                            }
                        }

                        BusyIndicator {
                            anchors.centerIn: parent
                            running: listView.model.busy
                            visible: running
                        }
                    }
                }

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
            modal: true

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
        height: 52
        padding: 0
        contentItem: ColumnLayout {
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 2
                visible: root.deviceClass.browsable
                Rectangle {
                    height: parent.height
                    width: parent.width / 2
                    color: app.accentColor
                    x: swipeView.currentIndex * width
                    Behavior on x { NumberAnimation { duration: 150 } }
                }
            }

            RowLayout {
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: root.deviceClass.browsable && swipeView.currentIndex > 0 ? parent.width / 4 : 0
                    Behavior on Layout.preferredWidth { NumberAnimation {} }
                    HeaderButton {
                        anchors.centerIn: parent
                        imageSource: "../images/back.svg"
                        opacity:  root.deviceClass.browsable && swipeView.currentIndex == 1 ? 1 : 0
                        Behavior on opacity { NumberAnimation {} }
                        onClicked: swipeView.currentIndex = 0
                    }
                }
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
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: root.deviceClass.browsable && swipeView.currentIndex == 0 ? parent.width / 4 : 0
                    Behavior on Layout.preferredWidth { NumberAnimation {} }
                    HeaderButton {
                        anchors.centerIn: parent
                        imageSource: "../images/next.svg"
                        onClicked: swipeView.currentIndex = 1
                        opacity:  root.deviceClass.browsable && swipeView.currentIndex == 0 ? 1 : 0
                        Behavior on opacity { NumberAnimation {} }
                    }
                }
            }
        }
    }
}
