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

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtCharts 2.2
import Nymea 1.0

RowLayout {
    id: root

    property Thing thing: null

    property State repeatState: thing.stateByName("repeat")
    property State shuffleState: thing.stateByName("shuffle")

    property State volumeState: thing.stateByName("volume")
    property State muteState: thing.stateByName("mute")

    Item {
        Layout.preferredHeight: app.iconSize
        Layout.fillWidth: true
        visible: root.repeatState !== null

        HeaderButton {
            anchors.centerIn: parent
            imageSource: root.repeatState.value === "One" ? "../images/media-playlist-repeat-one.svg" : "../images/media-playlist-repeat.svg"
            color: root.repeatState.value === "None" ? Style.iconColor : Style.accentColor
            property var allowedValues: ["None", "All", "One"]
            onClicked: {
                var params = []
                var param = {}
                param["paramTypeId"] = root.repeatState.stateTypeId;
                param["value"] = allowedValues[(allowedValues.indexOf(root.repeatState.value) + 1) % 3]
                params.push(param)
                engine.thingManager.executeAction(root.thing.id, root.repeatState.stateTypeId, params)
            }
        }
    }

    Item {
        Layout.preferredHeight: app.iconSize
        Layout.fillWidth: true
        visible: root.shuffleState !== null

        HeaderButton {
            anchors.centerIn: parent
            imageSource: "../images/media-playlist-shuffle.svg"
            color: root.shuffleState.value === true ? Style.accentColor: Style.iconColor
            onClicked: {
                var params = []
                var param = {}
                param["paramTypeId"] = root.shuffleState.stateTypeId
                param["value"] = !root.shuffleState.value
                params.push(param)
                engine.thingManager.executeAction(root.thing.id, root.shuffleState.stateTypeId, params)
            }
        }
    }

    Item {
        id: volumeButtonContainer
        Layout.fillWidth: true; Layout.fillHeight: true
        HeaderButton {
            id: volumeButton
            anchors.centerIn: parent
            imageSource: root.muteState && root.muteState.value === true ?
                             "../images/audio-speakers-muted-symbolic.svg"
                           : "../images/audio-speakers-symbolic.svg"
            onClicked: {
                print(volumeButton.x, volumeButton.y)
                print(Qt.point(volumeButton.x, volumeButton.y))
                print(volumeButton.mapToItem(root, volumeButton.x,0))
                var buttonPosition = root.mapFromItem(volumeButtonContainer, volumeButton.x, 0)
                var sliderHeight = 200
                var props = {}
                props["x"] = buttonPosition.x
                props["y"] = buttonPosition.y - sliderHeight
                props["height"] = sliderHeight
                var sliderPane = volumeSliderPaneComponent.createObject(root, props)
                sliderPane.open()
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

            property int pendingVolumeValue: -1

            contentItem: ColumnLayout {
                HeaderButton {
                    visible: root.volumeState === null
                    imageSource: "../images/up.svg"
                    onClicked: engine.thingManager.executeAction(root.thing.id, root.thing.thingClass.actionTypes.findByName("increaseVolume").id);
                }
                HeaderButton {
                    visible: root.volumeState === null
                    imageSource: "../images/down.svg"
                    onClicked: engine.thingManager.executeAction(root.thing.id, root.thing.thingClass.actionTypes.findByName("decreaseVolume").id);
                }

                ThrottledSlider {
                    Layout.fillHeight: true
                    visible: root.volumeState !== null
                    from: 0
                    to: 100
                    value: root.volumeState.value
                    orientation: Qt.Vertical
                    onMoved: engine.thingManager.executeAction(root.thing.id, root.volumeState.stateTypeId, [{paramTypeId: root.volumeState.stateTypeId, value: value}])
                }

                HeaderButton {
                    visible: root.muteState !== null
                    imageSource: "../images/audio-speakers-muted-symbolic.svg"
                    color: root.muteState.value === true ? Style.accentColor : Style.iconColor
                    onClicked: engine.thingManager.executeAction(root.thing.id, root.muteState.stateTypeId, [{paramTypeId: root.muteState.stateTypeId, value: !root.muteState.value}]);
                }
            }
        }
    }
}
