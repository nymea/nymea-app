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
import QtQuick.Layouts 1.2
import QtCharts 2.2
import Nymea 1.0
import "../../components"
import "../../delegates"

DashboardDelegateBase {
    id: root
    property DashboardSceneItem item: null

    readonly property Rule rule: item && !engine.ruleManager.fetchingData ? engine.ruleManager.rules.getRule(item.ruleId) : null

    property var colorTag: engine.tagsManager.tags.findRuleTag(root.item.ruleId, "color")
    property var iconTag: engine.tagsManager.tags.findRuleTag(root.item.ruleId, "icon")

    contentItem: MainPageTile {
        width: root.width
        height: root.height
        iconName: iconTag ? "qrc:/icons/" + iconTag.value + ".svg" : "qrc:/icons/slideshow.svg";
        fallbackIconName: "qrc:/icons/slideshow.svg"
        iconColor: colorTag && colorTag.value.length > 0 ? colorTag.value : Style.accentColor;
        lowerText: root.rule ? root.rule.name : ""

        onClicked: engine.ruleManager.executeActions(root.item.ruleId)
        onPressAndHold: root.longPressed()

        Connections {
            target: engine.tagsManager.tags
            onCountChanged: {
                colorTag = engine.tagsManager.tags.findRuleTag(root.item.ruleId, "color")
                iconTag = engine.tagsManager.tags.findRuleTag(root.item.ruleId, "icon")
            }
        }
    }
}
