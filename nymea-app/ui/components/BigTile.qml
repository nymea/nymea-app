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
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import Nymea

Item {
    id: root

    implicitHeight: layout.implicitHeight + app.margins

    property alias header: headerContainer.children
    property alias contentItem: content.contentItem
    property int contentHeight: root.height - headerContainer.height - content.topPadding - content.bottomPadding

    property alias showHeader: headerContainer.visible

    property alias leftPadding: content.leftPadding
    property alias rightPadding: content.rightPadding
    property alias topPadding: content.topPadding
    property alias bottomPadding: content.bottomPadding

    property bool interactive: true

    signal clicked();
    signal pressAndHold();

    Material.foreground: Style.tileForegroundColor

    function wobble() {
        wobbleAnimation.start();
    }

    transform: Translate { id: wobbleTransform }

    SequentialAnimation {
        id: wobbleAnimation

        PropertyAnimation {
            target: wobbleTransform
            property: "x"
            from: 0
            to: 10
            duration: 50
            easing.type: Easing.OutCirc
        }
        PropertyAnimation {
            target: wobbleTransform
            property: "x"
            from: 10
            to: 0
            duration: 400
            easing.type: Easing.OutElastic
            easing.amplitude: 2
            easing.period: 0.4
        }
    }


    Rectangle {
        id: background
        anchors.fill: parent
        anchors.margins: app.margins / 2
        radius: Style.cornerRadius
        clip: true

        gradient: Gradient {
            GradientStop {
                position: (headerContainer.height + app.margins) / background.height
                color: Style.tileBackgroundColor
            }
            GradientStop {
                position: (headerContainer.height + app.margins) / background.height
                color: headerContainer.visible ?
                          Style.tileOverlayColor
                        : Style.tileBackgroundColor
            }
        }

        Ripple {
            anchors.fill: parent
            clip: true
            clipRadius: background.radius
            pressed: content.pressed
            anchor: content
            active: content.pressed || content.visualFocus || content.hovered
            color: content.Material.rippleColor
        }
    }


    ColumnLayout {
        id: layout
        spacing: 0
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: app.margins / 2 }

        Item {
            id: headerContainer
            Layout.fillWidth: true
            Layout.margins: app.margins / 2
            visible: children.length > 0
            height: childrenRect.height
        }


        ItemDelegate {
            id: content
            Layout.fillWidth: true
            height: contentItem.implicitHeight
            onClicked: root.clicked()
            hoverEnabled: root.interactive
            onPressAndHold: {
                if (root.interactive) {
                    root.pressAndHold()
                }
            }
            background: Item {
                implicitHeight: Style.delegateHeight
            }
        }
    }
}
