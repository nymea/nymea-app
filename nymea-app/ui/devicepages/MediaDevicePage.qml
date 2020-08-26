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

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import Nymea 1.0
import "../components"
import "../customviews"
import "../delegates"

DevicePageBase {
    id: root
    popStackOnBackButton: false
    showBrowserButton: false

    onBackPressed: {
        swipeView.currentItem.backPressed()
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
    function executeBrowserItemAction(itemId, actionTypeId, params) {
        print("params2:", JSON.stringify(params))
        d.pendingItemId = itemId
        d.pendingBrowserItemId = engine.deviceManager.executeBrowserItemAction(device.id, itemId, actionTypeId, params);
    }

    function adjustVolume(volume) {
        d.pendingVolumeValue = volume;

        if (d.pendingVolumeId !== -1) {
            // busy
            return;
        }

        var params = []
        var volParam = {}
        volParam["paramTypeId"] = root.deviceClass.actionTypes.findByName("volume").id
        volParam["value"] = volume;
        params.push(volParam)
        var actionTypeId =  deviceClass.actionTypes.findByName("volume").id;
        d.pendingVolumeId = engine.deviceManager.executeAction(device.id, actionTypeId, params);
        print("exec", d.pendingVolumeId)
        return;
    }

    readonly property State playbackState: device.states.getState(deviceClass.stateTypes.findByName("playbackStatus").id)
    readonly property State volumeState: device.states.getState(deviceClass.stateTypes.findByName("volume").id)

    QtObject {
        id: d
        property int pendingBrowserItemId: -1
        property string pendingItemId: ""

        property int pendingVolumeId: -1
        property int pendingVolumeValue: -1
    }

    Connections {
        target: engine.deviceManager
        onExecuteBrowserItemReply: executionFinished(params)
        onExecuteBrowserItemActionReply: executionFinished(params)
        onExecuteActionReply: {
            print("actionfinished", params["id"])
            if (params["id"] === d.pendingVolumeId) {
                d.pendingVolumeId = -1
                print("volume action finished")
                if (params.params.deviceError !== "DeviceErrorNoError") {
                    print("Error setting volume", params.params.deviceError)
                    d.pendingVolumeValue = -1;
                    return;
                }

                if (d.pendingVolumeValue !== volumeState.value) {
                    root.adjustVolume(d.pendingVolumeValue);
                } else {
                    d.pendingVolumeValue = -1;
                }
            }
        }
    }
    function executionFinished(params) {
        print("Execute reply:", params, params.id, params["id"], d.pendingBrowserItemId)
        if (params.id === d.pendingBrowserItemId) {
            d.pendingBrowserItemId = -1;
            d.pendingItemId = ""
            print("yep finished")
            if (params.params.deviceError === "DeviceErrorNoError") {
                swipeView.currentIndex = 0;
            } else {
                header.showInfo(qsTr("Error: %1").arg(params.params.deviceError), true)
            }
        }
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent

        Component.onCompleted:  {
            if (root.deviceClass.browsable) {
                browserComponent.createObject(swipeView)
            }

            if (root.deviceClass.interfaces.indexOf("navigationpad") >= 0) {
                navigationComponent.createObject(swipeView)
            }
        }

        Item {
            function backPressed() {
                pageStack.pop();
            }

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
                    thing: root.device
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
                        thing: root.device
                        iconSize: app.iconSize * 2
                    }
                }
            }
        }

    }

    Component {
        id: browserComponent

        MediaBrowser {
            thing: root.device
        }
    }

    Component {
        id: navigationComponent
        Item {
            function backPressed() {
                swipeView.currentIndex--;
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: app.margins

                NavigationPad {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    device: root.device
                }

                MediaControls {
                    Layout.fillWidth: true
                    thing: root.device
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
                visible: swipeView.count > 1
                Rectangle {
                    height: parent.height
                    width: parent.width / swipeView.count
                    color: app.accentColor
                    x: swipeView.currentIndex * width
                    Behavior on x { NumberAnimation { duration: 150 } }
                }
            }

            RowLayout {
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: swipeView.count > 1 && swipeView.currentIndex > 0 ? parent.width / 4 : 0
                    Behavior on Layout.preferredWidth { NumberAnimation {} }
                    HeaderButton {
                        anchors.centerIn: parent
                        imageSource: "../images/back.svg"
                        opacity:  swipeView.count > 1 && swipeView.currentIndex > 0 ? 1 : 0
                        Behavior on opacity { NumberAnimation {} }
                        onClicked: swipeView.currentIndex--
                    }
                }
                ShuffleRepeatVolumeControl {
                    Layout.fillWidth: true
                    thing: root.device
                }

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: swipeView.count > 1 && swipeView.currentIndex < swipeView.count - 1 ? parent.width / 4 : 0
                    Behavior on Layout.preferredWidth { NumberAnimation {} }
                    HeaderButton {
                        anchors.centerIn: parent
                        imageSource: "../images/next.svg"
                        onClicked: swipeView.currentIndex++
                        opacity:  swipeView.count > 1 && swipeView.currentIndex < swipeView.count - 1 ? 1 : 0
                        Behavior on opacity { NumberAnimation {} }
                    }
                }
            }
        }
    }
}
