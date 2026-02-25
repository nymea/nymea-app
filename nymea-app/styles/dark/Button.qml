// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
// Copyright (C) 2017 The Qt Company Ltd.
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
import QtQuick.Templates as T
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    topInset: 6
    bottomInset: 6
    verticalPadding: Material.buttonVerticalPadding
    leftPadding: Material.buttonLeftPadding(flat, hasIcon && (display !== AbstractButton.TextOnly))
    rightPadding: Material.buttonRightPadding(flat, hasIcon && (display !== AbstractButton.TextOnly),
                                              (text !== "") && (display !== AbstractButton.IconOnly))
    spacing: 8

    icon.width: 24
    icon.height: 24
    icon.color: !enabled ? Material.hintTextColor :
        (control.flat && control.highlighted) || (control.checked && !control.highlighted) ? Material.accentColor :
        highlighted ? Material.primaryHighlightedTextColor : Material.foreground

    readonly property bool hasIcon: icon.name.length > 0 || icon.source.toString().length > 0

    Material.elevation: control.down ? 8 : 2
    Material.roundedScale: Material.FullScale

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display

        icon: control.icon
        text: control.text
        font: control.font
        color: !control.enabled ? control.Material.hintTextColor :
            (control.flat && control.highlighted) || (control.checked && !control.highlighted) ? control.Material.accentColor :
            control.highlighted ? control.Material.primaryHighlightedTextColor : control.Material.foreground
    }

    background: Rectangle {
        implicitWidth: 64
        implicitHeight: control.Material.buttonHeight

        radius: control.Material.roundedScale === Material.FullScale ? height / 2 : control.Material.roundedScale
        color: control.Material.buttonColor(control.Material.theme, control.Material.background,
            control.Material.accent, control.enabled, control.flat, control.highlighted, control.checked)

        // The layer is disabled when the button color is transparent so you can do
        // Material.background: "transparent" and get a proper flat button without needing
        // to set Material.elevation as well
        layer.enabled: control.enabled && color.a > 0 && !control.flat
        layer.effect: RoundedElevationEffect {
            elevation: control.Material.elevation
            roundedScale: control.background.radius
        }

        Ripple {
            clip: true
            clipRadius: parent.radius
            width: parent.width
            height: parent.height
            pressed: control.pressed
            anchor: control
            active: enabled && (control.down || control.visualFocus || control.hovered)
            color: control.flat && control.highlighted ? control.Material.highlightedRippleColor : control.Material.rippleColor
        }
    }
}
