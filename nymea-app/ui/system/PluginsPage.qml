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

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Nymea

import "../components"

SettingsPageBase {
    id: root
    header: NymeaHeader {
        text: qsTr("Plugins")
        backButtonVisible: true
        onBackPressed: pageStack.pop()

        HeaderButton {
            visible: false
            imageSource: "qrc:/icons/configure.svg"
            color: pluginsProxy.showOnlyConfigurable ? Style.accentColor : Style.iconColor
            onClicked: {
                pluginsProxy.showOnlyConfigurable = !pluginsProxy.showOnlyConfigurable
            }
        }
    }

    Button {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        text: qsTr("Install more plugins")
        visible: packagesFilterModel.count > 0
        onClicked: {
            pageStack.push(Qt.resolvedUrl("PackageListPage.qml"), {filter: "nymea-plugin"})
        }
        PackagesFilterModel {
            id: packagesFilterModel
            packages: engine.systemController.packages
            nameFilter: "nymea-plugin"
        }

    }

    SettingsPageSectionHeader {
        text: qsTr("Installed integration plugins")
    }

    Repeater {
        model: PluginsProxy {
            id: pluginsProxy
            plugins: engine.thingManager.plugins
        }

        delegate: NymeaSwipeDelegate {
            Layout.fillWidth: true
            property Plugin plugin: pluginsProxy.get(index)
            iconName: "qrc:/icons/plugin.svg"
            text: model.name
            progressive: plugin.paramTypes.count > 0
            onClicked: if (progressive) { pageStack.push(Qt.resolvedUrl("PluginParamsPage.qml"), {plugin: plugin}) }
        }
    }
}
