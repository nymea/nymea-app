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
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../delegates"

MeaDialog {
    id: root

    property Thing thing
    property string itemId
    property alias actionTypeIds: actionListView.model

    signal activated(var actionTypeId, var params)

    standardButtons: Dialog.NoButton

    StackView {
        id: stackView
        Layout.fillWidth: true
        Layout.preferredHeight: actionListView.implicitHeight

        property var actionTypeId

        initialItem: ListView {
            id: actionListView
            width: parent.width
            implicitHeight: contentHeight

            interactive: contentHeight > height
            clip: true
            delegate: NymeaSwipeDelegate {
                width: parent.width
                text: actionType.displayName
                progressive: false
                property ActionType actionType: root.thing.thingClass.browserItemActionTypes.getActionType(modelData)
                onClicked: {
                    var hasParams = actionType.paramTypes.count > 0
                    if (hasParams) {
                        stackView.actionTypeId = actionType.id
                        stackView.push(paramComponent, {model: actionType.paramTypes})
                        return;
                    }

                    var params = []
                    root.activated(actionType.id, params)

                    root.accept()
                    // In case the action removes the item from the browser, our closed handler might be deleted
                    // before being called and that would keep the popup open
                    // explicitly destroy the popup to make sure it'll always go away
                    root.destroy()
                }
            }
        }

        Component {
            id: paramComponent

            Repeater {
                id: paramListView

                delegate: ParamDelegate {
                    width: parent.width
                    paramType: paramListView.model.get(index)
                }
            }
        }
    }

    RowLayout {
        id: buttonRow
        Layout.fillWidth: true

        Button {
            id: cancelButton
            text: qsTr("Cancel")
            onClicked: root.reject()
        }
        Item { Layout.fillWidth: true }
        Button {
            text: qsTr("OK")
            visible: stackView.depth > 1
            onClicked: {
                var params = []
                for (var i = 0; i < stackView.currentItem.count; i++) {
                    var param =  {}
                    param["paramTypeId"] = stackView.currentItem.itemAt(i).paramType.id
                    param["value"] = stackView.currentItem.itemAt(i).value
                    params.push(param)
                }
                print("have params", params.length)
                root.activated(stackView.actionTypeId, params)
                root.accept();
            }
        }
    }
}
