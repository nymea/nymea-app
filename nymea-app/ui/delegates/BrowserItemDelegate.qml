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
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

NymeaListItemDelegate {
    id: root
    width: parent.width
    text: model.displayName
    progressive: model.browsable
    subText: model.description
    prominentSubText: false
    iconName: "../images/browser/" + (model.mediaIcon && model.mediaIcon !== "MediaBrowserIconNone" ? model.mediaIcon : model.icon) + ".svg"
    thumbnail: model.thumbnail
    enabled: !model.disabled
    secondaryIconName: model.actionTypeIds.length > 0 ? "../images/navigation-menu.svg" : ""
    secondaryIconClickable: true

    property Device device: null

    onPressAndHold: openContextMenu()
    onSecondaryIconClicked: openContextMenu()

    signal contextMenuActionTriggered(var actionTypeId, var params)

    function openContextMenu() {
        if (model.actionTypeIds.length === 0) {
            return;
        }

        var actionDialogComponent = Qt.createComponent(Qt.resolvedUrl("../components/BrowserContextMenu.qml"));
        var popup = actionDialogComponent.createObject(root.parent,
                                                       {
                                                           device: root.device,
                                                           title: model.displayName,
                                                           itemId: model.id,
                                                           actionTypeIds: model.actionTypeIds
                                                       });
        popup.activated.connect(function(actionTypeId, params) {
            root.contextMenuActionTriggered(actionTypeId, params)
        })
        popup.open()
    }
}
