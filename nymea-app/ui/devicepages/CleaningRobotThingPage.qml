/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2021, nymea GmbH
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
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"
import "../customviews"

ThingPageBase {
    id: root
    showBrowserButton: false


    readonly property State robotState: thing.stateByName("robotState")
    readonly property State errorMessageState: thing.stateByName("errorMessage")

    GridLayout {
        anchors.fill: parent
        columns: app.landscape ? 2 : 1

        Item {
            Layout.preferredWidth: app.landscape ?
                                       Math.min(parent.width - controlsContainer.minimumWidth, parent.height)
                                     : Math.min(Math.min(500, parent.width), parent.height)
            Layout.preferredHeight: width
            Layout.alignment: Qt.AlignHCenter

            Rectangle {
                id: robotArea
                anchors.centerIn: parent
                height: Math.min(parent.width, parent.height) - Style.hugeMargins * 2
                width: height
                radius: height / 2
                color: Style.tileBackgroundColor

                property int robotX: width / 2
                property int robotY: height / 2

                property bool initialized: false
                Timer {
                    interval: 500
                    running: true
                    repeat: false
                    onTriggered: {
                        robotArea.initialized = true;
                        robot.evaluateState()
                    }
                }

                ColorIcon {
                    id: robot
                    size: Style.largeIconSize
                    name: "../images/cleaning-robot.svg"
                    x: robotArea.robotX - (width / 2)
                    y: robotArea.robotY - (height / 2)
                    color: root.robotState.value == "cleaning"
                           ? Style.accentColor
                           : root.robotState.value === "error"
                             ? Style.red
                             : Style.iconColor

                    property int pixelsPerSecond: 30


                    function evaluateState() {
                        if (!robotArea.initialized) {
                            return
                        }

                        switch (root.robotState.value) {
                        case "cleaning":
                            if (travelAnimation.paused) {
                                travelAnimation.resume();
                            } else {
                                robot.travel()
                            }
                            return
                        case "paused":
                            travelAnimation.pause()
                            return
                        case "traveling":
                            if (travelAnimation.paused) {
                                travelAnimation.resume();
                            } else {
                                robot.travel()
                            }
                            return
                        case "docked":
                            if (Math.abs(robotArea.robotX - robotArea.radius) > 2 || Math.abs(robotArea.robotY - robotArea.radius) > 2 || robot.rotation != 0) {
                                robot.travel(true)
                            }
                            return
                        case "stopped":
                            travelAnimation.stop()
                            return
                        case "error":
                            travelAnimation.pause()
                        }
                    }

                    Connections {
                        target: root.robotState
                        onValueChanged: robot.evaluateState()
                    }

                    function travel(toHome) {
                        print("robot traveling")
                        var areaWidth = robotArea.width;
                        var radius = areaWidth / 2

                        if (radius < 0) {
                            return
                        }

                        var centerX = radius
                        var fromX = robotArea.robotX ? robotArea.robotX : radius
                        var toX;

                        var centerY = radius
                        var fromY = robotArea.robotY ? robotArea.robotY : radius
                        var toY;

                        if (toHome) {
                            toX = radius
                            toY = radius
                        } else {
                            var distanceToCenter
                            do {
                                toX = Math.floor(Math.random() * areaWidth)
                                toY = Math.floor(Math.random() * areaWidth)
                                var toXCentered = toX - centerX
                                var toYCentered = toY - centerY
                                distanceToCenter = Math.abs(Math.sqrt(Math.pow(toXCentered, 2) + Math.pow(toYCentered, 2)))
//                                print("new pos:", toX, toY, "to center:", toXCentered, toYCentered, "radius:", radius, "distance to center", distanceToCenter)
                            } while (distanceToCenter > (radius - robot.width / 2))
                        }

                        travelXAnimation.from = fromX
                        travelXAnimation.to = toX

                        travelYAnimation.from = fromY
                        travelYAnimation.to = toY

                        var distanceToTarget = Math.abs(Math.sqrt(Math.pow(toX - fromX, 2) + Math.pow(toY - fromY, 2)))
                        var travelDuration = 1000 * distanceToTarget / robot.pixelsPerSecond

                        travelXAnimation.duration = travelDuration
                        travelYAnimation.duration = travelDuration

                        rotationAnimation.from = robot.rotation
                        if (Math.abs(fromX - toX) <= 1 && Math.abs(fromY - toY) <= 1) {
                            rotationAnimation.to = 0;
                        } else {
                            rotationAnimation.to = robot.getAngleDegrees(fromX, fromY, toX, toY)
                        }
                        travelAnimation.start()
                    }

                    SequentialAnimation {
                        id: travelAnimation

                        onRunningChanged: {
                            if (!running) {
                                robot.evaluateState()
                            }
                        }

                        RotationAnimation {
                            id: rotationAnimation
                            target: robot
                            property: "rotation"
                            duration: 500
                            easing.type: Easing.InOutQuad
                            direction: RotationAnimation.Shortest
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                id: travelYAnimation
                                target: robotArea
                                property: "robotY"
                            }
                            NumberAnimation {
                                id: travelXAnimation
                                target: robotArea
                                property: "robotX"
                            }
                        }
                    }

                    function getAngleDegrees(fromX,fromY,toX,toY) {
                        var deltaX = fromX-toX;
                        var deltaY = fromY-toY; // reverse
                        var radians = Math.atan2(deltaY, deltaX)
                        var degrees = (radians * 180) / Math.PI - 90; // rotate
                        while (degrees >= 360) degrees -= 360;
                        while (degrees < 0) degrees += 360;
                        return degrees;
                    }
                }
            }
        }


        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                Layout.fillWidth: true
                Layout.margins: Style.margins
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                visible: root.errorMessageState != null && root.robotState.value === "error"
                text: root.errorMessageState ? root.errorMessageState.value : ""
            }

            RowLayout {
                id: controlsContainer
                Layout.margins: app.margins * 2
                property int minimumWidth: Style.iconSize * 2.7 * 3
                property int minimumHeight: Style.iconSize * 4.5

                Item {
                    Layout.fillWidth: true
                }

                ProgressButton {
                    longpressEnabled: false
                    mode: root.robotState.value === "cleaning" ? "normal" : "highlight"
                    size: Style.bigIconSize
                    imageSource: root.robotState.value === "cleaning" ? "../images/media-playback-pause.svg" : "../images/media-playback-start.svg"
                    onClicked: {
                        if (root.robotState.value === "cleaning" || root.robotState.value === "paused") {
                            engine.thingManager.executeAction(root.thing.id, root.thing.thingClass.actionTypes.findByName("pauseCleaning").id)
                        } else {
                            engine.thingManager.executeAction(root.thing.id, root.thing.thingClass.actionTypes.findByName("startCleaning").id)
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                }

                ProgressButton {
                    longpressEnabled: false
                    imageSource: "../images/media-playback-stop.svg"
                    size: Style.bigIconSize
                    mode: "destructive"
                    onClicked: {
                        engine.thingManager.executeAction(root.thing.id, root.thing.thingClass.actionTypes.findByName("returnToBase").id)
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
                ProgressButton {
                    longpressEnabled: false
                    imageSource: "../images/groups.svg"
                    mode: "normal"
                    size: Style.bigIconSize
                    visible: root.thing.thingClass.browsable
                    onClicked: {
                        pageStack.push(mapPageComponent)
                    }
                }
                Item {
                    Layout.fillWidth: true
                    visible: root.thing.thingClass.browsable
                }
            }
        }

    }

    Component {
        id: mapPageComponent
        Page {
            id: mapsPage
            property BrowserItems maps: engine.thingManager.browseThing(root.thing.id, "maps")

            header: NymeaHeader {
                text: root.thing.name
                onBackPressed: {
                    pageStack.pop()
                }
            }

            BusyIndicator {
                anchors.centerIn: parent
                visible: mapsPage.maps.busy
            }

            ColumnLayout {
                anchors.fill: parent
                visible: !mapsPage.maps.busy
                ComboBox {
                    id: mapComboBox
                    Layout.fillWidth: true
                    Layout.margins: Style.margins
                    model: mapsPage.maps.busy ? null :  mapsPage.maps
                    textRole: "displayName"
                }

                StackLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    currentIndex: mapComboBox.currentIndex

                    Repeater {
                        model: mapsPage.maps

                        delegate: Item {
                            id: mapView
                            anchors.fill: parent
                            property BrowserItem map: mapsPage.maps.get(index)
                            property BrowserItems boundaries: engine.thingManager.browseThing(root.thing.id, map.id)
                            Connections {
                                target: boundaries
                                onCountChanged: {
                                    canvas.requestPaint();
                                }
                            }

                            Image {
                                id: mapImage
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectFit
                                source: mapView.map.thumbnail
                            }

                            ShaderEffect {
                                id: colorizedImage
                                objectName: "shader"

                                anchors.centerIn: parent
                                height: mapImage.paintedHeight
                                width: mapImage.paintedWidth

                                // Whether or not a color has been set.
                                visible: mapImage.status == Image.Ready && outColor != inColor

                                property Image source: mapImage
                                property color outColor: Style.backgroundColor
                                // Colorize only pixels of this color, leave the rest untouched.
                                // This needs to match the basic color of the icon set
                                property color inColor: "#ebf3f3"
                                property real threshold: 0.1

                                fragmentShader: "
                                    varying highp vec2 qt_TexCoord0;
                                    uniform sampler2D source;
                                    uniform highp vec4 outColor;
                                    uniform highp vec4 inColor;
                                    uniform lowp float threshold;
                                    uniform lowp float qt_Opacity;
                                    void main() {
                                        lowp vec4 sourceColor = texture2D(source, qt_TexCoord0);
                                        gl_FragColor = mix(vec4(outColor.rgb, 1.0) * sourceColor.a, sourceColor, step(threshold, distance(sourceColor.rgb / sourceColor.a, inColor.rgb))) * qt_Opacity;
                                    }"
                            }

                            Canvas {
                                id: canvas
                                anchors.centerIn: parent
                                height: mapImage.paintedHeight
                                width: mapImage.paintedWidth

                                property int penWidth: 2

                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, canvas.width, canvas.height);
                                    ctx.fillStyle = Qt.rgba(1, 0, 0, 1);
                                    ctx.lineWidth = canvas.penWidth

                                    for (var i = 0; i < mapView.boundaries.count; i++) {
                                        var boundary = mapView.boundaries.get(i)
                                        var boundaryData = JSON.parse(boundary.description)
//                                        console.warn("Boundary:", boundary.id, boundary.description)

                                        var color = Qt.lighter(boundaryData["color"], 1)
                                        ctx.strokeStyle = color
                                        ctx.fillStyle = Qt.rgba(color.r, color.g, color.b, 0.3)
                                        var vertices = boundaryData["vertices"]

                                        ctx.beginPath();
                                        ctx.moveTo(vertices[0][0] * canvas.width, vertices[0][1] * canvas.height);
                                        for (var j = 1; j < vertices.length; j++) {
                                            ctx.lineTo(vertices[j][0] * canvas.width, vertices[j][1] * canvas.height)
                                        }
                                        ctx.closePath();
                                        ctx.stroke();
                                        ctx.fill();
                                    }
                                }
                                Repeater {
                                    model: mapView.boundaries
                                    delegate: ProgressButton {
                                        mode: "highlight"
                                        imageSource: "../images/media-playback-start.svg"
                                        size: Style.smallIconSize
                                        property BrowserItem boundary: mapView.boundaries.get(index)
                                        property var center: {
                                            var boundaryData = JSON.parse(boundary.description)
                                            if (!boundaryData) {
                                                return Qt.point(0, 0)
                                            }
                                            var x = 0
                                            var y = 0
                                            for (var i = 0; i < boundaryData["vertices"].length; i++) {
                                                var point = boundaryData["vertices"][i];
                                                x += boundaryData["vertices"][i][0] * canvas.width
                                                y += boundaryData["vertices"][i][1] * canvas.height
                                            }
                                            x /= boundaryData["vertices"].length
                                            y /= boundaryData["vertices"].length
                                            print("button center:", x, y)
                                            return Qt.point(x, y)
                                        }

                                        x: center.x - width / 2
                                        y: center.y - height / 2

                                        onClicked: {
                                            engine.thingManager.executeBrowserItem(root.thing.id, boundary.id)
                                        }
                                    }
                                }
                            }

                            BusyIndicator {
                                anchors.centerIn: parent
                                visible: mapView.boundaries.busy || mapImage.status == Image.Loading
                            }
                        }
                    }
                }
            }
        }
    }
}
