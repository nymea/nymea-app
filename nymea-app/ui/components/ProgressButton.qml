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

import QtQuick 2.9
import QtQuick.Layouts 1.3

Item {
    id: root

    property string imageSource
    property string longpressImageSource: imageSource
    property bool repeat: false

    property bool longpressEnabled: true

    signal clicked();
    signal longpressed();

    MouseArea {
        id: buttonDelegate
        anchors.fill: parent

        property bool longpressed: false

        onPressed: {
            canvas.inverted = false
            buttonDelegate.longpressed = false
        }
        onReleased: {
            if (!containsMouse) {
                print("cancelled")
                buttonDelegate.longpressed = false;
                return;
            }

            if (buttonDelegate.longpressed) {
                if (!repeat) {
                    root.longpressed();
                }
            } else {
                root.clicked();
            }
            buttonDelegate.longpressed = false
        }

        NumberAnimation {
            target: canvas
            properties: "progress"
            from: 0.0
            to: 1.0
            running: root.longpressEnabled && buttonDelegate.pressed
            duration: 750
            onRunningChanged: {
                if (!running && canvas.progress == 1) {
                    buttonDelegate.longpressed = true;
                    if (root.repeat) {
                        root.longpressed();
                        start();
                        canvas.inverted = !canvas.inverted
                    }
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -app.margins / 2
            radius: width / 2
            color: app.foregroundColor
            opacity: buttonDelegate.pressed ? .08 : 0
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }

        Canvas {
            id: canvas
            anchors.fill: parent
            anchors.margins: -app.margins / 2

            property real progress: 0
            property bool inverted: false

            readonly property int penWidth: 2
            onProgressChanged: {
                requestPaint()
            }
            Connections {
                target: buttonDelegate
                onPressedChanged: {
                    if (!buttonDelegate.pressed) {
                        canvas.progress = 0;
                        canvas.requestPaint()
                    }
                }
            }

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                ctx.fillStyle = Qt.rgba(1, 0, 0, 1);
                ctx.lineWidth = canvas.penWidth
                ctx.strokeStyle = app.accentColor

                var start = -Math.PI / 2;
                var stop = -Math.PI / 2;
                if (inverted) {
                    start += canvas.progress * 2 * Math.PI
                } else {
                    stop += canvas.progress * 2 * Math.PI
                }

                ctx.beginPath();
                ctx.arc(canvas.width / 2, canvas.height / 2, ((canvas.width - canvas.penWidth) / 2), start, stop);
                ctx.stroke();
            }
        }

        ColorIcon {
            anchors.fill: parent
            name: buttonDelegate.longpressed ? root.longpressImageSource : root.imageSource
        }
    }
}

