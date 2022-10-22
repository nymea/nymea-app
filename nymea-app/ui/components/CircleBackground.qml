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

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import Nymea 1.0
import "../utils"

Item {
    id: root
    implicitHeight: 400
    implicitWidth: 400

    property alias iconSource: icon.name
    property color onColor: Style.accentColor
    property bool on: false
    property alias showOnGradient: opacityMask.visible

    readonly property Item contentItem: background

    signal clicked()


    Rectangle {
        id: background
        anchors.centerIn: parent
        height: Math.min(400, Math.min(parent.height, parent.width))
        width: height
        radius: width / 2
        color: Style.tileBackgroundColor
    }
    Rectangle {
        id: mask
        anchors.fill: background
        radius: height / 2
        visible: false
        color: "red"
    }

    MouseArea {
        anchors.fill: background
        onClicked: root.clicked()
    }

    ColorIcon {
        id: icon
        anchors.centerIn: background
        size: Math.min(Style.hugeIconSize, background.width * 0.4)
        color: root.on ? root.onColor : Style.iconColor
        Behavior on color { ColorAnimation { duration: Style.animationDuration } }
    }

    RadialGradient {
        id: gradient
        anchors.fill: background
        visible: false
        gradient: Gradient{
            GradientStop { position: .45; color: "transparent" }
            GradientStop { position: .5; color: root.onColor }
        }
    }

    OpacityMask {
        id: opacityMask
        opacity: root.on ? 1 : 0
        anchors.fill: gradient
        source: gradient
        maskSource: mask
        Behavior on opacity { NumberAnimation { duration: Style.animationDuration } }
    }

}
