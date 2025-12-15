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
import Qt5Compat.GraphicalEffects
import Nymea

import "../components"

ThingsListPageBase {
    id: root

    property string iconBasename

    property bool invertControls: false

    header: NymeaHeader {
        id: header
        onBackPressed: pageStack.pop()
        text: root.title

        HeaderButton {
            imageSource: root.invertControls ? "qrc:/icons/down.svg" : "qrc:/icons/up.svg"
            onClicked: {
                for (var i = 0; i < thingProxy.count; i++) {
                    var thing = thingsProxy.get(i);
                    var actionType = thing.thingClass.actionTypes.findByName("open");
                    engine.thingManager.executeAction(thing.id, actionType.id)
                }
            }
        }
        HeaderButton {
            imageSource: "qrc:/icons/media-playback-stop.svg"
            onClicked: {
                for (var i = 0; i < thingsProxy.count; i++) {
                    var thing = thingsProxy.get(i);
                    var actionType = thing.thingClass.actionTypes.findByName("stop");
                    engine.thingManager.executeAction(thing.id, actionType.id)
                }
            }
        }
        HeaderButton {
            imageSource: root.invertControls ? "qrc:/icons/up.svg" : "qrc:/icons/down.svg"
            onClicked: {
                for (var i = 0; i < thingsProxy.count; i++) {
                    var thing = thingsProxy.get(i);
                    var actionType = thing.thingClass.actionTypes.findByName("close");
                    engine.thingManager.executeAction(thing.id, actionType.id)
                }
            }
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentGrid.implicitHeight
        topMargin: app.margins / 2
        clip: true

        GridLayout {
            id: contentGrid
            width: parent.width - app.margins
            anchors.horizontalCenter: parent.horizontalCenter
            columns: Math.ceil(width / 600)
            rowSpacing: 0
            columnSpacing: 0
            Repeater {
                model: root.thingsProxy

                delegate: BigThingTile {
                    id: itemDelegate
                    Layout.preferredWidth: contentGrid.width / contentGrid.columns
                    thing: root.thingsProxy.getThing(model.id)
                    showHeader: false
                    topPadding: 0
                    bottomPadding: 0

                    onClicked: {
                        if (isEnabled) {
                            root.enterPage(index)
                        } else {
                            itemDelegate.wobble()
                        }
                    }

                    property State movingState: thing.stateByName("moving")
                    property State percentageState: thing.stateByName("percentage")

                    contentItem: RowLayout {
                        spacing: app.margins

                        ColorIcon {
                            Layout.preferredHeight: Style.iconSize
                            Layout.preferredWidth: Style.iconSize
                            color: itemDelegate.movingState && itemDelegate.movingState.value === true
                                   ? Style.accentColor
                                   : Style.iconColor
                            name: itemDelegate.percentageState
                                  ? root.iconBasename + "-" + app.pad(Math.round(itemDelegate.percentageState.value / 10) * 10, 3) + ".svg"
                                  : root.iconBasename + "-050.svg"
                        }

                        Label {
                            Layout.fillWidth: true
                            text: itemDelegate.thing.name
                            elide: Text.ElideRight
                            enabled: itemDelegate.isEnabled
                        }

                        ThingStatusIcons {
                            thing: itemDelegate.thing
                        }

                        ShutterControls {
                            id: shutterControls
                            Layout.fillWidth: false
                            Layout.preferredWidth: Style.iconSize * 5
                            Layout.preferredHeight: Style.iconSize
                            height: parent.height
                            thing: itemDelegate.thing
                            invert: root.invertControls
                            enabled: itemDelegate.isEnabled
                        }
                    }
                }
            }
        }
    }
}
