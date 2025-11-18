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
import NymeaApp.Utils 1.0
import "../../components"
import "../../delegates"

DashboardDelegateBase {
    id: root
    property DashboardFolderItem item: null

    configurable: true

    function configure() {
        print("configure called")
        root.openDialog(configDialogComponent)
    }

    contentItem: MainPageTile {
        id: delegateRoot
        height: root.height
        width: root.width
//        text: root.item.name
        iconName: NymeaUtils.namedIcon(root.item.icon)
        iconColor: Style.accentColor
        onClicked: pageStack.push(Qt.resolvedUrl("DashboardPage.qml"), {item: root.item})
        onPressAndHold: root.longPressed();
        contentItem: Label {
            text: root.item.name
            width: parent.width
            height: parent.height
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            padding: app.margins / 2
        }
    }

    Component {
        id: configDialogComponent
        NymeaDialog {
            id: configDialog

            onAccepted: {
                root.item.name = nameTextField.text
            }

            TextField {
                id: nameTextField
                text: root.item.name
                Layout.fillWidth: true
                placeholderText: qsTr("Name")
            }

            GridView {
                id: iconsGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: Style.bigIconSize * 6
                model: Object.entries(NymeaUtils.namedIcons)
                property int columns: width / Style.bigIconSize - 1
                cellWidth: width / columns
                cellHeight: cellWidth
                clip: true
                delegate: MouseArea {
                    width: iconsGrid.cellWidth
                    height: iconsGrid.cellHeight
                    onClicked: {
                        print("clicked", modelData[0])
                        root.item.icon = modelData[0]
                    }

                    ColorIcon {
                        anchors.centerIn: parent
                        name: modelData[1]
                        color: modelData[0] == root.item.icon ? Style.accentColor : Style.iconColor
                        size: Style.bigIconSize
                    }
                }
            }
        }
    }
}

