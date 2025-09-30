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
import Nymea

import "../components"
import "../delegates"

Page {
    id: root

    property Thing thing: null
    property string itemId: ""

    signal selected(string selectedItemId)

    header: NymeaHeader {
        onBackPressed: pageStack.pop()
        text: qsTr("Select item")
    }

    Component.onCompleted: {
        listView.model = engine.thingManager.browseThing(root.thing.id, root.itemId)
    }

    ListView {
        id: listView
        anchors.fill: parent
        ScrollBar.vertical: ScrollBar {}

        BusyIndicator {
            anchors.centerIn: parent
            running: listView.model.busy
            visible: running
        }

        delegate: BrowserItemDelegate {
            width: parent.width
            thing: root.thing
            secondaryIconName: "" // We don't support BrowserItemActions in rules yet

            onClicked: {
                if (model.browsable) {
                    var page = pageStack.push(Qt.resolvedUrl("SelectBrowserItemActionPage.qml"), {thing: root.thing, itemId: model.id});
                    page.selected.connect(function(selectedItemId) {
                        pageStack.pop();
                        root.selected(selectedItemId);
                    })
                } else if (model.executable) {
                    pageStack.pop();
                    print("selected:", model.id)
                    root.selected(model.id);
                }
            }
        }
    }
}
