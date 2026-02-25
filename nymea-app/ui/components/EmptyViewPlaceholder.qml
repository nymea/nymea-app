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

ColumnLayout {
    id: root
    spacing: app.margins

    property alias title: titleLabel.text
    property alias text: textLabel.text
    property alias imageSource: image.source
    property alias buttonText: button.text
    property alias buttonVisible: button.visible

    signal imageClicked();
    signal buttonClicked();

    Label {
        id: titleLabel
        font.pixelSize: app.largeFont
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        color: Style.accentColor
    }
    Label {
        id: textLabel
        Layout.fillWidth: true
        Layout.maximumWidth: 400
        Layout.alignment: Qt.AlignHCenter
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }
    Image {
        id: image
        Layout.preferredWidth: Style.iconSize * 5
        Layout.preferredHeight: width
        Layout.alignment: Qt.AlignHCenter
        sourceSize.width: Style.iconSize * 5
        sourceSize.height: Style.iconSize * 5
        MouseArea {
            anchors.fill: parent
            onClicked: root.imageClicked();
        }
    }
    Button {
        id: button
        Layout.fillWidth: true
        Layout.maximumWidth: 400
        Layout.alignment: Qt.AlignHCenter
        onClicked: root.buttonClicked();
    }
}
