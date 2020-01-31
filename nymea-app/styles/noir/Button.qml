/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.9
import QtQuick.Templates 2.2 as T
import QtQuick.Controls 2.2
import QtQuick.Controls.impl 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Controls.Material.impl 2.2

T.Button {
    id: control

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             contentItem.implicitHeight + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    // external vertical padding is 6 (to increase touch area)
    padding: 12
    leftPadding: padding - 4
    rightPadding: padding - 4

    Material.elevation: flat ? control.down || control.hovered ? 2 : 0
                             : control.down ? 8 : 2
    Material.background: flat ? "transparent" : undefined

    contentItem: Text {
        text: control.text
        font.bold: control.font.bold
        font.capitalization: Font.AllUppercase
        font.family: control.font.family
        font.hintingPreference: control.font.hintingPreference
        font.italic: control.font.italic
        font.letterSpacing: control.font.letterSpacing
        font.overline: control.font.overline
        font.pixelSize: app.smallFont
        font.weight: Font.Bold
        color: app.foregroundColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    // TODO: Add a proper ripple/ink effect for mouse/touch input and focus state
    background: Rectangle {
        implicitWidth: 64
        implicitHeight: 40

        // external vertical padding is 6 (to increase touch area)
        y: 6
        width: parent.width
        height: parent.height - 12
        radius: height / 2
        color: !control.enabled ? control.Material.buttonDisabledColor :
                control.highlighted ? control.Material.highlightedButtonColor : control.Material.accentColor

        PaddedRectangle {
            y: parent.height - 4
            width: parent.width
            height: 4
            radius: 2
            topPadding: -2
            clip: true
            visible: control.checkable && (!control.highlighted || control.flat)
            color: control.checked && control.enabled ? control.Material.accentColor : control.Material.secondaryTextColor
        }

        // The layer is disabled when the button color is transparent so you can do
        // Material.background: "transparent" and get a proper flat button without needing
        // to set Material.elevation as well
        layer.enabled: control.enabled && control.Material.buttonColor.a > 0
        layer.effect: ElevationEffect {
            elevation: control.Material.elevation
        }

        Ripple {
            clipRadius: 2
            width: parent.width
            height: parent.height
            pressed: control.pressed
            anchor: control
            active: control.down || control.visualFocus || control.hovered
            color: control.Material.rippleColor
        }
    }
}
