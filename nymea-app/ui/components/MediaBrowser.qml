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
import "../delegates"


Item {
    id: root

    property Thing thing: null

    function backPressed() {
        if (internalPageStack.depth > 1) {
            internalPageStack.pop();
        } else {
            swipeView.currentIndex--
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

                property string nodeId: ""

                // Need to keep a explicit property here or the GC will eat it too early
                property BrowserItems browserItems: null
                Component.onCompleted: {
                    browserItems = engine.thingManager.browseDevice(root.thing.id, nodeId);
                }

                delegate: BrowserItemDelegate {
                    iconName: "../images/browser/" + (model.mediaIcon && model.mediaIcon !== "MediaBrowserIconNone" ? model.mediaIcon : model.icon) + ".svg"
                    busy: d.pendingItemId === model.id
                    device: root.thing

                    onClicked: {
                        print("clicked:", model.id)
                        if (model.executable) {
                            root.executeBrowserItem(model.id)
                        } else if (model.browsable) {
                            internalPageStack.push(internalBrowserPage, {device: root.thing, nodeId: model.id})
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
    }
}

