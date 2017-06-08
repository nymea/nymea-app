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

    property var device: null
    property var deviceClass: Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId)

    Rectangle {
        id: header
        color: "lightgray"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 40

        Button {
            id: backButton
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: parent.height
            height: parent.height
            text: "🡰"
            onClicked: mainStack.pop()
        }

        Label {
            anchors.centerIn: parent
            text: device.name
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.topMargin: header.height
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        contentHeight: stateColumn.height
        contentWidth: parent.width

        clip: true

        Column {
            id: stateColumn
            anchors.fill: parent
            spacing: 5

            Repeater {
                anchors.fill: parent
                model: deviceClass.stateTypes
                delegate: Item {
                    width: parent.width / 2
                    height: 20

                    Rectangle { anchors.fill: parent; color: "green"; opacity: 0.5 }

                    Label {
                        id: stateLable
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        text: name
                    }

                    Label {
                        id: valueLable
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 5
                        text: device.states.getState(id).value + " " + deviceClass.stateTypes.getStateType(id).unitString
                    }
                }
            }
        }

    }
}
