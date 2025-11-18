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
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2

RowLayout {
    id: root

    property var from
    property var to

    property var value

    property bool floatingPoint: false

    property bool editable: true

    signal valueModified(var value)

    ColorIcon {
        name: "remove"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var tmp = NaN
                if (root.floatingPoint) {
                    tmp = parseFloat(root.value)
                } else {
                    tmp = parseInt(root.value)
                }
                if (tmp != NaN){
                    root.value = Math.max(root.from, tmp - 1)
                    root.valueModified(root.value)
                }
            }
        }
    }
    TextField {
        text: root.value
        readOnly: !root.editable
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
        onTextEdited: {
            root.value = text
            root.valueModified(root.value)
        }

        validator: root.floatingPoint ? doubleValidator : intValidator

        IntValidator {
            id: intValidator
            bottom: Math.min(root.from, root.to)
            top: Math.max(root.from, root.to)
        }

        DoubleValidator {
            id: doubleValidator
            bottom: Math.min(root.from, root.to)
            top:  Math.max(root.from, root.to)
        }

    }
    ColorIcon {
        name: "add"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var tmp = NaN
                if (root.floatingPoint) {
                    tmp = parseFloat(root.value)
                } else {
                    tmp = parseInt(root.value)
                }
                if (tmp != NaN){
                    root.value = Math.min(root.to, tmp + 1)
                    root.valueModified(root.value)
                }
            }
        }
    }
}
