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
    readonly property var passwordRequirements: {
        var requirements = []
        requirements.push({
            text: qsTr("Minimum %1 characters").arg(root.minPasswordLength),
            fulfilled: root.isLongEnough
        })

        if (root.requireLowerCaseLetter) {
            requirements.push({
                text: qsTr("Lowercase letters"),
                fulfilled: root.hasLower
            })
        }

        if (root.requireUpperCaseLetter) {
            requirements.push({
                text: qsTr("Uppercase letters"),
                fulfilled: root.hasUpper
            })
        }

        if (root.requireNumber) {
            requirements.push({
                text: qsTr("Numbers"),
                fulfilled: root.hasNumbers
            })
        }

        if (root.requireSpecialChar) {
            requirements.push({
                text: qsTr("Special characters"),
                fulfilled: root.hasSpecialChar
            })
        }
        return requirements
    }

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

            ToolTip {
                id: passwordRequirementsToolTip
                parent: passwordTextField
                visible: root.signup && passwordTextField.focus && !root.isValidPassword
                delay: 1000
                timeout: -1
                x: 0
                y: passwordTextField.height + Style.smallMargins
                leftPadding: Style.smallMargins
                rightPadding: Style.smallMargins
                topPadding: Style.smallMargins
                bottomPadding: Style.smallMargins

                background: Rectangle {
                    color: Style.tooltipBackgroundColor
                    radius: Style.smallCornerRadius
                }

                contentItem: Column {
                    spacing: Style.extraSmallMargins

                    Repeater {
                        model: root.passwordRequirements

                        delegate: Row {
                            spacing: Style.extraSmallMargins

                            CheckBox {
                                anchors.verticalCenter: parent.verticalCenter
                                checked: modelData.fulfilled
                                checkable: false
                                opacity: 1
                            }

                            Label {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.text
                                color: Style.foregroundColor
                            }
                        }
                    }
                }
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

    spacing: root.signup ? Style.margins : 0

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
