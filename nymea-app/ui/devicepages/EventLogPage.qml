/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2023, nymea GmbH
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
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

Page {
    id: root

    property Thing thing: null
    property EventType eventType: null

    readonly property bool isLogged: thing.loggedEventTypeIds.indexOf(eventType.id) >= 0

    header: NymeaHeader {
        text: qsTr("History for %1").arg(root.eventType.displayName)
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "delete"
            visible: root.isLogged
            onClicked: {
                var popup = deleteLogsComponent.createObject(root)
                popup.open()
            }

            Component {
                id: deleteLogsComponent
                NymeaDialog {
                    title: qsTr("Remove logs?")
                    text: qsTr("Do you want to remove the log for this event and disable logging?")
                    standardButtons: Dialog.No | Dialog.Yes
                    onAccepted: engine.thingManager.setEventLogging(root.thing.id, root.eventType.id, false)
                }
            }
        }
    }

    NewLogsModel {
        id: logsModel
        engine: _engine
        source: "event-" + root.thing.id + "-" + root.eventType.name
        sortOrder: Qt.DescendingOrder
    }


    ListView {
        id: listView
        visible: root.isLogged
        model: logsModel
        clip: true
        anchors.fill: parent
        ScrollBar.vertical: ScrollBar {}

        delegate: NymeaItemDelegate {
            id: delegate
            width: listView.width
            height: contentColumn.implicitHeight + Style.margins
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            property NewLogEntry entry: logsModel.get(index)

            contentItem: RowLayout {
                id: contentColumn
                anchors { left: parent.left; right: parent.right; margins: app.margins / 2 }
                ColorIcon {
                    Layout.preferredWidth: Style.iconSize
                    Layout.preferredHeight: width
                    Layout.alignment: Qt.AlignVCenter
                    name: "event"
                }
                ColumnLayout {
                    Label {
                        Layout.fillWidth: true
                        text: Qt.formatDateTime(model.timestamp,"dd.MM.yy - hh:mm:ss")
                        elide: Text.ElideRight
                    }

                    Label {
                        Layout.fillWidth: true
                        text: {
                            var ret = []
                            var values = JSON.parse(entry.values.params)
                            for (var i = 0; i < root.eventType.paramTypes.count; i++) {
                                var paramType = root.eventType.paramTypes.get(i)
                                ret.push(paramType.displayName + ": " + Types.toUiValue(values[paramType.name], paramType.unit) + " " + Types.toUiUnit(paramType.unit))
                            }
                            return ret.join("<br>")
                        }
                        textFormat: Text.RichText
                        elide: Text.ElideRight
                        font: Style.smallFont
                        visible: text.length > 0
                    }
                }
            }
        }
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        title: qsTr("No data")
        text: qsTr("This event has not been triggered yet.")
        imageSource: "../images/logs.svg"
        visible: root.isLogged && logsModel.count == 0
        buttonVisible: false
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        title: qsTr("Logging not enabled")
        text: qsTr("This event is not being logged.")
        imageSource: "../images/logs.svg"
        buttonText: qsTr("Enable logging")
        visible: !root.isLogged
        onButtonClicked: {
            engine.thingManager.setEventLogging(root.thing.id, root.eventType.id, true)
        }
    }
}

