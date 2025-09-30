/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Nymea
import NymeaApp.Utils
import Qt5Compat.GraphicalEffects

import "../delegates"
import "../utils"

Item {
    id: root
    height: swipeView.height
    width: swipeView.width
    property Thing thing: null

    readonly property State playbackState: thing.stateByName("playbackStatus")
    readonly property State inputSourceState: thing.stateByName("inputSource")
    readonly property State playDurationState: thing.stateByName("playDuration")
    readonly property State playTimeState: thing.stateByName("playTime")

    readonly property State titleState: thing.stateByName("title")
    readonly property State artistState: thing.stateByName("artist")
    readonly property State collectionState: thing.stateByName("collection")
    readonly property State artworkState: thing.stateByName("artwork")

    readonly property bool hasVolumeControl: thing.thingClass.interfaces.indexOf("volumecontroller") >= 0
    readonly property State volumeState: thing.stateByName("volume")
    readonly property StateType volumeStateType: thing.thingClass.stateTypes.findByName("volume")
    readonly property State muteState: thing.stateByName("mute")

    readonly property State equalizerPresetState: thing.stateByName("equalizerPreset")
    readonly property State nightModeState: thing.stateByName("nightMode")
    readonly property State likeState: thing.stateByName("like")

    // NOTE: This is not in any interface, special feature just for AMBEO
    readonly property State ambeoModeState: thing.stateByName("ambeoMode")

    readonly property bool hasNavigationPatd: thing.thingClass.interfaces.indexOf("navigationpad") >= 0

    clip: true

    QtObject {
        id: d
        property var browser: null
        property int pendingCallId: -1
    }

    Connections {
        target: engine.thingManager
        onExecuteActionReply: {
            if (commandId == d.pendingCallId) {
                if (thingError !== Thing.ThingErrorNoError) {
                    var errorDialog = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"));
                    var dialogParams = {}
                    dialogParams.error = thingError
                    if (displayMessage.length > 0) {
                        dialogParams.text = displayMessage
                    }
                    var popup = errorDialog.createObject(app, dialogParams)
                    popup.open()
                }
            }
        }
    }

    MediaArtworkImage {
        id: artworkImage
        anchors { left: parent.left; top: parent.top; right: parent.right }
        height: parent.height
        thing: root.thing
    }

    Rectangle {
        id: gradientMask
        anchors.centerIn: parent
        height: Math.max(artworkImage.height, artworkImage.width)
        width: Math.max(artworkImage.height, artworkImage.width)
        rotation: app.landscape ? -90 : 0
        visible: contentStartPos < artworkEndPos

        property double artworkEndPos: app.landscape ?
                                         artworkImage.paintedWidth / artworkImage.width
                                       : artworkImage.paintedHeight / artworkImage.height
        property double contentStartPos: app.landscape ?
                                           (artworkImage.width - content.width - app.margins * 2) / artworkImage.width
                                         : (artworkImage.height - content.height - app.margins * 2) / artworkImage.height
        property double gradientEnd: Math.min(artworkEndPos, contentStartPos + .2)

        gradient: Gradient {
            GradientStop { position: gradientMask.gradientEnd - .5; color: "transparent"}
            GradientStop { position: gradientMask.gradientEnd; color: Style.backgroundColor }
        }
    }

    ColumnLayout {
        id: content
        anchors {
            bottom: parent.bottom;
            left: parent.left;
            right: parent.right
            leftMargin: app.landscape ? root.width / 2 : app.margins
            rightMargin: app.margins
            bottomMargin: app.margins
        }

        spacing: app.margins

        RowLayout {
            ColumnLayout {
                Label {
                    text: root.playbackState.value === "Stopped" ?
                              qsTr("No playback")
                            : root.titleState.value
                    maximumLineCount: 2
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    font.pixelSize: app.largeFont
                }

                Label {
                    text: root.artistState.value
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    visible: text.length > 0
                    font.pixelSize: app.smallFont
                }

                Label {
                    text: root.collectionState.value
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    visible: text.length > 0
                    font.pixelSize: app.smallFont
                }
            }
            ProgressButton {
                longpressEnabled: false
                imageSource: "qrc:/icons/like.svg"
                visible: root.likeState !== null
                color: root.likeState && root.likeState.value === true ? Style.accentColor : Style.iconColor
                onClicked: {
                    engine.thingManager.executeAction(root.thing.id, root.likeState.stateTypeId, [{ paramTypeId: root.likeState.stateTypeId, value: !root.likeState.value}])
                }
            }
        }

        RowLayout {
            visible: root.playTimeState !== null || root.playDurationState != null

            function timeString(seconds) {
                var hours = Math.floor(seconds / 3600);
                seconds = seconds % 3600;
                var minutes = Math.floor(seconds / 60);
                seconds = seconds % 60;
                var ret = "";
                if (hours > 0) {
                    ret += hours + ":";
                }
                ret += NymeaUtils.pad(minutes, 2) + ":";
                ret += NymeaUtils.pad(seconds, 2);
                return ret;
            }

            Label {
                font.pixelSize: app.smallFont
                text: root.playTimeState ? parent.timeString(root.playTimeState.value) : "00:00"
            }

            Slider {
                Layout.fillWidth: true
                from: 0
                to: root.playDurationState ? root.playDurationState.value : 0
                value: root.playTimeState ? root.playTimeState.value : 0
                property ActionType playTimeActionType: root.thing.thingClass.actionTypes.findByName("playTime")
                enabled: playTimeActionType !== null
                onPressedChanged: {
                    if (!pressed) {
                        engine.thingManager.executeAction(root.thing.id, playTimeActionType.id, [{paramTypeId: playTimeActionType.id, value: value}]);
                    }
                }
            }

            Label {
                font.pixelSize: app.smallFont
                text: root.playDurationState ? parent.timeString(root.playDurationState.value) : "00:00"
            }
        }

        MediaControls {
            thing: root.thing
            showExtendedControls: true
        }

        RowLayout {
            ProgressButton {
                longpressEnabled: false
                visible: root.thing.thingClass.browsable
                imageSource: "qrc:/icons/folder.svg"
                onClicked: {
                    if (!d.browser) {
                        d.browser = browserPage.createObject(root, {x: 0, y: root.height})
                    }
                    d.browser.show();
                }
            }
            ProgressButton {
                longpressEnabled: false
                visible: root.hasNavigationPatd
                imageSource: "qrc:/icons/navigationpad.svg"
                onClicked: pageStack.push(navigationPadPage)
            }
            RowLayout {
                spacing: 0
                ProgressButton {
                    id: inputSourceButton
                    longpressEnabled: false
                    visible: root.inputSourceState !== null
                    imageSource: "qrc:/icons/state-in.svg"
                    onClicked: {
                        var popup = inputSourceSelectDialogComponent.createObject(root)
                        popup.open()
                    }
                }
                Label {
                    Layout.fillWidth: true
                    text: root.inputSourceState ? root.inputSourceState.value : ""
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    font.pixelSize: app.smallFont
                    MouseArea { anchors.fill: parent; onClicked: inputSourceButton.clicked() }
                }
            }
            ColorIcon {
                visible: root.ambeoModeState !== null
                Layout.preferredWidth: Style.iconSize * 3
                name: "qrc:/icons/media/ambeo.svg"
                color: root.ambeoModeState && root.ambeoModeState.value !== "Off" ? Style.accentColor : Style.iconColor
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var popup = ambeoModeDialogComponent.createObject(root)
                        popup.open()
                    }
                }
            }
            ProgressButton {
                longpressEnabled: false
                visible: root.nightModeState !== null
                imageSource: "qrc:/icons/weathericons/weather-clear-night.svg"
                color: root.nightModeState && root.nightModeState.value === true ? Style.accentColor : Style.iconColor
                onClicked: d.pendingCallId = engine.thingManager.executeAction(root.thing.id, root.nightModeState.stateTypeId, [{paramTypeId: root.nightModeState.stateTypeId, value: !root.nightModeState.value}])
            }
            ProgressButton {
                longpressEnabled: false
                visible: root.equalizerPresetState !== null
                imageSource: "qrc:/icons/media/equalizer.svg"
                onClicked: {
                    var dialog = equalizerComponent.createObject(root)
                    dialog.open()
                }
            }
            ProgressButton {
                id: volumeButton
                visible: root.hasVolumeControl
                longpressEnabled: false
                imageSource: root.muteState && root.muteState.value === true ?
                                 "qrc:/icons/audio-speakers-muted-symbolic.svg"
                               : "qrc:/icons/audio-speakers-symbolic.svg"
                onClicked: {
                    print(volumeButton.x, volumeButton.y)
                    print(Qt.point(volumeButton.x, volumeButton.y))
                    print(volumeButton.mapToItem(root, volumeButton.x,0))
                    var buttonPosition = root.mapFromItem(volumeButton, 0, 0)
                    var sliderHeight = 200
                    var props = {}
                    props["x"] = buttonPosition.x - app.margins
                    props["y"] = buttonPosition.y - sliderHeight
                    props["height"] = sliderHeight
                    var sliderPane = volumeSliderPaneComponent.createObject(root, props)
                    sliderPane.open()
                }
            }
        }
    }

    Component {
        id: volumeSliderPaneComponent
        Dialog {
            id: volumeSliderDialog

            leftPadding: 0
            topPadding: app.margins / 2
            rightPadding: 0
            bottomPadding: app.margins / 2
            modal: true

            ActionQueue {
                id: volumeActionQueue
                thing: root.thing
                stateType: root.thing.thingClass.stateTypes.findByName("volume")
            }

            contentItem: ColumnLayout {
                ProgressButton {
                    visible: root.volumeState === null
                    Layout.alignment: Qt.AlignHCenter
                    longpressEnabled: false
                    imageSource: "qrc:/icons/up.svg"
                    onClicked: engine.thingManager.executeAction(root.thing.id, root.thing.thingClass.actionTypes.findByName("increaseVolume").id);
                }
                ProgressButton {
                    visible: root.volumeState === null
                    Layout.alignment: Qt.AlignHCenter
                    longpressEnabled: false
                    imageSource: "qrc:/icons/down.svg"
                    onClicked: engine.thingManager.executeAction(root.thing.id, root.thing.thingClass.actionTypes.findByName("decreaseVolume").id);
                }

                Slider {
                    Layout.fillHeight: true
                    visible: root.volumeState !== null
                    from: root.volumeStateType.minValue
                    to: root.volumeStateType.maxValue
                    value: volumeActionQueue.pendingValue || root.volumeState.value
                    orientation: Qt.Vertical
                    onMoved: volumeActionQueue.sendValue(value)
                }

                ProgressButton {
                    visible: root.muteState !== null
                    Layout.alignment: Qt.AlignHCenter
                    imageSource: "qrc:/icons/audio-speakers-muted-symbolic.svg"
                    color: root.muteState.value === true ? Style.accentColor : Style.iconColor
                    onClicked: engine.thingManager.executeAction(root.thing.id, root.muteState.stateTypeId, [{paramTypeId: root.muteState.stateTypeId, value: !root.muteState.value}]);
                }
            }
        }
    }

    Component {
        id: navigationPadPage
        Page {
            header: NymeaHeader { text: root.thing.name; onBackPressed: pageStack.pop() }
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: app.margins
                spacing: app.margins

                NavigationPad { Layout.fillWidth: true; Layout.fillHeight: true; thing: root.thing }
                MediaControls { Layout.fillWidth: true; thing: root.thing }
                ShuffleRepeatVolumeControl { Layout.fillWidth: true; Layout.fillHeight: false; Layout.preferredHeight: Style.iconSize; thing: root.thing }
            }
        }
    }

    Component {
        id: browserPage
        Page {
            width: root.width
            height: root.height
            y: root.height

            function show() { y = 0 }
            function hide() { y = root.height }

            header: Rectangle {
                height: Style.smallDelegateHeight
                width: parent.width
                color: Style.tileBackgroundColor

                RowLayout {
                    anchors.fill: parent
                    HeaderButton {
                        imageSource: "qrc:/icons/down.svg"
                        onClicked: d.browser.hide()
                    }

                    Flickable {
                        id: pathFlickable
                        Layout.fillWidth: true
                        Layout.margins: app.margins / 2
                        Layout.fillHeight: true
                        contentX: Math.max(0, contentWidth - width)
                        contentWidth: pathRow.width
                        clip: true
                        onContentWidthChanged: {
                            print("contentWidth", contentWidth, "width", width, contentX)
                        }

                        Row {
                            id: pathRow
                            Repeater {
                                model: mediaBrowser.path
        //                        orientation: ListView.Horizontal
                                Rectangle {
                                    height: pathFlickable.height
                                    width: Math.min(150, folderLabel.implicitWidth + app.margins)
                                    border.color: Style.backgroundColor
                                    border.width: 1
                                    radius: 4
                                    color: Qt.lighter(Style.backgroundColor)
                                    Label {
                                        id: folderLabel
                                        text: modelData
                                        width: parent.width
                                        elide: Text.ElideRight
                                        anchors.centerIn: parent
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            var backCount = mediaBrowser.path.count - index - 1;
                                            print("backCount:", backCount)
                                            for (var i = 0; i < backCount - 1; i++) {
                                                mediaBrowser.backPressed(true)
                                            }
                                            if (backCount > 0) {
                                                mediaBrowser.backPressed(false)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

            MediaBrowser {
                id: mediaBrowser
                anchors.fill: parent
                thing: root.thing
                onExit: {
                    d.browser.hide()
                }
                onItemLaunched: {
                    d.browser.hide()
                }
            }
        }
    }

    Component {
        id: inputSourceSelectDialogComponent
        NymeaDialog {
            id: inputSourceSelectDialog
            headerIcon: "qrc:/icons/state-in.svg"
            title: qsTr("Select input")
            standardButtons: Dialog.NoButton

            ListView {
                id: inputSourceListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 200
                clip: true
                model: root.thing.thingClass.stateTypes.findByName("inputSource").allowedValues
                delegate: RadioDelegate {
                    width: inputSourceListView.width
                    text: modelData
                    checked: root.inputSourceState.value === modelData
                    onClicked: {
                        d.pendingCallId = engine.thingManager.executeAction(root.thing.id, root.inputSourceState.stateTypeId, [{paramTypeId: root.inputSourceState.stateTypeId, value: modelData}])
                        inputSourceSelectDialog.close();
                    }
                }
            }
        }
    }

    Component {
        id: equalizerComponent
        NymeaDialog {
            id: equalizer
            headerIcon: "qrc:/icons/media/equalizer.svg"
            title: qsTr("Equalizer preset")
            standardButtons: Dialog.NoButton
            ListView {
                id: inputSourceListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 200
                clip: true
                model: root.thing.thingClass.stateTypes.findByName("equalizerPreset").allowedValues
                delegate: RadioDelegate {
                    width: inputSourceListView.width
                    text: modelData
                    checked: root.equalizerPresetState.value === modelData
                    onClicked: {
                        d.pendingCallId = engine.thingManager.executeAction(root.thing.id, root.equalizerPresetState.stateTypeId, [{paramTypeId: root.equalizerPresetState.stateTypeId, value: modelData}])
                        equalizer.close();
                    }
                }
            }
        }
    }
    Component {
        id: ambeoModeDialogComponent
        NymeaDialog {
            id: ambeoModeDialog
            standardButtons: Dialog.NoButton
            ColorIcon {
                Layout.preferredHeight: Style.hugeIconSize
                Layout.preferredWidth: Style.hugeIconSize * 3
                Layout.alignment: Qt.AlignHCenter
                name: "qrc:/icons/media/ambeo.svg"
                color: Style.accentColor
            }

            ListView {
                id: ambeoModeListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 200
                clip: true
                model: root.thing.thingClass.stateTypes.findByName("ambeoMode").allowedValues
                delegate: RadioDelegate {
                    width: ambeoModeListView.width
                    text: modelData
                    checked: root.ambeoModeState.value === modelData
                    onClicked: {
                        d.pendingCallId = engine.thingManager.executeAction(root.thing.id, root.ambeoModeState.stateTypeId, [{paramTypeId: root.ambeoModeState.stateTypeId, value: modelData}])
                        ambeoModeDialog.close();
                    }
                }
            }
        }
    }
}
