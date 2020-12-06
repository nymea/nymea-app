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

import QtQuick 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import "../../components"
import Nymea 1.0

Item {
    id: pane
    implicitHeight: shown ? 40 + 10 * app.smallFont : 25

    readonly property bool shown: (shownOverride === "auto" && autoWouldShow)
                                  || shownOverride == "shown"
    readonly property alias autoWouldShow: d.autoWouldShow
    property string shownOverride: "auto" // "shown", "hidden"

    default property alias panels: contentContainer.data

    QtObject {
        id: d
        property bool autoWouldShow: false
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        RowLayout {
            id: panelHeader
            Layout.fillWidth: true
            Layout.rightMargin: app.margins
            Layout.leftMargin: app.margins
            Layout.maximumHeight: 24
            Layout.minimumHeight: 24

            TabBar {
                id: panelTabs
                Layout.fillHeight: true

                Repeater {
                    model: contentContainer.data

                    TabButton {
                        implicitHeight: panelHeader.height
                        background: Rectangle {
                            implicitWidth: 200
                            implicitHeight: panelHeader.height
                            color: Style.backgroundColor
                            Label {
                                anchors.centerIn: parent
                                text: contentContainer.data[index].title
                                font.pixelSize: app.smallFont
                            }
                        }
                        Binding {
                            target: contentContainer.data[index]
                            property: "visible"
                            value: panelTabs.currentIndex === index
                        }
                        Connections {
                            target: contentContainer.data[index]
                            onRaise: {
                                panelTabs.currentIndex = index
                                d.autoWouldShow = true;
                            }
                        }
                    }
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            ColorIcon {
                name: "../images/edit-clear.svg"
                enabled: contentContainer.data[panelTabs.currentIndex].clearEnabled
                color: enabled ? Style.accentColor : Style.iconColor
                Layout.preferredHeight: app.iconSize  / 2
                Layout.preferredWidth: height
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -5
                    onClicked: contentContainer.data[panelTabs.currentIndex].clear()
                }
            }

            ColorIcon {
                name: pane.shown ? "../images/down.svg" : "../images/up.svg"
                Layout.preferredHeight: app.iconSize  / 2
                Layout.preferredWidth: height
                color: Style.accentColor
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -5
                    onClicked: {
                        if (pane.shown) {
                            if (pane.autoWouldShow) {
                                pane.shownOverride = "hidden"
                            } else {
                                pane.shownOverride = "auto"
                            }
                        } else {
                            if (pane.autoWouldShow) {
                                pane.shownOverride = "auto"
                            } else {
                                pane.shownOverride = "shown"
                            }
                        }
                    }
                }
            }
        }

        ThinDivider {}

        Item {
            id: contentContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

        }
    }
}
