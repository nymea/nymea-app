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
import QtGraphicalEffects 1.0

Item {
    id: root

    property alias iconName: colorIcon.name
    property alias fallbackIconName: fallbackIcon.name
    property alias iconColor: colorIcon.color
    property alias backgroundImage: backgroundImg.source
    property string text
    property bool disconnected: false
    property bool isWireless: false
    property int signalStrength: 0
    property int setupStatus: Thing.ThingSetupStatusNone
    property bool batteryCritical: false
    property bool updateStatus: false

    property alias contentItem: innerContent.children

    signal clicked();
    signal pressAndHold();

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.margins: app.margins / 2
        gradient: Gradient {
            GradientStop {
                position: 1 - innerContent.height / background.height
                color: Style.tileOverlayColor
            }
            GradientStop {
                position: 1 - innerContent.height / background.height
                color: Style.tileBackgroundColor
            }
        }

        radius: Style.cornerRadius
    }

    Image {
        id: backgroundImg
        anchors.fill: parent
        anchors.margins: app.margins / 2
        visible: false
        z: -1
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        id: backgroundImgClipper
        radius: background.radius
        anchors.fill: parent
        visible: false
        gradient: Gradient {
            GradientStop {
                position: 1 - innerContent.height / background.height
                color: "transparent"
            }
            GradientStop {
                position: 1 - innerContent.height / background.height
                color: "white"
            }
        }
    }

    OpacityMask {
        anchors.fill: parent
        anchors.margins: app.margins / 2
        source: backgroundImg
        maskSource: backgroundImgClipper
//        visible: root.backgroundImage.length > 0
    }

    ItemDelegate {
        anchors {
            top: parent.top; left: parent.left; right: parent.right; bottom: innerContent.top
            topMargin: app.margins / 2; leftMargin: app.margins / 2; rightMargin: app.margins / 2
        }
        padding: 0; topPadding: 0; bottomPadding: 0
        onClicked: root.clicked()
        onPressAndHold: root.pressAndHold()

        contentItem: ColumnLayout {
            spacing: 0
            ColumnLayout {
                Layout.fillHeight: true
                Layout.topMargin: app.margins
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.bottomMargin: app.margins / 2
                Item {
                    visible: backgroundImg.status !== Image.Ready
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColorIcon {
                        id: colorIcon
                        anchors.centerIn: parent
                        height: Style.largeIconSize
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
                    visible: backgroundImg.status !== Image.Ready

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
                        color: Style.tileForegroundColor
                    }
                }
            }
        }
    }

    Item {
        id: innerContent
        anchors { left: parent.left; bottom: parent.bottom; right: parent.right; margins: app.margins / 2 }
        height: Style.iconSize + app.margins * 2
        Material.foreground: Style.tileOverlayForegroundColor

        MouseArea {
            anchors.fill: parent
        }
    }

    RowLayout {
        id: quickAlertPane
        anchors { top: parent.top; right: parent.right; margins: app.margins }
        ColorIcon {
            height: Style.smallIconSize
            width: height
            name: "../images/system-update.svg"
            color: Style.accentColor
            visible: root.updateStatus
        }

        ColorIcon {
            height: Style.smallIconSize
            width: height
            name: root.isWireless ? "../images/connections/nm-signal-00.svg" : "../images/connections/network-wired-offline.svg"
            color: root.disconnected ? "red" : "orange"
            visible: root.setupStatus == Thing.ThingSetupStatusComplete && (root.disconnected || (root.isWireless && root.signalStrength < 20 && root.signalStrength >= 0))
        }
        ColorIcon {
            height: Style.smallIconSize
            width: height
            name: root.setupStatus === Thing.ThingSetupStatusFailed ? "../images/dialog-warning-symbolic.svg" : "../images/settings.svg"
            color: root.setupStatus === Thing.ThingSetupStatusFailed ? "red" : Style.tileForegroundColor
            visible: root.setupStatus === Thing.ThingSetupStatusFailed || root.setupStatus === Thing.ThingSetupStatusInProgress
        }
        ColorIcon {
            height: Style.smallIconSize
            width: height
            name: "../images/battery/battery-010.svg"
            visible: root.setupStatus == Thing.ThingSetupStatusComplete && root.batteryCritical
            color: Style.tileForegroundColor
        }
    }
}

