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
import QtQuick.Layouts
import QtQuick.Controls

import NymeaApp.Utils 1.0

RowLayout {
    id: root

    property var from
    property var to

    property var value
    property var showValue

    property bool floatingPoint: false

    property bool editable: true

    signal valueModified(var value)

    QtObject {
        id: internal
        property bool reactToValueChanged: true
    }

    function parseUserInputFloat(text) {
        if (typeof text === "string") {
            if (text.includes(",")) {
                text = text.replace(",", ".")
            }
            return parseFloat(text)
        } else {
            return text
        }
    }

    function toUserVisibleFloat(value) {
        if (!Number.isFinite(value)) {
            console.warn("Expected a finite number!")
            return value
        }

        var text = value.toFixed(NymeaUtils.numDecimals(value))
        if (typeof root.showValue === "string" && root.showValue.includes(",")) {
            text = text.replace(".", ",")
        }
        return text
    }

    Component.onCompleted: {
        if (root.floatingPoint) {
            root.showValue = NymeaUtils.floatToLocaleString(root.value)
        } else {
            root.showValue = root.value
        }
    }

    onValueChanged: {
        // Value was changed from outside (e.g. when resetting parameter values to
        // defaults in SetupWizard). showValue needs to be set in this case explicitely
        // to reflect the change of value.
        if (internal.reactToValueChanged && status === Component.Ready) {
            root.showValue = toUserVisibleFloat(root.value)
        }
    }

    ColorIcon {
        name: "remove"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var tmp = NaN
                if (root.floatingPoint) {
                    tmp = parseUserInputFloat(root.value)
                } else {
                    tmp = parseInt(root.value)
                }
                if (!isNaN(tmp)){
                    internal.reactToValueChanged = false
                    root.value = Math.max(root.from, tmp - 1)
                    root.showValue = toUserVisibleFloat(root.value)
                    root.valueModified(root.value)
                    internal.reactToValueChanged = true
                }
            }
        }
    }
    TextField {
        text: root.showValue
        readOnly: !root.editable
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
        onTextEdited: {
            internal.reactToValueChanged = false
            root.showValue = text
            var input = text
            if (input.includes(",")) {
                input = input.replace(",", ".")
            }
            root.value = input
            root.valueModified(root.value)
            internal.reactToValueChanged = true
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
                    tmp = parseUserInputFloat(root.value)
                } else {
                    tmp = parseInt(root.value)
                }
                if (!isNaN(tmp)){
                    internal.reactToValueChanged = false
                    root.value = Math.min(root.to, tmp + 1)
                    root.showValue = toUserVisibleFloat(root.value)
                    root.valueModified(root.value)
                    internal.reactToValueChanged = true
                }
            }
        }
    }
}
