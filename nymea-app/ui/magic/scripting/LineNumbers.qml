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

import QtQuick 2.4
import QtQuick.Controls 2.2
import Nymea 1.0

Rectangle {
    id: root

    property TextArea textArea: null

    FontMetrics {
        id: fontMetrics
        font: textArea.font
    }
    TextMetrics {
        id: textMetrics
        font: textArea.font
        text: {
            var digits = 1;
            var tmp = textArea.lineCount;
            while (tmp >= 10) {
                digits++;
                tmp /= 10;
            }
            var str = ""
            for (var i = 0; i < digits; i++) {
                str += "0"
            }
            return str;
        }
    }

    width: textMetrics.advanceWidth + app.margins / 2
    height: root.textArea.height - 10
    color: (Style.backgroundColor.r * 0.2126 + Style.backgroundColor.g * 0.7152 + Style.backgroundColor.b * 0.0722) * 255 < 128 ? "#202020" : "#e0e0e0"

    Column {
        id: lineNumbersColumn
        anchors.fill: parent
        anchors.topMargin: 8
        Repeater {
            model: root.textArea.lineCount
            delegate: Rectangle {
                id: lineNumberDelegate
                width: parent.width
                height: root.textArea.contentHeight / root.textArea.lineCount
                color: hasError ? "#FF0000" : "transparent"
                readonly property bool hasError: errorModel.errorLines.indexOf(index + 1) >= 0
                Label {
                    id: lineNumber
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 3
                    text: index + 1
                    font.pixelSize: root.textArea.font.pixelSize
                    font.family: root.textArea.font.family
                    font.weight: Font.Light
                    color: lineNumberDelegate.hasError ? "#FFFFFF" : "#808080"
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    ToolTip.visible: lineNumberDelegate.hasError && containsMouse
                    ToolTip.text: hasError ? errorModel.getError(index + 1).message : ""
                    property string bla: hasError ? ".." : ""
                    onBlaChanged: print("**", errorModel.getError(index + 1).message)
                }
            }
        }
    }
}
