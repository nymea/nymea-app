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
import Qt5Compat.GraphicalEffects
import Nymea
import "../delegates"


Item {
    id: root

    property Thing thing: null

    signal exit();
    signal itemLaunched()

    property ListModel path: ListModel {
        id: pathModel
        dynamicRoles: true
        Component.onCompleted: pathModel.append({modelData: root.thing.name})
    }


    function backPressed(immediate) {
        if (internalPageStack.depth > 1) {
            pathModel.remove(pathModel.count - 1)
            internalPageStack.pop(immediate ? StackView.Immediate : StackView.PopTransition);
        } else {
            root.exit();
        }
    }

    QtObject {
        id: d
        property int pendingItemExecutionId: -1
    }

    Connections {
        target: engine.thingManager
        onExecuteBrowserItemReply: {
            if (commandId == d.pendingItemExecutionId) {
                if (thingError === Thing.ThingErrorNoError) {
                    root.itemLaunched();
                } else {
                    var errorDialog = Qt.createComponent(Qt.resolvedUrl("ErrorDialog.qml"));
                    var text = qsTr("Sorry. An error happened launching the item. (Error code: %1)").arg(params.error);
                    if (displayMessage.length > 0) {
                        text = displayMessage;
                    }
                    var popup = errorDialog.createObject(app, {text: text})
                    popup.open()
                }
            }
        }
    }

    StackView {
        id: internalPageStack
        anchors.fill: parent
        initialItem: internalBrowserPage

        Component {
            id: internalBrowserPage
            ListView {
                id: listView
                model: browserItems
                ScrollBar.vertical: ScrollBar {}
                clip: true

                property string nodeId: ""

                // Need to keep a explicit property here or the GC will eat it too early
                property BrowserItems browserItems: null
                Component.onCompleted: {
                    browserItems = engine.thingManager.browseThing(root.thing.id, nodeId);
                }

                delegate: BrowserItemDelegate {
                    iconName: "qrc:/icons/browser/" + (model.mediaIcon && model.mediaIcon !== "MediaBrowserIconNone" ? model.mediaIcon : model.icon) + ".svg"
                    busy: d.pendingItemId === model.id
                    device: root.thing

                    onClicked: {
                        print("clicked:", model.id)
                        if (model.executable) {
                            d.pendingItemExecutionId = engine.thingManager.executeBrowserItem(root.thing.id, model.id)
                        } else if (model.browsable) {
                            pathModel.append({modelData: model.displayName})
                            internalPageStack.push(internalBrowserPage, {nodeId: model.id})
                        }
                    }

                    onContextMenuActionTriggered: {
                        engine.thingManager.executeBrowserItemAction(root.thing.id, model.id, actionTypeId, params)
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

