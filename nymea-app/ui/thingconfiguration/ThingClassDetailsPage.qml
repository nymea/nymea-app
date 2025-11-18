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
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"

SettingsPageBase {
    id: root
    property Thing thing: null
    readonly property ThingClass thingClass: thing ? thing.thingClass : null

    header: NymeaHeader {
        text: root.thingClass.displayName
        onBackPressed: pageStack.pop()
    }

    SettingsPageSectionHeader {
        text: qsTr("Type")
    }

    NymeaSwipeDelegate {
        Layout.fillWidth: true
        text: root.thingClass.displayName
        subText: root.thingClass.id.toString().replace(/[{}]/g, "")
        progressive: false
        onClicked: {
            PlatformHelper.toClipBoard(subText);
            ToolTip.show(qsTr("ID copied to clipboard"), 500);
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Interfaces")
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        wrapMode: Text.WordWrap
        text: root.thingClass.interfaces.join(", ") + (root.thingClass.providedInterfaces.length > 0 ? " (" + root.thingClass.providedInterfaces.join(", ") + ")" : "")
    }


    SettingsPageSectionHeader {
        text: qsTr("Parameters")
        visible: root.thingClass.paramTypes.count > 0
    }

    Repeater {
        model: root.thingClass.paramTypes
        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: root.thingClass.paramTypes.get(index).displayName
            subText: root.thingClass.paramTypes.get(index).id.toString().replace(/[{}]/g, "")
            progressive: false
            onClicked: {
                PlatformHelper.toClipBoard(subText);
                ToolTip.show(qsTr("ID copied to clipboard"), 500);
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Settings")
        visible: root.thingClass.settingsTypes.count > 0
    }

    Repeater {
        model: root.thingClass.settingsTypes
        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: root.thingClass.settingsTypes.get(index).displayName
            subText: root.thingClass.settingsTypes.get(index).id.toString().replace(/[{}]/g, "")
            progressive: false
            onClicked: {
                PlatformHelper.toClipBoard(subText);
                ToolTip.show(qsTr("ID copied to clipboard"), 500);
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Events")
        visible: root.thingClass.eventTypes.count > 0
    }

    Repeater {
        model: root.thingClass.eventTypes
        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: root.thingClass.eventTypes.get(index).displayName
            subText: root.thingClass.eventTypes.get(index).id.toString().replace(/[{}]/g, "")
            progressive: false
            onClicked: {
                PlatformHelper.toClipBoard(subText);
                ToolTip.show(qsTr("ID copied to clipboard"), 500);
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("States")
        visible: root.thingClass.stateTypes.count > 0
    }

    Repeater {
        model: root.thingClass.stateTypes
        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: root.thingClass.stateTypes.get(index).displayName
            subText: root.thingClass.stateTypes.get(index).id.toString().replace(/[{}]/g, "")
            progressive: false
            onClicked: {
                PlatformHelper.toClipBoard(subText);
                ToolTip.show(qsTr("ID copied to clipboard"), 500);
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Actions")
        visible: root.thingClass.actionTypes.count > 0
    }

    Repeater {
        model: root.thingClass.actionTypes
        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: root.thingClass.actionTypes.get(index).displayName
            subText: root.thingClass.actionTypes.get(index).id.toString().replace(/[{}]/g, "")
            progressive: false
            onClicked: {
                PlatformHelper.toClipBoard(subText);
                ToolTip.show(qsTr("ID copied to clipboard"), 500);
            }
        }
    }
}
