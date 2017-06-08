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

Page {
    id: root

    TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        TabButton {
            text: qsTr("Devices")
        }

        TabButton {
            text: qsTr("Rules")
        }

        TabButton {
            text: qsTr("Settings")
        }
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        anchors.topMargin: tabBar.height
        currentIndex: tabBar.currentIndex

        DevicesPage { id: devicePage }

        Page {
            Label {
                text: qsTr("Rules")
                anchors.centerIn: parent
            }
        }

        Page {
            Label {
                text: qsTr("Settings")
                anchors.centerIn: parent
            }
        }
    }
}
