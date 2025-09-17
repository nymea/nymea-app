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

    property bool signup: true

    // Only used when signup is true
    property int minPasswordLength: 8
    property bool requireSpecialChar: true
    property bool requireNumber: true
    property bool requireUpperCaseLetter: true
    property bool requireLowerCaseLetter: true

    readonly property alias password: passwordTextField.text

    readonly property bool isValidPassword:
        isLongEnough &&
        (hasLower || !requireLowerCaseLetter) &&
        (hasUpper || !requireUpperCaseLetter) &&
        (hasNumbers || !requireNumber) &&
        (hasSpecialChar || !requireSpecialChar)

    readonly property bool isValid: !signup || (isValidPassword && confirmationMatches)

    readonly property bool isLongEnough: passwordTextField.text.length >= minPasswordLength
    readonly property bool hasLower: passwordTextField.text.search(/[a-z]/) >= 0
    readonly property bool hasUpper: passwordTextField.text.search(/[A-Z/]/) >= 0
    readonly property bool hasNumbers: passwordTextField.text.search(/[0-9]/) >= 0    
    readonly property bool hasSpecialChar: passwordTextField.text.search(/(?=.*?[$*.\[\]{}()?\-'"!@#%&/\\,><':;|_~`^])/) >= 0
    readonly property bool confirmationMatches: passwordTextField.text === confirmationPasswordTextField.text

    property bool hiddenPassword: true

    property bool showErrors: false

    signal accepted()

    RowLayout {
        Layout.fillWidth: true

        NymeaTextField {
            id: passwordTextField
            Layout.fillWidth: true
            echoMode: root.hiddenPassword ? TextInput.Password : TextInput.Normal
            placeholderText: root.signup ? qsTr("Pick a password") : qsTr("Password")

            error: root.showErrors && !root.isValidPassword
//            palette.toolTipBase: Style.tooltipBackgroundColor
            ToolTip.visible: root.signup && focus && !root.isValidPassword
            ToolTip.delay: 1000
            ToolTip.onVisibleChanged: print("Tooltip visible changed:", ToolTip.visible, focus, root.isValidPassword)
            ToolTip.text: {
                var texts = []
                var checks = []
                texts.push(qsTr("Minimum %1 characters").arg(root.minPasswordLength))
                checks.push(root.isLongEnough)
                if (root.requireLowerCaseLetter) {
                    texts.push(qsTr("Lowercase letters"))
                    checks.push(root.hasLower)
                }
                if (root.requireUpperCaseLetter) {
                    texts.push(qsTr("Uppercase letters"))
                    checks.push(root.hasUpper)
                }
                if (root.requireNumber) {
                    texts.push(qsTr("Numbers"))
                    checks.push(root.hasNumbers)
                }
                if (root.requireSpecialChar) {
                    texts.push(qsTr("Special characters"))
                    checks.push(root.hasSpecialChar)
                }
                var ret = []
                for (var i = 0; i < texts.length; i++) {
                    var entry = "<font color=\"%1\">• ".arg(checks[i] ? "#ffffff" : Style.red)
                    entry += texts[i]
                    entry += "</font>"
                    ret.push(entry)
                }
                return ret.join("<br>")
            }

            onAccepted: {
                if (!root.signup) {
                    root.accepted()
                } else {
                    confirmationPasswordTextField.focus = true
                }
            }

        }
        ColorIcon {
            Layout.preferredHeight: Style.iconSize
            Layout.preferredWidth: Style.iconSize
            name: "qrc:/icons/eye.svg"
            color: root.hiddenPassword ? Style.iconColor : Style.accentColor
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.hiddenPassword = !root.hiddenPassword
                }
            }
        }
    }

    RowLayout {
        visible: root.signup

        NymeaTextField {
            id: confirmationPasswordTextField
            Layout.fillWidth: true
            echoMode: root.hiddenPassword ? TextInput.Password : TextInput.Normal
            placeholderText: qsTr("Confirm password")
            error: root.showErrors && (!root.isValidPassword || !root.confirmationMatches)

            onAccepted: root.accepted()
        }
    }
}
