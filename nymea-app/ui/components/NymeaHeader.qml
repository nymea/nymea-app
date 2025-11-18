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

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.1
import Nymea 1.0

Item {
    id: root
    implicitHeight: layout.implicitHeight + infoPane.height
    property string text
    property alias backButtonVisible: backButton.visible
    property alias menuButtonVisible: menuButton.visible
    default property alias children: layout.data
    property alias elide: label.elide

    signal backPressed();
    signal menuPressed();

    function showInfo(text, isError, isSticky) {
        if (isError === undefined) isError = false;
        if (isSticky === undefined) isSticky = false;

        infoPane.text = text;
        infoPane.isError = isError;
        infoPane.isSticky = isSticky;

        if (!isSticky) {
            infoPaneTimer.start();
        }
    }

    RowLayout {
        id: layout
        anchors { left: parent.left; top: parent.top; right: parent.right }

        HeaderButton {
            id: menuButton
            objectName: "headerMenuButton"
            imageSource: "qrc:/icons/navigation-menu.svg"
            visible: false
            onClicked: root.menuPressed();
        }

        HeaderButton {
            id: backButton
            objectName: "backButton"
            imageSource: "qrc:/icons/back.svg"
            onClicked: root.backPressed();
        }
        Label {
            id: label
            Layout.fillWidth: true
            Layout.maximumWidth: layout.width - Style.iconSize * 2
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: root.text
            font: Style.bigFont
        }
    }


    Pane {
        id: infoPane
        Material.elevation: 1

        property string text
        property bool isError: false
        property bool isSticky: false
        property bool shown: isSticky || infoPaneTimer.running

        visible: height > 0
        height: shown ? contentRow.implicitHeight : 0
        Behavior on height { NumberAnimation {} }
        anchors { left: parent.left; top: layout.bottom; right: parent.right }

        padding: 0
        contentItem: Rectangle {
            color: infoPane.isError ? "red" : Style.accentColor
            implicitHeight: contentRow.implicitHeight
            RowLayout {
                id: contentRow
                anchors { left: parent.left; top: parent.top; right: parent.right; leftMargin: Style.margins; rightMargin: Style.margins }
                Item {
                    Layout.fillWidth: true
                    height: Style.iconSize
                }

                Label {
                    text: infoPane.text
                    font: Style.smallFont
                    color: "white"
                }

                ColorIcon {
                    height: Style.iconSize / 2
                    width: height
                    visible: true
                    color: "white"
                    name: "qrc:/icons/dialog-warning-symbolic.svg"
                }
            }
        }
    }

    Timer {
        id: infoPaneTimer
        interval: 5000
        repeat: false
        running: false
    }
}
