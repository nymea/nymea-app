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
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

ThingPageBase {
    id: root

    readonly property EventType doorbellPressedType: thing.thingClass.eventTypes.findByName("doorbellPressed")

    GridLayout {
        anchors.fill: parent
        anchors.topMargin: app.margins
        columns: app.landscape ? 2 : 1
        columnSpacing: app.margins
        rowSpacing: app.margins

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColorIcon {
                id: doorbellIcon
                anchors.centerIn: parent
                height: Math.min(parent.width, parent.height)
                width: height
                name: "qrc:/icons/notification.svg"

                SequentialAnimation {
                    id: ringAnimation
                    ColorAnimation { target: doorbellIcon; property: "color"; from: Style.iconColor; to: Style.accentColor; duration: 200 }
                    ColorAnimation { target: doorbellIcon; property: "color"; from: Style.accentColor; to: Style.iconColor; duration: 300 }
                    ColorAnimation { target: doorbellIcon; property: "color"; from: Style.iconColor; to: Style.accentColor; duration: 200 }
                    ColorAnimation { target: doorbellIcon; property: "color"; from: Style.accentColor; to: Style.iconColor; duration: 300 }
                    ColorAnimation { target: doorbellIcon; property: "color"; from: Style.iconColor; to: Style.accentColor; duration: 200 }
                    ColorAnimation { target: doorbellIcon; property: "color"; from: Style.accentColor; to: Style.iconColor; duration: 300 }
                    ColorAnimation { target: doorbellIcon; property: "color"; from: Style.iconColor; to: Style.accentColor; duration: 200 }
                    ColorAnimation { target: doorbellIcon; property: "color"; from: Style.accentColor; to: Style.iconColor; duration: 300 }
                }

                Connections {
                    target: root.thing
                    onEventTriggered: {
                        print("evenEmitted", params)
                        if (eventTypeId == root.doorbellPressedType.id) {
                            ringAnimation.start();
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ColumnLayout {
                anchors.fill: parent
                spacing: app.margins

                ThinDivider {
                    visible: !app.landscape
                }

                RowLayout {
                    spacing: app.margins

                    Label {
                        Layout.fillWidth: true
                    }

                    ColorIcon {
                        Layout.preferredHeight: Style.iconSize
                        Layout.preferredWidth: Style.iconSize
                        name: "qrc:/icons/alarm-clock.svg"
                        color: Style.accentColor
                    }

                    Label {
                        text: qsTr("History")
                    }
                    Label {
                        Layout.fillWidth: true
                    }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    model: LogsModelNg {
                        engine: _engine
                        live: true
                        thingId: root.thing.id
                        typeIds: [root.doorbellPressedType.id]
                    }
                    delegate: NymeaSwipeDelegate {
                        width: parent.width
                        text: Qt.formatDateTime(model.timestamp)
                        progressive: false
                        textAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
}
