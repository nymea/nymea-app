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

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "../components"
import "../delegates"
import Nymea 1.0

SettingsPageBase {
    id: root
    property var plugin: null

    header: NymeaHeader {
        text: plugin.name
        backButtonVisible: true
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "qrc:/icons/tick.svg"
            onClicked: {
                pluginConfigManager.savePluginConfig()
            }
        }
    }

    Connections {
        target: engine.thingManager
        onSavePluginConfigReply: {
            if (thingError === Thing.ThingErrorNoError) {
                pageStack.pop();
            } else {
                console.warn("Error saving plugin params:", thingError)
                var dialog = errorDialog.createObject(root, {error: thingError});
                dialog.open();
            }
        }
    }

    PluginConfigManager {
        id: pluginConfigManager
        engine: _engine
        plugin: root.plugin
    }

    SettingsPageSectionHeader {
        text: qsTr("Settings")
    }

    Repeater {
        model: pluginConfigManager.params

        delegate: ParamDelegate {
            Layout.fillWidth: true
            paramType: root.plugin.paramTypes.getParamType(model.id)
            param: pluginConfigManager.params.getParam(model.id)
        }
    }

    Component {
        id: errorDialog
        ErrorDialog { }
    }
}
