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
    property Thing thing: null

    readonly property StateType artworkStateType: thing ? thing.thingClass.stateTypes.findByName("artwork") : null
    readonly property State artworkState: artworkStateType ? thing.states.getState(artworkStateType.id) : null

    readonly property StateType playerTypeStateType: thing ? thing.thingClass.stateTypes.findByName("playerType") : null
    readonly property State playerTypeState: playerTypeStateType ? thing.states.getState(playerTypeStateType.id) : null

    readonly property int paintedWidth: fallbackImage.visible ? fallbackImage.width : artworkImage.paintedWidth
    readonly property int paintedHeight: fallbackImage.visible ? fallbackImage.height : artworkImage.paintedHeight

    Rectangle {
        id: fallbackImage
        anchors { left: parent.left; top: parent.top }
        height: visible ? Math.min(parent.height, parent.width) : artworkImage.paintedHeight - 1
        width: visible ? Math.min(parent.height, parent.width) : artworkImage.paintedWidth - 1
        visible: artworkImage.status !== Image.Ready || artworkImage.source === ""
        color: "black"

        ColorIcon {
            anchors.centerIn: parent
            width: Math.min(parent.height, parent.width) - app.margins * 2
            height: Math.min(parent.height, parent.width) - app.margins * 2
            name: root.playerTypeState.value === "video" ? "qrc:/icons/stock_video.svg" : "qrc:/icons/stock_music.svg"
            color: "white"
        }
    }

    Image {
        id: artworkImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        source: root.artworkState.value
        visible: source !== ""
        horizontalAlignment: Image.AlignLeft
        verticalAlignment: Image.AlignTop
    }
}
