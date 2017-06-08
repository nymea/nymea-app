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
import QtQuick.Dialogs 1.1

import Guh 1.0

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("guh control")

    Connections {
        target: Engine
        onConnectedChanged: {
            if (!connected) {
                mainStack.clear()
                mainStack.push(Qt.resolvedUrl("ConnectionPage.qml"))
            }
        }
    }

    StackView {
        id: mainStack
        initialItem: ConnectionPage { }
        anchors.fill: parent
    }

    footer: Item {
        id: footerItem
        height: 20

        Rectangle { anchors.fill: parent; color: "darkgray"}

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            spacing: 5

            Item {
                id: busyIndicator
                Layout.preferredHeight: parent.height
                Layout.preferredWidth: parent.height
                Layout.alignment: Qt.AlignVCenter

                RotationAnimation {
                    target: busyIndicatorImage
                    duration: 2000
                    from: 360
                    to: 0
                    running: true
                    loops: RotationAnimation.Infinite
                }

                Image {
                    id: busyIndicatorImage
                    anchors.fill: parent
                    anchors.margins: 2
                    source: "qrc:/data/icons/busy-indicator.svg"
                }
            }

            Label {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                text: "guh-control"
                color: "white"
            }


            Item {
                id: connectionStatusItem
                Layout.preferredHeight: parent.height
                Layout.preferredWidth: parent.height
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: parent.height / 10
                    radius: height / 2
                    color: Engine.connected ? "green" : "red"

                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                            easing.type: Easing.InCubic
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Engine.interface.disable()
                }
            }
        }
    }
}
