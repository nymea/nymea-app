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

Item {
    id: swipeGroup

    property ListView listView: parent
    QtObject {
        id: d
        property var delegates: swipeGroup.listView.contentItem.children
        property var delegateCache: []

        onDelegatesChanged: {
            for (var i = 0; i < d.delegates.length; i++) {
                var thisItem = d.delegates[i];
                if (!thisItem.hasOwnProperty("swipe")) {
                    continue;
                }
                if (d.delegateCache.indexOf(thisItem) < 0) {
                    d.delegateCache.push(thisItem);

//                    print("cache is now", d.delegateCache.length)

                    thisItem.Component.destruction.connect(function() {
//                        print("item destroyed", thisItem)
                        var idx = d.delegateCache.indexOf(thisItem)
                        d.delegateCache.splice(idx, 1)
//                        print("cache is now", d.delegateCache.length)
                    })

                    thisItem.swipe.opened.connect(function() {
                        for (var j = 0; j < d.delegates.length; j++) {
                            var otherItem = d.delegates[j];
                            if (thisItem === otherItem) {
                                continue;
                            }
                            if (!otherItem.hasOwnProperty("swipe")) {
                                continue;
                            }
                            otherItem.swipe.close();
                        }
                    })
                }
            }
        }
    }
}
