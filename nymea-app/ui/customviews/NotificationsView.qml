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
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import "../components"
import Nymea 1.0

CustomViewBase {
    id: root
    height: grid.implicitHeight + app.margins * 2

    ColumnLayout {
        id: grid
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: app.margins }
        Label {
            Layout.fillWidth: true
            text: qsTr("Send a notification now:")
        }
        TextArea {
            id: titleTextArea
            placeholderText: qsTr("Title")
            Layout.fillWidth: true
        }
        TextArea {
            id: bodyTextArea
            placeholderText: qsTr("Text")
            Layout.fillWidth: true
        }
        Button {
            Layout.fillWidth: true
            text: qsTr("Send")
            onClicked: {

                var params = []
                var param1 = {}
                print("bla:", root.deviceClass.actionTypes.findByName("notify").paramTypes)
                var paramTypeId = root.deviceClass.actionTypes.findByName("notify").paramTypes.findByName("title").id
                param1.paramTypeId = paramTypeId
                param1.value = titleTextArea.text
                params.push(param1)
                var param2 = {}
                paramTypeId = root.deviceClass.actionTypes.findByName("notify").paramTypes.findByName("body").id
                param2.paramTypeId = paramTypeId
                param2.value = bodyTextArea.text
                params.push(param2)
                engine.deviceManager.executeAction(root.device.id, root.deviceClass.actionTypes.findByName("notify").id, params)
            }
        }
    }
}
