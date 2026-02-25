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
import QtCharts
import Nymea
import NymeaApp.Utils

import "../../components"
import "../../delegates"

DashboardDelegateBase {
    id: root
    property DashboardStateItem item: null

    readonly property Thing thing: engine.thingManager.fetchingData ? null : engine.thingManager.things.getThing(root.item.thingId)
    readonly property StateType stateType: thing ? thing.thingClass.stateTypes.getStateType(item.stateTypeId) : null
    readonly property State state: thing ? thing.state(root.item.stateTypeId) : null

    contentItem: MainPageTile {
        id: delegateRoot
        height: root.height
        width: root.width
//        lowerText: root.thing.name + "\n" + root.stateType.displayName
//        iconName: NymeaUtils.namedIcon(root.item.icon)
        iconColor: Style.accentColor
//        onClicked: pageStack.push(Qt.resolvedUrl("DashboardPage.qml"), {item: root.item})
        onPressAndHold: root.longPressed();
        contentItem: Item {
            id: bottomLayout
            width: parent.width
            height: parent.height

            RowLayout {
                anchors.fill: parent
                anchors.margins: Style.smallMargins

                ColorIcon {
                    size: Style.iconSize
                    name: root.thing ? app.interfacesToIcon(root.thing.thingClass.interfaces) : ""
                }

                Label {
                    Layout.fillWidth: true
                    text: root.thing ? root.thing.name : ""
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    maximumLineCount: 2
                    font: Style.smallFont
                }
            }
        }

        ColumnLayout {
            width: parent.width
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -bottomLayout.height / 2

            Label {
                Layout.fillWidth: true
                visible: root.stateType && root.stateType.type.toLowerCase() != "bool"
                horizontalAlignment: Text.AlignHCenter
                font: Style.largeFont
                elide: Text.ElideRight
                text: root.state ?
                          1.0 * Math.round(Types.toUiValue(root.state.value, root.stateType.unit) * Math.pow(10, 1)) / Math.pow(10, 1) + " " + Types.toUiUnit(root.stateType.unit)
                        : ""
            }

            Led {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Style.bigIconSize
                Layout.preferredHeight: Style.bigIconSize
                anchors.verticalCenterOffset: -bottomLayout.height / 2
                visible: root.stateType && root.stateType.type.toLowerCase() === "bool"
                state: root.state && root.state.value === true ? "on" : "off"
            }

            Label {
                Layout.fillWidth: true
                text: root.stateType ? root.stateType.displayName.toUpperCase() : ""
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Style.smallFont.pixelSize
                font.letterSpacing: 1
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 2

            }

        }
    }
}
