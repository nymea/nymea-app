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

Item {
    id: root
    property Device device: null

    readonly property StateType artworkStateType: device ? device.deviceClass.stateTypes.findByName("artwork") : null
    readonly property State artworkState: artworkStateType ? device.states.getState(artworkStateType.id) : null

    readonly property StateType playerTypeStateType: device ? device.deviceClass.stateTypes.findByName("playerType") : null
    readonly property State playerTypeState: playerTypeStateType ? device.states.getState(playerTypeStateType.id) : null

    Pane {
        Material.elevation: 2
        anchors.centerIn: parent
        height: fallback.visible ? Math.min(parent.height, parent.width) : artworkImage.paintedHeight - 1
        width: fallback.visible ? Math.min(parent.height, parent.width) : artworkImage.paintedWidth - 1
        padding: 0
        contentItem: Rectangle {
            color: "black"
        }
    }

    Image {
        id: artworkImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        source: root.artworkState.value
        visible: source !== ""
    }

    ColorIcon {
        id: fallback
        anchors.centerIn: parent
        width: Math.min(parent.height, parent.width) - app.margins * 2
        height: Math.min(parent.height, parent.width) - app.margins * 2

        name: root.playerTypeState.value === "video" ? "../images/stock_video.svg" : "../images/stock_music.svg"
        visible: artworkImage.status !== Image.Ready || artworkImage.source === ""
//        color: app.primaryColor
        color: "white"
    }
}
