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
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.1
import QtMultimedia 5.15

ToolBar {
    id: root
    height: 50 + (menuOpen ? app.iconSize * 3 + app.margins / 2 : 0)
    Behavior on height { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }

    property string title
    property alias model: menuRepeater.model

    property alias leftButtonVisible: leftButton.visible
    property alias leftButtonImageSource: leftButton.imageSource

    signal clicked(int index);
    signal leftButtonClicked();

    property bool menuOpen: false

    RowLayout {
        id: mainRow
        height: 50
        width: parent.width
        opacity: menuOpen ? 0 : 1
        Behavior on opacity { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }        

        HeaderButton {
            id: leftButton
            visible: false
            onClicked: root.leftButtonClicked()

            Video {
                id: moonVideo
                anchors.fill: parent
                anchors.margins: 1
                autoLoad: true
                autoPlay: true
                source: "../images/moon.mp4"
                loops: MediaPlayer.Infinite
            }
        }

        Label {
            id: label
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: app.margins
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: app.mediumFont
            elide: Text.ElideRight
            text: root.title
            color: app.headerForegroundColor
        }

        HeaderButton {
            id: menuButton
            imageSource: "../images/navigation-menu.svg"
            onClicked: menuOpen = true
        }
    }

    RowLayout {
        height: 50
        anchors.bottom: menuPanel.top
        width: parent.width
        opacity: menuOpen ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }

        Label {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: app.margins
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: app.mediumFont
            elide: Text.ElideRight
            text: qsTr("Menu")
            color: app.headerForegroundColor
        }

        HeaderButton {
            imageSource:"../images/close.svg"
            onClicked: menuOpen = false
        }
    }

    Flickable {
        id: menuPanel
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: app.margins / 2
        width: Math.min(menuRow.childrenRect.width, parent.width)
        height: app.iconSize * 3
        contentWidth: menuRow.childrenRect.width
        opacity: menuOpen ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }

        Row {
            id: menuRow
            Repeater {
                id: menuRepeater

                MouseArea {
                    height: app.iconSize * 3
                    width: app.iconSize * 3

                    onClicked: {
                        menuOpen = false
                        root.clicked(index)
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: app.margins / 2
                        border.width: 1
                        border.color: app.accentColor
                        color: "transparent"
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: app.margins / 2
                            spacing: 0
                            ColorIcon {
                                name: model.iconSource
                                Layout.preferredHeight: app.iconSize
                                Layout.preferredWidth: app.iconSize
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: model.text
                                Layout.fillWidth: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: app.extraSmallFont
                                color: app.headerForegroundColor
                            }
                        }
                    }
                }
            }
        }
    }
}
