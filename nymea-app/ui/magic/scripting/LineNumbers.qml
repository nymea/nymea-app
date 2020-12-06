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
