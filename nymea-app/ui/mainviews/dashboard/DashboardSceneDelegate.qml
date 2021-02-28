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
        iconName: iconTag ? "/ui/images/" + iconTag.value + ".svg" : "/ui/images/slideshow.svg";
        fallbackIconName: "/ui/images/slideshow.svg"
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
