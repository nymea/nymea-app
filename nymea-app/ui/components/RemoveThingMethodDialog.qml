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

Dialog {
    id: root
    width: Math.min(parent.width * .8, contentLabel.implicitWidth + app.margins * 2)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    modal: true

    property Thing thing: null
    property var rulesList: null

    ColumnLayout {
        width: parent.width
        Label {
            id: contentLabel
            text: qsTr("This thing is currently used in one or more rules:")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        ThinDivider {}
        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.iconSize * Math.min(count, 5)
            model: rulesList
            interactive: contentHeight > height
            delegate: Label {
                height: Style.iconSize
                width: parent.width
                elide: Text.ElideRight
                text: engine.ruleManager.rules.getRule(modelData).name
                verticalAlignment: Text.AlignVCenter
            }
        }
        ThinDivider {}

        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: qsTr("Remove all those rules")
            progressive: false
            onClicked: {
                engine.thingManager.removeThing(root.thing.id, ThingManager.RemovePolicyCascade)
                root.close()
                root.destroy();
            }
        }

        NymeaSwipeDelegate {
            text: qsTr("Update rules, removing this thing")
            Layout.fillWidth: true
            progressive: false
            onClicked: {
                engine.thingManager.removeThing(root.thing.id, ThingManager.RemovePolicyUpdate)
                root.close()
                root.destroy();
            }
        }

        NymeaSwipeDelegate {
            text: qsTr("Don't remove this thing")
            Layout.fillWidth: true
            progressive: false
            onClicked: {
                root.close()
                root.destroy();
            }
        }
    }
}
