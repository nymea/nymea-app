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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Nymea 1.0

SwipeDelegate {
    id: root
    implicitWidth: 200
    implicitHeight: Style.smallDelegateHeight


    property string subText
    property bool progressive: true
    property bool canDelete: false

    property bool wrapTexts: true
    property bool prominentSubText: true
    property int textAlignment: Text.AlignLeft

    property string iconName
    property string thumbnail
    property int iconSize: Style.iconSize
    property color iconColor: Style.accentColor
    property alias secondaryIconName: secondaryIcon.name
    property alias secondaryIconColor: secondaryIcon.color
    property alias secondaryIconClickable: secondaryIconMouseArea.enabled
    property alias tertiaryIconName: tertiaryIcon.name
    property alias tertiaryIconColor: tertiaryIcon.color
    property alias tertiaryIconClickable: tertiaryIconMouseArea.enabled

    property var contextOptions: []

    property alias additionalItem: additionalItemContainer.children

    property alias busy: busyIndicator.running

    signal deleteClicked()
    signal secondaryIconClicked()

    onPressAndHold: swipe.open(SwipeDelegate.Right)

    QtObject {
        id: d
        property var deleteContextOption: [{
            text: qsTr("Delete"),
            icon: "qrc:/icons/delete.svg",
            backgroundColor: "red",
            foregroundColor: "white",
            visible: canDelete,
            callback: function deleteClicked() {
                root.deleteClicked();
                swipe.close();
            }
        }]

        property var finalContextOptions: root.contextOptions.concat(d.deleteContextOption)
    }

    background: Item {
        // SwipeDelegate has a background set to cover the swipe items. However, that messes with gradient backgrounds
        // So we're removing the background and need to clip the swipe items instead
    }

    contentItem: RowLayout {
        id: innerLayout
        spacing: app.margins
        Item {
            Layout.preferredHeight: root.iconSize
            Layout.preferredWidth: height
            visible: root.iconName.length > 0 || root.thumbnail.length > 0

            ColorIcon {
                id: icon
                anchors.fill: parent
                name: root.iconName
                color: root.iconColor
                visible: root.iconName && thumbnailImage.status !== Image.Ready
            }

            Image {
                id: thumbnailImage
                anchors.fill: parent
                source: root.thumbnail
                visible: root.thumbnail.length > 0
                fillMode: Image.PreserveAspectFit
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
            }

            BusyIndicator {
                id: busyIndicator
                anchors.centerIn: parent
                width: Style.bigIconSize
                height: width
                visible: running
                running: false
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.text
                wrapMode: root.wrapTexts ? Text.WordWrap : Text.NoWrap
                maximumLineCount: root.wrapTexts ? 2 : 1
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: root.textAlignment
            }
            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.subText
                font.pixelSize: root.prominentSubText ? app.smallFont : app.extraSmallFont
                color: root.prominentSubText ? Material.foreground : Material.color(Material.Grey)
                wrapMode: root.wrapTexts ? Text.WordWrap : Text.NoWrap
                maximumLineCount: root.wrapTexts ? 2 : 1
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                visible: root.subText.length > 0
            }
        }

        ColorIcon {
            id: secondaryIcon
            Layout.preferredHeight: Style.smallIconSize
            Layout.preferredWidth: height
            visible: name.length > 0
            MouseArea {
                id: secondaryIconMouseArea
                enabled: false
                anchors.fill: parent
                anchors.margins: -app.margins
                onClicked: root.secondaryIconClicked();
            }
        }

        ColorIcon {
            id: tertiaryIcon
            Layout.preferredHeight: Style.smallIconSize
            Layout.preferredWidth: height
            visible: name.length > 0
            MouseArea {
                id: tertiaryIconMouseArea
                enabled: false
                anchors.fill: parent
                anchors.margins: -app.margins
                onClicked: root.tertiaryIconClicked();
            }
        }

        ColorIcon {
            id: progressionIcon
            Layout.preferredHeight: Style.smallIconSize
            Layout.preferredWidth: height
            name: "qrc:/icons/next.svg"
            visible: root.progressive
        }

        Item {
            id: additionalItemContainer
            Layout.fillHeight: true
            Layout.preferredWidth: childrenRect.width
            visible: children.length > 0
        }
    }

    swipe.enabled: {
        for (var i = 0; i < d.finalContextOptions.length; i++) {
            if (!d.finalContextOptions[i].hasOwnProperty("visible") || d.finalContextOptions[i].visible) {
                return true
            }
        }
        return false
    }

    swipe.right: swipeComponent

    Component {
        id: swipeComponent
        Item {
            height: parent.height
            width: {
                var count = 0
                for (var i = 0; i < d.finalContextOptions.length; i++) {
                    if (!d.finalContextOptions[i].hasOwnProperty("visible") || d.finalContextOptions[i].visible) {
                        count++;
                    }
                }
                return height * count
            }

            anchors.right: parent.right
            Item {
                anchors {
                    top: parent.top
                    right: parent.right
                    bottom: parent.bottom
                }
                width: parent.width * -swipe.position
                clip: true

                Row {
                    anchors {
                        top: parent.top
                        right: parent.right
                        bottom: parent.bottom
                    }
                    Repeater {
                        model: d.finalContextOptions

                        delegate: MouseArea {
                            height: root.height
                            width: height
                            property var entry: d.finalContextOptions[index]
                            visible: entry.hasOwnProperty("visible") ? entry.visible : true
                            Rectangle {
                                anchors.fill: parent
                                color: entry.hasOwnProperty("backgroundColor") ? entry.backgroundColor : "transparent"
                            }

                            ColorIcon {
                                anchors.fill: parent
                                anchors.margins: app.margins
                                name: entry.icon
                                color: entry.hasOwnProperty("foregroundColor") ? entry.foregroundColor : Style.iconColor
                            }
                            onClicked: {
                                swipe.close();
                                entry.callback()
                            }
                        }
                    }
                }
            }

        }
    }

    Component {
        id: contextMenu
        Dialog {
            width: 300
            height: 200
            x: (parent.width - width) / 2
            ColumnLayout {
                width: parent.width
                Repeater {
                    model: root.contextOptions
                    delegate: ItemDelegate {
                        property var entry: root.contextOptions[index]
                        width: parent.width
                        text: entry.text
                    }
                }
            }
        }
    }
}
