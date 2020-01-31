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

import QtQuick 2.6
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1
import "../components"
import "../delegates"
import Nymea 1.0

Item {
    id: root
    opacity: shown ? 1 : 0
    implicitWidth: searchColumn.implicitWidth
    implicitHeight: shown ? searchColumn.implicitHeight : 0
    Behavior on implicitHeight {NumberAnimation { duration: 130; easing.type: Easing.InOutQuad }}

    property bool shown: false
    property alias text: searchTextField.displayText

    ColumnLayout {
        id: searchColumn
        anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
        RowLayout {
            Layout.margins: app.margins
            spacing: app.margins
            TextField {
                id: searchTextField
                Layout.fillWidth: true
            }

            HeaderButton {
                imageSource: "../images/erase.svg"
                onClicked: searchTextField.text = ""
                enabled: searchTextField.displayText.length > 0
                color: enabled ? app.accentColor : keyColor
            }
        }
        ThinDivider {}
    }
}
