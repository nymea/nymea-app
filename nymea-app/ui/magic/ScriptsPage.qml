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

import QtQuick 2.0
import Nymea 1.0
import QtQuick.Controls 2.2
import "../components"

Page {
    header: NymeaHeader {
        text: qsTr("Scripts")
        onBackPressed: pageStack.pop();

        HeaderButton {
            text: qsTr("Add new script")
            imageSource: "qrc:/icons/add.svg"
            onClicked: {
                pageStack.push("ScriptEditor.qml");
            }
        }
    }

    QtObject {
        id: d
        property int pendingAction: -1
    }

    Connections {
        target: engine.scriptManager
        onRemoveScriptReply: {
            if (id == d.pendingAction) {
                d.pendingAction = -1;
            }
        }
    }

    ListView {
        anchors.fill: parent
        model: engine.scriptManager.scripts
        delegate: NymeaSwipeDelegate {
            width: parent.width
            text: model.name
            iconName: "qrc:/icons/script.svg"
            canDelete: true
            onClicked: {
                pageStack.push("ScriptEditor.qml", {scriptId: model.id});
            }

            onDeleteClicked: {
                print("removing script", model.id)
                d.pendingAction = engine.scriptManager.removeScript(model.id);
            }
        }

        EmptyViewPlaceholder {
            anchors.centerIn: parent
            width: parent.width - app.margins * 2
            title: qsTr("No scripts are installed yet.")
            text: qsTr("Press \"Add script\" to get started.")
            imageSource: "qrc:/icons/script.svg"
            buttonText: qsTr("Add script")
            visible: engine.scriptManager.scripts.count === 0
            onButtonClicked: {
                pageStack.push("ScriptEditor.qml");
            }
        }
    }

    BusyOverlay {
        id: busyOverlay
        visible: d.pendingAction != -1
    }
}
