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

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtCharts 2.2
import Nymea 1.0
import "../components"
import "../delegates"

MainViewBase {
    id: root

    ThingsProxy {
        id: mediaDevices
        engine: _engine
        shownInterfaces: ["mediaplayer"]
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: pageIndicator.currentIndex

        Repeater {
            model: mediaDevices
            delegate: Item {
                id: playerDelegate
                height: swipeView.height
                width: swipeView.width
                property Thing thing: mediaDevices.get(index)
                property State titleState: thing.stateByName("title")
                property State artistState: thing.stateByName("artist")
                property State collectionState: thing.stateByName("collection")

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: app.margins
                    columns: 1
                    rowSpacing: app.margins

                    MediaArtworkImage {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        thing: playerDelegate.thing
                    }
                    ColumnLayout {
                        spacing: app.margins
                        Label {
                            text: playerDelegate.titleState.value
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: app.largeFont
                        }
                        Label {
                            text: playerDelegate.artistState.value
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Label {
                            text: playerDelegate.collectionState.value
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    MediaControls {
                        Layout.fillWidth: true
                        thing: playerDelegate.thing
                    }

                    RowLayout {

                        Item {
                            Layout.preferredHeight: app.iconSize
                            Layout.fillWidth: true
                            visible: playerDelegate.thing.thingClass.browsable

                            HeaderButton {
                                anchors.centerIn: parent
                                imageSource: "../images/navigationpad.svg"
                                onClicked: {
                                    pageStack.push(navigationPadPage)
                                }
                            }
                            Component {
                                id: navigationPadPage
                                Page {
                                    header: NymeaHeader { text: playerDelegate.thing.name; onBackPressed: pageStack.pop() }
                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: app.margins
                                        spacing: app.margins

                                        NavigationPad { Layout.fillWidth: true; Layout.fillHeight: true; device: playerDelegate.thing }
                                        MediaControls { Layout.fillWidth: true; thing: playerDelegate.thing }
                                        ShuffleRepeatVolumeControl { Layout.fillWidth: true; Layout.fillHeight: false; Layout.preferredHeight: app.iconSize; thing: playerDelegate.thing }
                                    }
                                }
                            }
                        }

                        ShuffleRepeatVolumeControl {
                            Layout.fillWidth: true
                            Layout.fillHeight: false
                            Layout.preferredHeight: app.iconSize
                            thing: playerDelegate.thing
                        }

                        Item {
                            Layout.preferredHeight: app.iconSize
                            Layout.fillWidth: true
                            visible: playerDelegate.thing.thingClass.interfaces.indexOf("navigationpad") >= 0

                            HeaderButton {
                                anchors.centerIn: parent
                                imageSource: "../images/folder-symbolic.svg"
                                onClicked: {
                                    pageStack.push(browserPage)
                                }
                            }
                            Component {
                                id: browserPage
                                Page {
                                    header: NymeaHeader { text: playerDelegate.thing.name; onBackPressed: pageStack.pop() }
                                    MediaBrowser { anchors.fill: parent; thing: playerDelegate.thing }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    PageIndicator {
        id: pageIndicator
        count: swipeView.count
        currentIndex: swipeView.currentIndex
        interactive: true
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        visible: !engine.thingManager.fetchingData && mediaDevices.count == 0
        title: qsTr("There are no media players set up.")
        text: qsTr("Connect your media players in order to control them from here.")
        imageSource: "../images/media.svg"
        buttonText: qsTr("Add things")
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../thingconfiguration/NewThingPage.qml"))
    }

}
