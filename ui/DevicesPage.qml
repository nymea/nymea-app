/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of guh-control                                       *
 *                                                                         *
 *  This library is free software; you can redistribute it and/or          *
 *  modify it under the terms of the GNU Lesser General Public             *
 *  License as published by the Free Software Foundation; either           *
 *  version 2.1 of the License, or (at your option) any later version.     *
 *                                                                         *
 *  This library is distributed in the hope that it will be useful,        *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU      *
 *  Lesser General Public License for more details.                        *
 *                                                                         *
 *  You should have received a copy of the GNU Lesser General Public       *
 *  License along with this library; If not, see                           *
 *  <http://www.gnu.org/licenses/>.                                        *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1

import Guh 1.0

Page {
    id: root

    GridView {
        id: gridView
        anchors.fill: parent

        anchors.margins: 10

        property real cellSize: width / 5


        cellWidth: cellSize
        cellHeight: cellSize

        model: Engine.deviceManager.devicesProxy

        clip: true

        delegate:  Item {
            height: gridView.cellSize
            width: gridView.cellSize

            Button {
                anchors.fill: parent
                anchors.margins: 5
                text: model.name

                onClicked: mainStack.push(Qt.resolvedUrl("DevicePage.qml"), { device: Engine.deviceManager.devices.getDevice(model.id)})
            }

//            Rectangle {
//                anchors.fill: parent
//                anchors.margins: 4
//                color: "lightgray"

//                radius: width / 8

//                border.width: 1
//                border.color: "darkgray"
//            }

        }
    }
}
