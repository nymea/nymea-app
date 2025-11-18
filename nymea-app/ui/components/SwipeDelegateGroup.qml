// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.9
import QtQuick.Controls 2.2

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
