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
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

SettingsPageBase {
    header: NymeaHeader {
        text: qsTr("Server logging categories")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ServerDebugManager {
        id: serverDebugManager
        engine: _engine
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: root.height
        visible: serverDebugManager.fetchingData

        BusyIndicator {
            anchors.centerIn: parent
            visible: serverDebugManager.fetchingData
            running: visible
        }
    }

    RowLayout {
        Layout.margins: Style.margins
        Item {
            Layout.fillWidth: true
        }
        Label {
            Layout.preferredWidth: Style.smallDelegateHeight
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Critical")
            elide: Text.ElideRight
            font: Style.smallFont
        }
        Label {
            Layout.preferredWidth: Style.smallDelegateHeight
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Warning")
            elide: Text.ElideRight
            font: Style.smallFont
        }
        Label {
            Layout.preferredWidth: Style.smallDelegateHeight
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Info")
            elide: Text.ElideRight
            font: Style.smallFont
        }
        Label {
            Layout.preferredWidth: Style.smallDelegateHeight
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Debug")
            elide: Text.ElideRight
            font: Style.smallFont
        }
    }

    ThinDivider {}

    Repeater {
        model: serverDebugManager.categories
        delegate: ItemDelegate {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.smallDelegateHeight
            contentItem: RowLayout {
                height: parent.height
                Label {
                    Layout.fillWidth: true
                    text: model.name
                    elide: Text.ElideRight
                }
                RadioButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: Style.smallDelegateHeight
                    checked: model.level === ServerLoggingCategory.LevelCritical
                    onClicked: serverDebugManager.setLoggingLevel(model.name, ServerLoggingCategory.LevelCritical)
                }
                RadioButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: Style.smallDelegateHeight
                    checked: model.level === ServerLoggingCategory.LevelWarning
                    onClicked: serverDebugManager.setLoggingLevel(model.name, ServerLoggingCategory.LevelWarning)
                }
                RadioButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: Style.smallDelegateHeight
                    checked: model.level === ServerLoggingCategory.LevelInfo
                    onClicked: serverDebugManager.setLoggingLevel(model.name, ServerLoggingCategory.LevelInfo)
                }
                RadioButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: Style.smallDelegateHeight
                    checked: model.level === ServerLoggingCategory.LevelDebug
                    onClicked: serverDebugManager.setLoggingLevel(model.name, ServerLoggingCategory.LevelDebug)
                }
            }
        }
    }
}
