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

import QtQuick 2.4
import QtQuick.Window 2.3

Item {
    id: root
    implicitHeight: d.active
                    ? d.kbd.height
                    : (Qt.inputMethod.visible ? Math.max(0, Qt.inputMethod.keyboardRectangle.height / Screen.devicePixelRatio) : 0)


    Behavior on implicitHeight { NumberAnimation { duration: 130; easing.type: Easing.InOutQuad } }

    QtObject {
        id: d
        property bool active: d.kbd && d.kbd.active
        property var kbd: null
        property string virtualKeyboardString:
            '
            import QtQuick 2.8;
            import QtQuick.VirtualKeyboard 2.1
            InputPanel {
                id: inputPanel
                y: Qt.inputMethod.visible ? parent.height - inputPanel.height : parent.height
                anchors.left: parent.left
                anchors.right: parent.right
            }
            '
    }


    Component.onCompleted: {
        if (useVirtualKeyboard) {
            d.kbd = Qt.createQmlObject(d.virtualKeyboardString, root);
        }
    }
}
