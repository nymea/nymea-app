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
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import QtGraphicalEffects 1.0
import "../components"

ThingsListPageBase {
    id: root

    header: NymeaHeader {
        text: qsTr("Media")
        onBackPressed: pageStack.pop()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentGrid.implicitHeight
        topMargin: app.margins / 2
        clip: true

        GridLayout {
            id: contentGrid
            width: parent.width - app.margins
            anchors.horizontalCenter: parent.horizontalCenter
            columns: Math.ceil(width / 600)
            rowSpacing: 0
            columnSpacing: 0
            Repeater {
                model: root.thingsProxy

                delegate: BigThingTile {
                    id: itemDelegate
                    Layout.preferredWidth: contentGrid.width / contentGrid.columns
                    thing: thingsProxy.getThing(model.id)

                    topPadding: 0
                    bottomPadding: 0
                    leftPadding: 0
                    rightPadding: 0

                    readonly property StateType playbackStateType: thing.thingClass.stateTypes.findByName("playbackStatus")
                    readonly property State playbackState: thing.stateByName("playbackStatus")

                    readonly property StateType playerTypeStateType: thing.thingClass.stateTypes.findByName("playerType")
                    readonly property State playerTypeState: thing.stateByName("playerType")

                    onClicked: {
                        if (isEnabled) {
                            enterPage(index)
                        } else {
                            itemDelegate.wobble();
                        }
                    }

                    contentItem: RowLayout {
                        enabled: itemDelegate.isEnabled
                        ColumnLayout {
                            id: leftColummn
                            Layout.margins: app.margins
                            Label {
                                Layout.fillWidth: true
                                text: itemDelegate.playbackState.value === "Stopped" ?
                                          qsTr("No playback")
                                        : itemDelegate.thing.stateByName("title").value
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                            Label {
                                Layout.fillWidth: true
                                text: itemDelegate.thing.stateByName("artist").value
                                font.pixelSize: app.smallFont
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                            Label {
                                Layout.fillWidth: true
                                text: itemDelegate.thing.stateByName("collection").value
                                horizontalAlignment: Text.AlignHCenter
                                font.pixelSize: app.smallFont
                                elide: Text.ElideRight
                            }
                            MediaControls {
                                visible: itemDelegate.thing.thingClass.interfaces.indexOf("mediacontroller") >= 0
                                thing: itemDelegate.thing
                            }
                        }
                        Item {
                            Layout.preferredHeight: leftColummn.height + app.margins * 2
                            Layout.preferredWidth: height * .7

                            Item {
                                id: artworkContainer
                                anchors.fill: parent
                                Image {
                                    id: artworkImage
                                    width: artworkImage.sourceSize.width * height / artworkImage.sourceSize.height
                                    anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
                                    readonly property State artworkState: thing.stateByName("artwork")
                                    source: artworkState ? artworkState.value : ""
                                }
                                Rectangle {
                                    visible: artworkImage.status !== Image.Ready || artworkImage.source === ""
                                    anchors.fill: parent
                                    color: "black"
                                }

                                ColorIcon {
                                    width: Math.min(parent.width, parent.height) - app.margins * 2
                                    height: width
                                    anchors.centerIn: parent
                                    name: itemDelegate.playerTypeState && itemDelegate.playerTypeState.value === "video" ? "qrc:/icons/stock_video.svg" : "qrc:/icons/stock_music.svg"
                                    visible: artworkImage.status !== Image.Ready || artworkImage.source === ""
                                    color: "white"
                                }
                            }

                            Rectangle {
                                id: maskRect
                                anchors.centerIn: parent
                                height: parent.width
                                width: parent.height
                                radius: Style.cornerRadius
                                gradient: Gradient {
                                    GradientStop { position: 0; color: "#00FF0000" }
                                    GradientStop { position: 0.2; color: "#15FF0000" }
                                    GradientStop { position: 1; color: "#FFFF0000" }
                                }
                            }

                            ShaderEffect {
                                anchors.fill: parent
                                property variant source: ShaderEffectSource {
                                    sourceItem: artworkContainer
                                    hideSource: true
                                }
                                property variant mask: ShaderEffectSource {
                                    sourceItem: maskRect
                                    hideSource: true
                                }

                                fragmentShader: "
                                                                    varying highp vec2 qt_TexCoord0;
                                                                    uniform sampler2D source;
                                                                    uniform sampler2D mask;
                                                                    void main(void)
                                                                    {
                                                                        highp vec4 sourceColor = texture2D(source, qt_TexCoord0);
                                                                        highp float alpha = texture2D(mask, vec2(qt_TexCoord0.y, qt_TexCoord0.x)).a;
                                                                        sourceColor *= alpha;
                                                                        gl_FragColor = sourceColor;
                                                                    }
                                                                    "
                            }
                        }
                    }
                }
            }
        }
    }
}
