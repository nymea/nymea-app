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
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0

Item {
    id: root

    property alias iconName: colorIcon.name
    property alias fallbackIconName: fallbackIcon.name
    property alias iconColor: colorIcon.color
    property alias backgroundImage: background.source
    property string text
    property bool disconnected: false
    property bool isWireless: false
    property int signalStrength: 0
    property int setupStatus: Thing.ThingSetupStatusNone
    property bool batteryCritical: false

    property alias contentItem: innerContent.children

    signal clicked();
    signal pressAndHold();

    Pane {
        anchors.fill: parent
        anchors.margins: app.margins / 2
        Material.elevation: 1
        padding: 0

        Image {
            id: background
            anchors.fill: parent
            anchors.margins: 1
            z: -1
            fillMode: Image.PreserveAspectCrop
//            horizontalAlignment: Image.AlignTop
//            opacity: .5
//            Rectangle {
//                anchors.fill: parent
//                color: Material.background
//                opacity: .5
//            }
        }

        contentItem: ItemDelegate {
            padding: 0; topPadding: 0; bottomPadding: 0
            onClicked: root.clicked()
            onPressAndHold: root.pressAndHold()

            contentItem: ColumnLayout {
                spacing: 0
                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.margins: app.margins
                    Item {
                        visible: background.status !== Image.Ready
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColorIcon {
                            id: colorIcon
                            anchors.centerIn: parent
                            height: app.iconSize * 1.3
                            width: height
                            ColorIcon {
                                id: fallbackIcon
                                anchors.fill: parent
                                color: root.iconColor
                                visible: parent.status === Image.Error
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: background.status !== Image.Ready

                        Label {
                            id: label
                            anchors.centerIn: parent
                            width: parent.width
                            text: root.text.toUpperCase()
                            font.pixelSize: app.smallFont
                            font.letterSpacing: 1
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                    }

                }
                MouseArea {
                    id: innerContent
                    Layout.fillWidth: true
                    Layout.preferredHeight: app.iconSize + app.margins * 2
                    visible: root.contentItem.length > 1

                    Rectangle {
                        anchors.fill: parent
                        color: Material.background
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: Material.foreground
                        opacity: 0.05
                    }
                }
            }
        }
    }

    Row {
        id: quickAlertPane
        anchors { top: parent.top; right: parent.right; margins: app.margins }
        spacing: app.margins / 2
        ColorIcon {
            height: app.iconSize / 2
            width: height
            name: root.isWireless ? "../images/network-wifi-offline.svg" : "../images/network-wired-offline.svg"
            color: root.disconnected ? "red" : "orange"
            visible: root.setupStatus == Thing.ThingSetupStatusComplete && (root.disconnected || (root.isWireless && root.signalStrength < 20))
        }
        ColorIcon {
            height: app.iconSize / 2
            width: height
            name: root.setupStatus === Thing.ThingSetupStatusFailed ? "../images/dialog-warning-symbolic.svg" : "../images/settings.svg"
            color: root.setupStatus === Thing.ThingSetupStatusFailed ? "red" : keyColor
            visible: root.setupStatus === Thing.ThingSetupStatusFailed || root.setupStatus === Thing.ThingSetupStatusInProgress
        }
        ColorIcon {
            height: app.iconSize / 2
            width: height
            name: "../images/battery/battery-010.svg"
            visible: root.setupStatus == Thing.ThingSetupStatusComplete && root.batteryCritical
        }
    }
}

