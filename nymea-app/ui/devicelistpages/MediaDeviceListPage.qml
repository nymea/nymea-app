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
import QtGraphicalEffects 1.0
import "../components"

DeviceListPageBase {
    id: root

    header: NymeaHeader {
        text: qsTr("Media")
        onBackPressed: pageStack.pop()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentGrid.implicitHeight

        GridLayout {
            id: contentGrid
            width: parent.width
            columns: Math.ceil(width / 500)
            rowSpacing: 0
            columnSpacing: 0

            Repeater {
                model: root.devicesProxy

                delegate: ItemDelegate {
                    id: itemDelegate
                    Layout.preferredWidth: contentGrid.width / contentGrid.columns

                    property bool inline: width > 500

                    property Thing thing: thingsProxy.getThing(model.id)

                    readonly property StateType playbackStateType: thing.thingClass.stateTypes.findByName("playbackStatus")
                    readonly property State playbackState: thing.stateByName("playbackStatus")

                    readonly property StateType playerTypeStateType: thing.thingClass.stateTypes.findByName("playerType")
                    readonly property State playerTypeState: thing.stateByName("playerType")

                    bottomPadding: index === root.devicesProxy.count - 1 ? topPadding : 0
                    contentItem: Pane {
                        id: contentItem
                        Material.elevation: 2
                        leftPadding: 0
                        rightPadding: 0
                        topPadding: 0
                        bottomPadding: 0

                        contentItem: ItemDelegate {
                            leftPadding: 0
                            rightPadding: 0
                            topPadding: 0
                            bottomPadding: 0
                            contentItem: ColumnLayout {
                                spacing: 0
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: app.mediumFont + app.margins
                                    color: Qt.rgba(app.foregroundColor.r, app.foregroundColor.g, app.foregroundColor.b, .05)
                                    RowLayout {
                                        anchors { verticalCenter: parent.verticalCenter; left: parent.left; right: parent.right; margins: app.margins }
                                        Label {
                                            Layout.fillWidth: true
                                            text: model.name
                                            elide: Text.ElideRight
                                        }
                                        BatteryStatusIcon {
                                            Layout.preferredHeight: app.iconSize * .5
                                            Layout.preferredWidth: height
                                            thing: itemDelegate.thing
                                            visible: itemDelegate.thing.setupStatus == Thing.ThingSetupStatusComplete && (hasBatteryLevel || isCritical)
                                        }
                                        ConnectionStatusIcon {
                                            Layout.preferredHeight: app.iconSize * .5
                                            Layout.preferredWidth: height
                                            thing: itemDelegate.thing
                                            visible: itemDelegate.thing.setupStatus == Thing.ThingSetupStatusComplete && (hasSignalStrength || !isConnected)
                                        }
                                        SetupStatusIcon {
                                            Layout.preferredHeight: app.iconSize * .5
                                            Layout.preferredWidth: height
                                            thing: itemDelegate.thing
                                            visible: setupFailed || setupInProgress
                                        }
                                    }

                                }
                                RowLayout {
                                    ColumnLayout {
                                        id: leftColummn
                                        Layout.margins: app.margins
                                        Label {
                                            Layout.fillWidth: true
                                            text: itemDelegate.playbackState.value === "Stopped" ?
                                                      qsTr("No playback")
                                                    : itemDelegate.thing.stateByName("title").value
                                            horizontalAlignment: Text.AlignHCenter
                                            //                                    font.pixelSize: app.largeFont
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
                                                name: itemDelegate.playerTypeState && itemDelegate.playerTypeState.value === "video" ? "../images/stock_video.svg" : "../images/stock_music.svg"
                                                visible: artworkImage.status !== Image.Ready || artworkImage.source === ""
                                                color: "white"
                                            }
                                        }

                                        Rectangle {
                                            id: maskRect
                                            anchors.centerIn: parent
                                            height: parent.width
                                            width: parent.height
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
                            onClicked: {
                                enterPage(index, false)
                            }
                        }
                    }
                }
            }
        }
    }
}
