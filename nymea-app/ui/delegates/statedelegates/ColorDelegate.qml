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
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Nymea

import "../../components"

Item {
    id: colorComponentItem
    implicitWidth: Style.iconSize * 2
    implicitHeight: Style.iconSize
    property bool writable: false
    property var value
    signal changed(var value)

    Pane {
        anchors.fill: parent
        topPadding: 0
        bottomPadding: 0
        leftPadding: 0
        rightPadding: 0
        Material.elevation: 1
        contentItem: Rectangle {
            color: colorComponentItem.value

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (!colorComponentItem.writable) {
                        return;
                    }

                    var pos = colorComponentItem.mapToItem(root, 0, colorComponentItem.height)
                    print("opening", colorComponentItem.value)
                    var colorPicker = colorPickerComponent.createObject(root, {preferredY: pos.y, colorValue: colorComponentItem.value })
                    colorPicker.open()
                }
            }
        }
    }

    Component {
        id: colorPickerComponent
        Dialog {
            id: colorPickerDialog
            modal: true
            x: (parent.width - width) / 2
            y: Math.min(preferredY, parent.height - height)
            width: parent.width - app.margins * 2
            height: 200
            padding: app.margins
            property var colorValue
            property int preferredY: 0
            contentItem: ColorPickerPre510 {
                color: colorPickerDialog.colorValue
                property var lastSentTime: new Date()
                onColorChanged: {
                    var currentTime = new Date();
                    if (pressed && currentTime - lastSentTime > 200) {
                        colorComponentItem.changed(color);
                    }
                }
            }
        }
    }
}
