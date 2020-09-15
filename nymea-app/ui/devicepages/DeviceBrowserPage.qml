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
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("Browse %1").arg(root.device.name)
        onBackPressed: pageStack.pop()
    }
    property Device device: null
    property string nodeId: ""

    Component.onCompleted: {
        d.model = engine.deviceManager.browseDevice(root.device.id, root.nodeId);
    }

    function executeBrowserItem(itemId) {
        d.pendingItemId = itemId
        d.pendingBrowserItemId = engine.deviceManager.executeBrowserItem(root.device.id, itemId)
    }
    function executeBrowserItemAction(itemId, actionTypeId, params) {
        d.pendingItemId = itemId
        d.pendingBrowserItemId = engine.deviceManager.executeBrowserItemAction(root.device.id, itemId, actionTypeId, params)
    }

    QtObject {
        id: d
        property BrowserItems model: null
        property int pendingBrowserItemId: -1
        property string pendingItemId: ""
    }

    Connections {
        target: engine.deviceManager
        onExecuteBrowserItemReply: actionExecuted(commandId, params)
        onExecuteBrowserItemActionReply: actionExecuted(commandId, params)
    }
    function actionExecuted(commandId, params) {
        if (commandId === d.pendingBrowserItemId) {
            d.pendingBrowserItemId = -1;
            d.pendingItemId = ""
            if (params.deviceError !== "DeviceErrorNoError") {
                if (params.displayMessage.length > 0) {
                    header.showInfo(qsTr("Error: %1").arg(params.displayMessage), true)
                } else {
                    header.showInfo(qsTr("Error: %1").arg(params.deviceError), true)
                }
            }
        }
        engine.deviceManager.refreshBrowserItems(d.model)
    }

    ListView {
        id: listView
        anchors.fill: parent
        model: d.model
        ScrollBar.vertical: ScrollBar {}

        delegate: BrowserItemDelegate {
            id: delegate
            busy: d.pendingItemId === model.id
            device: root.device

            onClicked: {
                print("clicked:", model.id)
                if (model.executable) {
                    root.executeBrowserItem(model.id)
                } else if (model.browsable) {
                    pageStack.push(Qt.resolvedUrl("DeviceBrowserPage.qml"), {device: root.device, nodeId: model.id})
                }
            }

            onContextMenuActionTriggered: {
                root.executeBrowserItemAction(model.id, actionTypeId, params)
            }
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: listView.model.busy
            visible: running
        }
    }

}
