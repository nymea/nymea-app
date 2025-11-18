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

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import NymeaApp.Utils 1.0
import "../components"

Page {
    id: root

    property alias shownInterfaces: thingsProxyInternal.shownInterfaces
    property alias hiddenInterfaces: thingsProxyInternal.hiddenInterfaces
    property alias filterTagId: thingsProxyInternal.filterTagId

    property ThingsProxy thingsProxy: thingsProxyInternal

    function enterPage(index, interfaces) {
        if (interfaces === undefined) {
            interfaces = root.shownInterfaces
        }

        var thing = thingsProxy.get(index);
        print("matching interfaces", interfaces)
        var page = NymeaUtils.interfaceListToDevicePage(interfaces);
        pageStack.push(Qt.resolvedUrl("../devicepages/" + page), {thing: thingsProxy.get(index)})
    }

    ThingsProxy {
        id: thingsProxyInternal
        engine: _engine
    }
}
