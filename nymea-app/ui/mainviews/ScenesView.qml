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
import QtQuick.Controls.Material 2.2
import "../components"

MainViewBase {
    id: root

    contentY: interfacesGridView.contentY - interfacesGridView.originY + topMargin

    GridView {
        id: interfacesGridView
        anchors.fill: parent
        anchors.margins: app.margins / 2
        topMargin: root.topMargin
        bottomMargin: root.bottomMargin

        readonly property int minTileWidth: 172
        readonly property int tilesPerRow: root.width / minTileWidth

        model: RulesFilterModel {
            rules: engine.ruleManager.rules
            filterExecutable: true
        }
        cellWidth: width / tilesPerRow
        cellHeight: cellWidth

        delegate: MainPageTile {
            width: interfacesGridView.cellWidth
            height: interfacesGridView.cellHeight
            iconName: iconTag ? "qrc:/icons/" + iconTag.value + ".svg" : "qrc:/icons/slideshow.svg";
            fallbackIconName: "qrc:/icons/slideshow.svg"
            iconColor: colorTag && colorTag.value.length > 0 ? colorTag.value : Style.accentColor;
            lowerText: model.name

            property var colorTag: engine.tagsManager.tags.findRuleTag(model.id, "color")
            property var iconTag: engine.tagsManager.tags.findRuleTag(model.id, "icon")

            onClicked: engine.ruleManager.executeActions(model.id)

            Connections {
                target: engine.tagsManager.tags
                onCountChanged: {
                    colorTag = engine.tagsManager.tags.findRuleTag(model.id, "color")
                    iconTag = engine.tagsManager.tags.findRuleTag(model.id, "icon")
                }
            }
        }
    }


    EmptyViewPlaceholder {
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        anchors.verticalCenter: parent.verticalCenter
        visible: interfacesGridView.count === 0 && !engine.thingManager.fetchingData
        title: qsTr("There are no scenes set up yet.")
        text: engine.thingManager.things.count === 0 ?
                  qsTr("It appears there are no things set up either yet. In order to use scenes you need to add some things first.") :
                  qsTr("Scenes provide a useful way to control your things with just one click.")
        imageSource: "qrc:/icons/slideshow.svg"
        buttonText: engine.thingManager.things.count === 0 ? qsTr("Add things") : qsTr("Add scenes")
        onButtonClicked: {
            if (engine.thingManager.things.count === 0) {
                pageStack.push(Qt.resolvedUrl("../thingconfiguration/NewThingPage.qml"))
            } else {
                var newRule = engine.ruleManager.createNewRule();
                d.editRulePage = pageStack.push(Qt.resolvedUrl("../magic/EditRulePage.qml"), {rule: newRule });
                d.editRulePage.startAddAction();
                d.editRulePage.StackView.onRemoved.connect(function() {
                    newRule.destroy();
                })
                d.editRulePage.onAccept.connect(function() {
                    d.editRulePage.busy = true;
                    engine.ruleManager.addRule(d.editRulePage.rule);
                })
                d.editRulePage.onCancel.connect(function() {
                    pageStack.pop();
                })
            }
        }
    }
}
