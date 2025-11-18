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
import Nymea 1.0
import "../delegates"

NymeaDialog {
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
