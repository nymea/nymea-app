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

Dialog {
    id: root
    width: Math.min(parent.width * .8, Math.max(contentLabel.implicitWidth, 400))
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    property alias headerIcon: headerColorIcon.name
    property alias text: contentLabel.text
    default property alias children: content.children

    standardButtons: Dialog.Ok

    onClosed: root.destroy()

    // Connections {
    //     target: root.parent
    //     onDestroye: root.destroy()
    // }

    MouseArea {
        parent: app.overlay
        anchors.fill: parent
        z: -1
        onPressed: {
            print("Dialog: eating mouse press", root.title)
            mouse.accepted = true
        }
    }

    header: Item {
        implicitHeight: headerRow.height + app.margins
        implicitWidth: parent.width
        visible: root.title.length > 0
        RowLayout {
            id: headerRow
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: app.margins }
            spacing: app.margins
            ColorIcon {
                id: headerColorIcon
                Layout.preferredHeight: Style.hugeIconSize
                Layout.preferredWidth: height
                color: Style.accentColor
                visible: name.length > 0
            }

            Label {
                id: titleLabel
                Layout.fillWidth: true
                Layout.margins: app.margins
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: root.title
                color: Style.accentColor
                font.pixelSize: app.largeFont
            }
        }
    }
    contentItem: ColumnLayout {
        id: content

        Label {
            id: contentLabel
            Layout.fillWidth: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            visible: text.length > 0
        }
    }
}
