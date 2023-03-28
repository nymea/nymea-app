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
import QtQuick.Controls.Material 2.2
import Nymea 1.0

// There's a bug in QtQuick.Controls' SwipeDelegate in that it appears with wrong
// background when used in Popups/Dialogs So we need a non-swipable one for those cases

// FIXME: Eventually consoldate this again somehow

ItemDelegate {
    id: root
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

    QtObject {
        id: d
        property var deleteContextOption: [{
            text: qsTr("Delete"),
            icon: "../images/delete.svg",
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

    contentItem: RowLayout {
        id: innerLayout
        spacing: Style.margins
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
                font.pixelSize: root.prominentSubText ? Style.smallFont : app.extraSmallFont
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
                anchors.margins: -Style.margins
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
            name: "../images/next.svg"
            visible: root.progressive
        }

        Item {
            id: additionalItemContainer
            Layout.fillHeight: true
            Layout.preferredWidth: childrenRect.width
            visible: children.length > 0
        }
    }
}
