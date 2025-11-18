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
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.2
import Nymea 1.0

InfoPaneBase {
    id: root

    property alias text: textLabel.text
    property alias imageSource: icon.name
    property alias buttonText: button.text

    property color textColor: "white"

    property bool rotatingIcon: false

    signal buttonClicked();

    contentItem: RowLayout {
        id: contentRow
        anchors { left: parent.left; top: parent.top; right: parent.right }

        Label {
            id: textLabel
            color: root.textColor
            font.pixelSize: app.smallFont
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            wrapMode: Text.WordWrap
        }
        ColorIcon {
            id: icon
            Layout.preferredHeight: Style.smallIconSize
            Layout.preferredWidth: height
            color: root.textColor
            visible: name.length > 0

            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 2000
                loops: Animation.Infinite
                running: root.rotatingIcon
                onStopped: icon.rotation = 0;
            }
        }

        Button {
            id: button
            Layout.leftMargin: app.margins
            visible: text.length > 0
            onClicked: root.buttonClicked()
        }
    }
}


