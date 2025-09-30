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

import QtQuick
import Nymea

Item {
    id: arrows
    width: Style.iconSize * 2
    height: parent.height * .6
    clip: true
    visible: state !== ""

    state: "" // "opening", "closing" or ""

    readonly property bool up: arrows.state === "opening"

    // NumberAnimation doesn't reload to/from while it's running. If we switch from closing to opening or vice versa
    // we need to somehow stop and start the animation
    property bool animationHack: true
    onAnimationHackChanged: {
        if (!animationHack) hackTimer.start();
    }
    Timer { id: hackTimer; interval: 1; onTriggered: arrows.animationHack = true }
    onStateChanged: arrows.animationHack = false

    NumberAnimation {
        target: arrowColumn
        property: "y"
        duration: 500
        easing.type: Easing.Linear
        from: arrows.up ? Style.iconSize : -Style.iconSize
        to: arrows.up ? -Style.iconSize : Style.iconSize
        loops: Animation.Infinite
        running: arrows.animationHack && (arrows.state === "opening" || arrows.state === "closing")
    }

    Column {
        id: arrowColumn
        width: parent.width

        Repeater {
            model: arrows.height / Style.iconSize + 1
            ColorIcon {
                name: arrows.up ? "qrc:/icons/up.svg" : "qrc:/icons/down.svg"
                width: parent.width
                height: width
                color: Style.accentColor
            }
        }
    }
}
