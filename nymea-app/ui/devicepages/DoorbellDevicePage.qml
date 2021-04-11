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
                name: "../images/notification.svg"

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
                        name: "../images/alarm-clock.svg"
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
