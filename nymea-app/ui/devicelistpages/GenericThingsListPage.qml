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
import QtQuick.Layouts
import Nymea

import "../components"
import "../delegates"

ThingsListPageBase {
    id: root

    header: NymeaHeader {
        text: {
            if (root.shownInterfaces.length === 1) {
                return qsTr("My %1").arg(app.interfaceToString(root.shownInterfaces[0]))
            } else if (root.shownInterfaces.length > 1 || root.hiddenInterfaces.length > 0) {
                return qsTr("My things")
            }
            return qsTr("All my things")
        }

        onBackPressed: {
            pageStack.pop()
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

                    property State connectedState: thing.stateByName("connected")
                    property State powerState: thing.stateByName("power")

                    contentItem: RowLayout {
                        spacing: app.margins

                        ColorIcon {
                            Layout.preferredHeight: Style.iconSize
                            Layout.preferredWidth: Style.iconSize
                            name: app.interfacesToIcon(itemDelegate.thing.thingClass.interfaces)
                            color: itemDelegate.powerState && itemDelegate.powerState.value === true ? Style.accentColor : Style.iconColor
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
                    }
                }
            }
        }
    }
}
