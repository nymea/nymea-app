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

ColumnLayout {
    id: root
    spacing: app.margins

    property alias title: titleLabel.text
    property alias text: textLabel.text
    property alias imageSource: image.source
    property alias buttonText: button.text
    property alias buttonVisible: button.visible

    signal imageClicked();
    signal buttonClicked();

    Label {
        id: titleLabel
        font.pixelSize: app.largeFont
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        color: Style.accentColor
    }
    Label {
        id: textLabel
        Layout.fillWidth: true
        Layout.maximumWidth: 400
        Layout.alignment: Qt.AlignHCenter
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }
    Image {
        id: image
        Layout.preferredWidth: Style.iconSize * 5
        Layout.preferredHeight: width
        Layout.alignment: Qt.AlignHCenter
        sourceSize.width: Style.iconSize * 5
        sourceSize.height: Style.iconSize * 5
        MouseArea {
            anchors.fill: parent
            onClicked: root.imageClicked();
        }
    }
    Button {
        id: button
        Layout.fillWidth: true
        Layout.maximumWidth: 400
        Layout.alignment: Qt.AlignHCenter
        onClicked: root.buttonClicked();
    }
}
