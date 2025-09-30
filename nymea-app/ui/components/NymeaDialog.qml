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
import QtQuick.Layouts
import Nymea

Dialog {
    id: root
    width: Math.min(parent.width * .8, Math.max(contentLabel.implicitWidth, 400))
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    property alias headerIcon: headerColorIcon.name
    property alias text: contentLabel.text
    default property alias children: content.children

    standardButtons: Dialog.Ok

    onClosed: root.destroy()

    // Connections {
    //     target: root.parent
    //     onDestroye: root.destroy()
    // }

    MouseArea {
        parent: app.overlay
        anchors.fill: parent
        z: -1
        onPressed: {
            print("Dialog: eating mouse press", root.title)
            mouse.accepted = true
        }
    }

    header: Item {
        implicitHeight: headerRow.height + app.margins
        implicitWidth: parent.width
        visible: root.title.length > 0
        RowLayout {
            id: headerRow
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: app.margins }
            spacing: app.margins
            ColorIcon {
                id: headerColorIcon
                Layout.preferredHeight: Style.hugeIconSize
                Layout.preferredWidth: height
                color: Style.accentColor
                visible: name.length > 0
            }

            Label {
                id: titleLabel
                Layout.fillWidth: true
                Layout.margins: app.margins
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: root.title
                color: Style.accentColor
                font.pixelSize: app.largeFont
            }
        }
    }
    contentItem: ColumnLayout {
        id: content

        Label {
            id: contentLabel
            Layout.fillWidth: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            visible: text.length > 0
        }
    }
}
